/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import commonData from '../../data/commonData';
import HiLog from '../../utils/HiLog';
import { AudioPlayerService } from '../../service/AudioPlayerService';
import FileUtil, { formatFileSize, getMineTypeFromFileName, SavedFileInfo } from '../../utils/FileUtil';
import promptAction from '@ohos.promptAction';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import { Mms, ContactType, AddressInfo } from '../../utils/TypesUtils';
import image from '@ohos.multimedia.image';
import OperatorConfigUtil from '../../../cust/utils/OperatorConfigUtil';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import LooseObject from '../../data/LooseObject';
import myCommon from '@ohos.app.ability.common';
import MMPictureController from './MMPictureController';
import ObjectUtil from '../../utils/ObjectUtil';
import common from '../../data/commonData';
import lazy fs from '@ohos.file.fs';
import { BusinessError } from '@ohos.base';
import ConversationController from '../../pages/conversation/conversationController';
import { rcsFileInfo } from '../../pages/conversation/conversationController';
import StringUtil from '../../utils/StringUtil';
import lazy { VCardUtil } from '../../utils/VCardUtil';
import MmsUtil from '../../utils/MmsUtil';
import dotCommon, { mmsTypeParams } from '../../utils/MmsDot/DotCommon';
import DotUtil from '../../utils/MmsDot/DotUtils';
import fileUri from '@ohos.file.fileuri';
//import { filePreview } from '@kit.PreviewKit';
import { i18n, intl } from '@kit.LocalizationKit';
import { GlobalContextKey } from '../../data/commonData';
import { getTime } from '../../utils/SystemDateTimeUtil';
import { OBLIQUE } from '../../chatbot/utils/ChatbotFileUtils';
import MMMapController from './MMMapController'
import FileUtils from '../../utils/FileUtils';
import { NetUtils } from '../../utils/NetUtils';
import { LocationUtil } from '../../utils/LocationUtil';
//import { staticMap } from '@kit.MapKit';
import { SystemMode } from '../../utils/SystemMode';
import DeviceUtil from '../../utils/DeviceUtil';
import display from '@ohos.display';

const TAG = 'MMTabController';

export default class MMAttachmentAreaController {
  private static sInstance: MMAttachmentAreaController;
  mmDisplaySource: Array<Mms> = [];
  audioPlayerService: AudioPlayerService = AudioPlayerService.getInstance();
  public copySource: Array<Mms> = [];
  public isRcs: boolean = false;
  public rcsDisplaySource: Array<Mms> = [];
  public static readonly SUPPORTED_AUDIO_EXTENSION_NAMES =
    ['.mp3', '.m4a', '.aac', '.amr', '.jpg', '.png', '.gif', '.heic', '.bmp', '.jpeg', 'mp4', '3gp', 'heic', 'heif']
  public static readonly RCS_SUPPORTED_AUDIO_FILE_NAMES = ['.mp3', '.m4a', '.aac']
  public SUPPORTED_IMAGE_FILE_NAMES = ['jpg', 'png', 'gif', 'heic', 'bmp', 'jpeg', 'heic', 'heif']
  public SUPPORTED_VIDEO_FILE_NAMES = ['mp4', '3gp']
  private isTextAsMms: boolean = false;
  curMmsAttachmentType: null | number = null
  private isEnableMessage: boolean = SystemMode.getInstance().isEnableMessage;
  private padMargin: number = DeviceUtil.padMargin();

  static getInstance() {
    if (MMAttachmentAreaController.sInstance == null) {
      HiLog.i(TAG, 'getInstance');
      MMAttachmentAreaController.sInstance = new MMAttachmentAreaController();
    }
    return MMAttachmentAreaController.sInstance;
  }

  /* 根据系统模式判断一行放几个 */
  public tabsColumnsTemplateValue(displayOrientation: number, curBp: string): string {
    if (this.isEnableMessage) {
      // 5 个 附件
      if (DeviceUtil.isTablet() && this.padMargin === DeviceUtil.padLandSpaceMargin ||
        !DeviceUtil.isTablet() && curBp === commonData.STR.DEVICE_FLAT_PLATE) {
        return '1fr 1fr 1fr 1fr 1fr';
      } else {
        return '1fr 1fr 1fr 1fr';
      }
    } else {
      // 蓬莱模式下只有2个附件入口，位置和联系人
      if (!DeviceUtil.isTablet()) {
        return '1fr 1fr';
      } else {
        // 大平板
        if (this.padMargin === DeviceUtil.padLandSpaceMargin) {
          return '1fr 1fr 1fr 1fr 1fr';
        } else {
          // 小平板横屏
          if (displayOrientation == display.Orientation.LANDSCAPE ||
            displayOrientation == display.Orientation.LANDSCAPE_INVERTED) {
            return '1fr 2fr 2fr 2fr 1fr'
          } else {
            return '1fr 1fr 1fr';
          }
        }
      }
    }
  }

  public tabsRowsTemplateValue(displayOrientation: number, curBp: string) {
    let rowsTemplateValue = ''
    if (this.isEnableMessage) {
      rowsTemplateValue =  this.tabsColumnsTemplateValue(displayOrientation, curBp) === '1fr 1fr 1fr 1fr 1fr' ? '1fr' : '1fr 1fr'
    } else {
      rowsTemplateValue =  '1fr'
    }
    return rowsTemplateValue
  }

  refreshDisplay() {
    HiLog.i(TAG, 'refreshDisplay');
    let tabDisplayNeedChange: boolean = AppStorage.get('isAreaDisplayChange') as boolean;
    AppStorage.setOrCreate('isAreaDisplayChange', !tabDisplayNeedChange);
  }

  refreshConversation() {
    if (this.mmDisplaySource.length === 0) {
      AppStorage.setOrCreate('isConversationNeedChange', true);
    }
  }

  hasNeedReplaceVcard(){
    HiLog.i(TAG, 'hasNeedReplaceVcard');
    let checkVcard = false
    for(let i = 0; i < this.mmDisplaySource.length; i++) {
      const item = this.mmDisplaySource[i]
      if(item?.type && item?.type === common.MM_ATTACHMENT_TYPE.VCARD) {
        checkVcard = true
        break
      }
    }
    return checkVcard
  }

