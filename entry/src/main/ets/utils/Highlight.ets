/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import HiLog from './HiLog';
import StringUtil from './StringUtil';
import MeasureText from '@ohos.measure';
import commonData from '../data/commonData';
import common from '@ohos.app.ability.common';
import { GlobalContext } from '../MainAbility/GlobalHelper';

export interface HighlightsOptions {
  text: string,
  type: number
}

export enum HighlightType {
  normal,
  highlight
}

const splitLengthEn: number = 36;
const splitLengthCH: number = 18;
const dot: string = '...';
const TAG: string = 'Highlight';

export class Highlight {
  private static instance: Highlight;
  reg: RegExp = new RegExp('^[a-zA-Z_\\d]+$');

  static getInstance() {
    if (Highlight.instance == null) {
      Highlight.instance = new Highlight();
    }
    return Highlight.instance;
  }

  getHighlightTexts(text: string, search: string, isName?: boolean, addEllipsis?: boolean) {
    let highlights: Array<HighlightsOptions> = [];
    if (typeof text === 'number') {
      text = Number(text).toString();
    }
    let tempText = text.toString().toLowerCase();
    let tempSearch = search.toString().toLowerCase();
    if (text === '' || tempText.indexOf(tempSearch) < 0) {
      highlights.push({
        text: text,
        type: HighlightType.normal
      });
      return highlights;
    }
    let textString: string = tempText;
    if (addEllipsis) {
      textString = this.dealText(tempText, search, isName);
    }
    let splits = textString.split(tempSearch);
    let textLength = 0;
    splits.forEach((item, index) => {
      let lastHighlightData: HighlightsOptions = {text: '', type: -1};
      if (highlights.length !== 0) {
        lastHighlightData = highlights[highlights.length - 1];
      }
      if (item === '') {
        if (index !== splits.length - 1) {
          if (lastHighlightData && lastHighlightData.type === 1) {
            lastHighlightData.text = lastHighlightData.text +
              text.substring(textLength, textLength + search.length);
          } else {
            highlights.push({
              text: text.substring(textLength, textLength + search.length),
              type: HighlightType.highlight
            });
          }
          textLength = textLength + search.length;
        }
      } else {
        highlights.push({
          text: text.substring(textLength, textLength + item.length),
          type: HighlightType.normal
        });
        textLength = textLength + item.length;
        if (index < splits.length - 1) {
          highlights.push({
            text: text.substring(textLength, textLength + search.length),
            type: HighlightType.highlight });
          textLength = textLength + search.length;
        }
      }
    })
    return highlights;
  }

  dealText(str: string, search: string, isName?: boolean) {
    let text = str;
    let index = text.indexOf(search);
    if (isName && text.length >= splitLengthCH) {
      text = text.substring(0, splitLengthCH);
      text = text + dot;
    } else if (!isName) {
      let length = splitLengthCH;
      if (this.reg.test(text)) {
        length = splitLengthEn;
      }
      if (index >= length) {
        if ((text.length - index) > length) {
          let end = ((index + length) > text.length) ? text.length : index + length;
          text = text.substring(index, end);
          text = dot + text + dot;
        } else {
          text = text.substring(text.length - length, text.length);
          text = dot + text;
        }
      } else if (text.length >= length) {
        text = text.substring(0, length);
        text = text + dot;
      }
    }
    return text;
  }

