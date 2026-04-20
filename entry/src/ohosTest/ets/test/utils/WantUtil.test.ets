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
import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium'
import LooseObject from '../../../../main/ets/data/LooseObject';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import { ResponseType } from '../../../../main/ets/service/ConversationListService';
import HiLog from '../../../../main/ets/utils/HiLog';
import wantUtil, { Result } from '../../../../main/ets/utils/WantUtil'
import { systemShare } from '@kit.ShareKit';
import { window } from '@kit.ArkUI';
import { DynamicLoader } from '../../../../main/ets/utils/DynamicLoader';
import FileUtil from '../../../../main/ets/utils/FileUtil';
import commonData from '../../../../main/ets/data/commonData';
import { Mms } from '../../../../main/ets/utils/TypesUtils';
import ContactsService from '../../../../main/ets/service/ContactsService';
import DotUtil from '../../../../main/ets/utils/MmsDot/DotUtils';
import TelephoneUtil from '../../../../main/ets/utils/TelephoneUtil';
import NotificationService from '../../../../main/ets/service/NotificationService';
import DeviceUtil from '../../../../main/ets/utils/DeviceUtil';
import ConversationService from '../../../../main/ets/service/ConversationService';
import StringUtil from '../../../../main/ets/utils/StringUtil';
import { DTGlobalContext } from '../../testability/TestAbility';
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';
import { dataShare } from '@kit.ArkData';


