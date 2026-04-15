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

import commonData from '../data/commonData';
import HiLog from './HiLog';
import MmsUtil, { getMmsMapTextSource } from './MmsUtil';
import { Mms, Region } from './TypesUtils';
import util from '@ohos.util';
import lazy xml from '@ohos.xml';
import StringUtil from './StringUtil';
import FileUtil from './FileUtil';
import HashMap from '@ohos.util.HashMap';
import Constant from '../data/Constant';

const TAG = 'SmilFile ';

class SmilFile {

  private static readonly TAG_SMIL: string = 'smil';
  private static readonly TAG_SMIL_HEAD: string = 'head';
  private static readonly TAG_SMIL_HEAD_LAYOUT: string = 'layout';
  private static readonly TAG_SMIL_HEAD_LAYOUT_ROOT: string = 'root-layout';
  private static readonly TAG_SMIL_HEAD_LAYOUT_REGION: string = 'region';
  private static readonly TAG_SMIL_BODY: string = 'body';
  private static readonly TAG_SMIL_BODY_PAR: string = 'par';
  // Region attrs
  private static readonly ATTR_REGION_FIT: string = 'fit';
  private static readonly ATTR_REGION_WIDTH: string = 'width';
  private static readonly ATTR_REGION_HEIGHT: string = 'height';
  private static readonly ATTR_REGION_ID: string = 'id';
  private static readonly ATTR_REGION_LEFT: string = 'left';
  private static readonly ATTR_REGION_TOP: string = 'top';
  // Par attrs
  private static readonly ATTR_PAR_DUR: string = 'dur';
  // Common attrs for (text, img, audio, video, ref)
  private static readonly ATTR_COMMON_REGION: string = 'region';
  private static readonly ATTR_COMMON_SRC: string = 'src';
  private static readonly ATTR_COMMON_DUR: string = 'dur';

  /**
   * Build smil file
   *
   * @param mmsArray
   */
  public buildSmilFile(mmsArray: Mms[]): string {
    // verify mms order
    let hasPageNum: boolean = mmsArray.some((mms) => {
      return mms.pageNum;
    });
    // If there is no valid page number
    if (!hasPageNum) {
      mmsArray = this.handleHasNoPageNum(mmsArray);
    }
    // all region ids
    let regionIds: string[] = mmsArray.map((mms: Mms) => {
      return this.mmsTypeToRegionId(mms.type);
    }).filter((v) => {
      return !StringUtil.isEmpty(v);
    });
    regionIds = Array.from(new Set(regionIds));
    // all pars
    let pars: Par[] = [];
    for (let i = 0; i < mmsArray.length; i++) {
      // build parItem
      let mms: Mms = mmsArray[i];
      let parItem: ParItem = this.mmsToParItem(mms);
      // Find the par of the specified page.
      let par: Par | undefined = pars.find((p: Par) => {
        return p.num === (mms.pageNum ?? 1);
      });
      if (par) {
        // If par exists, add it.
        par.items.push(parItem);
        let durs: number[] = par.items.map((item: ParItem) => {
          return item.dur;
        })
        par.dur = Math.max(...durs) ?? 0;
      } else {
        // Otherwise, save it after creation.
        pars.push({
          // Page numbers start from 1
          num: mms.pageNum ?? 1,
          dur: parItem.dur,
          items: [parItem]
        });
      }
    }
    pars.sort((p1: Par, p2: Par) => {
      return p1.num - p2.num;
    })
    // build Smil.xml
    let arrayBuffer: ArrayBuffer = this.buildSmilXml(regionIds, pars);
    // generate xml
    let textDecoder: util.TextDecoder = util.TextDecoder.create();
    let smilXml: string = textDecoder.decodeWithStream(new Uint8Array(arrayBuffer));
    return smilXml;
  }