  async initSource(context: Context, isEnd: boolean, index: number) {
    let item = this.mmDisplaySource[index];
    let length = this.mmDisplaySource.length;
    if (!item) {
      return;
    }
    let copyItem = ObjectUtil.getCopyObject(item) as Mms;
    // Write images and videos to the sandbox.
    if (copyItem.type === common.MM_ATTACHMENT_TYPE.VIDEO) {
      copyItem.copyPath = copyItem.galleryPath ? copyItem.galleryPath : copyItem.path;
      copyItem.name = FileUtil.getFileName(copyItem.path);
    }
    if (copyItem.type === common.MM_ATTACHMENT_TYPE.IMAGE) {
      copyItem.copyPath = copyItem.galleryPath ? copyItem.galleryPath : copyItem.path;
      let a = await FileUtil.packingSize(copyItem.path)
      let name = FileUtil.getFileName(copyItem.path);
      item.name = name;
      HiLog.i(TAG, `initSource packingSize byteLength: ${a?.data?.byteLength}`);
      if (a.data.byteLength != 0) {
        let dotPosition = name.indexOf('.');
        let fileFormat: string = name.substring(dotPosition + 1);
        let mediaName = 'IMG_' + Date.now() + '.' + fileFormat;
        let targetPath = FileUtil.getSandboxPath(context) + '/' + mediaName;
        // 压缩图片后，删除源图片
        FileUtil.deleteFile(context, name);
        copyItem.name = mediaName;
        copyItem.path = targetPath;
        item.path = copyItem.path;
        item.name = mediaName;
        let file = fs.openSync(targetPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        let fd = file.fd;
        fs.writeSync(fd, a.data)
        fs.closeSync(file);
      } else {
        copyItem.name = name
      }
    }
    if (copyItem.type === common.MM_ATTACHMENT_TYPE.VCARD) {
      copyItem.copyPath = copyItem.galleryPath ? copyItem.galleryPath : copyItem.path;
      copyItem.name = FileUtil.getFileName(copyItem.path);
    }
    if (copyItem.type === commonData.MM_ATTACHMENT_TYPE.MAP) {
      copyItem.copyPath = copyItem.path;
      if (!copyItem.name) {
        copyItem.name = FileUtil.getFileName(copyItem.path);
      }
    }
    let size = FileUtil.getFileSizeByPath(copyItem.path);
    copyItem.size = JSON.stringify(size);
    item.size = copyItem.size;
    this.copySource.push(copyItem);
    if (length - 1 == index) {
      isEnd = true;
    }
    if (!isEnd) {
      await this.initSource(context, isEnd, ++index);
    }
  }

  /**
   * 用于拷贝生成彩信幻灯片消息的附件数据
   * @param context
   * @param isEnd
   * @param index
   * @param basePath
   * @param mmDisplaySource 可选参数，若指定且不为空，则使用该数据
   */
  async initSlideSource(context: Context, isEnd: boolean, index: number, basePath: string, mmDisplaySource?: Mms[]) {
    const tempMmDisplaySource = mmDisplaySource ?? this.mmDisplaySource;
    let item = tempMmDisplaySource[index];
    let length = tempMmDisplaySource.length;
    if (!item) {
      return;
    }
    let copyItem = ObjectUtil.getCopyObject(item) as Mms;
    // Write images and videos to the sandbox.
    if (copyItem.type === common.MM_ATTACHMENT_TYPE.VIDEO) {
      copyItem.copyPath = copyItem.galleryPath ? copyItem.galleryPath : copyItem.path;
      copyItem.name = FileUtil.getFileName(copyItem.path);
    }
    if (copyItem.type === common.MM_ATTACHMENT_TYPE.IMAGE) {
      copyItem.copyPath = copyItem.galleryPath ? copyItem.galleryPath : copyItem.path;
      let a = await FileUtil.packingSize(copyItem.path)
      let name = FileUtil.getFileName(copyItem.path);
      if (a.data.byteLength != 0) {
        let dotPosition = name.indexOf('.');
        let fileFormat: string = name.substring(dotPosition + 1);
        let mediaName = 'IMG_' + Date.now() + '_' + index + '.' + fileFormat;
        let targetPath = basePath + '/' + mediaName;
        FileUtil.deleteFile(context, name);
        copyItem.name = mediaName;
        copyItem.path = targetPath;
        item.path = copyItem.path;
        let file = fs.openSync(targetPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        let fd = file.fd;
        fs.writeSync(fd, a.data)
        fs.closeSync(file);
      } else {
        copyItem.name = name
      }
    }
    let size = FileUtil.getFileSizeByPath(copyItem.path);
    copyItem.size = JSON.stringify(size);
    item.size = copyItem.size;
    this.copySource.push(copyItem);
    if (length - 1 == index) {
      isEnd = true;
    }
    if (!isEnd) {
      await this.initSlideSource(context, isEnd, ++index, basePath, mmDisplaySource);
    }
  }

  private writeFileToSandBoxOfEnhancedInfo = (context: Context, copyItem: Mms, mediaType: string) => {
    let srcFileName = copyItem.name;
    let originalPath = copyItem.path;
    let dotPosition = srcFileName.indexOf('.');
    let fileFormat: string = srcFileName.substring(dotPosition + 1);
    let mediaName = `${mediaType}_` + (getTime(true) ?? Date.now()) + '.' + fileFormat;
    let targetPath = FileUtil.getSandboxPath(context) + OBLIQUE + mediaName;
    copyItem.copyPath = copyItem.path;
    this.copySrcFileToTargetSync(copyItem.copyPath, targetPath);
    copyItem.name = mediaName;
    copyItem.path = targetPath;
    FileUtil.deleteFile(context, srcFileName);
    // 视频类型消息需要删除之前生成的缩略图，后续会重新生成
    if (copyItem.type === common.ENHANCED_INFO_ITEM_TYPE.VIDEO)
    FileUtils.deleteVideoThumb(originalPath, context);
  }

  async initSourceOfEnhancedInfo(context: Context, isEnd: boolean, index: number, copySource: Mms[],
    mmDisplaySource?: Mms[]) {
    const attachmentDataList = mmDisplaySource ?? this.mmDisplaySource;
    let item = attachmentDataList[index];
    let length = attachmentDataList.length;
    if (!item) {
      return;
    }
    let copyItem = ObjectUtil.getCopyObject(item) as Mms;
    // Write images or Video to the sandbox.
    if (copyItem.type === common.ENHANCED_INFO_ITEM_TYPE.VIDEO && copyItem?.name) {
      this.writeFileToSandBoxOfEnhancedInfo(context, copyItem, 'VIDEO');
    } else if (copyItem.type === common.ENHANCED_INFO_ITEM_TYPE.IMAGE && copyItem?.name) {
      await this.writeImageToSandBoxOfEnhancedInfo(context, copyItem);
    } else if (copyItem.type === common.ENHANCED_INFO_ITEM_TYPE.VCARD && copyItem?.name) {
      this.writeFileToSandBoxOfEnhancedInfo(context, copyItem, 'VCARD');
    }
    let size = FileUtil.getFileSizeByPath(copyItem.path);
    copyItem.size = String(size);
    copySource.push(copyItem);
    if (length - 1 == index) {
      isEnd = true;
    }
    if (!isEnd) {
      await this.initSourceOfEnhancedInfo(context, isEnd, ++index, copySource, mmDisplaySource);
    }
  }

  private async writeImageToSandBoxOfEnhancedInfo(context: Context, copyItem: Mms) {
    let srcFileName = copyItem.name;
    let dotPosition = srcFileName.indexOf('.');
    let fileFormat: string = srcFileName.substring(dotPosition + 1);
    let mediaName = 'IMG_' + (getTime(true) ?? Date.now()) + '.' + fileFormat;
    let targetPath = FileUtil.getSandboxPath(context) + '/' + mediaName;
    copyItem.copyPath = copyItem.path;
    if (copyItem.isOriginalImage) {
      this.copySrcFileToTargetSync(copyItem.copyPath, targetPath);
    } else {
      let a = await FileUtil.packingSize(copyItem.path);
      if (a?.data?.byteLength !== 0) {
        let file = fs.openSync(targetPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        let fd = file.fd;
        fs.writeSync(fd, a.data);
        fs.closeSync(file);
      } else {
        this.copySrcFileToTargetSync(copyItem.copyPath, targetPath);
      }
    }
    copyItem.name = mediaName;
    copyItem.path = targetPath;
    FileUtil.deleteFile(context, srcFileName);
  }

  public copySrcFileToTargetSync(copyPath: string, targetPath: string) {
    try {
      let resourceFile: fs.File = fs.openSync(copyPath, fs.OpenMode.READ_ONLY);
      fs.copyFileSync(resourceFile.fd, targetPath, 0);
      fs.closeSync(resourceFile);
    } catch (e) {
      HiLog.i(TAG, `copySrcFileToTargetSync  copyFile fail, error: ${JSON.stringify(e)}`);
    }
  }

  setDisplaySource(context: Context, obj: Mms) {
    HiLog.i(TAG, 'setDisplaySource');
    if (obj) {
      this.refreshConversation();
      this.mmDisplaySource.push(obj);
      // 添加图片压缩处理
      if (this.mmDisplaySource.length > 0) {
        HiLog.i(TAG,'initSource packingSize')
        this.copySource = [];
        this.initSource(context, false, this.mmDisplaySource.length -1);
      }
      this.refreshDisplay();
      AppStorage.setOrCreate('isConversationNeedChange', true);
    } else {
      HiLog.i(TAG, 'setDisplaySource failed');
    }
  }

  setDisplaySourceOfEnhancedInfo(obj: Mms) {
    HiLog.i(TAG, 'setDisplaySourceOfEnhancedInfo');
    if (obj) {
      this.refreshConversation();
      this.mmDisplaySource.push(obj);
      this.refreshDisplay();
      AppStorage.setOrCreate('isConversationNeedChange', true);
    } else {
      HiLog.i(TAG, 'setDisplaySource failed');
    }
  }

  deleteTabDisplay(context: Context, item: Mms) {
    HiLog.i(TAG, 'deleteTabDisplay');
    if (item.type === commonData.MM_ATTACHMENT_TYPE.AUDIO) {
      this.audioPlayerService.stopAudio();
      mmsTypeParams.TYPE_STATUS = 1;
    } else if (item.type === commonData.MM_ATTACHMENT_TYPE.IMAGE) {
      mmsTypeParams.TYPE_STATUS = 2;
    } else if (item.type === commonData.MM_ATTACHMENT_TYPE.VIDEO) {
      mmsTypeParams.TYPE_STATUS = 3;
    } else if (item.type === commonData.MM_ATTACHMENT_TYPE.VCARD) {
      mmsTypeParams.TYPE_STATUS = commonData.int.TYPE_STATE_VCARD;
    } else if (item.type === commonData.MM_ATTACHMENT_TYPE.MAP) {
      mmsTypeParams.TYPE_STATUS = 5;
      mmsTypeParams.MODE_NAME = SystemMode.getInstance().mode;
    }
    // The type of the attachment to be deleted(DOT)
    DotUtil.getInstance().reportEvent(mmsTypeParams, dotCommon.eventName.DELETE_ATTACHMENTS_AREA);
    let fileSize: number = 0;
    if (item.size !== undefined) {
      fileSize = Number.parseFloat(item.size);
    }
    this.setTotalSize(false, item.path, fileSize);
    if (this.mmDisplaySource.length == 0) {
      GlobalContext.getContext().setObject('fileTotalSize', 0);
    }
    // Determine whether to convert to an SMS message.
    if (!ConversationController.getInstance().isRcsMms) {
      this.convertMsgInfo(false);
    }
    this.refreshConversation();
    FileUtil.deleteFile(context, item.name);
    FileUtils.deleteFile(item.path);
    // 视频删除时需要删除视频缩略图
    if (item.type === commonData.MM_ATTACHMENT_TYPE.VIDEO) {
      FileUtils.deleteVideoThumb(item.path, context);
    }
    this.copySource = [];
    AppStorage.setOrCreate('isConversationNeedChange', true);
  }

  handleEnhancedInfoCheckedChange(context: Context, mediaUri: string, selected: boolean, itemType: number,
    pixelMap?: PixelMap) {
    HiLog.i(TAG, 'handleEnhancedInfoCheckedChange start');
    if (selected) {
      if (itemType == MMPictureController.MESSAGE_ITEM_TYPE_PICTURE) {
        this.setPictureOrVideoOfEnhancedInfo(mediaUri, context, pixelMap, true);
      } else if (itemType === MMPictureController.MESSAGE_ITEM_TYPE_VIDEO) {
        //Not supported currently.
      }
    } else {
      let resList = this.mmDisplaySource.map(item => {
        return item.galleryPath;
      });
      let idx = resList.indexOf(mediaUri);
      if (idx > -1) {
        if (resList.length == 1) {
          animateTo({
            duration: 150, curve: Curve.Sharp
          }, () => {
            this.mmDisplaySource.splice(idx, 1);
          })
        } else {
          this.mmDisplaySource.splice(idx, 1);
        }
        this.changeSource(context);
      }

      let name = FileUtil.getFileName(mediaUri);
      this.setTotalSize(false, mediaUri);
      FileUtil.deleteFile(context, name);
      AppStorage.setOrCreate('isConversationNeedChange', true);
      this.refreshDisplay();
    }
  }

  handleCheckedChange(context: Context, mediaUri: string, selected: boolean, itemType: number, pixelMap?: PixelMap, callback?: Function) {
    HiLog.i(TAG, 'handleCheckedChange');
    if (selected) {
      this.isExceedSize(mediaUri).then(res => {
        if (res) {
          HiLog.i(TAG, 'exceed');
          if (callback) {
            callback();
          }
        } else {
          if (itemType == 1) {
            this.setPicture(context, mediaUri, pixelMap);
          } else if (itemType == 2) {
            this.setVideo(context, mediaUri, pixelMap);
          }
          this.convertMsgInfo(true);
        }
      })
    } else {
      let resList = this.mmDisplaySource.map(item => {
        return item.galleryPath;
      });
      let idx = resList.indexOf(mediaUri);
      if (idx > -1) {
        if (resList.length == 1) {
          animateTo({
            duration: 150, curve: Curve.Sharp
          }, () => {
            this.mmDisplaySource.splice(idx, 1);
          })
        } else {
          this.mmDisplaySource.splice(idx, 1);
        }
        if (idx == 0) {
          this.changeSource(context);
        }
      }

      let fileSize = GlobalContext.getContext().getObject('fileTotalSize') as number;
      let custMMSSize: number = OperatorConfigUtil.getInstance().getCustMMSSize(commonData.int.MMS_FILE_MAX_SIZE);
      if (fileSize && fileSize <= custMMSSize) {
        // Determine whether to convert to an SMS message.
        this.convertMsgInfo(false);
      }
      let name = FileUtil.getFileName(mediaUri);
      this.setTotalSize(false, mediaUri);
      FileUtil.deleteFile(context, name);
      this.refreshConversation();
      this.refreshDisplay();
    }
  }

  changeSource(context: Context) {
    HiLog.i(TAG, 'changeSource enter');
    let source = this.copySource.slice(0);
    for (let sourceElement of source) {
      fs.unlink(sourceElement.path, (err: BusinessError) => {
        if (err) {
          HiLog.e(TAG, 'remove file failed with error message: ' + err.message + ', error code: ' + err.code);
        } else {
          HiLog.i(TAG, 'sourceElement.name' + sourceElement.name + ' success');
        }
      });
    }
    this.copySource = [];
    this.initSource(context, false, 0);
  }

  setPicture(context: Context, imageUri: string, pixelMap?: image.PixelMap, flag?: boolean) {
    HiLog.i(TAG, 'setPicture');
    if (imageUri && imageUri !== commonData.STR.EMPTY_STR) {
      let path = FileUtil.writeMediaToSandBox(context, imageUri, commonData.MM_ATTACHMENT_TYPE.IMAGE, flag);
      // 图片重新写入沙箱后如果文件名称发生变化需要删除原文件 拍照、相册加入附件区图片路径为uri 需要获取FileName再沙箱中拼接路径删除
      // 路径类似file://com.ohos.mms/data/storage/el2/base/haps/entry/files/**** 删除会报错13900002
      if (FileUtil.getFileName(imageUri) !== FileUtil.getFileName(path)) {
        FileUtil.deleteFile(context, FileUtil.getFileName(imageUri));
      }
      let name: string
      if (flag) {
        name = FileUtil.getFileName(path)
      } else {
        name = FileUtil.getFileName(imageUri)
      }
      let obj: Mms = {
        type: commonData.MM_ATTACHMENT_TYPE.IMAGE,
        name: name,
        path: path,
        duration: '',
        galleryPath: imageUri
      };
      if (pixelMap) {
        obj.pixelMap = pixelMap
      }
      animateTo({
        duration: 300, curve: Curve.Sharp
      }, () => {
        this.setDisplaySource(context, obj);
      })
    } else {
      HiLog.i(TAG, 'setPicture failed');
    }
  }

  async setPictureOrVideoOfEnhancedInfo(imageUri: string, context: Context, pixelMap?: image.PixelMap,
    isOriginalImage?: boolean,
    isRefreshDisplay?: boolean) {
    HiLog.i(TAG, 'setPictureOfEnhancedInfo');
    if (imageUri) {
      const isVideo: boolean = imageUri.endsWith('mp4');
      let obj: Mms = {
        type: isVideo ? commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO :
        commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE,
        name: FileUtil.getFileName(imageUri),
        path: imageUri,
        duration: '',
        galleryPath: imageUri,
        isOriginalImage: isOriginalImage ?? false,
        isRcs: true
      };
      if (pixelMap) {
        obj.pixelMap = pixelMap
      }
      if (isVideo && context) {
        let thumbnailPath = await this.generateVideoThumbnailOfRcs(imageUri, context);
        obj.videoThumbnailUri = fileUri.getUriFromPath(thumbnailPath);
      }
      if (isRefreshDisplay) {
        animateTo({
          duration: 300, curve: Curve.Sharp
        }, () => {
          this.setDisplaySourceOfEnhancedInfo(obj);
        })
      } else {
        this.mmDisplaySource.push(obj);
      }
    } else {
      HiLog.i(TAG, 'setPictureOfEnhancedInfo failed');
    }
  }

  private generateVideoThumbnailOfRcs(imageUri: string, context: Context) {
    if (!context || !imageUri) {
      return Promise.resolve('');
    }
    return new Promise((resolve: (thumbnailPath: string) => void, reject: () => void) => {
      try {
        const file = new fileUri.FileUri(imageUri);
        FileUtil.writeVideoFirstFrameImageToSandBox(context, file.path, file.name, (thumbnailPath) => {
          resolve(thumbnailPath);
        });
      } catch (e) {
        HiLog.e(TAG, 'generateVideoThumbnail failed, error: ' + JSON.stringify(e));
        resolve('');
      }
    })
  }

  setVideo(context: Context, videoUri: string, pixelMap?: PixelMap) {
    HiLog.i(TAG, 'setVideo');
    if (videoUri && videoUri !== commonData.STR.EMPTY_STR) {
      let path = FileUtil.writeMediaToSandBox(context, videoUri, commonData.MM_ATTACHMENT_TYPE.VIDEO);
      // 视频重新写入沙箱文件名称发生变化后需要删除原文件 拍照、相册加入附件区图片路径为uri 需要获取FileName再沙箱中拼接路径删除
      // file://com.ohos.mms/data/storage/el2/base/haps/entry/files/**** 直接使用uri 删除会报错13900002
      if (FileUtil.getFileName(videoUri) !== FileUtil.getFileName(path)) {
        FileUtil.deleteFile(context, FileUtil.getFileName(videoUri));
      }
      let obj: Mms = {
        name: FileUtil.getFileName(path),
        type: commonData.MM_ATTACHMENT_TYPE.VIDEO,
        path: path,
        pixelMap: pixelMap,
        duration: '',
        galleryPath: videoUri
      };
      this.setDisplaySource(context, obj);
    } else {
      HiLog.i(TAG, 'setVideo failed');
    }
  }

  setAudio(context: Context, time: string, fdPath: string, name: string, fromReplace?: boolean) {
    HiLog.i(TAG, 'setAudio');
    if (time && time !== commonData.STR.EMPTY_STR && fdPath !== commonData.STR.EMPTY_STR) {
      let obj: Mms = {
        duration: time,
        path: fdPath,
        type: commonData.MM_ATTACHMENT_TYPE.AUDIO,
        name: name,
        isOnAudio: false
      };
      this.setDisplaySource(context, obj);
      this.convertMsgInfo(true, fromReplace);
    } else {
      HiLog.i(TAG, 'setAudio failed');
    }
  }

  setRcsAudio(time: string, fdPath: string, name: string) {
    HiLog.i(TAG, 'setRcsAudio');
    if (time && time !== commonData.STR.EMPTY_STR && fdPath !== commonData.STR.EMPTY_STR) {
      let obj: Mms = {
        duration: time,
        path: fdPath,
        type: commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO,
        name: name,
        isOnAudio: false
      };
      if (obj) {
        this.rcsDisplaySource.push(obj);
      }
    } else {
      HiLog.i(TAG, 'setRcsAudio failed');
    }
  }

  async setTotalSize(isAdd: boolean, path: string, currentfileSize?: number, isDragImage?: boolean) {
    AppStorage.setOrCreate('setTotalSizeFlag', true);
    HiLog.i(TAG, `setTotalSize isAdd: ${isAdd}`);
    let exceed: boolean = false;
    let fileSize = GlobalContext.getContext().getObject('fileTotalSize') as number;
    fileSize = !fileSize ? 0 : fileSize;
    if (fileSize < 0) {
      return false;
    }
    HiLog.i(TAG, 'setTotalSize fileSize is:' + JSON.stringify(fileSize))
    let size: number = 0;
    if (path.indexOf('file') === 0) {
      await FileUtil.packingSize(path, undefined, isDragImage).then(res => {
        if (res.size == 0) {
          AppStorage.setOrCreate('setTotalSizeFlag', false);
          return false;
        }
        size = res.size;
        let totalSize = fileSize;
        if (isAdd) {
          totalSize = fileSize + size;
          let custMMSSize: number = OperatorConfigUtil.getInstance().getCustMMSSize(commonData.int.MMS_FILE_MAX_SIZE);
          if (totalSize > custMMSSize) {
            HiLog.i(TAG, 'size exceed %dkb', custMMSSize);
            exceed = true;
          }
        } else {
          totalSize = (fileSize - size) < 0 ? 0 : (fileSize - size);
        }
        GlobalContext.getContext().setObject('fileTotalSize', totalSize);
        AppStorage.setOrCreate('setTotalSizeFlag', false);
        return exceed;
      })
    } else {
      size = this.getFileSize(path, currentfileSize);
      let totalSize = fileSize;
      if (isAdd) {
        totalSize = fileSize + size;
        let custMMSSize: number = OperatorConfigUtil.getInstance().getCustMMSSize(commonData.int.MMS_FILE_MAX_SIZE);
        if (totalSize > custMMSSize) {
          HiLog.i(TAG, 'size exceed %dkb', custMMSSize);
          exceed = true;
        }
      } else {
        totalSize = (fileSize - size) < 0 ? 0 : (fileSize - size);
      }
      GlobalContext.getContext().setObject('fileTotalSize', totalSize);
    }
    AppStorage.setOrCreate('setTotalSizeFlag', false);
    return exceed;
  }

  getFileSize(path: string, currentfileSize?: number): number {
    let size = FileUtil.getFileSizeByPath(path);
    if (size == 0 && currentfileSize !== undefined) {
      size = currentfileSize;
    }
    return size;
  }

  /**
   * 附件区清空同时删除附件区存储在沙箱的资源文件
   *
   * @param context 上下文
   */
  resetMmsAndDeleteSource(context: Context) {
    HiLog.i(TAG, 'resetMmsAndDeleteSource');
    // 附件区清空同时删除附件区存储在沙箱的资源文件
    this.mmDisplaySource.forEach((item) => {
      this.setTotalSize(false, item.path);
      FileUtil.deleteFile(context, FileUtil.getFileName(item.path));
      FileUtil.deleteFile(context, item.name);
      // 视频删除时需要删除视频缩略图
      if (item.type === commonData.MM_ATTACHMENT_TYPE.VIDEO) {
        FileUtils.deleteVideoThumb(item.path, context);
      }
    });
    this.resetMms(true);
  }

  /**
   * 附件区清空
   *
   * @param isFromAfterDeleteSource 是否为执行附件区清空同时删除附件区存储在沙箱的资源文件之后操作
   */
  resetMms(isFromAfterDeleteSource?: boolean) {
    HiLog.i(TAG, 'resetMms');
    if (!isFromAfterDeleteSource) {
      this.mmDisplaySource.forEach((item) => {
        this.setTotalSize(false, item.path);
      });
    }
    GlobalContext.getContext().setObject('fileTotalSize', 0);
    this.mmDisplaySource = [];
    this.copySource = [];
    this.rcsDisplaySource = [];
    AppStorage.setOrCreate('pictureSelectedNumber', 0);
    this.refreshDisplay();
  }

  /**
   * 待发区存在 vcard 时，为保证 vcard 互斥逻辑，替换 vcard
   *
   * @param context
   */
  replaceVcard(context: Context, callback: Function) {
    this.resetMmsAndDeleteSource(context);
    if (this.curMmsAttachmentType === commonData.MM_SELECT_ATTACHMENT_TYPE.GALLERY) {
      MMPictureController.getInstance().handlePhotoSelectResultOfRCS(context)
    } else if (this.curMmsAttachmentType === commonData.MM_SELECT_ATTACHMENT_TYPE.CAMERA) {
      callback()
    } else if (this.curMmsAttachmentType === commonData.MM_SELECT_ATTACHMENT_TYPE.MAP) {
      MMMapController.getInstance().handleLocation(context)
    }
  }

  convertMsgInfo(toMms: boolean, fromReplace?: boolean) {
    HiLog.i(TAG, 'convertMsgInfo');
    if (ConversationController.getInstance().isRcsMms) {
      return;
    }
    if (this.isTextAsMms) {
      HiLog.i(TAG, 'no need show toast for text mms');
      return;
    }
    if (fromReplace) {
      return;
    }
    if (toMms && this.mmDisplaySource.length === 1) {
      this.showToast($r('app.string.converting_mms'));
    } else if (!toMms && this.mmDisplaySource.length === 0) {
      this.showToast($r('app.string.converting_sms'));
    }
  }

  async isExceedSize(mediaUri: string): Promise<boolean> {
    let isExceed = await this.setTotalSize(true, mediaUri);
    if (isExceed) {
      // Over 300kb Deleted Data
      HiLog.i(TAG, 'isExceedSize exceed');
      let maxSize: number = OperatorConfigUtil.getInstance().getCustMMSSize(
        commonData.int.MMS_FILE_MAX_SIZE) / commonData.int.BYTE_CONVERSION_UNIT;
      let countryId = i18n.System.getSystemRegion();
      let numberFormat = new intl.NumberFormat(countryId, {
        style: 'unit', unit: 'kilobyte'
      });
      let masxSiseStr = numberFormat.format(maxSize);
      let msg: Resource = $r('app.string.attachment_failed', masxSiseStr);
      MmsUtil.showToast({
        message: msg,
        duration: 2000
      });
    }
    return isExceed;
  }

  async isExceedSizeNotShowToast(mediaUri: string, isDragImage?: boolean): Promise<boolean> {
    let isExceed = await this.setTotalSize(true, mediaUri, undefined, isDragImage);
    return isExceed;
  }

  isAttachmentUpperLimit(): boolean {
    HiLog.i(TAG, 'isAttachmentUpperLimit');
    if (this.mmDisplaySource.length >= commonData.int.MMS_ATTACHMENT_UPPER_LIMIT) {
      HiLog.i(TAG, 'isAttachmentUpperLimit true');
      this.showToast($r('app.string.attachment_upper_limit', commonData.int.MMS_ATTACHMENT_UPPER_LIMIT,
        commonData.int.MMS_ATTACHMENT_UPPER_LIMIT));
      return true;
    }
    return false;
  }

  checkImageNumOfEnhancedInfo() {
    if (this.mmDisplaySource.length >= commonData.int.MMS_ATTACHMENT_UPPER_LIMIT_ENHANCED_INFO_MODE) {
      HiLog.i(TAG, 'checkImageNumOfEnhancedInfoMode fail');
      this.showToast($r('app.string.attachment_upper_limit',
        commonData.int.MMS_ATTACHMENT_UPPER_LIMIT_ENHANCED_INFO_MODE,
        commonData.int.MMS_ATTACHMENT_UPPER_LIMIT_ENHANCED_INFO_MODE));
      return false;
    } else {
      HiLog.i(TAG, 'checkImageNumOfEnhancedInfoMode success');
      return true;
    }
  }

  showToast(msg: ResourceStr) {
    try {
      promptAction.showToast({
        message: msg,
        duration: 2000
      });
    } catch (err) {
      HiLog.e(TAG, `showToast error: ${err}`);
    }
  }

  async refreshBackProcessDisplay() {
    let photoAccessHelper = await import('@ohos.file.photoAccessHelper');
    const context = (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);
    let mPhotoAccessHelper = photoAccessHelper.default.getPhotoAccessHelper(context);

    try {
      let predicates = new dataSharePredicates.DataSharePredicates();
      let fetchResult = await mPhotoAccessHelper.getAssets({
        fetchColumns: [],
        predicates: predicates
      });
      let photoAssetList = await fetchResult.getAllObjects();
      let existArr: Array<Mms> = [];
      if (photoAssetList && photoAssetList.length >= 0 && this.mmDisplaySource.length > 0) {
        this.mmDisplaySource.forEach((ele, index) => {
          if (ele.type !== commonData.MM_ATTACHMENT_TYPE.AUDIO) {
            if (!photoAssetList.some(item => item.uri == ele.path)) {
              MMPictureController.getInstance().selectedMsgCount--;
              this.deleteTabDisplay(context, ele);
            } else {
              existArr.push(ele);
            }
          } else {
            existArr.push(ele);
          }
        })
        this.mmDisplaySource = existArr;
      } else {
        this.resetMms()
      }
    } catch (error) {
      HiLog.e(TAG, 'refreshBackProcessDisplay error = ' + error);
    }
  }

  async initRcsSource(context: Context, isEnd: boolean, index: number) {
    let item = this.rcsDisplaySource[index];
    let length = this.rcsDisplaySource.length;
    if (!item) {
      return;
    }
    let copyItem = ObjectUtil.getCopyObject(item) as Mms;
    // Write images and videos to the sandbox.
    if (copyItem.type === common.MM_ATTACHMENT_TYPE.VIDEO) {
      copyItem.copyPath = copyItem.galleryPath ? copyItem.galleryPath : copyItem.path;
      copyItem.name = FileUtil.getFileName(copyItem.path);
    }
    if (copyItem.type === common.MM_ATTACHMENT_TYPE.IMAGE) {
      copyItem.copyPath = copyItem.galleryPath ? copyItem.galleryPath : copyItem.path;
      let a = await FileUtil.packingSize(copyItem.path)
      let name = FileUtil.getFileName(copyItem.path);
      if (a.data.byteLength != 0) {
        let dotPosition = name.indexOf('.');
        let fileFormat: string = name.substring(dotPosition + 1);
        let mediaName = 'IMG_' + Date.now() + '.' + fileFormat;
        let targetPath = FileUtil.getSandboxPath(context) + '/' + mediaName;
        copyItem.name = mediaName;
        copyItem.path = targetPath;
        let file = fs.openSync(targetPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        let fd = file.fd;
        fs.writeSync(fd, a.data)
        fs.closeSync(file);
      } else {
        copyItem.name = name
      }
    }
    let size = FileUtil.getFileSizeByPath(copyItem.path);
    copyItem.size = JSON.stringify(size);
    this.copySource.push(copyItem);
    if (length - 1 == index) {
      isEnd = true;
    }
    if (!isEnd) {
      await this.initSource(context, isEnd, index++);
    }
  }

  refreshRcsConversation() {
    if (this.rcsDisplaySource.length === 0) {
      AppStorage.setOrCreate('isConversationNeedChange', true);
    }
  }

  async setMmsVcard(context: Context, contacts: ContactType[], fromReplace: boolean){
    let vcfFileInfo: SavedFileInfo =
      VCardUtil.getInstance().generateVcf(context, VCardUtil.getInstance().dealSelectedContactsToVcfItems(contacts, false));
    if (!StringUtil.isEmpty(vcfFileInfo.path)) {
      let obj: Mms = {
        name: vcfFileInfo.name,
        type: commonData.MM_ATTACHMENT_TYPE.VCARD,
        path: vcfFileInfo.path,
        duration: '',
        contacts,
      };
      try {
        const isExceed =  await this.isExceedSizeNotShowToast(obj.path)
        if(isExceed){
          // Over 300kb Deleted Data
          let maxSize: number = OperatorConfigUtil.getInstance().getCustMMSSize(
            commonData.int.MMS_FILE_MAX_SIZE) / commonData.int.BYTE_CONVERSION_UNIT;
          let countryId = i18n.System.getSystemRegion();
          let numberFormat = new intl.NumberFormat(countryId, {
            style: 'unit', unit: 'kilobyte'
          });
          let masxSiseStr = numberFormat.format(maxSize);
          promptAction.showToast({
            message: $r('app.string.attachment_failed', masxSiseStr),
            duration: 2000
          });
          FileUtil.deleteFile(context, vcfFileInfo.name);
        }else{
          this.setDisplaySource(context, obj);
          if (!fromReplace) {
            this.showToast($r('app.string.converting_mms'));
          }
          HiLog.i(TAG, 'setMmsVcard success');
        }
      } catch (err) {
        HiLog.e(TAG, 'setMmsVcard error = ' + JSON.stringify(err));
      }
    }else{
      HiLog.i(TAG, 'setMmsVcard failed');
    }
  }

  /**
   * Set vcard obj to attach list
   *
   * @param contacts
   */
  async setVcard(context: Context, contacts: ContactType[]) {
    let vcfFileInfo: SavedFileInfo =
      VCardUtil.getInstance().generateVcf(context, VCardUtil.getInstance().dealSelectedContactsToVcfItems(contacts, false));
    let isCheckPass = await MMPictureController.checkFileOfEnhancedInfo(vcfFileInfo.path);
    if (isCheckPass === false) {
      HiLog.i(TAG, 'setVcard checkFileOfEnhancedInfo false');
      // 校验失败后删除沙箱中的文件
      FileUtil.deleteFile(context, FileUtil.getFileName(vcfFileInfo.path));
      for (let element of contacts) {
        FileUtil.deleteFile(context, FileUtil.getFileName(element.photoPath ?? ''));
      }
      return;
    }
    if (!StringUtil.isEmpty(vcfFileInfo.path)) {
      let obj: Mms = {
        name: vcfFileInfo.name,
        type: commonData.ENHANCED_INFO_ITEM_TYPE.VCARD,
        path: vcfFileInfo.path,
        duration: '',
        contacts,
      };
      this.refreshRcsConversation();
      this.rcsDisplaySource.push(obj);
      this.refreshDisplay();
      AppStorage.setOrCreate('isConversationNeedChange', true);
      HiLog.i(TAG, 'setVcard success');
    }
  }

  /**
   * 处理从文件中发送增强信息语音消息(.amr文件)的场景
   * @param context
   * @param receiverData
   * @param isCalledInNewConversation 是否在新建会话场景被调用
   * @param sendAudioInNewConversation 在新建会话发送增强信息语音消息
   */
  public handleAndSendAudioFile = async (context: Context, receiverData: rcsFileInfo,
    isCalledInNewConversation: boolean, sendAudioInNewConversation: () => void) => {
    HiLog.iw(TAG, `handleAndSendAudioFile: isCalledInNewConversation: ${isCalledInNewConversation}`);
    try {
      await this.setAudioFileInfo(receiverData);
      if (isCalledInNewConversation) {
        sendAudioInNewConversation();
      } else {
        const conversationController = ConversationController.getInstance();
        conversationController.sendAudio(context);
      }
    } catch (e) {
      HiLog.i(TAG, `handleAndSendAudioFile: error: ${e?.code} ${e?.message}`);
    }
  }

  getDuration(second: number) {
    if (isNaN(second)) {
      return '00:00'
    }
    let minute: number = 0;
    if (second >= 60) {
      minute = Math.floor(second / 60)
      second = second - minute * 60
    }
    return ((minute >= 10) ? minute : ('0' + minute)) + ':' +
      ((second >= 10) ? second : ('0' + second));
  }

  async setAudioFileInfo(fileInfo: rcsFileInfo) {
    if (StringUtil.isEmpty(fileInfo.sandBoxPath)) {
      return;
    }
    let fileSize: string = formatFileSize(fileInfo.size, 2);
    let type: number = commonData.ENHANCED_INFO_ITEM_TYPE.FILE;

    type = commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO;
    let audioPlayerService = AudioPlayerService.getInstance();
    let audioTime = await audioPlayerService.getAudioDuration(fileInfo.sandBoxPath);
    audioTime = audioTime || '';
    audioPlayerService.realseAvPlayerForParseAudio();
    let audioDuration = parseInt(audioTime) / common.int.MESSAGE_CODE_THOUSAND;
    audioDuration = Math.floor(audioDuration);
    audioTime = this.getDuration(audioDuration)

    let obj: Mms = {
      name: fileInfo.name,
      type: type,
      path: fileInfo.sandBoxPath,
      duration: audioTime,
      size: fileSize,
      copyPath: ''
    };

    this.refreshRcsConversation();
    this.rcsDisplaySource.push(obj);
    this.refreshDisplay();
    AppStorage.setOrCreate('isConversationNeedChange', true);
  }

  async setFileInfo(fileInfo: rcsFileInfo) {
    if (!StringUtil.isEmpty(fileInfo.sandBoxPath)) {
      let fileSize: string = formatFileSize(fileInfo.size, 2);
      let type: number = commonData.ENHANCED_INFO_ITEM_TYPE.FILE;
      let fileNameInfo = fileInfo.name.split('.');
      let fileExtensionName = fileNameInfo[fileNameInfo.length - 1].toLowerCase();
      let audioTime: string = '';
      if (MMAttachmentAreaController.RCS_SUPPORTED_AUDIO_FILE_NAMES.some(v => (v.indexOf(fileExtensionName) > -1))) {
        type = commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE;
      } else if (fileExtensionName && this.SUPPORTED_IMAGE_FILE_NAMES.includes(fileExtensionName)) {
        type = commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE
      } else if (fileExtensionName && this.SUPPORTED_VIDEO_FILE_NAMES.includes(fileExtensionName)) {
        type = commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO
      } else {
        type = commonData.ENHANCED_INFO_ITEM_TYPE.FILE;
      }
      let obj: Mms = {
        name: fileInfo.name,
        type: type,
        path: fileInfo.sandBoxPath,
        duration: audioTime,
        size: fileSize,
        copyPath: ''
      };

      this.refreshRcsConversation();
      this.rcsDisplaySource.push(obj);
      this.refreshDisplay();
      AppStorage.setOrCreate('isConversationNeedChange', true);
    }
  }

  public previewRcsMessageWithPathOrUri = async (pathOrUri: string, name: string, isUri: boolean) => {
    if (!pathOrUri || !name) {
      return;
    }
    let uiContext = getContext(this) as myCommon.UIAbilityContext;
    let messageFileUri = isUri ? pathOrUri : fileUri.getUriFromPath(pathOrUri);
    GlobalContext.getContext().setObject(GlobalContextKey.IS_JUMP_TO_PREVIEW, true);
    // let isCanPreview = await filePreview.canPreview(uiContext, messageFileUri).then((result) => {
    //   HiLog.i(TAG, 'previewRcsMessageWithPathOrUri canPreview. result = ' + result);
    //   return result;
    // }).catch((err: BusinessError) => {
    //   HiLog.i(TAG, 'previewRcsMessageWithPathOrUri canPreview failed, err = ' + JSON.stringify(err));
    //   return false;
    // })
    // if (isCanPreview === false) {
    //   return;
    // }
    //
    // let fileInfo: filePreview.PreviewInfo = {
    //   title: decodeURIComponent(name),
    //   uri: messageFileUri,
    //   mimeType: getMineTypeFromFileName(name)
    // };
    // filePreview.openPreview(uiContext, fileInfo).then(() => {
    //   HiLog.i(TAG, 'previewRcsMessageWithPathOrUri openPreview success');
    // }).catch((err: BusinessError) => {
    //   HiLog.e(TAG, 'previewRcsMessageWithPathOrUri openPreview failed, err = ' + JSON.stringify(err));
    // });
  }

  /**
   * After a user selects an address, the address information needs to be assembled into an Mms.
   *
   * @param addressInfo
   * @param pixelMap
   */
  public setMap(addressInfo: AddressInfo, mapImgName: string, jpegPath: string) {
    HiLog.i(TAG, 'setMap');
    this.refreshConversation();
    let addressJson: string = this.getRcsAddressJson(addressInfo);
    let obj: Mms = {
      name: mapImgName,
      type: commonData.ENHANCED_INFO_ITEM_TYPE.MAP,
      address: addressInfo,
      duration: '',
      path: jpegPath,
      content: addressJson,
    };
    this.mmDisplaySource.push(obj);
    this.refreshDisplay();
    AppStorage.setOrCreate('isConversationNeedChange', true);
  }

  public getRcsAddressJson(addressInfo: AddressInfo) {
    let accuracy: number = 0;
    let arrLocInfo: string = addressInfo.name + ';' + addressInfo.address;
    let arrAddressInfo: [RcsMapInfo] = [{
      'body': arrLocInfo,
      'longitude': addressInfo.longitude.toString(),
      'latitude': addressInfo.latitude.toString(),
      'accuracy': accuracy.toString(),
    }];
    let addressJson: string = '';
    try {
      addressJson = JSON.stringify(arrAddressInfo);
      addressJson = addressJson.slice(1, -1);
    } catch (err) {
      HiLog.e(TAG, 'setMap splicing err=' + JSON.stringify(err));
    }
    return addressJson;
  }

  public setTextMms(isTextAsMms: boolean) {
    this.isTextAsMms = isTextAsMms
  }

  /**
   * 生成彩信位置消息的位置图片
   */
  // private generateMapImage = (location: mapCommon.LatLng) => {
  //   try {
  //     let markers: staticMap.StaticMapMarker[] = [
  //       {
  //         'location': location
  //       }
  //     ]
  //     let mapOptions: staticMap.StaticMapOptions = {
  //       'location': location,
  //       'zoom': commonData.MMS_MAP_CONSTANT.MAP_ZOOM,
  //       'imageWidth': commonData.MMS_MAP_CONSTANT.IMAGE_WIDTH,
  //       'imageHeight': commonData.MMS_MAP_CONSTANT.IMAGE_WIDTH / commonData.MMS_MAP_CONSTANT.ASPECT_RATIO,
  //       'scale': commonData.MMS_MAP_CONSTANT.SCALE,
  //       'markers': markers
  //     }
  //
  //     return LocationUtil.getMapImageOfMms(mapOptions);
  //   } catch (e) {
  //     HiLog.e(TAG, `getMapImageOfMms error: ${e?.code} ${e?.message}`);
  //   }
  //   return Promise.resolve(null);
  // }

  /**
   * 添加所选彩信位置信息到附件待发区
   * @param context
   * @param uiContext
   * @param address
   * @param fromReplace 是否在附件待发区替换彩信vCard
   */
  public async handleLocationOfMms(context: Context | undefined, uiContext: UIContext,
    address: AddressInfo | undefined, fromReplace?: boolean) {
    if (!context || !uiContext) {
      HiLog.e(TAG, 'handleLocationOfMms: context or uiContext empty');
      return;
    }

    if (!address) {
      HiLog.e(TAG, 'handleLocationOfMms: address empty');
      return;
    }
    //判断网络状态
    const netConnectType = await NetUtils.getNetConnectType();
    HiLog.i(TAG, 'handleLocationOfMms netConnectType: ' + netConnectType);
    if (netConnectType === 'noNet') {
      uiContext.getPromptAction().showToast({
        message: $r('app.string.net_no_connection'),
        duration: 2000,
      });
      return;
    }

    AppStorage.setOrCreate('selectPicFromGalleryDone', true);

    //根据位置信息生成位置图片
    // let pixelMap = await this.generateMapImage({
    //   longitude: address.longitude,
    //   latitude: address.latitude
    // });

    let pixelMap = null

      let mapImgName: string = address.buildMapImgName();
    let jpegPath = FileUtil.getSandboxPath(context) + '/' + mapImgName;

    let size: number = 0;
    if (pixelMap) {
      size = await FileUtil.packPixelMapToSandBox(context, jpegPath, pixelMap, mapImgName, true);
    }

    //若待添加的位置消息和之前的附件消息的总大小大于300KB则提示超出附件上限，不添加该位置消息
    let fileSize = Number(GlobalContext.getContext().getObject('fileTotalSize')) || 0;
    let custMMSSize: number = OperatorConfigUtil.getInstance().getCustMMSSize(commonData.int.MMS_FILE_MAX_SIZE);
    if (fileSize + size > custMMSSize) {
      FileUtils.deleteFileByPathOrUri(jpegPath);
      let maxSize: number = custMMSSize / commonData.int.BYTE_CONVERSION_UNIT;
      let countryId = i18n.System.getSystemRegion();
      let numberFormat = new intl.NumberFormat(countryId, {
        style: 'unit', unit: 'kilobyte'
      });
      uiContext.getPromptAction().showToast({
        message: $r('app.string.attachment_failed', numberFormat.format(maxSize)),
        duration: 2000,
      });
      return;
    }

    // 将位置消息添加到附件待发区
    let item: Mms = {
      name: mapImgName,
      type: commonData.MM_ATTACHMENT_TYPE.MAP,
      path: jpegPath,
      duration: '',
      address: address,
      pixelMap: undefined,
      text: JSON.stringify(address)
    };
    uiContext.animateTo({
      duration: 300, curve: Curve.Sharp
    }, () => {
      if (this.mmDisplaySource.length === 0 && !fromReplace) { // 当附件待发区没有内容，第一次添加的时候才提示
        uiContext.getPromptAction().showToast({
          message: $r('app.string.converting_mms'),
          duration: 2000
        });
      }
      this.setDisplaySource(context, item);

      // 添加联系人附件打点
      mmsTypeParams.TYPE_STATUS = 5;
      mmsTypeParams.MODE_NAME = SystemMode.getInstance().mode;
      DotUtil.getInstance().reportEvent(mmsTypeParams, dotCommon.eventName.ADD_ATTACHMENT);
    })

    // 发送按钮上显示已添加附件的总大小
    this.setTotalSize(true, jpegPath);
    AppStorage.setOrCreate('isConversationNeedChange', true);
  }
}

export interface RcsMapInfo {
  body: string;
  longitude: string;
  latitude: string;
  accuracy: string;
}