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
import HashSet from '@ohos.util.HashSet'
import HiLog from './HiLog'

const TAG = 'URLRegexRecognizer'
export interface IEntity {
  name: string
  value: string
  index: number
  regex: string
}

export class RegexResultEntity implements IEntity {
  public name: string
  public value: string
  public index: number
  public regex: string

  constructor(name: string, value: string, index: number, regex: string) {
    this.name = name
    this.value = value
    this.index = index
    this.regex = regex
  }
}

export class RegexFilterResult {
  public res: IEntity[]
  public urlCache: HashSet<string>

  constructor() {
    this.res = []
    this.urlCache = new HashSet()
  }
}

export class URLRegexRecognizer {
  private urlCache: HashSet<string> = new HashSet();
  private maxMatchTimes = 5
  private nerType: string = 'UrlEntity'
  private regexString: string = '';
  public padString(padChar: string, size: number): string {
    /* ECMAScript 2017 will support this function
     * */
    let padStr: string = ''
    let beg = 0
    while (beg < size) {
      padStr += padChar
      beg += 1
    }
    return padStr
  }
  public recognize(content: string): Array<IEntity> {
    HiLog.i(TAG, 'recognize Start')
    let res: IEntity[] = []
    UrlBase.URL_REGEXES.forEach((urlRegExp: RegExp, regexIndex: number) => {
      let result = this.regexFilter(urlRegExp, regexIndex, content)
      result.res.forEach((value) => {
        res.push(value)
      })
      result.urlCache.forEach((value) => {
        this.urlCache.add(value);
      })
    })
    HiLog.i(TAG, 'recognize End Result Size: ' + res.length)
    return res
  }

  public mailRecognize(content: string): boolean {
    HiLog.i(TAG, 'mailRecognize Start')
    let isEmail: boolean = UrlBase.MAIL_REGEXES.test(content);
    HiLog.i(TAG, 'mailRecognize End isEmail : ' + isEmail);
    return isEmail;
  }

  regexFilter(urlRegExp: RegExp, regexIndex: number, content: string): RegexFilterResult {
    if (this.regexString === '') {
      let newContent = content.toString().trim();
      let regex = new RegExp('\\s', 'g');
      this.regexString = newContent.replace(regex, ',');
    }
    let isMatchUrl: boolean = false
    let result: RegexFilterResult = new RegexFilterResult()

    do {
      isMatchUrl = false
      let matchArray: string[] | null = this.regexString.match(urlRegExp);
      if (matchArray && matchArray.length >= 3) {
        let findIndex = content.indexOf(matchArray[2]);
        this.regexString = this.regexString.replace(matchArray[2], '');
        isMatchUrl = true;
        if (this.urlCache.has(matchArray[2]) || result.urlCache.has(matchArray[2])) {
          continue;
        }
        result.urlCache.add(matchArray[2]);
        result.res.push(new RegexResultEntity(
          this.nerType,
          matchArray[2],
          findIndex,
          regexIndex.toString())
        )
        if (this.regexString === '') {
          break;
        }
      }
    } while (isMatchUrl);
    return result
  }
}

export class UrlBase {
  private static readonly WEBSITE_SUFFIX: string = '(?:com|edu|gov|mil|net|org|biz|info|name|museum|us|ca|uk|cn|cc|tw|de|au|sg|hk|ei|fr|me|im)(?![a-z])';
  private static readonly IP: string = '(?:(?:1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|[1-9])(?:\\.(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)){3})';
  private static readonly PORT: string = '(?:\\d|[1-9]\\d{1,3}|[1-5]\\d{4}|6[0-4]\\d{3}|65[0-4]\\d{2}|655[0-2]\\d|6553[0-5])';
  /**
   * url规则集
   */
  public static readonly URL_REGEXES: Array<RegExp> = [
    new RegExp('^(?<urlStrIndex>.*?)(?<urlStr>ftps?[:：]//[a-z]\\w{2,}\\:\\w{3,}@' + UrlBase.IP + '\\:' + UrlBase.PORT + '(?:/\\w+)+).*$', 'i'),
    new RegExp('^(?<urlStrIndex>.*?)(?<urlStr>(?:ht|f)tps?[:：]//(?:[a-z0-9-]+\\.)+' + UrlBase.WEBSITE_SUFFIX + '(?:\\:[0-9][0-9]*)?(?:\\:[0-9][0-9]*)?(?:\\.?/(?:(?:[a-z0-9@！!.?' + '\'' + '\\|*:\\\\+&%$#=~_-]|//)*[a-z0-9&%$#=~_-])?)*).*$', 'i'),
    new RegExp('^(?<urlStrIndex>.*?)(?<urlStr>https?[:：]//[^/]+/svn(?:/[a-z0-9.?' + '\'' + '*:+&%$#=~_ \\u4E00-\\u9FA5-]*)*).*$', 'i'),
    new RegExp('^(?<urlStrIndex>.*?)(?<urlStr>(?:(?:ht|f)tps?[:：]//)?(?:[a-z0-9@-]+\\.)+' +
      UrlBase.WEBSITE_SUFFIX + '(?:\\:[0-9][0-9]*)?(?:\\.?/[a-z0-9.?' + '\'' + '\\|*:\\\\+&%$#=~_-]*)*).*$', 'i'),
    new RegExp('^(?<urlStrIndex>.*?)(?<urlStr>ftps?[:：]//' + UrlBase.IP + ').*$"=', 'i'),
    new RegExp('^(?<urlStrIndex>.*?)(?<urlStr>(?:ht|f)tps?[:：]//(?:[a-z0-9-]+\\.)*[a-z0-9-]+(?:/[a-z0-9]+)*[/a-z0-9.?' + '\'' + '\\|*:\\\\+&%$#=~_-]*).*$', 'i'),
    new RegExp('^(?<urlStrIndex>.*?)(?<urlStr>t\\.cn[0-9a-z]+).*$', 'i'),
    new RegExp('^(?<urlStrIndex>.*?)(?<urlStr>(?:https?[:：]//)?(?:[a-z0-9-\\\\]+\\.)+' + UrlBase.WEBSITE_SUFFIX + '(?:\\:\\d{4})?(?:/[a-z0-9.?' + '\'' + '\\|*:\\\\+&%$#=~_-]*)*\\?(?:[a-z0-9]*=[a-z0-9.?' + '\'' + '*:+%$#=~_\\u4E00-\\u9FA5-]*&?)*).*$', 'i'),
    new RegExp('^(?<urlStrIndex>.*?)(?:＞\\s*(?<urlStr>b23\\.tv\\/\\w+)\\s*).*$', 'i')
  ];

  /**
   * 邮箱规则集
   */
  public static readonly MAIL_REGEXES: RegExp = new RegExp('[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$$', 'i');
}