  private buildSmilXml(regionIds: string[], pars: Par[]) {
    let arrayBuffer: ArrayBuffer = new ArrayBuffer(2048);
    let serializer: xml.XmlSerializer = new xml.XmlSerializer(arrayBuffer);
    // <smil>
    serializer.startElement(SmilFile.TAG_SMIL);
    // <head>
    serializer.startElement(SmilFile.TAG_SMIL_HEAD);
    // <layout>
    serializer.startElement(SmilFile.TAG_SMIL_HEAD_LAYOUT);
    // <root-layout>
    serializer.addEmptyElement(SmilFile.TAG_SMIL_HEAD_LAYOUT_ROOT);
    // <region fit="meet" height="100%" id="Image" left="0" top="0" width="100%">
    for (let i = 0; i < regionIds.length; i++) {
      let id: string = regionIds[i];
      serializer.startElement(SmilFile.TAG_SMIL_HEAD_LAYOUT_REGION);
      serializer.setAttributes(SmilFile.ATTR_REGION_FIT, 'meet');
      serializer.setAttributes(SmilFile.ATTR_REGION_WIDTH, '100%');
      serializer.setAttributes(SmilFile.ATTR_REGION_HEIGHT, '100%');
      serializer.setAttributes(SmilFile.ATTR_REGION_LEFT, '0');
      serializer.setAttributes(SmilFile.ATTR_REGION_TOP, '0');
      serializer.setAttributes(SmilFile.ATTR_REGION_ID, id);
      // </region>
      serializer.endElement();
    }
    // </layout>
    serializer.endElement();
    // </head>
    serializer.endElement();
    // <body>
    serializer.startElement(SmilFile.TAG_SMIL_BODY);
    // <par dur="5000ms">
    for (let i = 0; i < pars.length; i++) {
      let par: Par = pars[i];
      serializer.startElement(SmilFile.TAG_SMIL_BODY_PAR);
      serializer.setAttributes(SmilFile.ATTR_PAR_DUR, `${par.dur}ms`);
      // Make sure Text is at the end
      par.items.sort((a: ParItem, b: ParItem) => {
        let aScore: number = a.type === 'text' ? 1 : -1;
        let bScore: number = b.type === 'text' ? 1 : -1;
        return aScore - bScore;
      });
      for (let j = 0; j < par.items.length; j++) {
        let parItem: ParItem = par.items[j];
        // <text, img, audio, video, ref>
        serializer.startElement(parItem.type);
        serializer.setAttributes(SmilFile.ATTR_COMMON_SRC, parItem.src);
        if (parItem.dur > 0) {
          serializer.setAttributes(SmilFile.ATTR_COMMON_DUR, `${parItem.dur}ms`);
        }
        if (!StringUtil.isEmpty(parItem.region)) {
          serializer.setAttributes(SmilFile.ATTR_COMMON_REGION, parItem.region);
        }
        // </text, img, audio, video, ref>
        serializer.endElement();
      }
      // </par>
      serializer.endElement();
    }
    // </body>
    serializer.endElement();
    // </smil>
    serializer.endElement();
    return arrayBuffer;
  }

  private handleHasNoPageNum(mmsArray: Mms[]) {
    let texts: Mms[] = mmsArray.filter((m) => {
      return MmsUtil.isText(m.type);
    });
    let notTexts: Mms[] = mmsArray.filter((m) => {
      return !MmsUtil.isText(m.type);
    });
    let newMmsArr: Mms[] = [];
    for (let i = 0; i < Math.max(texts.length, notTexts.length); i++) {
      let notTextItem: Mms | undefined = notTexts[i];
      let textItem: Mms | undefined = texts[i];
      if (notTextItem) {
        notTextItem.pageNum = i + 1;
        newMmsArr.push(notTextItem);
      }
      if (textItem) {
        textItem.pageNum = i + 1;
        newMmsArr.push(textItem);
      }
    }
    return newMmsArr;
  }

  /**
   * mmsType map to smil par item type.
   *
   * @param mmsType
   * @returns
   */
  private mmsTypeToParItemType(mmsType: number): PartItemType {
    switch (mmsType) {
      case commonData.MM_ATTACHMENT_TYPE.IMAGE:
        return 'img';
      case commonData.MM_ATTACHMENT_TYPE.VIDEO:
        return 'video';
      case commonData.MM_ATTACHMENT_TYPE.AUDIO:
        return 'audio'
      case commonData.MM_ATTACHMENT_TYPE.VCARD:
        return 'ref';
      case commonData.MM_ATTACHMENT_TYPE.TEXT:
        return 'text';
      case commonData.MM_ATTACHMENT_TYPE.SMIL:
      case commonData.MM_ATTACHMENT_TYPE.THEME:
      case commonData.MM_ATTACHMENT_TYPE.SLIDE:
      default:
        return 'text';
    }
  }

