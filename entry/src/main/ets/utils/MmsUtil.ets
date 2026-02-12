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
import common from '../data/commonData';
import HiLog from './HiLog';
import { Mms, AddressInfo, RcsSendLoc, mmsInfo, SlideMmsItem } from './TypesUtils';
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import mms from '@ohos.telephony.sms';
import myCommon from '@ohos.app.ability.common';
import { promptAction } from '@kit.ArkUI';
import lazy UTD from '@ohos.data.uniformTypeDescriptor';
import SharedPreferencesUtils from './SharedPreferencesUtils';
import mmsReceive from '../views/MmsReceive/mmsReceiveMain';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import FileUtil from './FileUtil';
import dotCommon from '../utils/MmsDot/DotCommon';
import lazy fs from '@ohos.file.fs';
import LooseObject, { isObjectType, MyAny } from '../data/LooseObject';
import { mmsListType } from '../pages/conversation/conversationController';
import OperatorConfigUtil from '../../cust/utils/OperatorConfigUtil';
import { i18n, intl } from '@kit.LocalizationKit';
import SmilFile from './SmilFile';
import StringUtil, { isJSONString } from './StringUtil';
import lazy convertxml from '@ohos.convertxml';
import DotUtil from './MmsDot/DotUtils';
import { BusinessError } from '@kit.BasicServicesKit';
import { plainToClass } from 'class-transformer';
import { getCountryCode } from '../chatbot/utils/ChatbotLocationUtil';
import utd from '@ohos.data.uniformTypeDescriptor';
//import { systemShare } from '@kit.ShareKit';

const TAG = 'MmsUtil ';
const SUPPORT_FORMART = [
  commonData.MM_ATTACHMENT_TYPE.IMAGE,
  commonData.MM_ATTACHMENT_TYPE.VIDEO,
  commonData.MM_ATTACHMENT_TYPE.AUDIO,
  commonData.MM_ATTACHMENT_TYPE.TEXT,
  commonData.MM_ATTACHMENT_TYPE.MMS_NOT_DOWNLOAD,
  commonData.MM_ATTACHMENT_TYPE.VCARD,
  commonData.MM_ATTACHMENT_TYPE.MAP
];
const SUPPORT_RCS_FORMAT = [commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE, commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO,
  commonData.ENHANCED_INFO_ITEM_TYPE.FILE, commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE,
  commonData.ENHANCED_INFO_ITEM_TYPE.MAP];
const SUPPORT_SLIDE_FORMAT =
  [commonData.MMS_CONTENT_TYPE.SLIDE_CONTAINS_IMAGE, commonData.MMS_CONTENT_TYPE.SLIDE_NO_IMAGE];
const SUPPORT_ATTACH_FORMART = [
  commonData.MM_ATTACHMENT_TYPE.IMAGE,
  commonData.MM_ATTACHMENT_TYPE.VIDEO,
  commonData.MM_ATTACHMENT_TYPE.AUDIO,
  commonData.MM_ATTACHMENT_TYPE.VCARD,
  commonData.MM_ATTACHMENT_TYPE.MAP
];
const UNSUPPORT_RCS_TYPE_OF_MMS: number[] = [commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO,
  commonData.ENHANCED_INFO_ITEM_TYPE.THEME,
  commonData.ENHANCED_INFO_ITEM_TYPE.SLIDE, commonData.ENHANCED_INFO_ITEM_TYPE.MAP,
  commonData.ENHANCED_INFO_ITEM_TYPE.FILE, commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE];

export const SUPPORT_MMS_TRANSFORM_FORMAT = [
  commonData.MM_ATTACHMENT_TYPE.IMAGE,
  commonData.MM_ATTACHMENT_TYPE.VIDEO,
  commonData.MM_ATTACHMENT_TYPE.AUDIO,
  commonData.MM_ATTACHMENT_TYPE.VCARD,
  commonData.MM_ATTACHMENT_TYPE.MAP
];

const tagNameMap: LooseObject = {
  'img': commonData.MM_ATTACHMENT_TYPE.IMAGE,
  'video': commonData.MM_ATTACHMENT_TYPE.VIDEO,
  'audio': commonData.MM_ATTACHMENT_TYPE.AUDIO,
  'vcard': commonData.MM_ATTACHMENT_TYPE.VCARD
};

interface ConvertObject {
  _name: string,
  _text: string,
  _type: string,
  _attributes: Record<string, string>,
  _declaration: string,
  _elements: ConvertObject[]
}
/**
 * start to download mms info.
 *
 * @param data Mms data
 * @param isManual true: indicates manual download and no retry is required. false: Automatic download need retry.
 * @param mmsContext Context
 * @returns
 */
@Concurrent
export async function startDownloadMMsFunction(data: mmsInfo, isManual: boolean, retryTimes: number,
  mmsContext: Context) {
  SharedPreferencesUtils.init(mmsContext);
  const TAG = 'MmsUtil';
  HiLog.w(TAG, 'startDownloadMMs id:' + data.id);
  DotUtil.getInstance()
    .reportSendReceiveSuccessRate(dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_MMS,
      dotCommon.smsReceiveRecord.SUCCESS_RATE_BEHAVIOR_DOWNLOAD, dotCommon.smsReceiveRecord.SUCCESS_RATE_STATE_START);
  let context: Context = mmsContext ? mmsContext :
    (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);
  if (!data || data.mmsPdu?.length == 0) {
    await mmsReceive.dealReceiveFailed(data, false, context); // The pdu is empty. No need to retry.
    return false;
  }
  let encodeData: number[] = [];
  for (let i = 0; i < data.mmsPdu.length; i += 2) {
    encodeData.push(Number('0x' + data.mmsPdu.slice(i, i + 2)));
  }
  let decodeData: mms.MmsInformation = await mms.decodeMms(encodeData);
  let mmsType = decodeData.mmsType as mms.MmsNotificationInd;
  let sandPath = context.filesDir;
  let mmsRecName = `${data.id}_RetrieveConf.mms`;
  if (retryTimes > common.int.RETRY_TIME_INVALID) {
    mmsRecName = `${data.id}_RetrieveConf_${retryTimes}.mms`;
  }
  let mmsRecPath = '/' + mmsRecName;
  let pduPath = sandPath + mmsRecPath;
  let dataBuffer = new Uint8Array(encodeData).buffer;
  FileUtil.writeToSandBox(context, pduPath, dataBuffer);
  let mmsParam: mms.MmsParams = {
    mmsc: '',
    slotId: data.subId,
    mmsConfig: {
      'userAgent':'OpenHarmony-Mms/2.0',
      'userAgentProfile':context.resourceManager.getStringSync($r('app.string.uaprof_url'))
    },
    data: sandPath + mmsRecPath
  }
  mmsParam.mmsc = mmsType.contentLocation;
  mmsReceive.createDownloadMmsTask(data, mmsParam, context, sandPath, mmsType, isManual, retryTimes)
  return true;
}