  /**
   * Constructs highlights and ignores case.
   * The em tag is matched first. If failed, use hlText.
   *
   * @param text content
   * @param hlText The highlight text, if it's empty, match by tag: <em>.*</em>
   * @returns Highlights
   */
  buildHighlightsByEmTag(text: string, hlText: string): HighlightsOptions[] {
    // Replace invalids.
    text = text.replace(new RegExp('[\\r\\n\\s]', 'g'), '')
    // Match highlight and split normal.
    let hlRegExp: RegExp = new RegExp(`${commonData.STR.EM_TAG_START}.*?${commonData.STR.EM_TAG_END}`, 'ig');
    let normalStrings: string[] = text.split(hlRegExp);
    //正在里面+有特殊含义,如果要匹配+这个字符串需要转义
    // hlText = hlText.replace('+', `/\+`);
    hlText = hlText.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    // If tag matching fails.
    if (normalStrings.length === 1) {
      hlRegExp = new RegExp(hlText, 'ig');
      normalStrings = text.split(hlRegExp);
    }
    let highlightStrings: RegExpMatchArray | null = text.match(hlRegExp);
    // Preload match (Sometimes the match result is incorrect. After the preload, the result is correct.)
    JSON.stringify(highlightStrings);
    // Reassemble text.
    let highlights: HighlightsOptions[] = [];
    for (let i = 0; i < normalStrings.length; i++) {
      // Add normal item.
      let normal: string = normalStrings[i];
      if (!StringUtil.isEmpty(normal)) {
        highlights.push({
          text: normal,
          type: HighlightType.normal
        });
      }
      // Add highlight item.
      if (highlightStrings !== null && i < highlightStrings.length) {
        let highlight: string = highlightStrings[i];
        if (text.indexOf(highlight) === -1) {
          continue;
        }
        // Remove tag: <em> </em>
        if (highlight.indexOf(commonData.STR.EM_TAG_START) === 0 &&
          highlight.lastIndexOf(commonData.STR.EM_TAG_END) === highlight.length - 5) {
          highlight = highlight.replace(new RegExp(`${commonData.STR.EM_TAG_START}|${commonData.STR.EM_TAG_END}`, 'g'), '');
        }
        highlights.push({
          text: highlight,
          type: HighlightType.highlight
        });
      }
    }
    return highlights;
  }

  /**
   * Create highlights based on the Em tag and do not use the RegExp.
   * e.g.
   * '1234<em>56</em>78901' => [{"text":"1234","type":0},{"text":"56","type":1},{"text":"78901","type":0}]
   *
   * @param text content
   * @returns Highlights
   */
  public buildHighlightsByEmTagWithoutReg(text: string): HighlightsOptions[] {
    let highlights: HighlightsOptions[] = [];
    let lastIndex: number = 0;
    for (let i = 0; i < text.length; i++) {
      let char: string = text[i];
      if (char != '<') {
        continue;
      }
      let token: string | null = this.tryReadEmToken(text.substring(i));
      switch (token) {
        case commonData.STR.EM_TAG_START:
          highlights.push(this.newHighLight(text.substring(lastIndex, i), HighlightType.normal));
          lastIndex = i + commonData.STR.EM_TAG_START.length;
        break;
        case commonData.STR.EM_TAG_END:
          highlights.push(this.newHighLight(text.substring(lastIndex, i), HighlightType.highlight));
          lastIndex = i + commonData.STR.EM_TAG_END.length;
        break;
      }
    }
    highlights.push(this.newHighLight(text.substring(lastIndex, text.length), HighlightType.normal));
    return highlights;
  }

  /**
   * Build new HighlightsOptions
   *
   * @param text
   * @param type
   * @returns
   */
  public newHighLight(text: string, type: HighlightType): HighlightsOptions {
    return {
      text: text,
      type: type
    } as HighlightsOptions;
  }

  /**
   * Try read em tag.
   * @param str
   * @returns
   */
  private tryReadEmToken(str: string): string | null {
    if (str.indexOf(commonData.STR.EM_TAG_START) === 0) {
      return commonData.STR.EM_TAG_START;
    }
    if (str.indexOf(commonData.STR.EM_TAG_END) === 0) {
      return commonData.STR.EM_TAG_END;
    }
    return null;
  }


  /**
   * Add Em Tags to highlights.
   *
   * @param text The content text
   * @param key The highlight key
   * @returns
   */
  public addEmTags(text: string, key: string): string {
    key = key.replace(new RegExp('[\\s]', 'g'), '');
    text = text.replace(new RegExp('[\\s]', 'g'), '');
    let emKey: string = commonData.STR.EM_TAG_START + key + commonData.STR.EM_TAG_END;
    /*
    * 当搜索关键字是大写时，匹配文字中含有小写，也应该高亮
    * 相反，搜索关键字是小写时，匹配文字中含有大写，也应该高亮
    */
    let emKeyUpper: string = commonData.STR.EM_TAG_START + key.toUpperCase() + commonData.STR.EM_TAG_END;
    let emKeyLower: string = commonData.STR.EM_TAG_START + key.toLowerCase() + commonData.STR.EM_TAG_END;
    text = text.replace(new RegExp(key, 'g'), emKey);
    text = text.replace(new RegExp(key.toUpperCase(), 'g'), emKeyUpper);
    text = text.replace(new RegExp(key.toLowerCase(), 'g'), emKeyLower);
    return text;
  }