  /**
   * mmsType map to regionId
   *
   * @param mmsType
   * @returns
   */
  private mmsTypeToRegionId(mmsType: number): string {
    let parItemType: PartItemType = this.mmsTypeToParItemType(mmsType);
    switch (parItemType) {
      case 'img':
      case 'video':
        return 'Image';
      case 'text':
        return 'Text';
      case 'audio':
      case 'ref':
      default:
        return '';
    }
  }

  /**
   * Convert mms to par item
   *
   * @param mms
   * @returns
   */
  private mmsToParItem(mms: Mms): ParItem {
    return {
      type: this.mmsTypeToParItemType(mms.type),
      dur: this.getDurationTime(mms.duration),
      src: mms.name,
      region: this.mmsTypeToRegionId(mms.type)
    }
  }

  /**
   * Convert durationStr to durationNum
   *
   * @param durStr eg. '00:01' or '1000ms'
   * @returns
   */
  public getDurationTime(durStr: string): number {
    if (durStr.indexOf(':') !== -1) {
      return parseInt(this.getDuration(durStr).replace('ms', '')) || 0;
    } else {
      return parseInt(durStr.replace('ms', '')) || 0;
    }
  }

  getSmil(text: string, mmsSource: Array<Mms>): string {
    HiLog.i(TAG, 'getSmil');
    if (!mmsSource || mmsSource.length === 0) {
      HiLog.i(TAG, 'getSmil failed');
      return '';
    }

    let head = '';
    let layout = '';
    let body = '';
    let firstMms = mmsSource[0];
    if (mmsSource.length === 1 || (text !== '' && mmsSource.length === 2)) {
      let par: string = '';
      let mmsMapSource = mmsSource.find(v => (v && !v?.isRcs && v?.type === commonData.MM_ATTACHMENT_TYPE.MAP));
      if (mmsMapSource) { //彩信位置消息
        HiLog.i(TAG, 'mms map message');
        let textSource = mmsSource.find(v => (v.type === commonData.MM_ATTACHMENT_TYPE.TEXT));
        layout += `<metadata name="${Constant.MMS_MESSAGE_TYPE_IN_SMIL}">${
        Constant.LOCATION_MMS_MESSAGE_TYPE}</metadata>`; //在smil的head中新增metadata来标记是否是彩信位置消息
        if (mmsMapSource.address) {
          layout += `<metadata name="${Constant.LONGITUDE_IN_SMIL}">${mmsMapSource.address.longitude}</metadata>`;
          layout += `<metadata name="${Constant.LATITUDE_IN_SMIL}">${mmsMapSource.address.latitude}</metadata>`;
        }
        layout += this.getHeadLayoutOfMmsMap(text);
        par = this.getBodyParOfMmsMap(mmsMapSource, text, textSource);
      } else if (MmsUtil.isAudio(firstMms.type)) {
        HiLog.i(TAG, 'audio');
        // audio region and par
        let duration: string = this.getDuration(firstMms.duration);
        let audio: string = this.addAudioElement(firstMms.name, duration);
        let parContent: string = audio;
        let textRegion: string = '';
        if (text !== '') {
          let textRegionObj = this.getDefaultRegion();
          textRegionObj.id = 'Text'; // Must use " NOT ALLOW MODIFY IT!
          textRegion = this.addRegionElement(textRegionObj);
          let textObj = mmsSource[1];
          let text: string = this.addTextElement(textObj.name);
          parContent = parContent + text;
        }
        par = this.addParElement(duration, parContent);
        if (textRegion.length > 0) {
          layout = this.addLayoutNode([textRegion]);
        } else {
          layout = this.addLayoutNode([]);
        }
      } else if (MmsUtil.isImage(firstMms.type)) {
        HiLog.i(TAG, 'image');
        // image region and par
        let regionObj = this.getDefaultRegion();
        regionObj.id = 'Image'; // Must use " NOT ALLOW MODIFY IT!
        let imageRegion: string = this.addRegionElement(regionObj);
        let image: string = this.addImgElement(firstMms.name);
        let parContent: string = image;
        let textRegion: string = '';
        if (text !== '') {
          let textRegionObj = this.getDefaultRegion();
          textRegionObj.id = 'Text'; // Must use " NOT ALLOW MODIFY IT!
          textRegion = this.addRegionElement(textRegionObj);
          let textObj = mmsSource[1];
          let text: string = this.addTextElement(textObj?.name);
          parContent = image + text;
        }
        let duration: string = this.getDuration(firstMms.duration);
        par = this.addParElement(duration, parContent);
        if (textRegion.length > 0) {
          let array: Array<string> = [textRegion, imageRegion];
          layout = this.addLayoutNode(array);
        } else {
          layout = this.addLayoutNode([imageRegion]);
        }

      } else if (MmsUtil.isVideo(firstMms.type)) {
        HiLog.i(TAG, 'video');
        // video region and par
        let regionObj = this.getDefaultRegion();
        regionObj.id = 'Image'; // Must use " NOT ALLOW MODIFY IT!
        let imageRegion: string = this.addRegionElement(regionObj);
        let duration: string = this.getDuration(firstMms.duration);
        let video: string = this.addVideoElement(firstMms.name, duration);
        let parContent: string = video;
        let textRegion: string = '';
        if (text !== '') {
          let textRegionObj = this.getDefaultRegion();
          textRegionObj.id = 'Text'; // Must use " NOT ALLOW MODIFY IT!
          textRegion = this.addRegionElement(textRegionObj);
          let textObj = mmsSource[1];
          let text: string = this.addTextElement(textObj.name);
          parContent = parContent + text;
        }
        par = this.addParElement(duration, parContent);
        if (textRegion.length > 0) {
          let array: Array<string> = [textRegion, imageRegion];
          layout = this.addLayoutNode(array);
        } else {
          layout = this.addLayoutNode([imageRegion]);
        }
      } else if (MmsUtil.isText(firstMms.type)) {
        HiLog.i(TAG, 'text only');
        let textRegion: string = '';
        if (text !== '') {
          let textRegionObj = this.getDefaultRegion();
          textRegionObj.id = 'Text';
          textRegion = this.addRegionElement(textRegionObj);
          let text: string = this.addTextElement(firstMms.name);
          par = this.addParElement('', text);
          let array: string[] = [textRegion];
          layout = this.addLayoutNode(array);
        }
      } else if (MmsUtil.isVcard(firstMms.type)) {
        const resVcardSmil: VcardSmil = this.getVcardSmil(firstMms, text, mmsSource)
        par = resVcardSmil.par
        layout = resVcardSmil.layout
      }
      body = this.addBodyNode([par]);
      head = this.addHeadNode(layout);
    }

    let smil = `<smil>${head}${body}</smil>`;
    return smil;
  }

