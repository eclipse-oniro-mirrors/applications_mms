/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { convertxml } from '@kit.ArkTS';
import HiLog from './HiLog';

interface XmlNode {
  _type: string;
  _name?: string;
  _attributes?: Record<string, string>;
  _elements?: XmlNode[];
  _text?: string;
}

export interface FilePathOfSmilBody {
  name: string | undefined;
  src: string | undefined
}

const TAG = 'XmlUtil';

export class XmlUtil {
  /**
   * 将xml文本解析成对象
   * @param xml
   * @returns
   */
  public static convertToJSObject(xml: string) {
    let options: convertxml.ConvertOptions = {
      trim: false,
      declarationKey: '_declaration',
      instructionKey: '_instruction',
      attributesKey: '_attributes',
      textKey: '_text',
      cdataKey: '_cdata',
      doctypeKey: '_doctype',
      commentKey: '_comment',
      parentKey: '_parent',
      typeKey: '_type',
      nameKey: '_name',
      elementsKey: '_elements'
    };
    try {
      let conv: convertxml.ConvertXML = new convertxml.ConvertXML();
      let result: object = conv.fastConvertToJSObject(xml, options);
      return result as XmlNode;
    } catch (e) {
      HiLog.e(TAG, `convertToJSObject error: ${e?.code} ${e?.message}`);
    }
    return null;
  }

  /**
   * 从XmlNode对象获取head的metadata数据
   */
  public static getMetadataFromXmlNode = (xmlRoot: XmlNode): Map<string, string> | null => {
    if (!xmlRoot) {
      HiLog.e(TAG, `getMetadataFromXmlNode xmlRoot empty`);
      return null;
    }
    const map = new Map<string, string>();
    try {
      const findMetadata = (node: XmlNode) => {
        if (node._name === 'metadata' && node._attributes?.name) {
          const textNode = node._elements?.find(e => e._type === 'text');
          if (textNode?._text) {
            map.set(node._attributes.name, textNode._text);
          }
        }
      };
      const smil = xmlRoot._elements?.find(e => e._name === 'smil');
      if (!smil) {
        HiLog.e(TAG, `getMetadataFromXmlNode smil empty`);
        return null;
      }
      const head = smil._elements?.find(e => e._name === 'head');
      head?._elements?.forEach(findMetadata);
      return map;
    } catch (e) {
      HiLog.e(TAG, `getMetadataFromXmlNode error: ${e?.code} ${e?.message}`);
    }
    return null;
  }
  /**
   * 从XmlNode对象获取body的par的img标签数据
   * 用于解析接收消息的smil文件
   */
  public static getImgPathListFromXmlNode = (xmlRoot: XmlNode) => {
    if (!xmlRoot) {
      HiLog.e(TAG, 'getImgPathListFromXmlNode xmlRoot empty');
      return null;
    }
    let arr: FilePathOfSmilBody[][] = [];
    try {
      const tempFunc = (node: XmlNode) => {
        if (node._name === 'par') {
          let tempArray: FilePathOfSmilBody[] = [];
          node._elements?.forEach(v => {
            if (v && v._type === 'element' && v._name === 'img') { //img标签
              tempArray.push({
                'name': v._name,
                'src': v._attributes?.src,
              });
            }
          })
          if (tempArray.length > 0) {
            arr.push(tempArray);
          }
        }
      };
      const smil = xmlRoot._elements?.find(e => e._name === 'smil');
      if (!smil) {
        HiLog.e(TAG, `getImgPathListFromXmlNode smil empty`);
        return null;
      }
      const body = smil._elements?.find(e => e._name === 'body');
      body?._elements?.forEach(tempFunc);
      return arr;
    } catch (e) {
      HiLog.e(TAG, `getImgPathListFromXmlNode error: ${e?.code} ${e?.message}`);
    }
    return null;
  }
}