export default function wantUtilTest() {
  describe('WantUtilTest', () => {

    const TAG = 'WantUtil';
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    it('WantUtilTest_getWant', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      GlobalContext.getContext().setObject('abilityWant', null);
      let path = {} as NavPathStack;
      wantUtil.getWant(context, path);
      expect(JSON.stringify(path)).assertEqual('{}');
      mocker.clear(HiLog);
    })

    it('WantUtilTest_getWant_action_sendData_generalText', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('abilityWant')
        .afterReturn({
          action: 'ohos.want.action.sendData',
          parameters: {
            'ability.picker.records': {
              'general.text': [{
                utd: '',
              } as systemShare.SharedRecord]
            }
          } as LooseObject,
          uri: ''
        } as Object | window.WindowStage);
      when(mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire))(ArgumentMatchers.any)
        .afterReturn(new Promise<boolean>(resolve => resolve(false)))
      let path = {} as NavPathStack;

      wantUtil.getWant(context, path);

      expect(JSON.stringify(path)).assertEqual('{}');

      mocker.clear(GlobalContext.getContext());
      mocker.clear(DynamicLoader.getInstance());
    })

    it('WantUtilTest_getWant_action_sendData_plainText_stream_hasFileMms', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('abilityWant')
        .afterReturn({
          action: 'ohos.want.action.sendData',
          parameters: {
            'ability.picker.records': {
              'general.plain-text': [{
                utd: '',
                2: ''
              } as systemShare.SharedRecord],
              'ability.params.stream': ['file://com.ohos.mms', 'file://com.ohos.mms']
            }
          } as LooseObject,
          uri: ''
        } as Object | window.WindowStage);
      when(mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire))(ArgumentMatchers.any)
        .afterReturn(new Promise<boolean>(resolve => resolve(false)));
      when(mocker.mockFunc(FileUtil, FileUtil.writeMediaToSandBox))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(wantUtil, wantUtil.getMms))(ArgumentMatchers.any)
        .afterReturn({
          type: 2
        } as Mms);
      when(mocker.mockFunc(wantUtil, wantUtil.getMmsType))(ArgumentMatchers.any)
        .afterReturn(commonData.MM_ATTACHMENT_TYPE.IMAGE);
      let path = {} as NavPathStack;

      wantUtil.getWant(context, path);

      expect(JSON.stringify(path)).assertEqual('{}');

      mocker.clear(GlobalContext.getContext());
      mocker.clear(DynamicLoader.getInstance());
      mocker.clear(wantUtil);
      mocker.clear(FileUtil);
    })

    it('WantUtilTest_getWant_action_sendData_plainText_stream_notHaveFileMms', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('abilityWant')
        .afterReturn({
          action: 'ohos.want.action.sendData',
          parameters: {
            'ability.picker.records': {
              'general.plain-text': [{
                utd: '',
                2: ''
              } as systemShare.SharedRecord],
              'ability.params.stream': ['', '']
            }
          } as LooseObject,
          uri: ''
        } as Object | window.WindowStage);
      when(mocker.mockFunc(DynamicLoader.getInstance(), DynamicLoader.getInstance().fire))(ArgumentMatchers.any)
        .afterReturn(new Promise<boolean>(resolve => resolve(false)));
      when(mocker.mockFunc(FileUtil, FileUtil.getSandboxPath))()
        .afterReturn('y/');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileFullDirectoryUri))(ArgumentMatchers.any)
        .afterReturn('/xy/z');
      when(mocker.mockFunc(wantUtil, wantUtil.getMms))(ArgumentMatchers.any)
        .afterReturn({
          type: 2
        } as Mms);
      when(mocker.mockFunc(wantUtil, wantUtil.getMmsType))(ArgumentMatchers.any)
        .afterReturn(commonData.MM_ATTACHMENT_TYPE.IMAGE);
      let path = {} as NavPathStack;

      wantUtil.getWant(context, path);

      expect(JSON.stringify(path)).assertEqual('{}');

      when(mocker.mockFunc(FileUtil, FileUtil.getSandboxPath))()
        .afterReturn('z');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileFullDirectoryUri))(ArgumentMatchers.any)
        .afterReturn('/xy/z');

      wantUtil.getWant(context, path);
      expect(JSON.stringify(path)).assertEqual('{}');

      mocker.clear(GlobalContext.getContext());
      mocker.clear(DynamicLoader.getInstance());
      mocker.clear(wantUtil);
      mocker.clear(FileUtil);
    })

    it('WantUtilTest_getWant_uri_thirdPartJump1', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('abilityWant')
        .afterReturn({
          action: 'ohos.want.action.receiveData',
          parameters: {
            'sms_body': 'sms body',
            'content': '',
            'address': 'address',
            'contactObjects': '',
            'ability.picker.records': {
              'general.text': [{
                utd: '',
              } as systemShare.SharedRecord]
            }
          } as LooseObject,
          uri: 'sms:570988776?xxx='
        } as Object | window.WindowStage);
      when(mocker.mockFunc(ContactsService.getInstance(),
        ContactsService.getInstance().dealContactParams))(ArgumentMatchers.any)
        .afterReturn({
          content: ''
        } as LooseObject);
      mocker.mockFunc(wantUtil, wantUtil.jump);
      let path = {} as NavPathStack;

      wantUtil.getWant(context, path);

      expect(JSON.stringify(path)).assertEqual('{}');

      mocker.clear(GlobalContext.getContext());
      mocker.clear(DynamicLoader.getInstance());
      mocker.clear(ContactsService.getInstance());
      mocker.clear(wantUtil);
    })

    it('WantUtilTest_getWant_uri_thirdPartJump2', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('abilityWant')
        .afterReturn({
          action: 'ohos.want.action.receiveData',
          parameters: {
            'sms_body': '',
            'content': undefined,
            'isRcs': true,
            'address': '',
            'contactObjects': undefined,
            'ability.picker.records': {
              'general.text': [{
                utd: '',
              } as systemShare.SharedRecord]
            }
          } as LooseObject,
          uri: 'sms:570988764'
        } as Object | window.WindowStage);
      mocker.mockFunc(wantUtil, wantUtil.jump);
      let path = {} as NavPathStack;

      wantUtil.getWant(context, path);

      expect(JSON.stringify(path)).assertEqual('{}');

      mocker.clear(GlobalContext.getContext());
      mocker.clear(DynamicLoader.getInstance());
      mocker.clear(wantUtil);
    })

    it('WantUtilTest_getWant_uri_thirdPartJump3', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('abilityWant')
        .afterReturn({
          action: 'ohos.want.action.receiveData',
          parameters: {
            'sms_body': '',
            'content': undefined,
            'isRcs': true,
            'address': '',
            'contactObjects': undefined,
            'ability.picker.records': {
              'general.text': [{
                utd: '',
              } as systemShare.SharedRecord]
            }
          } as LooseObject,
          uri: ''
        } as Object | window.WindowStage);
      mocker.mockFunc(wantUtil, wantUtil.jump);
      let path = {} as NavPathStack;

      wantUtil.getWant(context, path);

      expect(JSON.stringify(path)).assertEqual('{}');

      mocker.clear(GlobalContext.getContext());
      mocker.clear(DynamicLoader.getInstance());
      mocker.clear(wantUtil);
    })

    it('WantUtilTest_getWant_uri_thirdPartJump4', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('abilityWant')
        .afterReturn({
          action: 'ohos.want.action.receiveData',
          parameters: {
            'sms_body': '',
            'content': undefined,
            'isRcs': true,
            'address': '',
            'contactObjects': undefined,
            'ability.picker.records': {
              'general.text': [{
                utd: '',
              } as systemShare.SharedRecord]
            }
          } as LooseObject,
          uri: 'sms:'
        } as Object | window.WindowStage);
      mocker.mockFunc(wantUtil, wantUtil.jump);
      let path = new NavPathStack();

      wantUtil.getWant(context, path);

      expect(path.getParamByName('pathArray').length).assertEqual(0);

      mocker.clear(GlobalContext.getContext());
      mocker.clear(DynamicLoader.getInstance());
      mocker.clear(wantUtil);
    })

    it('WantUtilTest_getWant_parameters', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('abilityWant')
        .afterReturn({
          action: 'mms.event.notification',
          parameters: {
            'searchMsgId': '1',
            'searchContent': 'xx',
            'pageFlg': '1',
            'sms_body': '',
            'content': 'xx',
            'isRcs': true,
            'address': '',
            'contactObjects': {} as LooseObject,
            'ability.picker.records': {
              'general.text': [{
                utd: '',
              } as systemShare.SharedRecord]
            },
            'ohos.aafwk.param.callerBundleName': 'com.ohos.contacts',
          } as LooseObject,
          uri: ''
        } as Object | window.WindowStage);
      when(mocker.mockFunc(StringUtil, StringUtil.isEmpty))(ArgumentMatchers.any).afterReturn(true);
      when(mocker.mockFunc(wantUtil, wantUtil.parameterCompare))(ArgumentMatchers.any).afterReturn(true);
      mocker.mockFunc(wantUtil, wantUtil.jump);
      when(mocker.mockFunc(ContactsService.getInstance(),
        ContactsService.getInstance().dealContactParams))(ArgumentMatchers.any)
        .afterReturn({
          content: 'xx'
        } as LooseObject);
      let path = {} as NavPathStack;

      wantUtil.getWant(context, path);

      expect(JSON.stringify(path)).assertEqual('{}');

      mocker.clear(GlobalContext.getContext());
      mocker.clear(DynamicLoader.getInstance());
      mocker.clear(wantUtil);
      mocker.clear(ContactsService.getInstance());
      AppStorage.clear();
      mocker.clear(StringUtil);
    })

    it('WantUtilTest_getWant_parameters2', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('abilityWant')
        .afterReturn({
          action: 'mms.event.notification',
          parameters: {
            'searchMsgId': undefined,
            'searchContent': undefined,
            'pageFlg': undefined,
            'sms_body': '',
            'content': undefined,
            'isRcs': true,
            'address': '',
            'contactObjects': undefined,
            'ability.picker.records': {
              'general.text': [{
                utd: '',
              } as systemShare.SharedRecord]
            },
            'ohos.aafwk.param.callerBundleName': 'com.ohos.contacts',
          } as LooseObject,
          uri: ''
        } as Object | window.WindowStage);
      when(mocker.mockFunc(StringUtil, StringUtil.isEmpty))(ArgumentMatchers.any).afterReturn(true);
      when(mocker.mockFunc(wantUtil, wantUtil.parameterCompare))(ArgumentMatchers.any).afterReturn(true);
      mocker.mockFunc(wantUtil, wantUtil.jump);
      when(mocker.mockFunc(ContactsService.getInstance(),
        ContactsService.getInstance().dealContactParams))(ArgumentMatchers.any)
        .afterReturn({
          content: 'xx'
        } as LooseObject);
      let path = {} as NavPathStack;

      wantUtil.getWant(context, path);

      expect(JSON.stringify(path)).assertEqual('{}');

      mocker.clear(GlobalContext.getContext());
      mocker.clear(DynamicLoader.getInstance());
      mocker.clear(wantUtil);
      mocker.clear(ContactsService.getInstance());
      AppStorage.clear();
      mocker.clear(StringUtil);
    })

    it('WantUtilTest_parameterCompare1', 0, () => {
      let parameters: LooseObject = {
        'ohos.aafwk.param.callerBundleName': 'com.ohos.contacts'
      };
      let res = wantUtil.parameterCompare(parameters, 'mms.event.notification');
      expect(res).assertTrue();
    })

    it('WantUtilTest_buildTransmitParam1', 0, () => {
      let parameters: LooseObject = {
        'sms_body': '',
        'content': undefined,
        'isRcs': true,
        'address': '',
        'contactObjects': undefined,
        'ability.picker.records': {
          'general.text': [{
            '2': undefined,
            utd: '',
          } as systemShare.SharedRecord]
        }
      } as LooseObject;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(wantUtil, wantUtil.getMmsType))(ArgumentMatchers.any)
        .afterReturn(7);
      let res = wantUtil.buildTransmitParam(context, parameters, ['general.text']);
      expect(res.transmitContent).assertEqual('');
      mocker.clear(wantUtil);
    })

    it('WantUtilTest_buildTransmitParam1_type_text', 0, () => {
      let parameters: LooseObject = {
        'sms_body': '',
        'content': undefined,
        'isRcs': true,
        'address': '',
        'contactObjects': undefined,
        'ability.picker.records': {
          'general.text': [{
            '2': '',
            utd: '',
          } as systemShare.SharedRecord]
        }
      } as LooseObject;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(wantUtil, wantUtil.getMmsType))(ArgumentMatchers.any)
        .afterReturn(7);
      let res = wantUtil.buildTransmitParam(context, parameters, ['general.text']);
      expect(res.transmitContent).assertEqual('');
      mocker.clear(wantUtil);
    })

    it('WantUtilTest_buildTransmitParam2', 0, () => {
      let parameters: LooseObject = {
        'sms_body': '',
        'content': undefined,
        'isRcs': true,
        'address': '',
        'contactObjects': undefined,
        'ability.params.stream': ['file://com.ohos.mms'],
        'ability.picker.records': {
          'key': [{
            '2': undefined,
            utd: '',
          } as systemShare.SharedRecord]
        }
      } as LooseObject;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(wantUtil, wantUtil.getMmsType))(ArgumentMatchers.any)
        .afterReturn(8);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileFullDirectoryUri))(ArgumentMatchers.any)
        .afterReturn('zz/xx');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getSandboxPath))()
        .afterReturn('/');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any)
        .afterReturn(0);
      when(mocker.mockFunc(wantUtil, wantUtil.getMms))(ArgumentMatchers.any)
        .afterReturn({} as Mms);
      let res = wantUtil.buildTransmitParam(context, parameters, ['key']);
      expect(res.transmitContent).assertEqual('');
      mocker.clear(wantUtil);
      mocker.clear(FileUtil);
    })

    it('WantUtilTest_buildTransmitParam3', 0, () => {
      let parameters: LooseObject = {
        'sms_body': '',
        'content': undefined,
        'isRcs': true,
        'address': '',
        'contactObjects': undefined,
        'ability.params.stream': ['file://com.ohos.contact'],
        'ability.picker.records': {
          'key': [{
            '2': '',
            utd: '',
          } as systemShare.SharedRecord]
        }
      } as LooseObject;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(wantUtil, wantUtil.getMmsType))(ArgumentMatchers.any)
        .afterReturn(8);
      when(mocker.mockFunc(FileUtil, FileUtil.writeMediaToSandBox))(ArgumentMatchers.any)
        .afterReturn('zz/xx');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any)
        .afterReturn(0);
      when(mocker.mockFunc(wantUtil, wantUtil.getMms))(ArgumentMatchers.any)
        .afterReturn({} as Mms);
      let res = wantUtil.buildTransmitParam(context, parameters, ['key']);
      expect(res.transmitContent).assertEqual('');
      mocker.clear(wantUtil);
      mocker.clear(FileUtil);
    })

    it('WantUtilTest_getMms', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(wantUtil, wantUtil.setFileSize))(ArgumentMatchers.any)
        .afterReturn(10);
      expect(wantUtil.getMms('xx', 0, '', '10', 'name').size).assertEqual('10');
      mocker.clear(wantUtil);
    })

    it('WantUtilTest_setFileSize', 0, () => {
      expect(wantUtil.setFileSize(10)).assertEqual('10B');
      expect(wantUtil.setFileSize(1025)).assertEqual('1.00KB');
      expect(wantUtil.setFileSize(1024 * 1024 + 1)).assertEqual('1.00MB');
    })

    it('WantUtilTest_getMmsType1', 0, () => {
      expect(wantUtil.getMmsType('general.image', '1.jpg')).assertEqual(1);
    })

    it('WantUtilTest_getMmsType2', 0, () => {
      expect(wantUtil.getMmsType('com.microsoft.bmp', '1.bmp')).assertEqual(1);
    })
    it('WantUtilTest_getMmsType3', 0, () => {
      expect(wantUtil.getMmsType('general.jpeg', '1.jpeg')).assertEqual(1);
    })
    it('WantUtilTest_getMmsType4', 0, () => {
      expect(wantUtil.getMmsType('general.gif', '1.gif')).assertEqual(1);
    })
    it('WantUtilTest_getMmsType5', 0, () => {
      expect(wantUtil.getMmsType('general.png', '1.png')).assertEqual(1);
    })
    it('WantUtilTest_getMmsType6', 0, () => {
      expect(wantUtil.getMmsType('general.heic', '1.heic')).assertEqual(1);
    })
    it('WantUtilTest_getMmsType7', 0, () => {
      AppStorage.setOrCreate('isOnlineRcs', true);
      expect(wantUtil.getMmsType('general.audio', 'X.m4a')).assertEqual(9);
      AppStorage.clear();
    })
    it('WantUtilTest_getMmsType8', 0, () => {
      AppStorage.setOrCreate('isOnlineRcs', false);
      expect(wantUtil.getMmsType('general.audio', 'X.m4a')).assertEqual(3);
      AppStorage.clear();
    })
    it('WantUtilTest_getMmsType9', 0, () => {
      AppStorage.setOrCreate('isOnlineRcs', false);
      expect(wantUtil.getMmsType('general.video', '1.mp4')).assertEqual(2);
      AppStorage.clear();
    })
    it('WantUtilTest_getMmsType10', 0, () => {
      AppStorage.setOrCreate('isOnlineRcs', false);
      expect(wantUtil.getMmsType('general.text', '1.txt')).assertEqual(7);
      AppStorage.clear();
    })

    it('WantUtilTest_jump_conversation_contactParams', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      when(mocker.mockFunc(wantUtil, wantUtil.jumpIsNewPage))(ArgumentMatchers.any)
        .afterReturn(new Promise<void>(resolve => resolve()));
      wantUtil.jump(context, "conversation", {}, new NavPathStack(), true, '', 0, '');
      mocker.verify('setObject', ['isFromNotify', true]).once();
      AppStorage.clear();
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DotUtil.getInstance());
      mocker.clear(wantUtil);
    })

    it('WantUtilTest_jump_conversation_contactParams_searchMsgId_undefined', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      when(mocker.mockFunc(wantUtil, wantUtil.jumpIsNewPage))(ArgumentMatchers.any)
        .afterReturn(new Promise<void>(resolve => resolve()));
      wantUtil.jump(context, "conversation", {}, new NavPathStack(), true, '', 0);
      mocker.verify('setObject', ['isFromNotify', true]).once();

      AppStorage.clear();
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DotUtil.getInstance());
      mocker.clear(wantUtil);
    })

    it('WantUtilTest_jump_blockedList', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);

      wantUtil.jump(context, "blockedList", {
        pageFlag: 'conversation',
        contactObjects: '18351440964',
        content: 'aaa'
      } as LooseObject, new NavPathStack(), false);
      mocker.verify('setObject', ['isFromNotify', true]).never();

      AppStorage.clear();
      mocker.clear(GlobalContext.getContext());
    })

    it('WantUtilTest_jump', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);

      wantUtil.jump(context, "", {
        pageFlag: 'conversation',
        contactObjects: '18351440964',
        content: 'aaa'
      } as LooseObject, new NavPathStack(), false);
      mocker.verify('setObject', ['isFromNotify', true]).never();

      AppStorage.clear();
      mocker.clear(GlobalContext.getContext());
    })

    it('WantUtilTest_jumpIsNewPage_fail', 0, async () => {
      let result: Result = {
        uri: '',
        params: {
          rawContactId: '1'
        }
      };
      let contactParams: LooseObject = {
        contactsNum: 1,
        strContactsNumber: null,
        rawContactId: '1'
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNumIntl))(ArgumentMatchers.any)
        .afterReturn(new Promise<string>(resolve => resolve('570988765')));
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.removeWhitespace))(ArgumentMatchers.any)
        .afterReturn('570988768');
      mocker.mockFunc(NotificationService.getInstance(), NotificationService.getInstance().updateBadgeNumber);
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isFoldable))(ArgumentMatchers.any)
        .afterReturn(true);
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isTablet))(ArgumentMatchers.any)
        .afterReturn(false);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));

      await wantUtil.jumpIsNewPage(context, result, contactParams, new NavPathStack(), true);

      mocker.verify('removeWhitespace', [null]).never();

      mocker.clear(DeviceUtil);
      mocker.clear(NotificationService.getInstance());
      mocker.clear(TelephoneUtil);
    })

    it('WantUtilTest_jumpIsNewPage_fail1', 0, async () => {
      let result: Result = {
        uri: '',
        params: {
          rawContactId: '1'
        }
      };
      let contactParams: LooseObject = {
        contactsNum: 2,
        strContactsNumber: null,
        rawContactId: '1'
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(NotificationService.getInstance(), NotificationService.getInstance().updateBadgeNumber);
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isFoldable))(ArgumentMatchers.any)
        .afterReturn(false);
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isTablet))(ArgumentMatchers.any)
        .afterReturn(false);

      await wantUtil.jumpIsNewPage(context, result, contactParams, new NavPathStack(), false);

      mocker.verify('removeWhitespace', [null]).never();

      mocker.clear(DeviceUtil);
      mocker.clear(NotificationService.getInstance());
    })

    it('WantUtilTest_jumpIsNewPage_success', 0, async () => {
      let result: Result = {
        uri: '',
        params: {
          rawContactId: '1',
          isNewMsgWithDraft: false,
          isNewMsg: false,
          threadId:1,
          isDraft:1
        }
      };
      let contactParams: LooseObject = {
        contactsNum: 2,
        strContactsNumber: '570977632',
        rawContactId: '1'
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNumIntl))(ArgumentMatchers.any)
        .afterReturn(new Promise<string>(resolve => resolve('570988765')));
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.removeWhitespace))(ArgumentMatchers.any)
        .afterReturn('570988768');
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isFoldable))(ArgumentMatchers.any)
        .afterReturn(false);
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isTablet))(ArgumentMatchers.any)
        .afterReturn(true);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0, abilityResult: [{
                id: 1,
                hasDraft: 1,
                messageCount: 0
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as object | window.WindowStage);
      mocker.mockFunc(NotificationService.getInstance(), NotificationService.getInstance().updateBadgeNumber);

      await wantUtil.jumpIsNewPage(context, result, contactParams, new NavPathStack(), true);
      mocker.verify('removeWhitespace', [null]).never();

      mocker.clear(DeviceUtil);
      mocker.clear(NotificationService.getInstance());
      mocker.clear(TelephoneUtil);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationService.getInstance());
    })

    it('WantUtilTest_jumpIsNewPage_success1', 0, async () => {
      let result: Result = {
        uri: '',
        params: {
          rawContactId: '1',
          isNewMsgWithDraft: false,
          isNewMsg: false,
          threadId:1,
          isDraft:1
        }
      };
      let contactParams: LooseObject = {
        contactsNum: 2,
        strContactsNumber: '570977632',
        rawContactId: '1'
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNumIntl))(ArgumentMatchers.any)
        .afterReturn(new Promise<string>(resolve => resolve('570988765')));
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.removeWhitespace))(ArgumentMatchers.any)
        .afterReturn('570988768');
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isFoldable))(ArgumentMatchers.any)
        .afterReturn(true);
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isTablet))(ArgumentMatchers.any)
        .afterReturn(false);
      mocker.mockFunc(NotificationService.getInstance(), NotificationService.getInstance().updateBadgeNumber);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0, abilityResult: [{
                id: 1,
                hasDraft: 0,
                messageCount: 1
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as object | window.WindowStage);

      await wantUtil.jumpIsNewPage(context, result, contactParams, new NavPathStack(), false);

      mocker.verify('removeWhitespace', [null]).never();

      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isFoldable))(ArgumentMatchers.any)
        .afterReturn(false);
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isTablet))(ArgumentMatchers.any)
        .afterReturn(false);

      await wantUtil.jumpIsNewPage(context, result, contactParams, new NavPathStack(), false);
      mocker.verify('removeWhitespace', [null]).never();

      mocker.clear(DeviceUtil);
      mocker.clear(NotificationService.getInstance());
      mocker.clear(TelephoneUtil);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationService.getInstance());
    })

    it('WantUtilTest_jumpIsNewPage_success2', 0, async () => {
      let result: Result = {
        uri: '',
        params: {
          rawContactId: '1',
          isNewMsgWithDraft: false,
          isNewMsg: false,
          threadId:1,
          isDraft:1
        }
      };
      let contactParams: LooseObject = {
        contactsNum: 2,
        strContactsNumber: '570977632',
        rawContactId: '1'
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNumIntl))(ArgumentMatchers.any)
        .afterReturn(new Promise<string>(resolve => resolve('570988765')));
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.removeWhitespace))(ArgumentMatchers.any)
        .afterReturn('570988768');
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isFoldable))(ArgumentMatchers.any)
        .afterReturn(false);
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isTablet))(ArgumentMatchers.any)
        .afterReturn(false);
      mocker.mockFunc(NotificationService.getInstance(), NotificationService.getInstance().updateBadgeNumber);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0, abilityResult: [{
                id: 1,
                hasDraft: 0,
                messageCount: 1
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as object | window.WindowStage);

      await wantUtil.jumpIsNewPage(context, result, contactParams, new NavPathStack(), false);
      mocker.verify('removeWhitespace', [null]).never();

      mocker.clear(DeviceUtil);
      mocker.clear(NotificationService.getInstance());
      mocker.clear(TelephoneUtil);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationService.getInstance());
    })
  })
}