  /**
   * 获取彩信位置消息的smil的head的layout
   * @param text 该消息的文本数据
   * @returns
   */
  private getHeadLayoutOfMmsMap(text: string) {
    let layout = '';
    let regionObj = this.getDefaultRegion();
    regionObj.id = 'Image'; // Must use " NOT ALLOW MODIFY IT!
    let imageRegion: string = this.addRegionElement(regionObj);
    let textRegion: string = '';
    if (text) {
      let textRegionObj = this.getDefaultRegion();
      textRegionObj.id = 'Text'; // Must use " NOT ALLOW MODIFY IT!
      textRegion = this.addRegionElement(textRegionObj);
    }
    if (textRegion.length > 0) {
      let array: Array<string> = [textRegion, imageRegion];
      layout = this.addLayoutNode(array);
    } else {
      layout = this.addLayoutNode([imageRegion]);
    }
    return layout;
  }

  /**
   * 获取彩信位置消息的smil的body的par
   */
  private getBodyParOfMmsMap(mmsMapSource: Mms, text: string, textSource: Mms | undefined) {
    let par: string = '';
    let image: string = this.addImgElement(mmsMapSource.name);
    let parContent: string = image;
    if (text) {
      let textObj = textSource;
      let text: string = this.addTextElement(textObj?.name || '');
      parContent = text + image;
    }
    let duration: string = this.getDuration(mmsMapSource.duration);
    par = this.addParElement(duration, parContent);
    return par;
  }

  getVcardSmil(firstMms: Mms, text: string, mmsSource: Array<Mms>) {
    HiLog.i(TAG, 'vcard');
    const resVcardSmil: VcardSmil = { par: '', layout: '' }
    let duration: string = this.getDuration(firstMms.duration);
    resVcardSmil.par = this.addParElement(duration, '');
    resVcardSmil.layout = this.addLayoutNode([]);
    return resVcardSmil
  }