  /**
   * 按文字大小和控件宽度裁切内容，以确保高亮内容在中间
   *
   * @param highlights
   * @param fontSizeFp
   * @param maxWidthVp
   * @returns
   */
  public highlightTextCrop(highlights: HighlightsOptions[], fontSizeFp: number, maxWidthVp: number): HighlightsOptions[] {
    let startTime: number = Date.now();
    // 前置计算Part1：控件最大宽度Px、拼接成的完整字串、完整字串的显示宽度Px
    const textMaxWidthPx: number = vp2px(Math.floor(maxWidthVp));
    const fullText: string = highlights.map(item => item.text).join('');
    const fullTextWidthPx: number = MeasureText.measureText({ textContent: fullText, fontSize: fontSizeFp });
    if (fullTextWidthPx < textMaxWidthPx) {
      // Text控件宽度足够显示下所有的内容
      return highlights;
    }
    // 前置计算Part2：首个高亮部分的Index、从高亮部分开始的所有内容、从高亮部分开始的所有内容的显示宽度Px
    let firstLightItemIndex: number = highlights.findIndex(item => item.type === HighlightType.highlight);
    firstLightItemIndex = firstLightItemIndex < 0 ? 0 : firstLightItemIndex;
    let lightStartText: string = highlights.slice(firstLightItemIndex).map(item => item.text).join('');
    lightStartText = firstLightItemIndex !== 0 ? (commonData.STR.ELLIPSIS_STR + lightStartText) : lightStartText;
    let lightStartTextWidthPx: number = MeasureText.measureText({ textContent: lightStartText, fontSize: fontSizeFp });
    /**
     * 计算出合适的Index，以该Index裁切字符串能保证高亮内容显示效果符合设计需求：
     *  高亮部分在头部：从前往后计算Index，头部不显示省略号，尾部显示省略号 (abc…)
     *  高亮部分在尾部：从后往前计算Index，尾部不显示省略号，头部显示省略号 (…xyz)
     *  高亮部分在中间：头部显示省略号，尾部显示省略号 (…abc…)
     */
    let startIndex: number;
    let endIndex: number;
    if (firstLightItemIndex === 0) {
      //  情况1：高亮部分在头部
      const ellipsisLightStartText: string = StringUtil.buildEllipsis(lightStartText, fontSizeFp, maxWidthVp);
      const contentFromLight: string = ellipsisLightStartText.replace(new RegExp(commonData.STR.ELLIPSIS_STR, 'g'), '');
      startIndex = 0;
      endIndex = contentFromLight.length;
    } else if (lightStartTextWidthPx <= textMaxWidthPx) {
      // 情况2：高亮部分在尾部
      let ellipsisStartText: string = StringUtil.buildEllipsis(fullText, fontSizeFp, maxWidthVp, false);
      let maxCharCount: number = ellipsisStartText.length - 1;
      startIndex = fullText.length - maxCharCount;
      endIndex = fullText.length;
    } else {
      // 情况3：高亮部分在中间；特殊条件下，当前情况也可变成 => 情况1：高亮部分在头部
      const ellipsisLightStartText: string = StringUtil.buildEllipsis(lightStartText, fontSizeFp, maxWidthVp);
      const contentFromLight: string = ellipsisLightStartText.replace(new RegExp(commonData.STR.ELLIPSIS_STR, 'g'), '');
      let roughMaxContentLen: number = contentFromLight.length;
      let indexes: number[] = this.moveHighlightToCenter(highlights, fullText, roughMaxContentLen, textMaxWidthPx, fontSizeFp);
      startIndex = indexes[0];
      endIndex = indexes[1];
    }
    // 按 startIndex 和 endIndex 裁切高亮内容
    let texts: HighlightsOptions[] = this.cutHighlightsByIndex(highlights, startIndex, endIndex);
    return texts;
  }

