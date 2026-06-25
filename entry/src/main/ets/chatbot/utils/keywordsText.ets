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
import HiLog from '../../utils/HiLog';
import { BusinessError } from '@kit.BasicServicesKit';

// instrument ignore file
@Builder
function keywordTextView(text: string, keywords: string[]) {
  ForEach(extractTextWithKeywords(text, keywords), (tvt: TextViewTag) => {
    Span(tvt.text)
      .fontColor(tvt.isHighlight ? $r('sys.color.font_emphasize') : $r('sys.color.font_secondary'))
  })
}


function extractTextWithKeywords(text: string, keywords: string[]): TextViewTag[] {
  if (!text) {
    HiLog.w('extractTextWithKeywords', `text empty`);
    return [];
  }
  try {
    if (keywords.length > 0 && keywords[0] === '') {
      return [new TextViewTag(text, false)]
    }
    // 将关键字数组转换为正则表达式字符串，使其不区分大小写
    const regexStr = keywords.map(keyword =>
    keyword.replace(/[A-Za-z]/g, (char) => `[${char}${char.toUpperCase()}]`)
    ).join('|');

    // 创建正则表达式，添加全局匹配（g）和不区分大小写（i）的标志
    const regex = new RegExp(regexStr, 'gi');
    // 用于存储结果的数组
    let result: TextViewTag[] = [];
    let lastMatchEnd = 0;

    // 执行匹配操作
    let match: RegExpExecArray | null;
    while ((match = regex.exec(text)) !== null) {
      // 如果当前匹配不是第一个匹配，且上一个匹配和当前匹配之间有文本，则添加这部分文本到结果中
      if (lastMatchEnd !== match.index) {
        result.push(new TextViewTag(text.substring(lastMatchEnd, match.index), false));
      }

      // 添加当前匹配的关键字到结果中
      result.push(new TextViewTag(match[0], true));

      // 更新上一个匹配结束的位置
      lastMatchEnd = regex.lastIndex;
    }

    // 如果最后一个匹配之后还有文本，则添加这部分文本到结果中
    if (lastMatchEnd < text.length) {
      result.push(new TextViewTag(text.substring(lastMatchEnd), false));
    }

    return result;
  } catch (e) {
    let error = e as BusinessError;
    HiLog.e('extractTextWithKeywords', `error ${error?.code} ${error?.message}`);
    return [];
  }
}

class TextViewTag {
 public text: string = ''
 public isHighlight: boolean = false

  constructor(text: string, isHighlight: boolean) {
    this.text = text
    this.isHighlight = isHighlight
  }
}

export { keywordTextView }