  /**
   * 获取彩信幻灯片消息的smil
   * @param text
   * @param mmsSource
   * @param context
   * @returns
   */
  async getSlideSmil(text: string, mmsSource: Array<Mms>, context: Context): Promise<string> {
    HiLog.i(TAG, 'getSlideSmil');
    if (!mmsSource || mmsSource.length === 0) {
      HiLog.i(TAG, 'getSlideSmil failed');
      return '';
    }
    let source: (Mms[] | Mms)[] = mmsSource.slice(0);
    let head = '';
    let layout = '';
    let body = '';
    let parArr: string[] = [];
    let textRegion: string = '';
    let imageRegion: string = '';
    const hasImageRegion: boolean = mmsSource.some(mms => MmsUtil.isImage(mms.type) || MmsUtil.isVideo(mms.type));
    //该消息是否有彩信位置附件
    let isHasMapSource = mmsSource.some(v => MmsUtil.isMmsMapAttach(v?.isRcs, v?.type));
    HiLog.i(TAG, 'getSlideSmil isHasMapSource: ' + isHasMapSource);

    // add smil region
    if (text !== '' || isHasMapSource) {
      HiLog.i(TAG, 'getSlideSmil text region');
      let textRegionObj = this.getDefaultRegion();
      textRegionObj.id = 'Text'; // Must use " NOT ALLOW MODIFY IT!
      textRegion = this.addRegionElement(textRegionObj);
    }
    if (hasImageRegion || isHasMapSource) {
      HiLog.i(TAG, 'getSlideSmil image region');
      let imageRegionObj = this.getDefaultRegion();
      imageRegionObj.id = 'Image'; // Must use " NOT ALLOW MODIFY IT!
      imageRegion = this.addRegionElement(imageRegionObj);
    }
    layout = this.addLayoutNode([textRegion, imageRegion]);
    let indexListOfMmsMap: number[] = [];
    // add smil par
    for (let i = 0; i < mmsSource.length; i++) {
      let par: string = '';
      let parContent: string = '';
      const currentMms = mmsSource[i];
      //currentMms是否是彩信位置附件
      let isMmsMapAttachment: boolean = (currentMms && MmsUtil.isMmsMapAttach(currentMms.isRcs, currentMms.type));
      HiLog.i(TAG, `getSlideSmil index ${i}, isMmsMapAttachment: ${isMmsMapAttachment}`);

      if (!isMmsMapAttachment && text !== '' && i === 0) {
        let textObj = mmsSource.find(item => MmsUtil.isText(item.type));
        let textStr: string = this.addTextElement(textObj?.name || '');
        parContent += textStr;
      }
      if (MmsUtil.isAudio(currentMms.type)) {
        let duration: string = this.getDuration(currentMms.duration);
        parContent += this.addAudioElement(currentMms.name, duration);
        par = this.addParElement(duration, parContent);
      } else if (MmsUtil.isImage(currentMms.type)) {
        parContent += this.addImgElement(currentMms.name);
        par = this.addParElement('', parContent);
      } else if (MmsUtil.isVideo(currentMms.type)) {
        let duration: string = this.getDuration(currentMms.duration);
        parContent += this.addVideoElement(currentMms.name, duration);
        par = this.addParElement(duration, parContent);
      } else if (isMmsMapAttachment) { //彩信位置附件
        let mmsMapText: string = (i === 0) ? text : '';
        let textSource = await getMmsMapTextSource(context, mmsMapText, currentMms.address, (value) => {
          mmsMapText = value;
        });
        source.splice(i, 1, [currentMms, textSource]);
        par = this.getBodyParOfMmsMap(currentMms, mmsMapText, textSource);

        indexListOfMmsMap.push(i);
        if (mmsMapText) { //彩信位置附件文本内容
          layout += `<metadata name="${Constant.MMS_LOCATION_CONTENT_IN_SLIDE_SMIL}_${i}">${mmsMapText}</metadata>`;
        }
        mmsMapText = '';

        if (currentMms.address) {
          layout += `<metadata name="${Constant.COORDINATE_IN_SMIL}_${i}">${currentMms.address.longitude ?? 0}${
          commonData.STR.COMMA}${currentMms.address.latitude ?? 0}</metadata>`;
        }
      }
      if (par) {
        parArr.push(par);
      }
    }

    if (indexListOfMmsMap.length > 0) { //彩信位置附件在body中的索引列表
      layout += `<metadata name="${Constant.MMS_LOCATION_MESSAGE_IN_SLIDE_SMIL}">${indexListOfMmsMap.join(
        commonData.STR.COMMA)}</metadata>`;
    }

    body = this.addBodyNode(parArr);
    head = this.addHeadNode(layout);
    let smil = `<smil>${head}${body}</smil>`;
    if (source && source.length > 0 && source.length === mmsSource.length) {
      let mmsSourceLength = mmsSource.length;
      mmsSource.splice(0, mmsSourceLength, ...(source.flat(1)));
    }
    return smil;
  }

