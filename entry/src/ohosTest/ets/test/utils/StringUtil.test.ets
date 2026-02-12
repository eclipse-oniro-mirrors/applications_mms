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
import { describe, it, expect, TestType, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import LooseObject from '../../../../main/ets/data/LooseObject';
import stringUtil, { isJSONString } from '../../../../main/ets/utils/StringUtil';
import { MeasureText } from '@kit.ArkUI';
import myCommon from '@ohos.app.ability.common';

export default function StringUtilTest() {
  describe('StringUtilTest', () => {

    it('StringUtilTest_getFirstName_empty', 0, () => {
      let result = stringUtil.getFirstName('');
      expect(result).assertEqual(' ');
    })

    it('StringUtilTest_getFirstName_chinese', 0, () => {
      let result = stringUtil.getFirstName('你好');
      expect(result).assertEqual('好');
    })

    it('StringUtilTest_getFirstName_has_chinese', 0, () => {
      let result = stringUtil.getFirstName('siw你好');
      expect(result).assertEqual('好');
    })

    it('StringUtilTest_getFirstName_has_chinese_else', 0, () => {
      let result = stringUtil.getFirstName('siw你好mm');
      expect(result).assertEqual('好');
    })

    it('StringUtilTest_getFirstName_has_english', 0, () => {
      let result = stringUtil.getFirstName('siw#!@3');
      expect(result).assertEqual('S');
    })

    it('StringUtilTest_getFirstName', 0, () => {
      let result = stringUtil.getFirstName('#!@3');
      expect(result).assertEqual(' ');
    })

    it('StringUtilTest_getFirstName_else', 0, () => {
      let result = stringUtil.getFirstName('$');
      expect(result).assertEqual(' ');
    })

    it('StringUtilTest_textAddSpace', TestType.FUNCTION, () => {
      expect(stringUtil.textAddSpace('ABC', 0, 2)).assertEqual(2);
      expect(stringUtil.textAddSpace('一二', 0, 2)).assertEqual(1);
      expect(stringUtil.textAddSpace('ABC', 4, 2)).assertEqual(4);
      expect(stringUtil.textAddSpace('as',1,1)).assertEqual(2);
    })

    it('StringUtilTest_countNonAlphabet', 0, () => {
      let str = '汉字';
      let result = stringUtil.countNonAlphabet(str);
      expect(result).assertEqual(2);
    })
    it('StringUtilTest_countNonAlphabet_en', 0, () => {
      let str = 'abc';
      let result = stringUtil.countNonAlphabet(str);
      expect(result).assertEqual(0);
    })

    it('StringUtilTest_getOffsetForSession', 0, () => {
      let page = 1;
      let result = stringUtil.getOffsetForSession(page);
      expect(result).assertEqual(0);
    })
    it('StringUtilTest_getOffsetForSession_page', 0, () => {
      let page = 2;
      let result = stringUtil.getOffsetForSession(page);
      expect(result).assertEqual(50);
    })
    it('StringUtilTest_getOffsetForSession_pageOff', 0, () => {
      let page = 6;
      let result = stringUtil.getOffsetForSession(page);
      expect(result).assertEqual(790);
    })

    it('StringUtilTest_getLimitForSession', 0, () => {
      let page = 1;
      let result = stringUtil.getLimitForSession(page);
      expect(result).assertEqual(50);
    })
    it('StringUtilTest_getLimitForSession_page', 0, () => {
      let page = 2;
      let result = stringUtil.getLimitForSession(page);
      expect(result).assertEqual(140);
    })
    it('StringUtilTest_getLimitForSession_pageSession', 0, () => {
      let page = 6;
      let result = stringUtil.getLimitForSession(page);
      expect(result).assertEqual(200);
    })

    it('StringUtilTest_getGroupIdsFromResultList', 0, () => {
      let resultList = [{
        groupId: 123
      } as LooseObject];
      let resultArray = [123];
      let array = stringUtil.getGroupIdsFromResultList(resultList);
      expect(JSON.stringify(array)).assertEqual(JSON.stringify(resultArray));
    })

    it('StringUtilTest_getGroupIdsFromResultList_resultList_null', 0, () => {
      let array = stringUtil.getGroupIdsFromResultList(null);
      expect(array.length).assertEqual(0);
    })

    it('StringUtilTest_getGroupIdsFromResultList_groupId_hasNull', 0, () => {
      let resultList = [{
        groupId: 123
      } as LooseObject,{
        groupId: null
      } as LooseObject,{
        groupId: undefined
      } as LooseObject];
      let resultArray = [123];
      let array = stringUtil.getGroupIdsFromResultList(resultList);
      expect(JSON.stringify(array)).assertEqual(JSON.stringify(resultArray));
    })

    it('StringUtilTest_getOffsetForSmsMmsInfo_page_1_contactsNum_0', 0, () => {
      let page = 1;
      let result = stringUtil.getOffsetForSmsMmsInfo(page, 0);
      expect(result).assertEqual(0);
    })

    it('StringUtilTest_getOffsetForSmsMmsInfo_page_1_contactsNum_2', 0, () => {
      let page = 1;
      let result = stringUtil.getOffsetForSmsMmsInfo(page, 2);
      expect(result).assertEqual(0);
    })

    it('StringUtilTest_getOffsetForSmsMmsInfo_page_3_contactsNum_0', 0, () => {
      let page = 3;
      let result = stringUtil.getOffsetForSmsMmsInfo(page, 0);
      expect(result).assertEqual(320);
    })

    it('StringUtilTest_getOffsetForSmsMmsInfo_page_3_contactsNum_2', 0, () => {
      let page = 3;
      let result = stringUtil.getOffsetForSmsMmsInfo(page, 2);
      expect(result).assertEqual(640);
    })

    it('StringUtilTest_getLimitForSmsMmsInfo_page_1_contactsNum_0', 0, () => {
      let page = 1;
      let result = stringUtil.getLimitForSmsMmsInfo(page, 0);
      expect(result).assertEqual(20);
    })

    it('StringUtilTest_getLimitForSmsMmsInfo_page_1_contactsNum_2', 0, () => {
      let page = 1;
      let result = stringUtil.getLimitForSmsMmsInfo(page, 2);
      expect(result).assertEqual(40);
    })

    it('StringUtilTest_getLimitForSmsMmsInfo_page_2_contactsNum_0', 0, () => {
      let page = 2;
      let result = stringUtil.getLimitForSmsMmsInfo(page, 0);
      expect(result).assertEqual(300);
    })

    it('StringUtilTest_getLimitForSmsMmsInfo_page_2_contactsNum_2', 0, () => {
      let page = 2;
      let result = stringUtil.getLimitForSmsMmsInfo(page, 2);
      expect(result).assertEqual(600);
    })

    it('StringUtilTest_isEmpty_undefined', 0, () => {
      expect(stringUtil.isEmpty(undefined)).assertTrue();
    })

    it('StringUtilTest_isEmpty_null', 0, () => {
      expect(stringUtil.isEmpty(null)).assertTrue();
    })

    it('StringUtilTest_isEmpty_empty', 0, () => {
      expect(stringUtil.isEmpty('')).assertTrue();
    })

    it('StringUtilTest_removeSpace', 0, () => {
      let str = stringUtil.removeSpace('');
      expect(str).assertEqual('');

      let str1 = stringUtil.removeSpace('a b c')
      expect(str1).assertEqual('abc');
    })

    it('StringUtilTest_trimBlank_str_null', 0, () => {
      let str = stringUtil.trimBlank(null);
      expect(str).assertEqual(undefined);
    })

    it('StringUtilTest_trimBlank', 0, () => {
      let str = stringUtil.trimBlank('n ul  l');
      expect(str).assertEqual('null');
    })

    it('StringUtilTest_getPathTail_undefined', 0, () => {
      let str = stringUtil.getPathTail(undefined);
      expect(str).assertEqual('');
    })

    it('StringUtilTest_getPathTail_empty', 0, () => {
      let str = stringUtil.getPathTail('');
      expect(str).assertEqual('');
    })

    it('StringUtilTest_getPathTail_no', 0, () => {
      let str = stringUtil.getPathTail('path');
      expect(str).assertEqual('');
    })

    it('StringUtilTest_getPathTail_result_empty', 0, () => {
      let str = stringUtil.getPathTail('/');
      expect(str).assertEqual('');
    })

    it('StringUtilTest_getPathTail', 0, () => {
      let str = stringUtil.getPathTail('path1/path2/path3')
      expect(str).assertEqual('path3');
    })

    it('StringUtilTest_buildEllipsis_originWidthPx_lessThan_maxWidthPx', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(MeasureText, MeasureText.measureText))(ArgumentMatchers.any)
        .afterReturn(10);
      let res: string = stringUtil.buildEllipsis("", 15, 115, false);
      expect(res).assertEqual("");
      mocker.clear(MeasureText);
    })

    it('StringUtilTest_buildEllipsis_originWidthPx_graterThan_maxWidthPx_ellipsisEnd_false_cutContentWidthPx_graterThan_contentMaxWidth',
      0, () => {
        let mocker: MockKit = new MockKit();
        when(mocker.mockFunc(MeasureText, MeasureText.measureText))(ArgumentMatchers.any)
          .afterReturn(500);
        let res: string = stringUtil.buildEllipsis("string", 15, 115, false);
        expect(res).assertEqual("…");
        mocker.clear(MeasureText);
      })

    it('StringUtilTest_buildEllipsis_originWidthPx_graterThan_maxWidthPx_ellipsisEnd_true_cutContentWidthPx_graterThan_contentMaxWidth',
      0, () => {
        let mocker: MockKit = new MockKit();
        when(mocker.mockFunc(MeasureText, MeasureText.measureText))(ArgumentMatchers.any)
          .afterReturn(500);
        let res: string = stringUtil.buildEllipsis("string", 15, 115, true);
        expect(res).assertEqual("…");
        mocker.clear(MeasureText);
      })

    it('StringUtilTest_buildEllipsis_originWidthPx_graterThan_maxWidthPx_ellipsisEnd_true_cutContentWidthPx_graterThan_contentMaxWidth_ellipsisEnd',
      0, () => {
        let mocker: MockKit = new MockKit();
        when(mocker.mockFunc(MeasureText, MeasureText.measureText))(ArgumentMatchers.any)
          .afterReturn(500);
        let res: string = stringUtil.buildEllipsis("string", 15, 115);
        expect(res).assertEqual("…");
        mocker.clear(MeasureText);
      })

    it('StringUtilTest_buildEllipsis_originWidthPx_lessThan_maxWidthPx_cutContentWidthPx_equal_contentMaxWidth_ellipsisEnd_false',
      0, () => {
        let mocker: MockKit = new MockKit();
        when(mocker.mockFunc(MeasureText, MeasureText.measureText))(ArgumentMatchers.any)
          .afterReturn(0);
        let res: string = stringUtil.buildEllipsis("str", 15, 0, false);
        expect(res).assertEqual("…tr");
        mocker.clear(MeasureText);
      })

    it('StringUtilTest_buildEllipsis_originWidthPx_lessThan_maxWidthPx_cutContentWidthPx_equal_contentMaxWidth_ellipsisEnd_true',
      0, () => {
        let mocker: MockKit = new MockKit();
        when(mocker.mockFunc(MeasureText, MeasureText.measureText))(ArgumentMatchers.any)
          .afterReturn(0);
        let res: string = stringUtil.buildEllipsis("str", 15, 0, true);
        expect(res).assertEqual("st…");
        mocker.clear(MeasureText);
      })

    it('StringUtilTest_formatWithSpace_empty', 0, () => {
      let text: string = '';
      expect(stringUtil.formatWithSpace(text, [3, 4, 4])).assertEqual('');
    })

    it('StringUtilTest_formatWithSpace', 0, () => {
      let text: string = '1234567890';
      expect(stringUtil.formatWithSpace(text, [3, 4, 4])).assertEqual('123 4567 890');
    })

    it('StringUtilTest_formatWithSpaceIgnoreEmTag_empty', 0, () => {
      let text: string = '';
      expect(stringUtil.formatWithSpaceIgnoreEmTag(text, [3, 4, 4])).assertEqual('');
    })

    it('StringUtilTest_formatWithSpaceIgnoreEmTag', 0, () => {
      let text: string = '1234<em>56</em>78 9  01';
      expect(stringUtil.formatWithSpaceIgnoreEmTag(text, [3, 4, 4])).assertEqual('123 4<em>56</em>7 8901');
    })

    it('StringUtilTest_convertResourceToString', 0, () => {
      let context: myCommon.UIAbilityContext = {
        resourceManager: {
          getStringSync: (resource: Resource): string => ''
        }
      } as myCommon.UIAbilityContext;

      let res: string = stringUtil.convertResourceToString($r('app.string.attachment_picture'), context);

      expect(res).assertEqual('');
    })

    it('StringUtilTest_convertResourceToString_context_null', 0, () => {
      let res: string = stringUtil.convertResourceToString($r('app.string.attachment_picture'), null);

      expect(res).assertEqual('');
    })

    it('StringUtilTest_convertResourceToString_contextResourceManager_null', 0, () => {
      let context: myCommon.UIAbilityContext = {
        resourceManager: null
      } as myCommon.UIAbilityContext;
      let res: string = stringUtil.convertResourceToString($r('app.string.attachment_picture'), context);

      expect(res).assertEqual('');
    })

    it('StringUtilTest_mask_str_null', 0, () => {
      expect(stringUtil.mask(null)).assertEqual('');
    })

    it('StringUtilTest_mask_length_1', 0, () => {
      expect(stringUtil.mask('x')).assertEqual('x');
    })

    it('StringUtilTest_phoneMask_str_null', 0, () => {
      expect(stringUtil.phoneMask(null)).assertEqual('');
    })

    it('StringUtilTest_phoneMask_length_Zero', 0, () => {
      expect(stringUtil.phoneMask('')).assertEqual('');
    })

    it('StringUtilTest_phoneMask_length_Three', 0, () => {
      expect(stringUtil.phoneMask('123')).assertEqual('123');
    })

    it('StringUtilTest_phoneMask_length_Four', 0, () => {
      expect(stringUtil.phoneMask('1234')).assertEqual('****1234');
    })

    it('StringUtilTest_phoneMask_length_Seven', 0, () => {
      expect(stringUtil.phoneMask('1234567')).assertEqual('****4567');
    })

    it('StringUtilTest_phoneMask_length_Eleven', 0, () => {
      expect(stringUtil.phoneMask('15288991275')).assertEqual('152****1275');
    })

    it('StringUtilTest_isJSONString', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(JSON, JSON.parse);
      expect(isJSONString('string')).assertTrue();
      mocker.clear(JSON);
    })

    it('StringUtilTest_isJSONString_catch', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(JSON, JSON.parse))(ArgumentMatchers.any)
        .afterThrow('error');
      expect(isJSONString('string')).assertFalse();
      mocker.clear(JSON);
    })

    it('StringUtilTest_getConversionOffsetForSession_PAGE_ONE', 0, () => {
      let result = stringUtil.getConversionOffsetForSession(1, 1, false, 0);
      expect(result).assertEqual(10);
    })

    it('StringUtilTest_getConversionOffsetForSession_PAGE_TWO', 0, () => {
      let result = stringUtil.getConversionOffsetForSession(2, -1, false, 0);
      expect(result).assertEqual(60);
    })

    it('StringUtilTest_getConversionOffsetForSession_PAGE_THERE', 0, () => {
      let result = stringUtil.getConversionOffsetForSession(3, 0, false, 0);
      expect(result).assertEqual(200);
    })

    it('StringUtilTest_isContain_true_one', 0, () => {
      expect(stringUtil.isContain('1234567','123')).assertTrue();
    })

    it('StringUtilTest_isContain_true_two', 0, () => {
      expect(stringUtil.isContain('123','12345678')).assertTrue();
    })

    it('StringUtilTest_isContain_false_one', 0, () => {
      expect(stringUtil.isContain('aaaaaa','12345678')).assertFalse();
    })

    it('StringUtilTest_isContain_false_two', 0, () => {
      expect(stringUtil.isContain('11111111','12345678')).assertFalse();
    })

    it('StringUtilTest_isContain_empty_one', 0, () => {
      expect(stringUtil.isContain('','12345678')).assertFalse();
    })

    it('StringUtilTest_isContain_empty_two', 0, () => {
      expect(stringUtil.isContain('1111','')).assertFalse();
    })
  })
}