  /**
   * 计算出将高亮部分移动到中间时的左右Index
   *
   * @param highlights 具有高亮内容的数组
   * @param fullText 将highlights拼接起来的完整字串
   * @param roughMaxContentLen 粗略的，最大内容的长度 （最大内容长度随计算会变动，这只是个粗略的长度）
   * @param textMaxWidthPx Text控件最大显示宽度
   * @param fontSizeFp Text控件字体大小
   * @returns
   */
  public moveHighlightToCenter(highlights: HighlightsOptions[], fullText: string,
                               roughMaxContentLen: number, textMaxWidthPx: number, fontSizeFp: number,): number[] {
    let leftLightIndex: number = -1;
    let rightLightIndex: number = -1;
    let textSumLength: number = 0;
    // For循环遍历 ，计算总长度，并依情况计算出能显示出来的高亮部分的最左边Index和最右边Index
    for (let i = 0; i < highlights.length; i++) {
      let item: HighlightsOptions = highlights[i];
      if (item.type === HighlightType.highlight && leftLightIndex < 0) {
        leftLightIndex = textSumLength;
      }
      textSumLength += item.text.length;
      // 如果遇到高亮的部分，需要计算并保存下高亮部分最右边的index
      if (item.type === HighlightType.highlight) {
        if (textSumLength <= leftLightIndex + roughMaxContentLen) {
          rightLightIndex = textSumLength - 1;
        } else if (textSumLength - item.text.length <= leftLightIndex + roughMaxContentLen) {
          rightLightIndex = leftLightIndex + roughMaxContentLen - 1;
        }
      }
      if (textSumLength <= leftLightIndex + roughMaxContentLen && item.type === HighlightType.highlight) {
        // 高亮部分右边在全部内容中的Index
        rightLightIndex = textSumLength - 1;
      }
    }
    // 高亮部分在显示区域中的左右距离
    let leftSpaceToLight: number = 0;
    let rightSpaceToLight: number = MeasureText.measureText({
      textContent: fullText.substring(rightLightIndex + 1, leftLightIndex + roughMaxContentLen),
      fontSize: fontSizeFp
    });
    HiLog.i(TAG, 'Highlight#highlightTextCrop;LeftSpace: ' + leftSpaceToLight + ', RightSpace: ' + rightSpaceToLight);
    // 记录截取内容的左边Index和右边Index
    let leftCutIndex: number = leftLightIndex;
    let rightCutIndex: number = leftLightIndex + roughMaxContentLen;
    // 上一次的截取Index
    let preLeftCutIndex: number = leftCutIndex;
    let preRightCutIndex: number = rightCutIndex;
    const ellipsisWidth: number = MeasureText.measureText({ textContent: commonData.STR.ELLIPSIS_STR, fontSize: fontSizeFp });
    let cutContentMaxWidth: number = textMaxWidthPx - ellipsisWidth * 2;
    // 开始循环，直到 高亮内容左边的文字的长度>=高亮内容右边的文字长度 为止
    while (leftSpaceToLight < rightSpaceToLight) {
      // Save preIndex
      preLeftCutIndex = leftCutIndex;
      preRightCutIndex = rightCutIndex;
      if (preLeftCutIndex === 0) {
        break;
      }
      // Left index --, 从左边扩张内容
      leftCutIndex --;
      leftSpaceToLight = MeasureText.measureText({
        textContent: fullText.substring(leftCutIndex, leftLightIndex),
        fontSize: fontSizeFp
      });
      // 开始计算高亮内容到最右边的距离：先确定rightIndex，然后计算当前内容的宽度，然后逐步减少rightIndex，直到内容能完全显示
      let cutContentWidth: number = MeasureText.measureText({
        textContent: fullText.substring(leftCutIndex, rightCutIndex),
        fontSize: fontSizeFp
      });
      if (leftCutIndex === 0) {
        // 由情况3变成了情况1：高亮部分在头部；重新计算除去省略号后最大内容的显示宽度，因为此时只有右边有显示省略号了
        cutContentMaxWidth = textMaxWidthPx - ellipsisWidth;
        // 因为内容最大显示宽度增大了，所以需要向右扩张裁切区域，以增加显示内容
        while (cutContentWidth < cutContentMaxWidth) {
          rightCutIndex ++;
          cutContentWidth = MeasureText.measureText({
            textContent: fullText.substring(leftCutIndex, rightCutIndex),
            fontSize: fontSizeFp
          });
        }
      }
      // 左边裁切的Index减少了，显示内容增加了，所以需要再调整下右边的Index，确保显示内容的宽度不超过最大内容显示区域
      while (cutContentWidth > cutContentMaxWidth) {
        rightCutIndex --;
        cutContentWidth = MeasureText.measureText({
          textContent: fullText.substring(leftCutIndex, rightCutIndex),
          fontSize: fontSizeFp
        });
      }
      // 计算出右边的Index后，才能计算出高亮内容到最右边的距离
      rightSpaceToLight = MeasureText.measureText({
        textContent: fullText.substring(rightLightIndex + 1, rightCutIndex),
        fontSize: fontSizeFp
      });
    }
    // 循环退出时，已经是左边的长度大于右边的长度了，我们偏好的是左边长度小于右边长度，即选用上一次的裁切Index
    return [preLeftCutIndex, preRightCutIndex];
  }

