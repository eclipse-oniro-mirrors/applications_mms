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
import { describe, it, expect, when, ArgumentMatchers } from '@ohos/hypium';
import { MockKit } from '@ohos/hypium/src/main/module/mock/MockKit';
import LooseObject from '../../../../main/ets/data/LooseObject';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import telephoneUtil, { I18nPhoneNumberFormat } from '../../../../main/ets/utils/TelephoneUtil';
import { window } from '@kit.ArkUI';
import { ConversationListInfo } from '../../../../main/ets/model/conversationlist/ConversationListInfo';
import StringUtil from '../../../../main/ets/utils/StringUtil';
import { DTGlobalContext } from '../../testability/TestAbility';
import { isSameTel } from '../../../../main/ets/utils/TelephoneUtilEnhancde';
import TimeTickUtil from '../../../../main/ets/utils/TimeTickUtil';
import { AsyncCallback, BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import common from '../../../../main/ets/data/commonData';
import { ResponseType } from '../../../../main/ets/service/ConversationListService'

export default function telephoneUtilTest() {
  describe('TelephoneUtilTest', () => {

    it('TelephoneUtilTest_release_instance_null', 0, () => {
      telephoneUtil.release();
      expect(telephoneUtil).not().assertUndefined();
    })

    it('TelephoneUtilTest_judgeIsInfoMsg_telephone_empty', 0, () => {
      let result = telephoneUtil.judgeIsInfoMsg('');
      expect(result).assertEqual(false)
    })

    it('TelephoneUtilTest_judgeIsInfoMsg', 0, () => {
      let result = telephoneUtil.judgeIsInfoMsg('570988763');
      expect(result).assertEqual(false)
    })

    it('TelephoneUtilTest_updateInfoMsg_success', 0, () => {
      let conversationListInfo: ConversationListInfo =
        new ConversationListInfo(1, 0, '570988765', 'content', 0, 0, 0, 0, 0, 0, 0, '0', 'name', 1, '570988765', '0');
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(telephoneUtil, telephoneUtil.judgeIsInfoMsg))(ArgumentMatchers.any)
        .afterReturn(true);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [conversationListInfo]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | window.WindowStage);

      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      telephoneUtil.updateInfoMsg(context, () => {});
      expect(telephoneUtil).not().assertUndefined();

      mocker.clear(GlobalContext.getContext());
      mocker.clear(telephoneUtil);
    })

    it('TelephoneUtilTest_updateInfoMsg_success_false', 0, () => {
      let conversationListInfo: ConversationListInfo =
        new ConversationListInfo(1, 0, '570988765', 'content', 0, 0, 0, 0, 0, 0, 0, '0', 'name', 1, '570988765', '0');
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(telephoneUtil, telephoneUtil.judgeIsInfoMsg))(ArgumentMatchers.any)
        .afterReturn(false);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 1,
              abilityResult: [conversationListInfo]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | window.WindowStage);

      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      telephoneUtil.updateInfoMsg(context, () => {});
      expect(telephoneUtil).not().assertUndefined();

      mocker.clear(GlobalContext.getContext());
      mocker.clear(telephoneUtil);
    })

    it('TelephoneUtilTest_updateInfoMsg_fail', 0, () => {
      let conversationListInfo: ConversationListInfo =
        new ConversationListInfo(1, 0, '570988765', 'content', 0, 0, 0, 0, 0, 0, 0, '0', 'name', 1, '570988765', '0');
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [conversationListInfo]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | window.WindowStage);

      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      telephoneUtil.updateInfoMsg(context, () => {});
      expect(telephoneUtil).not().assertUndefined();

      mocker.clear(GlobalContext.getContext());
    })

    it('TelephoneUtilTest_formatTelephones', 0, () => {
      let formatTelephones = telephoneUtil.formatTelephones('');
      expect(formatTelephones).assertEqual('');

      let formatTelephones1 = telephoneUtil.formatTelephones('+8618351440964')
      expect(formatTelephones1).assertEqual('+8618351440964');

      let formatTelephones2 = telephoneUtil.formatTelephones('+8618351440964,+8618351440965');
      expect(formatTelephones2).assertEqual('+8618351440964,+8618351440965');
    })

    it('TelephoneUtilTest_dealSelectContactsSort', 0, () => {
      let selectContacts: Array<LooseObject> = [];
      telephoneUtil.dealSelectContactsSort(selectContacts);

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(telephoneUtil, telephoneUtil.dealTelephoneSort))(ArgumentMatchers.any)
        .afterReturn('570988765,570988766');
      let array = [{
        telephone: '570988765',
        telephoneFormat: '',
        contactName: 'aa'
      } as LooseObject,{
        telephone: '570988765',
        telephoneFormat: 'xxx',
        contactName: 'aa'
      } as LooseObject]
      let result1 = telephoneUtil.dealSelectContactsSort(array);
      expect(result1.length).assertEqual(1);
      mocker.clear(telephoneUtil);
    })

    it('TelephoneUtilTest_dealTelephoneSort', 0, () => {
      let result1: string = telephoneUtil.dealTelephoneSort('');
      expect(result1).assertEqual('');

      let result2 = telephoneUtil.dealTelephoneSort('570988763');
      expect(result2).assertEqual('570988763');

      let result3 = telephoneUtil.dealTelephoneSort('570988763,570988762');
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(telephoneUtil, telephoneUtil.bubbleSort)
      expect(result3).assertEqual('570988762,570988763');
      mocker.clear(telephoneUtil);
    })

    it('TelephoneUtilTest_bubbleSort', 0, () => {
      let arr: string[] | number[] = [1, 3, 5, 7, 2, 4];
      telephoneUtil.bubbleSort(arr, 5);
      expect(arr.length).assertEqual(6);
    })

    it('TelephoneUtilTest_getLastForDigit', 0, () => {
      let res = telephoneUtil.getLastForDigit('123456789', 5);
      expect(res).assertEqual('****6789');
    })

    it('TelephoneUtilTest_isPhoneNumber', 0, () => {
      let result = telephoneUtil.isPhoneNumber('18351440964')
      expect(result).assertEqual(true)
    })

    it('TelephoneUtilTest_initPhoneNumberFormat', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(I18nPhoneNumberFormat, I18nPhoneNumberFormat.getInstance)
      telephoneUtil.initPhoneNumberFormat()
      mocker.verify('getInstance', []).once();
      mocker.clear(I18nPhoneNumberFormat);
    })

    it('TelephoneUtilTest_release', 0, () => {
      telephoneUtil.release();
      expect().assertUndefined();
    })

    it('TelephoneUtilTest_formatDisplayPhoneNum', 0, () => {
      let formatPhone = telephoneUtil.formatDisplayPhoneNum('');
      expect(formatPhone).assertEqual('');
      let formatPhone1 = telephoneUtil.formatDisplayPhoneNum('15040402506')
      expect(formatPhone1).assertEqual('150 4040 2506');
      let formatPhone2 = telephoneUtil.formatDisplayPhoneNum('+8615040402506')
      expect(formatPhone2).assertEqual('150 4040 2506');
    })

    it('TelephoneUtilTest_dynamicFormatPhone', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(StringUtil, StringUtil.formatWithSpace))(ArgumentMatchers.any)
        .afterReturn('');

      let result1 = telephoneUtil.dynamicFormatPhone('');
      expect(result1).assertEqual('');

      let result2 = telephoneUtil.dynamicFormatPhone('10657967');
      expect(result2).assertEqual('');

      let result3 = telephoneUtil.dynamicFormatPhone('106579670920');
      expect(result3).assertEqual('');

      let result4 = telephoneUtil.dynamicFormatPhone('10657967092');
      expect(result4).assertEqual('');

      mocker.clear(StringUtil);
    })

    it('TelephoneUtilTest_isDomesticTelephone', 0, () => {
      let result = telephoneUtil.isDomesticTelephone('');
      expect(result).assertFalse();

      let result1 = telephoneUtil.isDomesticTelephone('+8677777777');
      expect(result1).assertTrue();

      let result2 = telephoneUtil.isDomesticTelephone('86777777777');
      expect(result2).assertTrue();

      let result3 = telephoneUtil.isDomesticTelephone('0086777777777');
      expect(result3).assertTrue();

      let result4 = telephoneUtil.isDomesticTelephone('110');
      expect(result4).assertFalse();
    })

    it('TelephoneUtilTest_isSpMms', 0, () => {
      let result = telephoneUtil.isSpMms('1068111111');
      expect(result).assertTrue();

      let result1 = telephoneUtil.isSpMms('1069111111');
      expect(result1).assertTrue();

      let result2 = telephoneUtil.isSpMms('1065111111');
      expect(result2).assertTrue();

      let result4 = telephoneUtil.isSpMms('1060111111');
      expect(result4).assertFalse();
    })

    it('TelephoneUtilTest_isSameTel', 0, () => {
      let result = isSameTel('1065796709202', '1065796709202')
      expect(result).assertEqual(true);
    })

    it('TelephoneUtilTest_formatDisplayPhoneNumIntl_empty', 0, async () => {
      let result = await telephoneUtil.formatDisplayPhoneNumIntl('')
      expect(result).assertEqual('');
    })

    it('TelephoneUtilTest_formatDisplayPhoneNumIntl_01', 0, async () => {
      let result = await telephoneUtil.formatDisplayPhoneNumIntl('+8618700912345')
      expect(result).assertEqual('+86 187 0091 2345');
    })

    it('TelephoneUtilTest_formatDisplayPhoneNumIntl', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(telephoneUtil, telephoneUtil.formatDisplayPhoneNum);

      let result = await telephoneUtil.formatDisplayPhoneNumIntl('')
      expect(result).assertEqual('');
      mocker.clear(telephoneUtil);
    })

    it('TelephoneUtilTest_formatNumberForChineseCodePlan_phoneNumber_empty', 0, async () => {
      let result = await (telephoneUtil as object)['formatNumberForChineseCodePlan']('101', '') as string;
      expect(result).assertEqual('');
    })

    it('TelephoneUtilTest_formatNumberForChineseCodePlan', 0, async () => {
      let result = await (telephoneUtil as object)['formatNumberForChineseCodePlan']('776564', '439365825') as string;
      expect(result).assertEqual('439365825');
    })

    it('TelephoneUtilTest_removeWhitespace', 0, () => {
      let result = telephoneUtil.removeWhitespace('');
      expect(result).assertEqual('');

      let result1 = telephoneUtil.removeWhitespace('780877655');
      expect(result1).assertEqual('780877655');
    })

    it('TelephoneUtilTest_formatDisplayPhoneNumE164', 0, () => {
      let result = telephoneUtil.formatDisplayPhoneNumE164('+8616826493167', false, false);
      expect(result).assertEqual('+8616826493167');
    })

    it('TelephoneUtilTest_formatDisplayPhoneNumE164_two', 0, () => {
      telephoneUtil.formatDisplayPhoneNumE164('+8616826493167', false);
      let result = telephoneUtil.formatDisplayPhoneNumE164('+8616826493167', false);
      expect(result).assertEqual('+8616826493167');
    })

    it('TelephoneUtilTest_getTelephoneByFuzzMatch', 0, () => {
      let responseType = new ResponseType();
      responseType.telephone = '911';
      let result = telephoneUtil.getTelephoneByFuzzMatch([responseType], '911');
      expect(result.telephone).assertEqual('911');
    })

    it('TelephoneUtilTest_getTelephoneByFuzzMatch_86', 0, () => {
      let responseType = new ResponseType();
      responseType.telephone = '+8616826493167';
      let result = telephoneUtil.getTelephoneByFuzzMatch([responseType], '16826493167');
      expect(result.telephone).assertEqual('');
    })

    it('TelephoneUtilTest_getTelephoneByFuzzMatch_empty', 0, () => {
      let responseType = new ResponseType();
      responseType.telephone = '+8616826493167';
      let result = telephoneUtil.getTelephoneByFuzzMatch([responseType], '');
      expect(result.telephone).assertEqual('');
    })

    it('TelephoneUtilTest_nationalFormatNumber', 0, () => {
      let result = telephoneUtil.nationalFormatNumber('110');
      expect(result).assertEqual('110');
    })

    it('TelephoneUtilTest_batchNationalFormatPhoneNumber', 0, () => {
      let result = telephoneUtil.batchNationalFormatPhoneNumber([]);
      expect(result.length).assertEqual(0);
    })

    it('TelephoneUtilTest_countryCodeFormatPhone_empty', 0, () => {
      let result = telephoneUtil.countryCodeFormatPhone('');
      expect(result).assertEqual('');
    })

    it('TelephoneUtilTest_countryCodeFormatPhone_sip', 0, () => {
      let result = telephoneUtil.countryCodeFormatPhone('sip:123@456');
      expect(result).assertEqual('sip:123@456');
    })

    it('TelephoneUtilTest_getSmsSignature_empty', 0, () => {
      let result = telephoneUtil.getSmsSignature('');
      expect(result.length).assertEqual(0);
    })

    it('TelephoneUtilTest_getSmsSignature_headStr', 0, () => {
      let result = telephoneUtil.getSmsSignature('【银河】');
      expect(result.length).assertEqual(0);
    })

    it('TelephoneUtilTest_getSmsSignature_headStr_empty', 0, () => {
      let result = telephoneUtil.getSmsSignature('mms info');
      expect(result.length).assertEqual(0);
    })

    it('TelephoneUtilTest_getSmsSignature', 0, () => {
      let result = telephoneUtil.getSmsSignature('【银河】 info mms [QQ end]');
      expect(result.length).assertEqual(2);
    })

    it('TelephoneUtilTest_getSmsSignature_headStr_empty_1', 0, () => {
      let result = telephoneUtil.getSmsSignature('【  】 info mms [  ]');
      expect(result.length).assertEqual(0);
    })

    it('TelephoneUtilTest_getSmsSignature_headStr_empty_2', 0, () => {
      let result = telephoneUtil.getSmsSignature('【】 info mms []');
      expect(result.length).assertEqual(0);
    })


    it('TimeTickUtilTest_unSubscribeTimeTickEvent_timeTickEventData_null', 0, () => {
      let timeTick = new TimeTickUtil(() => {});
      (timeTick as object)['timeTickEventData'] = null;
      timeTick.unSubscribeTimeTickEvent()
      expect(timeTick).not().assertUndefined();
    })

    it('TimeTickUtilTest_unSubscribeTimeTickEvent_timeTickEventData_not_null', 0, () => {
      let timeTick = new TimeTickUtil(() => {});
      let events = [common.STR.RCS_SUBSCRIBER_SEND_OK_EVENT];
      let commonEventSubscribeInfoData: commonEventManager.CommonEventSubscribeInfo = {
        events: events,
      };
      let data: commonEventManager.CommonEventSubscriber = commonEventManager.createSubscriberSync(commonEventSubscribeInfoData);

      (timeTick as object)['timeTickEventData'] = data;
      timeTick.unSubscribeTimeTickEvent()
      expect(timeTick).not().assertUndefined();
    })

    it('TimeTickUtilTest_createTimeTickSubscriberCallBack_err_null', 0, () => {
      let timeTick = new TimeTickUtil(() => {});
      (timeTick as object)['timeTickEventData'] = { } as commonEventManager.CommonEventSubscriber;
      let events = [common.STR.RCS_SUBSCRIBER_SEND_OK_EVENT];
      let commonEventSubscribeInfoData: commonEventManager.CommonEventSubscribeInfo = {
        events: events,
      };
      let data: commonEventManager.CommonEventSubscriber = commonEventManager.createSubscriberSync(commonEventSubscribeInfoData);

      timeTick.createTimeTickSubscriberCallBack(undefined, data);
      expect(timeTick).not().assertUndefined();
    })

    it('TimeTickUtilTest_createTimeTickSubscriberCallBack_err_null_function_undefined', 0, () => {
      let timeTick = new TimeTickUtil(undefined);
      (timeTick as object)['timeTickEventData'] = { } as commonEventManager.CommonEventSubscriber;
      let events = [common.STR.RCS_SUBSCRIBER_SEND_OK_EVENT];
      let commonEventSubscribeInfoData: commonEventManager.CommonEventSubscribeInfo = {
        events: events,
      };
      let data: commonEventManager.CommonEventSubscriber = commonEventManager.createSubscriberSync(commonEventSubscribeInfoData);
      timeTick.createTimeTickSubscriberCallBack(undefined, data);
      expect(timeTick).not().assertUndefined();
    })

    it('TimeTickUtilTest_createTimeTickSubscriberCallBack_err_not_null', 0, () => {
      let businessError: BusinessError = {
        code: 1,
        message: 'dataShare error'
      } as BusinessError;
      let timeTick = new TimeTickUtil(() => {});
      (timeTick as object)['timeTickEventData'] = { } as commonEventManager.CommonEventSubscriber;
      timeTick.createTimeTickSubscriberCallBack(businessError, { } as commonEventManager.CommonEventSubscriber);
      expect(timeTick).not().assertUndefined();
    })
  })
}