class MmsUtil {
  public mmsPendingListCache: Map<number, number> = new Map();

  private hasGotCachedInfo = false;

  isImage(type: number): boolean {
    HiLog.w(TAG, `isImage(1), type: ${type}`);
    if (type === commonData.MM_ATTACHMENT_TYPE.IMAGE) {
      return true;
    } else {
      return false;
    }
  }

  isAudio(type: number): boolean {
    HiLog.w(TAG, `isAudio(3), type: ${type}`);
    if (type === commonData.MM_ATTACHMENT_TYPE.AUDIO) {
      return true;
    } else {
      return false;
    }
  }

  isVideo(type: number): boolean {
    HiLog.w(TAG, `isVideo(2), type: ${type}`);
    if (type === commonData.MM_ATTACHMENT_TYPE.VIDEO) {
      return true;
    } else {
      return false;
    }
  }

  isSmil(type: number): boolean {
    HiLog.w(TAG, `isSmil(0), type: ${type}`);
    if (type === commonData.MM_ATTACHMENT_TYPE.SMIL) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * Is Vcard msg
   */
  isVcard(type: number): boolean {
    HiLog.w(TAG, `isVcard(4), type: ${type}`);
    return type === commonData.ENHANCED_INFO_ITEM_TYPE.VCARD;
  }

  isText(type: number): boolean {
    HiLog.w(TAG, `isText(7), type: ${type}`);
    return type === commonData.MM_ATTACHMENT_TYPE.TEXT;
  }

  /**
   * 是否是彩信位置消息的附件，只用于mmsSource
   */
  public isMmsMapAttach(isRcs: boolean | undefined, type: number | undefined): boolean {
    HiLog.w(TAG, `isMmsMapAttach(8), isRcs: ${isRcs}, type: ${type}`);
    return (!isRcs && type === commonData.MM_ATTACHMENT_TYPE.MAP);
  }

  isFile(type: number): boolean {
    HiLog.w(TAG, `isFile(8), type: ${type}`);
    return type === commonData.ENHANCED_INFO_ITEM_TYPE.FILE;
  }

  isRcsMap(type: number): boolean {
    HiLog.w(TAG, `isRcsMap(10), type: ${type}`);
    return type === commonData.ENHANCED_INFO_ITEM_TYPE.MAP;
  }

  isSlideType(type: number): boolean {
    HiLog.w(TAG, `isSlideType(1,2), type: ${type}`);
    return SUPPORT_SLIDE_FORMAT.includes(type);
  }

  isSlideHasImage(type: number): boolean {
    HiLog.w(TAG, `isSlideHasImage(1), type: ${type}`);
    return type === commonData.MMS_CONTENT_TYPE.SLIDE_CONTAINS_IMAGE;
  }

  isSlideNoImage(type: number): boolean {
    HiLog.w(TAG, `isSlideNoImage(2), type: ${type}`);
    return type === commonData.MMS_CONTENT_TYPE.SLIDE_NO_IMAGE;
  }

  isSlideAttach(type: number): boolean {
    HiLog.w(TAG, `isSlideAttach(1,2,3), type: ${type}`);
    return SUPPORT_ATTACH_FORMART.includes(type);
  }

  getRcsContentType(source: Mms[]) {
    HiLog.w(TAG, 'getRcsContentType');
    let contentType: number = 0;
    let type: number = -1;
    if (source.length > 1) {
      type = source[1].type;
    }
    if (this.isVcard(type)) {
      contentType = commonData.MMS_CONTENT_TYPE.VCARD;
    } else if (this.isFile(type)) {
      contentType = commonData.MMS_CONTENT_TYPE.FILE;
    } else {
      contentType = commonData.MMS_CONTENT_TYPE.ORIGIN;
    }
    HiLog.w(TAG, `getRcsContentType contentType: ${contentType}`);
    return contentType;
  }

  isMap(type: number): boolean {
    HiLog.w(TAG, `isMap(8), type: ${type}`);
    return type === commonData.MM_ATTACHMENT_TYPE.MAP;
  }

  hasVcard(source: Array<Mms>) {
    HiLog.w(TAG, 'hasVcard start');
    if (!source || source.length === 0) {
      return null;
    }
    return source.find(item => this.isVcard(item.type)) || null;
  }

  getMmsContentType(source: Array<Mms>, msgTitle?: string) {
    HiLog.w(TAG, '[getMmsContentType] start');
    let contentType: number = 0;
    let smilSource = this.getSmilSource(source);
    let imageSource: Mms | null = this.getImageSource(source)
    HiLog.i(TAG, `[getMmsContentType] smilName: ${smilSource?.name}, imageSourceName: ${imageSource?.name}`);
    let smilPath = smilSource?.path || '';
    if (smilPath) {
      HiLog.i(TAG, '[getMmsContentType] The smil path has been obtained.');
      try {
        // 适配三方手机的数据库中存储了 vcard， xml 文件中没有 vcard
        let smilStr: string = fs.readTextSync(smilPath);
        if (this.hasVcard(source) && !smilStr.includes('vcard')) {
          return commonData.MMS_CONTENT_TYPE.ORIGIN
        }
      } catch (err) {
        HiLog.i(TAG, `getSmilFileContent err: ${err}` );
      }
      let parCounts: number;
      let smilParCountsObj: LooseObject = AppStorage.get('smilParCounts') || {};
      if (smilParCountsObj && smilParCountsObj[smilPath]) {
        parCounts = smilParCountsObj[smilPath];
      } else {
        parCounts = this.getSmilParStrData(smilPath)?.length || 0;
      }
      HiLog.i(TAG, '[getMmsContentType] smil par counts is: ' + parCounts);
      if (parCounts > 0) {
        let firstType = this.getMmsFirstType(source);
        HiLog.i(TAG, '[getMmsContentType] firstType is: ' + firstType);
        if (parCounts === 1) {
          // When there is only one MMS attachment, the MMS message is displayed as it is.
          contentType =
            ((!this.isSlideAttach(firstType) && msgTitle) || this.isText(firstType)) ?
            commonData.MMS_CONTENT_TYPE.SLIDE_NO_IMAGE : commonData.MMS_CONTENT_TYPE.ORIGIN;
        } else {
          // The first attachment is a picture or video, showing the slideshow with the picture.
          // The first is a recording, which is shown as a slideshow without pictures.
          contentType = this.getSlideShowTypeByFirstItemType(firstType);
        }
      }
    } else {
      contentType = imageSource ? commonData.MMS_CONTENT_TYPE.ORIGIN : commonData.MMS_CONTENT_TYPE.SLIDE_NO_IMAGE;
      HiLog.w(TAG, `[getMmsContentType] The smil path is empty, contentType: ${contentType}`);
    }
    HiLog.w(TAG, '[getMmsContentType] contentType is: ' + contentType);
    return contentType;
  }

  getSlideShowTypeByFirstItemType(firstType: number) {
    return (this.isImage(firstType) || this.isVideo(firstType) || this.isMmsMapAttach(false, firstType)) ?
    commonData.MMS_CONTENT_TYPE.SLIDE_CONTAINS_IMAGE : commonData.MMS_CONTENT_TYPE.SLIDE_NO_IMAGE
  }

  getSmilSource(source: Array<Mms>): Mms | null {
    HiLog.w(TAG, '[getSmilSource] start');
    if (!source || source.length === 0) {
      return null;
    }
    return source.find(item => this.isSmil(item.type)) || null;
  }

  getImageSource(source: Array<Mms>): Mms | null {
    HiLog.w(TAG, '[getImageSource] start');
    if (!source || source.length === 0) {
      HiLog.w(TAG, '[getImageSource] source is null or no image');
      return null;
    }
    return source.find(item => this.isImage(item.type)) || null;
  }

  getAllParNodeFromSmil(parentNode: ConvertObject[], parArray: ConvertObject[]) {
    if (parentNode == undefined || parentNode.length == 0) {
      return;
    }
    parentNode.forEach((node) => {
      if (node._name && node._name == 'par') {
        parArray.push(node);
      } else {
        if (node._elements && node._elements.length != 0) {
          this.getAllParNodeFromSmil(node._elements, parArray);
        }
      }
    })
  }

  getSmilParStrData(smilPath: string) {
    HiLog.i(TAG, 'getSmilParStrData start');
    let parArray: ConvertObject[] = [];
    try {
      let smilStr: string = fs.readTextSync(smilPath);
      let xmlConvert = new convertxml.ConvertXML();
      let convertOptions: convertxml.ConvertOptions = {
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
      let smilConvertResult: ConvertObject = xmlConvert.convertToJSObject(smilStr, convertOptions) as ConvertObject;
      this.getAllParNodeFromSmil(smilConvertResult._elements, parArray);
      if (parArray?.length == 0) {
        HiLog.w(TAG, 'getSmilParStrData no par tag found');
        return parArray;
      }
      AppStorage.setOrCreate('smilParCounts', {
        smilPath: parArray.length
      });
      HiLog.i(TAG, 'getSmilParStrData par counts is: ' + parArray?.length);
      return parArray;
    } catch (e) {
      HiLog.e(TAG, 'getSmilParStrData error: ' + JSON.stringify(e));
      return parArray;
    }
  }

  getSmilFullMmsSource(source: Array<Mms>): Array<Mms> {
    HiLog.i(TAG, 'getSmilFullMmsSource start');
    let fullSource: Mms[] = [];
    let smilPath = this.getSmilSource(source)?.path || '';
    let parStrArr: ConvertObject[] = this.getSmilParStrData(smilPath);
    if (parStrArr?.length > 0) {
      const basePath = smilPath.substring(0, smilPath.lastIndexOf('\/') + 1);
      HiLog.i(TAG, 'getSmilFullMmsSource smil has base path');
      for (let i = 0; i < parStrArr.length; i++) {
        if (parStrArr[i]._elements?.length > 0) {
          parStrArr[i]._elements?.forEach((attach, index) => {
            let mediaObj: Mms | undefined = {
              duration: '',
              type: 0,
              path: '',
              name: ''
            };
            let tagName: string = '';
            let src: string = '';
            if (attach._name == null) {
              HiLog.e(TAG, index + 'th attach has no tag name');
            } else {
              tagName = attach._name;
            }
            if (attach._attributes['src'] == null) {
              HiLog.e(TAG, index + 'th attach has no src');
            } else {
              src = attach._attributes['src'].startsWith('cid:') ?
                attach._attributes['src'].replace('cid:', '') : attach._attributes['src'];
            }
            if (tagName !== 'text') { // 根据smil文件中媒体内容（不含纯text）的src文件名和相应的消息列表数据，构建实际的Mms对象。
              // 直接匹配文件名，item.name是从完整path中提取的文件名，src是smil文件中的文件名。
              mediaObj = source.find((item: Mms) => item.name === src);
              if (!mediaObj) { // 尝试匹配文件后缀，解决双升单时，文件名前加PART_xxxx前缀场景
                HiLog.w(TAG, 'try fuzzy search for media src. ' + tagName);
                mediaObj = source.find((item: Mms) => item.name.endsWith(src));
              }
              // 尝试带尖括号路径。这里保持旧逻辑
              if (!mediaObj) {
                HiLog.w(TAG, 'cannot find media src without <>.');
                src = '<' + src + '>';
                mediaObj = source.find((item: Mms) => item.name === src);
              }
              // 如果是vCard,直接找对应类型的文件。彩信中的vcard只能有一个？这里保持旧逻辑
              if (!mediaObj && tagName === 'vcard') {
                mediaObj = source.find((item: Mms) => item.ct === 'text/x-vCard');
              }
              // 如果还是找不到，直接按照资源在smil附件顺位去source中提取对位的数据, 解决smil内的文件名和path中的文件名完全不能匹配的场景
              // 这里保持同一类型数据的先后顺序。例如，当前类型是A，是smil附件列表中第二个A类型附件，那就从source中拿取第二个A类型的信息
              if (!mediaObj) {
                let sType = (tagNameMap[tagName] || 0) as number;
                let typeIdx = fullSource.filter(obj => obj.type === sType).length;
                mediaObj = source.filter(sItem => sItem.type === sType)[typeIdx];
                HiLog.w(TAG, `try use index for media src. ${tagName} ${typeIdx}`);
              }
              if (!mediaObj) {
                mediaObj = {
                  duration: '',
                  type: tagNameMap[tagName] || 0,
                  path: basePath + src,
                  name: src
                };
                HiLog.w(TAG, 'mediaObj cannot find from source, type is: ' + mediaObj.type);
              }
            } else {
              if (!FileUtil.checkFileAccess(basePath + src)) {
                HiLog.w(TAG, 'cannot find text src without <>.');
                src = '<' + src + '>';
                if (!FileUtil.checkFileAccess(basePath + src)) {
                  HiLog.w(TAG, 'cannot find text src with <>.')
                }
              }
              mediaObj.type = commonData.MM_ATTACHMENT_TYPE.TEXT;
              mediaObj.path = basePath + src;
              mediaObj.name = src;
            }
            mediaObj.smilParIndex = i;
            fullSource.push(mediaObj);
          })
        } else {
          HiLog.w(TAG, i + 'th par length is zero, push default mediaObj');
          fullSource.push({
            duration: '',
            type: 0,
            path: '',
            name: '',
            smilParIndex: i
          });
        }
      }
    }
    HiLog.i(TAG, 'getSmilFullMmsSource fullSource length is: ' + fullSource.length);
    return fullSource;
  }

  getSmilMmsSourceDelEmptyPar(source: Array<Mms>): Array<Mms> {
    const fullSource: Mms[] = this.getSmilFullMmsSource(source);
    return fullSource.filter(item =>!!item.path && !!item.name);
  }

  generateSlidePreviewData(source: Array<Mms>): Array<Mms> {
    HiLog.i(TAG, '[generateSlidePreviewData] start');
    let slideList: Mms[] = [];
    try {
      let textIndex: number = 0;
      // fullSource为从smil文件中读取的数据对象数组
      const fullSource: Mms[] = this.getSmilFullMmsSource(source);
      HiLog.w(TAG, `[generateSlidePreviewData] source.length: ${source?.length}, fullSource.length: ${fullSource?.length}`);
      // 先过滤下db中查询到的所有是文本的附件对象，并对其按partIndex进行排序
      let textSource: Array<Mms> = source.filter((sourceItem: Mms) => this.isText(sourceItem.type))
        .sort((a, b) => Number(a.partIndex) - Number(b.partIndex));

      if (fullSource?.length) {
        let contentObj: LooseObject = {};
        fullSource.forEach(item => {
          HiLog.w(TAG, `generateSlidePreviewData smilSource type: ${item.type}`);
          let smilParIndex = item.smilParIndex as number;
          if (this.isText(item.type)) {
            if (fs.accessSync(item.path, fs.AccessModeType.READ)) {
              contentObj[smilParIndex] = fs.readTextSync(item.path) || '';
            } else {
              // 如果smil文件中记录的path路径访问不到沙箱文件，则需要使用db中查询出来的附件数组的path进行访问
              let textItem = source.find((sourceItem: Mms) =>
                ('<' + sourceItem.name + '>') === item.name || sourceItem.name === item.name);

              // 这里判断下textItem?.content是否为空，如果为空则通过db中查出来的source的content直接读取文件内容
              if (!textItem && !StringUtil.isEmpty(textSource[textIndex]?.content)) {
                HiLog.w(TAG, 'generateSlidePreviewData textSource from db is not null');
                contentObj[smilParIndex] = (textSource[textIndex]?.content);
              } else {
                contentObj[smilParIndex] = textItem?.content || '';
                HiLog.w(TAG, 'dusk generateSlidePreviewData textItem is empty!!!');
              }
            }
            textIndex++;
          }
          item.content = contentObj[smilParIndex];
          let objIndex = slideList.findIndex(ele => ele?.smilParIndex === item.smilParIndex);
          if (objIndex > -1) {
            if (this.isSlideAttach(item.type)) {
              slideList[objIndex] = item;
            } else {
              slideList[objIndex].content = item.content;
            }
          } else {
            slideList.push(item)
          }
        })
      } else {
        HiLog.w(TAG, `[generateSlidePreviewData] attachment len: ${source.length}`);
        if (source && source.length === 1) {
          let item = source[0];
          HiLog.w(TAG,
            `generateSlidePreviewData no smil and attachment len is one, item type: ${item?.type}, item ct: ${item?.ct}`);
          if (this.isText(item.type)) {
            try {
              if (fs.accessSync(item.path, fs.AccessModeType.READ)) {
                item.content = fs.readTextSync(item.path) || '';
                HiLog.w(TAG, `generateSlidePreviewData, item partIndex: ${item?.partIndex}`);
                slideList.push(item);
              } else {
                HiLog.e(TAG, 'slide text path not found');
              }
            } catch (error) {
              HiLog.e(TAG, 'no access text file right')
            }
          }
        }
        HiLog.w(TAG, 'fullSource length is zero');
      }
      HiLog.w(TAG, '[generateSlidePreviewData] slide list length is: ' + slideList.length);
    } catch (e) {
      let error = e as BusinessError;
      HiLog.e(TAG, `generateSlidePreviewData readTextSync error msg:${error?.message} + code: ${error?.code}`);
    }
    return slideList;
  }

  getMmsFirstType(source: Array<Mms>): number {
    HiLog.i(TAG, '[getMmsFirstType] start');
    let slideData = this.generateSlidePreviewData(source);
    let contentType: number = 0;
    if (slideData.length > 0) {
      let firstType = slideData[0].type as number;
      HiLog.i(TAG, `[getMmsFirstType] has mmsSource, firstType: ${firstType}`);
      return firstType;
    } else {
      HiLog.w(TAG, '[getMmsFirstType] no mmsSource, return default contentType 0');
      return contentType;
    }
  }

  isValidSize(source: Array<Mms>) {
    let mmsSource = this.deleteSmil(source);
    // 彩信 map 的 mmsource, 不在第一个，单独判断
    const mmsMapAttach = mmsSource.find(v => this.isMap(v.type))
    if (mmsMapAttach) {
      return mmsMapAttach.size;
    }
    if (mmsSource.length > 0) {
      return mmsSource[0].size;
    }
    return undefined;
  }

  deleteSmil(source: Array<Mms>) {
    HiLog.i(TAG, 'deleteSmil');
    if (!source || source.length === 0) {
      return [];
    }
    let mmsSource: Mms[] = [];
    source.forEach((item) => {
      HiLog.i(TAG, 'item.type is:' + item.type);
      if (SUPPORT_FORMART.includes(item.type)) {
        mmsSource.push(item);
      }
    });
    return mmsSource;
  }
  deleteRcsSmil(source: Mms[]) {
    HiLog.i(TAG, 'deleteSmil');
    if (!source || source.length === 0) {
      return [];
    }
    let mmsSource: Mms[] = [];
    source.forEach((item) => {
      if (SUPPORT_RCS_FORMAT.includes(item.type)) {
        mmsSource.push(item);
      }
    });
    return mmsSource;
  }

  getMmsSourceFromRequest(list: Array<Record<string, number | string>>, setMsgShowType?: (type: number) => void) {
    HiLog.i(TAG, 'getMmsSourceFromRequest');
    if (!list || list.length === 0) {
        return [];
    }
    let source: Mms[] = [];
    list.forEach((item: Record<string, number | string>) => {
      let isMmsMapAttach: boolean = Boolean(!item.rcsId && item.type === commonData.MM_ATTACHMENT_TYPE.MAP);
      if (isMmsMapAttach && setMsgShowType) {
        setMsgShowType(common.MESSAGE_SHOW_TYPE.MAP);
      }
      let obj: Mms = {
        duration: item.recordingTime as string,
        type: item.type as number,
        ct: item.ct as string,
        path: item.path as string,
        imagePath: item?.imagePath as string,
        name: '',
        size: item.partSize as string,
        content: (item.type === commonData.ENHANCED_INFO_ITEM_TYPE.MAP ||
          item.type === commonData.MM_ATTACHMENT_TYPE.TEXT) ? item.content as string : '',
        text: isMmsMapAttach ? item.content as string : undefined,
        isFraud: item.isFraud as number,
      };
      let pathStrings = obj.path.split('/');
      obj.name = pathStrings[pathStrings.length - 1];
      source.push(obj);
    });
    return source;
  }

  getRcsSourceFromRequest(list: Array<Record<string, number | string>>, content: string) {
    HiLog.i(TAG, 'getRcsSourceFromRequest');
    if (!list || list.length === 0) {
      return [];
    }
    let source: Mms[] = [];
    try {
      list.forEach((item: Record<string, number | string>) => {
        if (!item) {
          HiLog.e(TAG, 'item is empty')
          return;
        }
        let obj: Mms = {
          duration: item.recordingTime as string,
          type: item.type as number,
          path: item.path as string,
          imagePath: item?.imagePath as string,
          name: '',
          size: item.partSize as string,
          isFraud: item.isFraud as number
        };
        let pathStrings = obj.path.split('/');
        obj.name = pathStrings[pathStrings.length - 1];
        if (this.isRcsMap(obj.type)) {
          obj.content = content;
          let locStrings: string[] = [];
          let latitudeNum: number = 0;
          let longitudeNum: number = 0;
          if (content != '' && content != undefined && isJSONString(content)) {
            let sendLoc: RcsSendLoc = JSON.parse(content) as RcsSendLoc;
            locStrings = sendLoc?.body?.split(';');
            latitudeNum = Number(sendLoc?.latitude);
            longitudeNum = Number(sendLoc?.longitude);
          }
          let address: AddressInfo = new AddressInfo(latitudeNum, longitudeNum, locStrings[0],
            locStrings[locStrings.length - 1]);
          obj.address = address;
        }
        source.push(obj);
      });
    } catch (e) {
      HiLog.e(TAG, 'getRcsSourceFromRequest, error: ' + JSON.stringify(e));
    }
    return source;
  }

  // Check whether the advanced security mode is enabled
  checkAdvancedMode() {
    let isSecurityMode: boolean = false;
    try {
      let value = systemParameterEnhance.getSync('ohos.boot.advsecmode.state');
      if (value === '1') {
        isSecurityMode = true;
      } else if (value === '0' || value === undefined) {
        isSecurityMode = false;
      }
      HiLog.w(TAG, 'isSecurityMode：' + isSecurityMode);

    } catch (e) {
      HiLog.e(TAG, 'checkAdvancedMode, failed: ' + JSON.stringify(e));
    }
    return isSecurityMode;
  }

  showToast(options: promptAction.ShowToastOptions) {
    try {
      promptAction.showToast(options);
    } catch (err) {
      HiLog.e(TAG, `showToast error: ${err}`);
    }
  }

  getFileUTD(path: string, ct?: string) {
    const lastDotIndex = path.lastIndexOf('.');
    if (lastDotIndex < 0 && !ct) {
      HiLog.e(TAG, `getFileUTD fail: lastDotIndex=` + lastDotIndex + ',ct=' + ct);
      return ''
    }
    let fileExtName: string | undefined = '';
    if (!ct || ct == '*') {
      fileExtName = path.slice(lastDotIndex + 1);
    } else {
      fileExtName = ct
    }
    HiLog.i(TAG, `getFileUTD FileExtName: ` + JSON.stringify(fileExtName));
    let utd = ''
    if (fileExtName == 'jpg' || fileExtName == 'jpe' || fileExtName == 'jpeg') {
      utd = UTD.UniformDataType.JPEG
    } else if (fileExtName == 'png') {
      utd = UTD.UniformDataType.PNG
    } else if (fileExtName == 'bmp') {
      utd = UTD.UniformDataType.BMP
    } else if (fileExtName == 'gif') {
      utd = UTD.UniformDataType.GIF
    } else if (fileExtName == 'heif') {
      utd = 'general.heif'
    } else if (fileExtName == 'heic') {
      utd = 'general.heic'
    } else if (fileExtName == 'mp3') {
      utd = UTD.UniformDataType.MP3
    } else if (fileExtName == 'm4a') {
      utd = UTD.UniformDataType.MPEG_4_AUDIO
    } else if (fileExtName == 'mp2') {
      utd = UTD.UniformDataType.MP2
    } else if (fileExtName == 'flac') {
      utd = UTD.UniformDataType.FLAC
    } else if (fileExtName == 'aac') {
      utd = UTD.UniformDataType.AAC
    } else if (fileExtName == 'wav' || fileExtName == 'wave') {
      utd = UTD.UniformDataType.WAVEFORM_AUDIO
    } else if (fileExtName == 'mp4') {
      utd = UTD.UniformDataType.MPEG4
    } else if (fileExtName == 'mkv') {
      utd = UTD.UniformDataType.MATROSKA_VIDEO
    } else if (fileExtName == 'amr') {
      utd = UTD.UniformDataType.AUDIO
    } else if (fileExtName == 'vcf') {
      utd = UTD.UniformDataType.VCARD
    }
    return utd
  }

  badgePosition(count: number, fontSizeScale: number): BadgePosition | Position {
    if (count > 99 && fontSizeScale >= 1.75) {
      return { x: 4, y: -4 };
    }
    return { x: 24, y: -4 };
  }

  getRetryTime(mmsId: number): number {
    let retryNum: number = SharedPreferencesUtils.getFromPreferencesTaskPool('MMS_RETRY' + mmsId, 0) as number;
    HiLog.e(TAG, 'getRetryTime mmsId:' + mmsId + 'retrynumber:' + retryNum);
    return retryNum;
  }

  increasesRetryTime(mmsId: number) {
    let retryTime = this.getRetryTime(mmsId);
    HiLog.e(TAG, 'increasesRetryTime mmsId:' + mmsId + ', old:' + retryTime + ', new:' + (retryTime + 1));
    SharedPreferencesUtils.saveToPreferencesTaskPool('MMS_RETRY' + mmsId, retryTime + 1);
  }

  clearRetryTime(mmsId: number) {
    HiLog.e(TAG, 'clearRetryTime for msgId:' + mmsId);
    SharedPreferencesUtils.deletePreferencesTaskPool('MMS_RETRY' + mmsId);
  }

  checkRcsTransmitToMms(msgSource: mmsListType): boolean {
    HiLog.i(TAG, 'checkRcsTransmitToMms start');
    for (let index: number = 0; index < msgSource.mmsSource.length; index++) {
      if (UNSUPPORT_RCS_TYPE_OF_MMS.includes(msgSource.mmsSource[index].type)) {
        HiLog.e(TAG, 'mms transmit unsupport rcs type msg, original rcs type is: ' + msgSource.mmsSource[index].type);
        let msg: Resource = $r('app.string.audio_play_error');
        this.showToast({
          message: msg,
          duration: 3000
        });
        return false;
      }
      if (msgSource.mmsSource[index].type == commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE ||
        msgSource.mmsSource[index].type == commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
        let size = FileUtil.getFileSizeByUri(msgSource.mmsSource[index].path);
        HiLog.e(TAG, 'rcs message use mms send, attachment size: ' + JSON.stringify(size));
        if (size > OperatorConfigUtil.getInstance().getCustMMSSize(commonData.int.MMS_FILE_MAX_SIZE)) {
          let maxSize: number = OperatorConfigUtil.getInstance().getCustMMSSize(
            commonData.int.MMS_FILE_MAX_SIZE) / commonData.int.BYTE_CONVERSION_UNIT;
          let countryId = i18n.System.getSystemRegion();
          let numberFormat = new intl.NumberFormat(countryId, { style: 'unit', unit: 'kilobyte' });
          let masxSiseStr = numberFormat.format(maxSize);
          let msg: Resource = $r('app.string.attachment_failed', masxSiseStr);
          this.showToast({
            message: msg,
            duration: 3000
          });
          return false;
        }
      }
    }
    return true;
  }

  setSmilSource(context: Context, textValue: string, source: Array<Mms>): Mms {
    HiLog.i(TAG, 'getSmilSource');
    let smilSource: Mms = {
      duration: '',
      type: common.MM_ATTACHMENT_TYPE.SMIL,
      path: '',
      name: ''
    }
    let smil: string = SmilFile.getSmil(textValue, source);
    let smilObj: Record<string, string> = FileUtil.writeTextToSandBox(context, smil, true);
    smilSource.path = smilObj.path;
    smilSource.name = smilObj.name;
    smilSource.text = smil;
    HiLog.i(TAG, 'send mms smil');
    return smilSource;
  }

  /**
   * 根据rcsType获取UE打点msgContent（1:文本, 2:图片, 3:视频, 4:VCard, 5:录音, 6:幻灯片彩信only, 7:位置,
   * 8:主题(文字+图片、彩信only), 9:音乐文件, 10:文件, 11:rcs应用号卡片, 12:rcs应用号卡片的视频富媒体缩略图文件）
   * @param rcsType 增强信息消息类型
   * @returns msgContent UE打点消息类型
   */
  getMsgContentByRcsType(rcsType: number): number {
    let msgContent: number = 0;
    switch (rcsType) {
      case commonData.ENHANCED_INFO_ITEM_TYPE.TEXT: //文本
        msgContent = commonData.ueMsgContent.TEXT;
        break;
      case commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE: //图片
        msgContent = commonData.ueMsgContent.IMAGE;
        break;
      case commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO: //视频
        msgContent = commonData.ueMsgContent.VIDEO;
        break;
      case commonData.ENHANCED_INFO_ITEM_TYPE.VCARD: //联系人
        msgContent = commonData.ueMsgContent.VCARD;
        break;
      case commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO: //录音
        msgContent = commonData.ueMsgContent.AUDIO;
        break;
      case commonData.ENHANCED_INFO_ITEM_TYPE.MAP: //位置
        msgContent = commonData.ueMsgContent.MAP;
        break;
      case commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE: //音频文件
        msgContent = commonData.ueMsgContent.AUDIO_FILE;
        break;
      case commonData.ENHANCED_INFO_ITEM_TYPE.FILE: //文件
        msgContent = commonData.ueMsgContent.FILE;
        break;
      case commonData.ENHANCED_INFO_ITEM_TYPE.CHATBOT_CARD: //rcs应用号卡片
        msgContent = commonData.ueMsgContent.CHATBOT_CARD;
        break;
      case commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO_THUMBNAIL: //rcs应用号卡片的视频富媒体缩略图文件
        msgContent = commonData.ueMsgContent.VIDEO_THUMBNAIL;
        break;
      default:
        break;
    }
    return msgContent;
  }

  /**
   * 根据mmsSource获取UE打点的msgContent（1:文本, 2:图片, 3:视频, 4:VCard, 5:录音, 6:幻灯片彩信only）
   * @param mmsSource 彩信附件数组
   * @returns msgContent UE打点消息类型
   */
  getMsgContentByMmsSource(mmsSource: Array<Mms>): number {
    if (!mmsSource || mmsSource.length < 1) {
      return commonData.ueMsgContent.TEXT;
    }
    let typeArr: number[] = [];
    mmsSource.filter(e => e.type != 0).forEach(item => {
      typeArr.push(item.type);
    })

    if (!typeArr) {
      return commonData.ueMsgContent.TEXT;
    }

    if (typeArr.length > 1) {
      return commonData.ueMsgContent.SLIDE;
    }
    switch (typeArr[0]) {
      case commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE:
        return commonData.ueMsgContent.IMAGE;
      case commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO:
        return commonData.ueMsgContent.VIDEO;
      case commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO:
        return commonData.ueMsgContent.AUDIO;
      case commonData.ENHANCED_INFO_ITEM_TYPE.VCARD:
        return commonData.ueMsgContent.VCARD;
      default:
        return commonData.ueMsgContent.TEXT;
    }
  }
}

/**
 * 在China获取彩信位置消息文本数据中的位置链接
 * @param context
 * @param latitude
 * @param longitude
 * @returns
 */
function getLocationWeblinkInChina(context: Context, latitude: string, longitude: string) {
  try {
    return context.resourceManager.getStringSync($r('app.string.location_gaode_weblink')) + latitude + "," + longitude;
  } catch (e) {
    HiLog.e(TAG, `getLocationWeblinkInChina error: ${e?.code} ${e?.mesage}`)
  }
  return '';
}

/**
 * Gets location web link
 *
 * @param latitude
 * @param longitude
 * @param countryCode
 * @return the location web link
 */
export function getLocationWebLink(context: Context, latitude: string, longitude: string,
  countryCode: string) {
  const req= getLocationWeblinkInChina(context, latitude, longitude);
  return req
}

/**
 * 将jsonPayload解析成AddressInfo对象
 *
 * @param jsonPayload
 */
export function parseAddressInfo(jsonPayload: string | undefined) {
  let addressInfo: AddressInfo | null = null;
  if (!jsonPayload) {
    return addressInfo;
  }
  try {
    const jsonObject: MyAny = JSON.parse(jsonPayload);
    if (!jsonObject || !isObjectType(jsonObject)) {
      HiLog.e(TAG, `parseAddressInfo: jsonObject is empty or is not Object Type`);
      return null;
    }
    addressInfo = plainToClass(AddressInfo, jsonObject, { excludeExtraneousValues: true });
  } catch (e) {
    HiLog.e(TAG, `parseAddressInfo error: ${e?.code} ${e?.message}`);
  }
  return addressInfo;
}

/**
 * 生成彩信位置消息的文本附件
 * @param context
 * @param textValue 彩信位置消息的输入框文本
 * @param address 彩信位置消息的位置数据
 * @param setNewTextValue
 * @returns
 */
export async function getMmsMapTextSource(context: Context, textValue: string, address: AddressInfo | undefined,
  setNewTextValue?: (newTextValue: string) => void) {
  HiLog.i(TAG, 'getMmsMapTextSource');
  let textSource: Mms = {
    duration: '',
    type: common.MM_ATTACHMENT_TYPE.TEXT,
    path: '',
    name: '',
  }
  let addressInfo = address ?? new AddressInfo(0, 0, '', '');
  let countryCodeString: string | undefined = addressInfo.countryCode;
  if (!countryCodeString) {
    let countryCode = await getCountryCode();
    countryCodeString = countryCode?.country;
  }
  //根据国家码来判断使用China的地图链接还是非China的地图链接
  let locationWebLink = getLocationWebLink(context, String(addressInfo.latitude ?? ''),
    String(addressInfo.longitude ?? ''), countryCodeString ?? '');

  let mmsMapText: string = '';
  mmsMapText = mmsMapText + (addressInfo.name ?? '') + '\n';
  mmsMapText = mmsMapText + (addressInfo.address ?? '') + '\n';
  mmsMapText = mmsMapText + (locationWebLink ?? '');
  if (textValue) {
    mmsMapText = mmsMapText + '\n' + textValue;
  }
  setNewTextValue?.(mmsMapText);
  let textObj: Record<string, string> = FileUtil.writeTextToSandBox(context, mmsMapText, false);
  textSource.path = textObj.path;
  textSource.name = textObj.name;
  return textSource;
}

/**
 * 解析彩信位置消息的文本以获取输入框文本
 * @param content
 * @returns
 */
export function getMapInputBoxText(content: string | number | Resource | undefined) {
  try {
    if (!content || typeof content !== 'string') {
      return '';
    }
    let tempArray = content.split('\n');
    if (tempArray.length <= 3) {
      return '';
    }
    return (tempArray.slice(3).join('\n')) ?? '';
  } catch (e) {
    HiLog.e(TAG, `getInputBoxText error: ${e?.code} ${e?.message}`);
  }
  return '';
}

/**
 * 判断item是否是彩信位置消息
 * @param isRcs
 * @param item: mmsListType
 * @returns
 */
export function isMmsMapMessageByMmsListType(isRcs: boolean, item: mmsListType): boolean {
  if (!item?.mmsSource) {
    return false;
  }
  return !isRcs && (item.msgShowType === common.MESSAGE_SHOW_TYPE.MAP || (item.mmsSource.length === 3 &&
  item.mmsSource.some(v => (v && v.type === common.MM_ATTACHMENT_TYPE.MAP))));
}
/**
 * 根据mmsSource判断是否是彩信位置消息
 * @param isRcs
 * @param mmsSource
 * @returns
 */
export function getIsMmsMapMessageByMmsSource(isRcs: boolean, mmsSource: Mms[] | null | undefined): boolean {
  return Boolean(!isRcs && mmsSource && mmsSource.length === 3 && mmsSource.some(v => (v &&
    v.type === common.MM_ATTACHMENT_TYPE.MAP)));
}

/**
 * 找到彩信位置消息的位置附件数据
 * @param isRcs 该消息是否为增强信息消息
 * @param mmsSource 消息的附件列表
 * @returns
 */
export function findMapSourceOfMmsMapMessage(isRcs: boolean, mmsSource: Mms[] | null | undefined) {
  //一条彩信位置消息包含smil、位置图片和位置描述txt文件等三个附件
  if (!isRcs && mmsSource && mmsSource.length === 3) {
    return mmsSource.find(v => (v && v.type === common.MM_ATTACHMENT_TYPE.MAP));
  }
  return null;
}

/**
 * 获取彩信位置链接分享选项
 * @param textContent 彩信位置文本内容
 */
// export function getMmsMapLinkShareData(textContent: string): systemShare.SharedRecord {
//   //彩信位置文本内容为固定格式的字符串，第一行为标题；第二行为位置详细描述；第三行为位置链接；第四行及之后内容为消息附带的输入框文本。
//   let tempArray = textContent.split('\n');
//   if (tempArray.length >= 3) {
//     return {
//       utd: utd.UniformDataType.HYPERLINK,
//       content: tempArray[2] ?? '',
//       title: tempArray[0] ?? '',
//       description: tempArray[1] ?? ''
//     };
//   } else {
//     return {
//       utd: utd.UniformDataType.PLAIN_TEXT,
//       content: textContent
//     };
//   }
// }

//会话页面中 从短彩信模式切换到增强信息模式时 附件待发区保留的附件类型
export const KEEP_MESSAGE_TYPE_WHEN_MMS_TO_RCS: number[] = [
  commonData.MM_ATTACHMENT_TYPE.IMAGE,
  commonData.MM_ATTACHMENT_TYPE.VIDEO,
  commonData.MM_ATTACHMENT_TYPE.VCARD,
  commonData.MM_ATTACHMENT_TYPE.MAP
];

//会话页面中 从增强信息模式切换到短彩信模式时 附件待发区保留的附件类型
export const KEEP_MESSAGE_TYPE_WHEN_RCS_TO_MMS: number[] = [
  commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE,
  commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO,
  commonData.ENHANCED_INFO_ITEM_TYPE.VCARD,
  commonData.ENHANCED_INFO_ITEM_TYPE.MAP
];

export default new MmsUtil();