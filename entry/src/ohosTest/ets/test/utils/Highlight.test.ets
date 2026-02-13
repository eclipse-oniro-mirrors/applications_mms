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
import {
  describe,
  beforeEach,
  it,
  expect,
  MockKit,
  ArgumentMatchers,
  when
} from '@ohos/hypium'
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper'
import { Highlight, HighlightsOptions, HighlightType } from '../../../../main/ets/utils/Highlight'
import { MeasureText, window } from '@kit.ArkUI'
import { resourceManager } from '@kit.LocalizationKit'

export default function highlightTest() {
  describe('HighlightTest', () => {
    let highLight: Highlight;

    beforeEach(() => {
      highLight = Highlight.getInstance()
    })

    it('HighlightTest_getHighlightTexts', 0, () => {
      let array = highLight.getHighlightTexts('', '')
      let highlights: Array<HighlightsOptions> = [{
        text: '', type: 0
      }];
      expect(JSON.stringify(array)).assertEqual(JSON.stringify(highlights))
    })

    it('HighlightTest_getHighlightTexts_xx', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(highLight, highLight.dealText))(ArgumentMatchers.any)
        .afterReturn('570977632xx ');
      let array = highLight.getHighlightTexts('xxxxxx', 'xx', true);
      expect(array.length).assertEqual(1);
      mocker.clear(highLight);
    })

    it('HighlightTest_dealText_isName_false_en', 0, () => {
      let result = highLight.dealText('dfgf', 'aaaaa', false);
      expect(result).assertEqual('dfgf');

      let str = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabaaaaaaaaaaaaa';
      let str1 = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab';
      let result1 = highLight.dealText(str, 'aaaaa', false);
      expect(result1).assertEqual('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa...');
      let result2 = highLight.dealText(str, str1, false);
      expect(result2).assertEqual('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa...');
    })

    it('HighlightTest_dealText_isName_false_ch', 0, () => {
      let result = highLight.dealText('测试', 'aaaaa', false);
      expect(result).assertEqual('测试');
    })

    it('HighlightTest_dealText_isName_true', 0, () => {
      let result = highLight.dealText('搜索测试的数据搜索测试的数据搜索测试的数据', '', true)
      expect(result).assertEqual('搜索测试的数据搜索测试的数据搜索测试...');
    })

    it('HighlightTest_dealText_isName_true_length_2', 0, () => {
      let result = highLight.dealText('test', '', true)
      expect(result).assertEqual('test');
    })

    it('HighlightTest_dealText_isNameFalse', 0, () => {
      let result =
        highLight.dealText('可发送图片语音文件等多种富媒体信息沟通更便捷搜索测试的数据搜索测试的数据搜索测试的数据',
          '搜索测试的数据搜索测试的数据搜索测试的数据', false)
      expect(result).assertEqual('...搜索测试的数据搜索测试的数据搜索测试...');
    })

    it('HighlightTest_dealText_isNameFalse_ch', 0, () => {
      let result = highLight.dealText('可发送图片语音文件等多种富媒体信息沟通更便捷搜索测试的数据搜',
        '搜索测试的数据搜索测试的数据搜索测试的数据', false);
      expect(result).assertEqual('可发送图片语音文件等多种富媒体信息沟...');
    })

    it('HighlightTest_dealText', 0, () => {
      let result = highLight.dealText('dt test sms by roxy who is from warsaw research center',
        'center', false);
      expect(result).assertEqual('...aw research center');
    })

    it('HighlightTest_buildHighlightsByEmTag', 0, () => {
      expect(highLight.addEmTags('abc111', '111')).assertEqual('abc<em><em><em>111</em></em></em>');
      expect(highLight.buildHighlightsByEmTag('abc<em>111</em>', '111').length).assertEqual(2);
      expect(highLight.buildHighlightsByEmTag('abc<em>111</em><em></em>', '111').length).assertEqual(3);
      expect(highLight.buildHighlightsByEmTag('abc', '111').length).assertEqual(1);
      expect(highLight.buildHighlightsByEmTagWithoutReg('abc<em>111</em>').length > 0).assertEqual(true);
    })

    it('HighlightTest_buildHighlightsByEmTagWithoutReg', 0, () => {
      expect(highLight.buildHighlightsByEmTagWithoutReg('abc<em>111</em>').length).assertEqual(3);
    })

    it('HighlightTest_addEmTags', 0, () => {
      expect(highLight.addEmTags('xx', 'xx')).assertEqual('<em><em>xx</em></em>');
    })

    it('HighlightTest_highlightTextCrop', 0, () => {
      let hlTexts: HighlightsOptions[] = [
        {
          text: 'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz',
          type: HighlightType.normal
        }
      ];
      expect(highLight.highlightTextCrop(hlTexts, 14, 339.6923076923077)[0].text)
        .assertContain('abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrs');
    })

    it('HighlightTest_highlightTextCrop_fullTextWidthPx_lessThan_textMaxWidthPx', 0, () => {
      let hlTexts: HighlightsOptions[] = [
        {
          text: 'abc',
          type: HighlightType.normal
        }
      ];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(MeasureText, MeasureText.measureText))(ArgumentMatchers.any)
        .afterReturn(1100);
      expect(highLight.highlightTextCrop(hlTexts, 14, 339.6923076923077)[0].text)
        .assertEqual('abc');
      mocker.clear(MeasureText);
    })

    it('HighlightTest_highlightTextCrop_highlight_normal', 0, () => {
      let hlTexts: HighlightsOptions[] = [
        {
          text: 'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz',
          type: HighlightType.normal
        }
      ];
      expect(highLight.highlightTextCrop(hlTexts, 14, 339.6923076923077)[0].text)
        .assertContain('abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrs');
    })

    it('HighlightTest_highlightTextCrop_highlight_highlight', 0, () => {
      let hlTexts: HighlightsOptions[] = [
        {
          text: 'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz',
          type: HighlightType.normal
        }, {
        text: 'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz',
        type: HighlightType.highlight
      }
      ];
      expect(highLight.highlightTextCrop(hlTexts, 14, 339.6923076923077)[0].text)
        .assertEqual('…');
    })

    it('HighlightTest_moveHighlightToCenter', 0, () => {
      expect(highLight.moveHighlightToCenter([], '', 0, 0, 0).length)
        .assertEqual(2);
    })

    it('HighlightTest_moveHighlightToCenter1', 0, () => {
      let hlTexts: HighlightsOptions[] = [
        {
          text: 'abc',
          type: HighlightType.normal
        }, {
        text: 'abc',
        type: HighlightType.highlight
      }];
      expect(highLight.moveHighlightToCenter(hlTexts, '', 0, 200, 0).length)
        .assertEqual(2);
    })

    it('HighlightTest_moveHighlightToCenter2', 0, () => {
      let hlTexts: HighlightsOptions[] = [
        {
          text: 'abc',
          type: HighlightType.normal
        }, {
        text: 'abc',
        type: HighlightType.highlight
      }];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(MeasureText, MeasureText.measureText))(ArgumentMatchers.any)
        .afterReturn(10);
      expect(highLight.moveHighlightToCenter(hlTexts, '', 10, 200, 0).length)
        .assertEqual(2);
      mocker.clear(MeasureText);
    })

    it('HighlightTest_cutHighlightsByIndex', 0, () => {
      let hlTexts: HighlightsOptions[] = [
        {
          text: 'abc',
          type: HighlightType.normal
        }, {
        text: 'abc',
        type: HighlightType.highlight
      }];
      expect(highLight.cutHighlightsByIndex(hlTexts, 0, 0).length)
        .assertEqual(1);
    })

    it('HighlightTest_cutHighlightsByIndex_remainSpace_gt_0', 0, () => {
      let hlTexts: HighlightsOptions[] = [
        {
          text: 'abc',
          type: HighlightType.normal
        }, {
        text: 'abcd',
        type: HighlightType.highlight
      }, {
        text: 'cutHighlightsByIndex',
        type: HighlightType.highlight
      }];
      expect(highLight.cutHighlightsByIndex(hlTexts, 1, 5).length)
        .assertEqual(3);
    })

    it('HighlightTest_resourceStrToHighlight', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          resourceManager: {
            getStringSync: (resId: number): string => '5709876543'
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);
      let highlightsOption: HighlightsOptions[] = highLight.resourceStrToHighlight({
        bundleName: '', moduleName: '', id: 0
      } as Resource);
      expect(highlightsOption.length).assertLarger(0);
      mocker.clear(GlobalContext.getContext());
    })

    it('HighlightTest_resourceStrToHighlight_2', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          resourceManager: {
            getStringSync: (resId: number): string => {
              if (resId === 0) {
                return 'abc%1$sefg';
              } else if (resId === 1) {
                return 'abc'
              } else if (resId === 2) {
                return 'efg'
              } else {
                return 'ddd'
              }
            }
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);
      let highlightsOption: HighlightsOptions[] = highLight.resourceStrToHighlight({
        bundleName: '', moduleName: '', id: 0
      } as Resource,{
        bundleName: '', moduleName: '', id: 1
      } as Resource,{
        bundleName: '', moduleName: '', id: 2
      } as Resource,{
        bundleName: '', moduleName: '', id: 3
      } as Resource);
      expect(highlightsOption.length).assertLarger(0);
      mocker.clear(GlobalContext.getContext());
    })

    it('HighlightTest_resourceStrToHighlight_1', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          resourceManager: {
            getStringSync: (resId: number): string => {
              if (resId === 0) {
                return 'abc%1$sefg%2$s%3$sQQQ';
              } else if (resId === 1) {
                return 'abc'
              } else if (resId === 2) {
                return 'efg'
              } else {
                return ''
              }
            }
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);
      let highlightsOption: HighlightsOptions[] = highLight.resourceStrToHighlight({
        bundleName: '', moduleName: '', id: 0
      } as Resource,{
        bundleName: '', moduleName: '', id: 1
      } as Resource,{
        bundleName: '', moduleName: '', id: 2
      } as Resource,{
        bundleName: '', moduleName: '', id: 3
      } as Resource);
      expect(highlightsOption.length).assertLarger(0);
      mocker.clear(GlobalContext.getContext());
    })

    it('HighlightTest_getHighlightTexts_addEllipsis', 0, () => {
      let array = highLight.getHighlightTexts('dfgf', 'aaaaa', false, true)
      let action = [{
        text: 'dfgf',
        type: 0
      } as HighlightsOptions]
      expect(JSON.stringify(array)).assertEqual(JSON.stringify(action))
    })

    it('HighlightTest_getHighlightTexts_addEllipsis_search', 0, () => {
      let array = highLight.getHighlightTexts('aaa', '', false, true)
      let action = [{
        text: 'a',
        type: 0
      } as HighlightsOptions, {
        text: '',
        type: 1
      } as HighlightsOptions, {
        text: 'a',
        type: 0
      } as HighlightsOptions, {
        text: '',
        type: 1
      } as HighlightsOptions, {
        text: 'a',
        type: 0
      } as HighlightsOptions]
      expect(JSON.stringify(array)).assertEqual(JSON.stringify(action))
    })

    it('HighlightTest_tryReadEmToken', 0, () => {
      let res: string | null = (highLight as object)['tryReadEmToken']('<>');
      expect(res).assertEqual(null);
    })
  })
}