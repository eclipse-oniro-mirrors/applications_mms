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
import { describe, expect, it, when } from '@ohos/hypium';
import ArgumentMatchers from '@ohos/hypium/src/main/module/mock/ArgumentMatchers';
import { MockKit } from '@ohos/hypium/src/main/module/mock/MockKit';
import { IEntity, RegexFilterResult, UrlBase, URLRegexRecognizer } from '../../../../main/ets/utils/URLRegexRecognizer';
import { HashSet } from '@kit.ArkTS';

export default function uRLRegexRecognizerTest() {
  describe('URLRegexRecognizerTest', () => {

    it('URLRegexRecognizerTest_padString', 0, () => {
      expect(new URLRegexRecognizer().padString('', 1)).assertEqual('');
    })

    it('URLRegexRecognizerTest_recognize', 0, () => {
      let hashSet =new HashSet<string>();
      hashSet.add('xx');
      let uRLRegexRecognizer: URLRegexRecognizer = new URLRegexRecognizer()
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(uRLRegexRecognizer, uRLRegexRecognizer.regexFilter))(ArgumentMatchers.any).afterReturn({
        res:[{
          name:'x',
          value:'x',
          index:0,
          regex:''
        } as  IEntity],
        urlCache:new HashSet<string>()
      } as RegexFilterResult);
      expect(uRLRegexRecognizer.recognize('').length).assertEqual(9);
      mocker.clear(uRLRegexRecognizer);
    })

    it('URLRegexRecognizerTest_regexFilter', 0, () => {
      let uRLRegexRecognizer: URLRegexRecognizer = new URLRegexRecognizer()
      uRLRegexRecognizer.regexFilter(new RegExp('[a-z]{3}','g'),0,'');
      (uRLRegexRecognizer as object)['urlCache'].add('aaa');
      let res = uRLRegexRecognizer.regexFilter(new RegExp('[a-z]{3}','g'),0,'xxx xxx aaa');
      expect(res).not().assertUndefined()
    })

    it('URLRegexRecognizerTest_URL_REGEXES',0,()=>{
      expect(UrlBase.URL_REGEXES.length).assertEqual(9);
    })
  })
}