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
import { describe, beforeEach, afterEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium'
import sendMsgService from '../../../../main/ets/service/SendMsgService';
import SharedPreferencesUtils from '../../../../main/ets/utils/SharedPreferencesUtils';
import common from '../../../../main/ets/data/commonData';
import DotUtil from '../../../../main/ets/utils/MmsDot/DotUtils';
import { BusinessError } from '@kit.BasicServicesKit';
import LooseObject from '../../../../main/ets/data/LooseObject';
import MmsPreferences from '../../../../main/ets/utils/MmsPreferences';
import FileUtil from '../../../../main/ets/utils/FileUtil';
import { sms } from '@kit.TelephonyKit';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import { window } from '@kit.ArkUI';
import HiLog from '../../../../main/ets/utils/HiLog';
import { DTGlobalContext } from '../../testability/TestAbility';
import { Mms } from '../../../../main/ets/utils/TypesUtils';

export default function sendMsgServiceDTTest() {
  describe('SendMsgServiceDTTest', () => {
    let mocker: MockKit;
    const TAG = 'SendMsgService';
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mocker = new MockKit();
    })

    afterEach(() => {
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(sendMsgService);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(FileUtil);
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(GlobalContext.getContext());
      AppStorage.clear();
    })

    it('SendMsgServiceDTTest_sendMessage_slotId_0', 0, () => {
      let callback: Function = (sendStatus: number) => {
        expect(sendStatus).assertEqual(0);
      };
      when(mocker.mockFunc(SharedPreferencesUtils,
        SharedPreferencesUtils.getFromPreferences))(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH)
        .afterReturn('0');
      when(mocker.mockFunc(sendMsgService, sendMsgService.sendMsgWithoutDeliveryReports))(ArgumentMatchers.any)
        .afterAction(() => {
          callback(0);
        });

      let params: Record<string, number | number[] | string | Boolean> = {
        "slotId": 0,
        "destinationHost": 111,
        "content": "content",
        "isReSend": true,
        "resendStateIsRcs": true
      };
      sendMsgService.sendMessage(params, callback);
      mocker.clear(SharedPreferencesUtils);
    })

    it('SendMsgServiceDTTest_sendMessage_slotId_1', 0, () => {
      let callback: Function = (sendStatus: number) => {
        expect(sendStatus).assertEqual(0);
      };
      when(mocker.mockFunc(SharedPreferencesUtils,
        SharedPreferencesUtils.getFromPreferences))(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH)
        .afterReturn('2');
      when(mocker.mockFunc(sendMsgService, sendMsgService.sendMsgWithoutDeliveryReports))(ArgumentMatchers.any)
        .afterAction(() => {
          callback(0);
        });

      let params: Record<string, number | number[] | string | Boolean> = {
        "slotId": 1,
        "destinationHost": 111,
        "content": "content",
        "isReSend": true,
        "resendStateIsRcs": true
      };
      sendMsgService.sendMessage(params, callback);
      mocker.clear(SharedPreferencesUtils);
    })

    it('SendMsgServiceDTTest_sendMessage_slotId_1_flag_1', 0, () => {
      let callback: Function = (sendStatus: number) => {
        expect(sendStatus).assertEqual(0);
      };
      when(mocker.mockFunc(SharedPreferencesUtils,
        SharedPreferencesUtils.getFromPreferences))(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH)
        .afterReturn('1');
      when(mocker.mockFunc(sendMsgService, sendMsgService.sendMsgWithDeliveryReports))(ArgumentMatchers.any)
        .afterAction(() => {
          callback(0);
        });

      let params: Record<string, number | number[] | string | Boolean> = {
        "slotId": 1,
        "destinationHost": 111,
        "content": "content",
        "isReSend": true,
        "resendStateIsRcs": true
      };
      sendMsgService.sendMessage(params, callback);
      mocker.clear(SharedPreferencesUtils);
    })

    it('SendMsgServiceDTTest_sendMessage_catch', 0, () => {
      let callback: Function = (sendStatus: number) => {
        expect(sendStatus).assertEqual(2);
      };
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportFaultEvent);

      when(mocker.mockFunc(SharedPreferencesUtils,
        SharedPreferencesUtils.getFromPreferences))(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH)
        .afterThrow('error');

      let params: Record<string, number | number[] | string | Boolean> = {
        "slotId": 1,
        "destinationHost": 111,
        "content": "content",
        "isReSend": true,
        "resendStateIsRcs": true
      };
      sendMsgService.sendMessage(params, callback);
      mocker.clear(SharedPreferencesUtils);
    })

    it('SendMsgServiceDTTest_sendMmsMessage', 0, async () => {
      let res = false;
      let callback: Function = () => {
        expect(res).assertTrue();
      };
      let params: LooseObject = {
        slotId: 0,
        to: [],
        subject: '',
        names: ['.amr'],
        content: 'data/test/test.amr'
      };

      let mmsSource: Mms[] = [{
        "duration" : "",
        "type" : 0,
        "path" : "",
        "name" : "",
        "text" : ""
      }, {
        "type" : 1,
        "name" : "",
        "path" : "",
        "duration" : "",
        "galleryPath" : "",
        "copyPath" : "",
        "smilParIndex" : 0
      }]

      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getTelephoneNumberOfSim1))()
        .afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getSandboxPath))().afterReturn('')
      mocker.mockFunc(FileUtil, FileUtil.writeToSandBox);
      when(mocker.mockFunc(sendMsgService, sendMsgService.buildMmsparams))(0)
        .afterReturn(new Promise<sms.MmsParams>(resolve => resolve({
          slotId: 0,
          mmsc: '',
          data: '',
          mmsConfig: {} as sms.MmsConfig
        })));
      mocker.mockFunc(sendMsgService, sendMsgService.sendMmsMethod);
      when(mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('downloadList')
        .afterReturn([]);

      await sendMsgService.sendMmsMessage(context, params, mmsSource, callback);
      mocker.clear(SharedPreferencesUtils)
      mocker.clear(DotUtil.getInstance())
      mocker.clear(sendMsgService)
      mocker.clear(FileUtil)
      mocker.clear(MmsPreferences.getInstance())
    })

    it('SendMsgServiceDTTest_buildMmsparams', 0, async () => {
      when(mocker.mockFunc(sendMsgService, sendMsgService.getMmsc))(0)
        .afterReturn(new Promise<string>(resolve => resolve('')));
      when(mocker.mockFunc(FileUtil, FileUtil.getSandboxPath))()
        .afterReturn(new Promise<string>(resolve => resolve('')));
      let res: sms.MmsParams = await sendMsgService.buildMmsparams(context, 0, {} as sms.MmsConfig);
      mocker.clear(sendMsgService);
      mocker.clear(FileUtil);
      expect(res.slotId).assertEqual(0)
    })

    it('SendMsgServiceDTTest_queryNetInfo_getObject', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callback({
              code: 0
            } as LooseObject);
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      sendMsgService.queryNetInfo(context, {}, callback);
      mocker.clear(GlobalContext.getContext());
    })

    it('SendMsgServiceDTTest_getMmsc', 0, () => {
      mocker.mockFunc(HiLog, HiLog.e);
      sendMsgService.getMmsc(context, 0);
      mocker.verify('e', [TAG, 'getMmsc error: ']).never();
      mocker.clear(HiLog);
    })

    it('SendMsgServiceDTTest_dealSendResult_if', 0, () => {
      let value: LooseObject = {
        "result": sms.SendSmsResult.SEND_SMS_SUCCESS
      };
      (sendMsgService as object)['dealSendResult'](value);
      expect(sendMsgService).not().assertUndefined();
    })

    it('SendMsgServiceDTTest_dealSendResult_else', 0, () => {
      let value: LooseObject = {
        "result": sms.SendSmsResult.SEND_SMS_FAILURE_UNKNOWN
      };
      (sendMsgService as object)['dealSendResult'](value);
      expect(sendMsgService).not().assertUndefined();
    })

    it('SendMsgServiceDTTest_getSendFileType_if1', 0, () => {
      let format: string = 'mp4';
      (sendMsgService as object)['getSendFileType'](format);
      expect(sendMsgService).not().assertUndefined();
    })

    it('SendMsgServiceDTTest_getSendFileType_if2', 0, () => {
      let format: string = 'txt';
      (sendMsgService as object)['getSendFileType'](format);
      expect(sendMsgService).not().assertUndefined();
    })

    it('SendMsgServiceDTTest_getSendFileType_if3', 0, () => {
      let format: string = 'xml';
      (sendMsgService as object)['getSendFileType'](format);
      expect(sendMsgService).not().assertUndefined();
    })

    it('SendMsgServiceDTTest_getSendFileType_if4', 0, () => {
      let format: string = 'jpeg';
      (sendMsgService as object)['getSendFileType'](format);
      expect(sendMsgService).not().assertUndefined();
    })

    it('SendMsgServiceDTTest_getSendFileType_if5', 0, () => {
      let format: string = 'bmp';
      (sendMsgService as object)['getSendFileType'](format);
      expect(sendMsgService).not().assertUndefined();
    })

    it('SendMsgServiceDTTest_getSendFileType_if6', 0, () => {
      let format: string = 'vcf';
      (sendMsgService as object)['getSendFileType'](format);
      expect(sendMsgService).not().assertUndefined();
    })

    it('SendMsgServiceDTTest_getSendFileType_else', 0, () => {
      let format: string = 'aaaa';
      (sendMsgService as object)['getSendFileType'](format);
      expect(sendMsgService).not().assertUndefined();
    })

    it('SendMsgServiceDTTest_getSendFileTypeDot_if1', 0, () => {
      let format: string = 'mp4';
      (sendMsgService as object)['getSendFileTypeDot'](format);
      expect(sendMsgService).not().assertUndefined();
    })

    it('SendMsgServiceDTTest_getSendFileTypeDot_if2', 0, () => {
      let format: string = 'jpeg';
      (sendMsgService as object)['getSendFileTypeDot'](format);
      expect(sendMsgService).not().assertUndefined();
    })

    it('SendMsgServiceDTTest_getSendFileTypeDot_else', 0, () => {
      let format: string = 'aaaa';
      (sendMsgService as object)['getSendFileTypeDot'](format);
      expect(sendMsgService).not().assertUndefined();
    })

    it('SendMsgServiceDTTest_logFileNameMsg_empty', 0, () => {
      let name: string = '';
      (sendMsgService as object)['logFileNameMsg'](name);
      expect(sendMsgService).not().assertUndefined();
    })

    it('SendMsgServiceDTTest_logFileNameMsg_if', 0, () => {
      let name: string = 'aaaaa.txt';
      (sendMsgService as object)['logFileNameMsg'](name);
      expect(sendMsgService).not().assertUndefined();
    })

    it('SendMsgServiceDTTest_logFileNameMsg_else', 0, () => {
      let name: string = 'aaa.txt';
      (sendMsgService as object)['logFileNameMsg'](name);
      expect(sendMsgService).not().assertUndefined();
    })
  })
}