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
import { ContactType } from '../../../../main/ets/utils/TypesUtils';
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium';
import { VCardParser, VCardParserResult, VCardProperty } from '../../../../main/ets/utils/VCardParser';
import { DTGlobalContext } from '../../testability/TestAbility';
import { HOSBase64 } from '../../../../main/ets/utils/HOSBase64';

export default function VCardParserTest() {
  let vCardParser = new VCardParser();
  let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
  describe('VCardParserTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })

    it('VCardParserTest_sInstance', 0, () => {
      VCardParser.getInstance();
      let result = VCardParser.getInstance();
      expect(typeof result).assertEqual(typeof vCardParser);
    });

    it('VCardParserTest_parseVcardStr_empty', 0, async () => {
      let result: ContactType[] = await vCardParser.parseVcardStr(context, '', 0);
      expect(result.length).assertEqual(0);
    });

    it('VCardParserTest_parseVcardStr_private_parseItemInter_n_judgeBeginVCard_true', 0, async () => {
      let vcard: string = '\nBEGIN:VCARD\nVERSION:0.1\nPHOTO;\n=768END:VCARDer'
      let result: ContactType[] = await vCardParser.parseVcardStr(context, vcard, 0);
      expect(result.length).assertEqual(0);
    });

    it('VCardParserTest_parseItemInter', 0, () => {
      (vCardParser as object)['parseItemInter'](['VERSION:2.1'], 0, []);
      expect(vCardParser).not().assertUndefined();
    });

    it('VCardParserTest_handleParams', 0, () => {
      let propertyData: VCardProperty = new VCardProperty();
      (vCardParser as object)['handleParams'](propertyData, '110');
      (vCardParser as object)['handleParams'](propertyData, 'type=0');
      (vCardParser as object)['handleParams'](propertyData, 'param=0');
      expect(vCardParser).not().assertUndefined();
    });

    it('VCardParserTest_constructPropertyData', 0, () => {
      (vCardParser as object)['constructPropertyData']('propertyName:');
      (vCardParser as object)['constructPropertyData']('propertyName:2314');
      (vCardParser as object)['constructPropertyData']('.we');
      (vCardParser as object)['constructPropertyData']('groupName.we;ss;as:3;');
      (vCardParser as object)['constructPropertyData']('groupName.we;ss;"as3";');
      expect(vCardParser).not().assertUndefined();
    });

    it('VCardParserTest_parseItemsByStr__return_null', 0, async () => {
      let vcard: string = 'BEGIN:VCARD\n\nVERSION:0.1\nPHOTO;\n=768END:VCARDer'
      let result: ContactType[] = await vCardParser.parseVcardStr(context, vcard, 0);
      expect(result.length).assertEqual(0);
    });

    it('VCardParserTest_parseItemsByStr_jing_return_null', 0, async () => {
      let vcard: string = 'BEGIN:VCARD\n#end\nVERSION:0.1\nPHOTO;\n=768END:VCARDer'
      let result: ContactType[] = await vCardParser.parseVcardStr(context, vcard, 0);
      expect(result.length).assertEqual(0);
    });

    it('VCardParserTest_parseItemsByStr_return_data_name', 0, async () => {
      let vcard: string = 'BEGIN:VCARD\nFN:001.\nTEL:002.37\nVERSION:0.1\nPHOTO;\n=768END:VCARDer'
      let result: ContactType[] = await vCardParser.parseVcardStr(context, vcard, 0);
      expect(result.length).assertEqual(1);
    });

    it('VCardParserTest_parseItemsByStr_return_data_name_status_1', 0, async () => {
      let m_vCardParser = new VCardParser();
      let m_context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let vcard: string = 'BEGIN:VCARD\nPHOTO:456\nPATH:src\nFN:001.\nTEL:002.37\nVERSION:0.1\nPHOTO;\n=768END:VCARDer'
      let result: ContactType[] = await m_vCardParser.parseVcardStr(m_context, vcard, 1);
      expect(result.length).assertEqual(1);
    });

    it('VCardParserTest_parseItemsByStr_return_data_name_status_path', 0, async () => {
      let m_vCardParser = new VCardParser();
      let m_context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let vcard: string = 'BEGIN:VCARD\nPATH:src\nFN:001.\nTEL:002.37\nVERSION:0.1\nPHOTO;\n=768END:VCARDer'
      let result: ContactType[] = await m_vCardParser.parseVcardStr(m_context, vcard, 0);
      expect(result.length).assertEqual(1);
    });

    it('VCardParserTest_parseItemsByStr_return_data_name_status_2', 0, async () => {
      let m_vCardParser = new VCardParser();
      let m_context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let vcard: string = 'BEGIN:VCARD\nPHOTO:456\nFN:001.\nTEL:002.37\nVERSION:0.1\nPHOTO;\n=768END:VCARDer'
      let result: ContactType[] = await m_vCardParser.parseVcardStr(m_context, vcard, 2);
      expect(result.length).assertEqual(1);
    });

    it('VCardParserTest_parseItemsByStr_return_data_name_status_no_begin', 0, async () => {
      let m_vCardParser = new VCardParser();
      let m_context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let vcard: string = 'PATH:src\nFN:001.\nTEL:002.37\nVERSION:0.1\nPHOTO;\n=768END:VCARD'
      let result: ContactType[] = await m_vCardParser.parseVcardStr(m_context, vcard, 0);
      expect(result.length).assertEqual(0);
    });

    it('VCardParserTest_parseItemsByStr_return_data_name_createContactAvatar', 0, async () => {
      let m_vCardParser = new VCardParser();
      let m_context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let vcard: string = 'BEGIN:VCARD\nPHOTO:456\nFN:001.\nTEL:002.37\nVERSION:0.1\nPHOTO;\n=768END:VCARDer'
      let tempList = new VCardParserResult();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(new HOSBase64(), new HOSBase64().decode))(ArgumentMatchers.any).afterThrow('catch');
      let result: ContactType[] = await m_vCardParser.parseVcardStr(m_context, vcard, 0);
      expect(result.length).assertEqual(1);
    });
  })
}