  /**
   * 按照Index裁切HighLights（被裁切的部分以省略号代替）
   *
   * @param highlights 包含高亮的内容
   * @param startIndex 起始Index
   * @param endIndex 结束Index（不包含）
   * @returns
   */
  public cutHighlightsByIndex(highlights: HighlightsOptions[], startIndex: number, endIndex: number): HighlightsOptions[] {
    let textSumLength: number = 0;
    let texts: HighlightsOptions[] = [];
    for (let i = 0; i < highlights.length; i++) {
      let item: HighlightsOptions = highlights[i];
      textSumLength += item.text.length;
      if (textSumLength <= startIndex) {
        continue;
      }
      // 如果startIndex > 0，裁切字串之前存在省略的内容，需要添加省略号
      if (texts.length === 0 && startIndex > 0) {
        let ellipsisItem: HighlightsOptions = {
          text: commonData.STR.ELLIPSIS_STR,
          type: HighlightType.normal
        };
        texts.push(ellipsisItem);
        item = {
          text: item.text.substring(item.text.length - (textSumLength - startIndex), item.text.length),
          type: item.type
        };
      }
      let remainSpace: number = (endIndex - startIndex) - (textSumLength - startIndex);
      // 如果当前已添加的字符超出了 endIndex - startIndex
      if (remainSpace < 0) {
        let cutItem: HighlightsOptions = {
          text: item.text.substring(0, item.text.length + remainSpace) + commonData.STR.ELLIPSIS_STR,
          type: item.type
        }
        texts.push(cutItem);
        break;
      } else {
        // 如果还有剩余空间，直接将当前Item添加到结果列表中
        texts.push(item);
      }
    }
    return texts;
  }

  /**
   * Convert resource string to highlights.
   *
   * @param fullRes
   * @param hlRes
   * @returns
   */
  public resourceStrToHighlight(fullRes: Resource, ...hlRes: Resource[]): HighlightsOptions[] {
    HiLog.d(TAG, 'Highlight#resourceStrToHighlight start.')
    let context: common.UIAbilityContext = (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);
    let fullText: string = context.resourceManager.getStringSync(fullRes.id);
    let hlTexts: string[] = hlRes.map((res) => {
      return context.resourceManager.getStringSync(res.id);
    })
    let hlTextMap: Map<string, string> = new Map();
    for (let i = 0; i < hlTexts.length; i++) {
      hlTextMap.set(hlTexts[i], `%${i + 1}$s`);
    }
    hlTexts.sort((s1: string, s2: string) => {
      return fullText.indexOf(hlTextMap[s1]) - fullText.indexOf(hlTextMap[s2]);
    })
    let normalTexts: string[] = fullText.split(new RegExp('%[0-9]+\\$s', 'g'));
    let hlResultSet: HighlightsOptions[] = [];
    for (let i = 0; i < Math.max(normalTexts.length, hlTexts.length); i++) {
      if (i < normalTexts.length) {
        let text: string = normalTexts[i];
        if (!StringUtil.isEmpty(text)) {
          let normalItem: HighlightsOptions = {
            text: text,
            type: HighlightType.normal
          };
          hlResultSet.push(normalItem);
        }
      }
      if (i < hlTexts.length) {
        let text: string = hlTexts[i];
        if (!StringUtil.isEmpty(text)) {
          let highlightItem: HighlightsOptions = {
            text: text,
            type: HighlightType.highlight
          };
          hlResultSet.push(highlightItem);
        }
      }
    }
    HiLog.d(TAG, 'Highlight#resourceStrToHighlight success.')
    return hlResultSet;
  }

}