  addBodyNode(pars: Array<string>) {
    HiLog.i(TAG, 'addBodyNode');
    let body: string = `<body>`;
    pars.forEach(par => {
      body = body + par;
    });
    body = body + '</body>';
    return body;
  }

  addHeadNode(layout: string) {
    HiLog.i(TAG, 'addHeadNode');
    let head = '';
    head = `<head>${layout}</head>`;
    return head;
  }

  addLayoutNode(regions: Array<string>): string {
    HiLog.i(TAG, 'addLayoutNode');
    let layout = `<layout><root-layout />`;
    regions.forEach((region) => {
      layout = layout + region;
    })
    layout = layout + '</layout>';
    return layout;
  }

  addParElement(duration: string, subElement: string): string {
    HiLog.i(TAG, 'addParElement');
    let par: string = '';
    par = `<par dur="${duration}">${subElement}</par>`; // Must use " NOT ALLOW MODIFY IT!
    return par;
  }

  addAudioElement(src: string, dur: string): string {
    HiLog.i(TAG, 'addAudioElement');
    let audio: string = '';
    audio = `<audio src="${src}" dur="${dur}" />`; // Must use " NOT ALLOW MODIFY IT!
    return audio;
  }

  addImgElement(src: string): string {
    HiLog.i(TAG, 'addImgElement');
    let image: string = '';
    image = `<img src="${src}" region="Image" />`; // Must use " NOT ALLOW MODIFY IT!
    return image;
  }

  addVcardElement(src: string): string {
    HiLog.i(TAG, 'addVcardElement');
    let vcard: string = '';
    vcard = `<vcard src="${src}" />`; // Must use " NOT ALLOW MODIFY IT!
    return vcard;
  }

  addVideoElement(src: string, dur: string): string {
    HiLog.i(TAG, 'addVideoElement');
    let video: string = '';
    video = `<video src="${src}" dur="${dur}" region="Image" />`; // Must use " NOT ALLOW MODIFY IT!
    return video;
  }

  addTextElement(src: string): string {
    HiLog.i(TAG, 'addTextElement');
    let text: string = '';
    text = `<text src="${src}" region="Text" />`; // Must use " NOT ALLOW MODIFY IT!
    return text;
  }

  addRegionElement(regionObj: Region): string {
    HiLog.i(TAG, 'addRegionElement');
    let region: string = '';
    region = `<region id="${regionObj.id}" top="${regionObj.top}" left="${regionObj.left}"` +
      ` height="${regionObj.height}" width="${regionObj.width}" `; // Must use " NOT ALLOW MODIFY IT!
    if (regionObj.fit) {
      region = region + `fit="${regionObj.fit}"`; // Must use " NOT ALLOW MODIFY IT!
    }
    region = region + '/>';
    return region;
  }

  private getDefaultRegion() {
    HiLog.i(TAG, 'getDefaultRegion');
    let regionObj: Region = { // Must use " NOT ALLOW MODIFY IT!
      id: '',
      fit: 'meet',
      top: '0',
      left: '0',
      height: '100%',
      width: '100%'
    }
    return regionObj;
  }

  getDuration(durationString: string): string {
    HiLog.i(TAG, 'getDuration');
    if (durationString === '') {
      return durationString;
    }
    let durationArr = durationString.split(':');
    let minterStr = durationArr[0];
    let secondStr = durationArr[1];
    let duration: number = (Number(minterStr) * 60 + Number(secondStr)) * 1000;
    let durationStr: string = duration + 'ms';
    return durationStr;
  }
}

export type PartItemType = 'img' | 'audio' | 'video' | 'text' | 'ref';

export interface ParItem {
  type: PartItemType | string;
  dur: number,
  src: string,
  region: string
}

export interface Par {
  num: number,
  dur: number,
  items: ParItem[]
}

interface VcardSmil {
  par: string,
  layout: string
}

export default new SmilFile();