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

import LooseObject from '../../data/LooseObject';
import MMPictureDataSource from '../../model/MMPictureDataSource';
import HiLog from '../../utils/HiLog';
import MMAttachmentAreaController from './MMAttachmentAreaController';
import lazy photoAccessHelper from '@ohos.file.photoAccessHelper';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import myCommon from '@ohos.app.ability.common';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import commonData from '../../data/commonData';
import { BusinessError } from '@ohos.base';
import promptAction from '@ohos.promptAction';
import { Permissions } from '@ohos.abilityAccessCtrl';
import { Mms, PictureListData } from '../../utils/TypesUtils';
import FileUtil from '../../utils/FileUtil';
import MmsUtil from '../../utils/MmsUtil';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';
import bundleManager from '@ohos.bundle.bundleManager';
import OperatorConfigUtil from '../../../cust/utils/OperatorConfigUtil';
import lazy fs from '@ohos.file.fs';
import fileuri from '@ohos.file.fileuri';
import DotUtil from '../../utils/MmsDot/DotUtils';
import dotCommon, { mmsTypeParams } from '../../utils/MmsDot/DotCommon';
import { i18n, intl } from '@kit.LocalizationKit';
import fileUri from '@ohos.file.fileuri';
import { image } from '@kit.ImageKit';
import ImageUtil from '../../utils/ImageUtil';

const TAG = 'MMPictureController ';
const SUPPORT_VIDEO_FORMAT = '.mp4';
const SUPPORT_VIDEO_FORMAT_LIST = ['.mp4', '.3gp'];
const VIDEO_FILE_PATH_INCLUDE = 'VID';
const IMAGE_MAX_WIDTH = 7680;
const IMAGE_MAX_SIZE = '8K';

export default class MMPictureController {
  private static sInstance: MMPictureController;
  pictureDataSource: MMPictureDataSource = new MMPictureDataSource();
  mmAreaController: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
  pictureList: Array<PictureListData> = [];
  // Deleted Count
  selectedMsgCount: number = 0;
  public isRcs: boolean = false;
  public static readonly MESSAGE_ITEM_TYPE_PICTURE = 1;
  public static readonly MESSAGE_ITEM_TYPE_VIDEO = 2;
  private isTextAsMms: boolean = false;
  public photoSelectRes: null | photoAccessHelper.PhotoSelectResult = null;
  public photoSelectResOfRCS: undefined | photoAccessHelper.PhotoSelectResult = undefined;

  static getInstance() {
    if (MMPictureController.sInstance == null) {
      MMPictureController.sInstance = new MMPictureController();
    }
    return MMPictureController.sInstance;
  }

  async checkAccessToken(permissionName: Permissions): Promise<boolean> {
    let atManager = abilityAccessCtrl.createAtManager();
    let info = await bundleManager.getApplicationInfo(commonData.STR.BUNDLE_NAME, bundleManager.ApplicationFlag.GET_APPLICATION_INFO_WITH_PERMISSION)
    let hasPermission = atManager.verifyAccessTokenSync(info.accessTokenId, permissionName);
    return hasPermission === 0;
  }

  async initPermission(permissionName: Permissions): Promise<boolean> {
    let atManager = abilityAccessCtrl.createAtManager();
    let permissions: Array<Permissions> = []
    permissions.push(permissionName);
    let context = (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);
    let permissionResult = await atManager.requestPermissionsFromUser(context, permissions)
    return permissionResult.authResults[0] == 0;
  }

  async checkPermission(name: Permissions, callback?: Function) {
    let res = await this.checkAccessToken(name)
    HiLog.i(TAG, `checkPermission_res:${res}`)
    if (!res) {
      let resultInit = await this.initPermission(name)
      return resultInit
    } else {
      return res
    }
  }

  async getPicFromGallery() {
    HiLog.i(TAG, 'getPicFromGallery');
    this.pictureList = [
      {
        image: '',
        selected: false,
        photoType: 0
      }
    ];
    const context = (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);
    let mPhotoAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);

    try {
      let predicates = new dataSharePredicates.DataSharePredicates();
      let fetchOption: photoAccessHelper.FetchOptions = {
        fetchColumns: [],
        predicates: predicates
      };

      let fetchResult = await mPhotoAccessHelper.getAssets(fetchOption);
      fetchResult.getAllObjects((err, photoAssetList: LooseObject[]) => {
        if (photoAssetList != undefined && photoAssetList.length > 0) {
          HiLog.i(TAG, 'photoAssetList success');
          let display = JSON.parse(JSON.stringify(MMAttachmentAreaController.getInstance()
            .mmDisplaySource)) as Array<Mms>;
          photoAssetList.reverse();
          let resultList = this.splitPhotoArray(photoAssetList, 500);
          resultList.forEach((ele, resultIndex) => {
            let count = 0;
            let eleList: PictureListData[] = [];
            ele.forEach((item: photoAccessHelper.PhotoAsset, index: number) => {
              item.getThumbnail((err: BusinessError, pixelMap: PixelMap) => {
                if (err == undefined) {
                  let obj: PictureListData = {
                    image: item.uri,
                    selected: display.length > 0 ? display.some(ele => ele.galleryPath == item.uri) : false,
                    photoType: item.photoType,
                    mediaUri: item.uri,
                    pixelMap: pixelMap,
                    index: index
                  }
                  eleList.push(obj)
                } else {
                  HiLog.i(TAG, 'getThumbnail fail', err);
                }
                count ++;
              });
            })
            let a = setInterval(() => {
              if (count == ele.length) {
                if (eleList.length >= 2) {
                  this.pictureList.push(...eleList.sort((a, b) => {
                    if (a.index !== undefined && b.index !== undefined) {
                      return a.index - b.index
                    } else {
                      return 0
                    }
                  }))
                } else if(eleList.length < 2 && eleList.length > 0){
                  this.pictureList.push(...eleList);
                }
                HiLog.i(TAG, 'pictureList: ' + this.pictureList.length);
                this.pictureDataSource.refresh(this.pictureList);
                clearInterval(a);
              }
            }, 1)
          })
        } else {
          HiLog.e(TAG, 'photoAssetList failed with err:' + err);
          this.pictureDataSource.refresh(this.pictureList);
        }
      })
    } catch (error) {
      HiLog.e(TAG, '[picker] getThumbnail error = ' + error);
    }
  }

  resetPictureHeight() {
    AppStorage.setOrCreate('selectPicFromMaxHeightDone', true);
  }

  async getThumbnailFunc(uri: string,videoUri: string, callback: Function) {
    HiLog.i(TAG, 'getThumbnailFunc getThumbnailFunc');
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    predicates.equalTo('uri', uri);
    let fetchOption: photoAccessHelper.FetchOptions = {
      fetchColumns: [],
      predicates: predicates
    };
    try {
      const context = (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);
      let mPhotoAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
        await mPhotoAccessHelper.getAssets(fetchOption);
        const asset: photoAccessHelper.PhotoAsset|undefined = await fetchResult.getFirstObject();
        HiLog.i(TAG, 'asset displayName = ', asset.displayName);
        asset.getThumbnail((err, pixelMap) => {
          if (err == undefined) {
            HiLog.i(TAG, 'getThumbnailFunc getThumbnail successful ' + pixelMap.getPixelBytesNumber());
            callback(pixelMap);
          } else {
            HiLog.e(TAG, 'getThumbnailFunc getThumbnail fail', err);
            callback(undefined)
          }
        });
    } catch (e) {
      HiLog.e(TAG, 'error:', e);
      // 尝试使用 AVImageGenerator 获取视频缩略图
      const imagePixmap = await this.getVideoThumbnailByImageUtil(videoUri);
      if (imagePixmap) {
        HiLog.i(TAG, 'getThumbnailFunc getThumbnail successful via AVImageGenerator');
        callback(imagePixmap);
      }else {
        callback(undefined);
      }
    }

  }

  private async getVideoThumbnailByImageUtil(videoUri: string): Promise<PixelMap | undefined> {
    return new Promise((resolve) => {
      ImageUtil.getFetchFrameByTime(videoUri, (pixMap: PixelMap) => {
        if (pixMap) {
          resolve(pixMap);
        } else {
          resolve(undefined);
        }
      });
    });
  }

  async handleRcsPhotoSelectResultURLItem(context: Context, uri: string, isOriginalPhoto: boolean,
    isRefreshDisplay?: boolean) {
    if (!uri) {
      return;
    }
    let currentAppPhotoUri = await this.savePictureToSandBoxWithUrlOfEnhancedInfo(context, uri);
    let isCheckPass = false;
    try {
      isCheckPass = await this.checkGalleryImageFileOfEnhancedInfo(currentAppPhotoUri);
    } catch (e) {
      HiLog.e(TAG, 'handleRcsPhotoSelectResultURLItem checkGalleryImageFileOfEnhancedInfo error: ' + JSON.stringify(e));
      isCheckPass = false;
    }
    if (isCheckPass === false) {
      try {
        fs.unlink(new fileUri.FileUri(currentAppPhotoUri).path);
      } catch (e) {
        HiLog.e(TAG, 'handleRcsPhotoSelectResultURLItem fs.unlink error: ' + JSON.stringify(e));
      }
      return;
    }
    if (currentAppPhotoUri.endsWith('mp4')) {
      this.mmAreaController.setPictureOrVideoOfEnhancedInfo(currentAppPhotoUri, context, undefined, isOriginalPhoto,
        true);
    } else if (currentAppPhotoUri.endsWith('gif')) {
      this.mmAreaController.setPictureOrVideoOfEnhancedInfo(currentAppPhotoUri, context, undefined, true,
        true);
    } else {
      this.mmAreaController.setPictureOrVideoOfEnhancedInfo(currentAppPhotoUri, context, undefined, isOriginalPhoto,
        isRefreshDisplay);
    }
  }

  async jumpToGalleryOfRCS(context: Context, callback?:() => void) {
    HiLog.i(TAG, 'jumpToGalleryOfRCS')
    AppStorage.setOrCreate('selectPicFromGalleryDone', false);
    let photoSelectOptions = this.getPhotoSelectOptionsOfEnhancedInfo();
    try {
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      this.photoSelectResOfRCS = await photoPicker.select(photoSelectOptions)
      if (this.mmAreaController.hasNeedReplaceVcard() && this.photoSelectResOfRCS.photoUris.length > 0 && callback) {
        callback()
      } else {
        this.handlePhotoSelectResultOfRCS(context)
      }
    } catch (err) {
      HiLog.e(TAG, 'jumpToGalleryOfRCS error, code: ' + (err as BusinessError).code + ', message: ' +
      (err as BusinessError).message);
    }
  }

  // 添加所选信息 this.photoSelectResOfRCS 到附件待发区
  async handlePhotoSelectResultOfRCS(context: Context) {
    HiLog.i(TAG, 'jumpToGalleryOfRCS photoPicker.select return.');
    if (!this.photoSelectResOfRCS) {
      HiLog.e(TAG, 'jumpToGalleryOfRCS photoSelectResult is empty');
      return;
    }
    AppStorage.setOrCreate('selectPicFromGalleryDone', this.photoSelectResOfRCS.photoUris.length > 0);
    this.mmAreaController.refreshConversation();
    let toastArr: ResourceStr[] = [];
    for (let i = 0; i < this.photoSelectResOfRCS.photoUris.length; i++) {
      if (this.photoSelectResOfRCS.photoUris[i]) {
        let isAdd: boolean =
          await this.isAddImageFromCheckImageWidthAndHeight(context, this.photoSelectResOfRCS.photoUris[i]);
        if (isAdd) {
          await this.handleRcsPhotoSelectResultURLItem(context, this.photoSelectResOfRCS.photoUris[i],
            this.photoSelectResOfRCS.isOriginalPhoto, false)
        } else {
          let msg: Resource = $r('app.string.attachment_add_failed', IMAGE_MAX_SIZE);
          toastArr.push(msg);
        }
      } else {
        HiLog.iw(TAG,'jumpToGalleryOfRCS select image url is empty')
      }
    }
    //如果rcs同时添加了好多图片，每张图都满足大于8k提示，则依次提示
    toastArr.forEach((ele, index) => {
      if (index == 0) {
        if (this.isTextAsMms) {
          HiLog.iw(TAG, 'no need show toast for text mms');
          return;
        }
        promptAction.showToast({
          message: ele,
          duration: 2000
        });
      } else {
        setTimeout(() => {
          promptAction.showToast({
            message: ele,
            duration: 2000
          });
        }, 2100)
      }
    })
    this.mmAreaController.refreshDisplay();
    AppStorage.setOrCreate('isConversationNeedChange', true);
  }

  jumpToGallery(context: Context, callback?:() => void) {
    try {
      AppStorage.setOrCreate('selectPicFromGalleryDone', false);
      let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE;
      photoSelectOptions.maxSelectNumber = 9;
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select(photoSelectOptions).then(async (photoSelectResult) => {
        this.photoSelectRes = photoSelectResult
        if (this.mmAreaController.hasNeedReplaceVcard() && this.photoSelectRes.photoUris.length > 0 && callback) {
          callback()
        } else {
          this.handlePhotoSelectResult(context)
        }
      }).catch((err: BusinessError) => {
        HiLog.i(TAG, 'PhotoViewPicker.select failed with err: ', err);
      });
    } catch (err) {
      HiLog.e(TAG, 'queryAirPlaneMode query out error: code: ' + (err as BusinessError).code + ', message: ' +
      (err as BusinessError).message);
    }
  }

  async handlePhotoSelectResult(context: Context, fromReplace?: boolean) {
    if (this.photoSelectRes) {
      console.log('PhotoViewPicker.select successfully, PhotoSelectResult uri: ' +
      JSON.stringify(this.photoSelectRes.photoUris));
      AppStorage.setOrCreate('selectPicFromGalleryDone', this.photoSelectRes.photoUris.length > 0);
      let toastArr: ResourceStr[] = [];
      await this.photoSelectResult(context, this.photoSelectRes, toastArr, fromReplace);
      toastArr.forEach((ele, index) => {
        if (index == 0) {
          if (this.isTextAsMms) {
            HiLog.i(TAG, 'no need show toast for text mms');
            return;
          }
          promptAction.showToast({
            message: ele,
            duration: 2000
          });
        } else {
          setTimeout(() => {
            promptAction.showToast({
              message: ele,
              duration: 2000
            });
          }, 2100)
        }
      })
      AppStorage.setOrCreate('isAreaDisplayChange', true);
    }
  }

  public async photoSelectResult(context: Context, photoSelectResult: photoAccessHelper.PhotoSelectResult,
    toastArr: Array<ResourceStr>, fromReplace?: boolean) {
    for (let i = 0; i < photoSelectResult.photoUris.length; i++) {
      if (photoSelectResult.photoUris[i]) {
        let isAdd: boolean = await this.isAddImageFromCheckImageWidthAndHeight(context, photoSelectResult.photoUris[i]);
        if (isAdd) {
          let item = this.savePictureToSandBoxWithUrl(context, photoSelectResult.photoUris[i])
          if (this.mmAreaController.isAttachmentUpperLimit()) {
            FileUtil.deleteFile(context, FileUtil.getFileName(item));
            HiLog.i(TAG, 'saveVideoAlbums AttachmentUpperLimit');
            break;
          } else if (await this.mmAreaController.isExceedSizeNotShowToast(item)) {
            // Over 300kb Deleted Data
            await this.mmAreaController.setTotalSize(false, item);
            FileUtil.deleteFile(context, FileUtil.getFileName(item));
            let maxSize: number = OperatorConfigUtil.getInstance().getCustMMSSize(
              commonData.int.MMS_FILE_MAX_SIZE) / commonData.int.BYTE_CONVERSION_UNIT;
            let countryId = i18n.System.getSystemRegion();
            let numberFormat = new intl.NumberFormat(countryId, {
              style: 'unit', unit: 'kilobyte'
            });
            let masxSiseStr = numberFormat.format(maxSize);
            let msg: Resource = $r('app.string.attachment_failed', masxSiseStr);
            toastArr.push(msg);
            continue;
          } else {
            this.mmsTypeParams(context, item, toastArr, photoSelectResult.photoUris[i], fromReplace);
          }
        } else {
          let msg: Resource = $r('app.string.attachment_add_failed', IMAGE_MAX_SIZE);
          toastArr.push(msg);
        }
      }
    }
  }

  private mmsTypeParams(context: Context, item: string, toastArr: ResourceStr[], photoUri: string, 
    fromReplace?: boolean) {
    let msg: Resource = $r('app.string.converting_mms');
    //如果先添加语音/拍照添加图片，就不提示msg"正在转化为彩信…";当附件区没有内容，第一次添加的时候才提示msg
    if (this.mmAreaController.mmDisplaySource.length == 0 && !fromReplace) {
      toastArr.push(msg);
    }
    let fileName = FileUtil.getFileName(item);
    if (this.isVideoType(fileName)) {
      this.getThumbnailFunc(photoUri,item, (pixmap?: PixelMap) => {
        HiLog.i(TAG, `mmsTypeParams setVideo`);
        this.mmAreaController.setVideo(context, item, pixmap);
      });
      mmsTypeParams.TYPE_STATUS = 2;
    } else {
      this.mmAreaController.setPicture(context, item);
      mmsTypeParams.TYPE_STATUS = 1;
    }
    // Confirm Attachment Type(DOT)
    DotUtil.getInstance().reportEvent(mmsTypeParams, dotCommon.eventName.ADD_ATTACHMENT);
  }

  private isVideoType(fileName: string) {
    let isSupport = false;
    for (let supportFormat of SUPPORT_VIDEO_FORMAT_LIST) {
      if (fileName.toLowerCase().endsWith(supportFormat)) {
        isSupport = true;
        break;
      }
    }
    HiLog.i(TAG, `isVideoType isSupport:${isSupport}`);
    return isSupport;
  }

  savePictureToSandBoxWithUrl(context: Context, url: string): string {
    try {
      const originalName = FileUtil.getFileName(url);
      const fileNameExtension = originalName.slice(originalName.lastIndexOf('.') + 1);
      const fileName = `${commonData.STR.GALLERY_PREFIX}${Date.now()}.${fileNameExtension}`;
      let filePath = FileUtil.getFilePath(context, fileName)
      fs.createRandomAccessFileSync(filePath, fs.OpenMode.CREATE);
      let filePathuri = fileuri.getUriFromPath(filePath);
      let file = fs.openSync(url, fs.OpenMode.READ_ONLY)
      try {
        let file2 = fs.openSync(filePathuri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
        fs.copyFileSync(file.fd, file2.fd)
        fs.closeSync(file);
        fs.closeSync(file2);
      } catch (e) {
        HiLog.i(TAG, `openSync or copyFileSync error: ${JSON.stringify(e)}`);
      }
      return filePathuri;
    } catch (e) {
      HiLog.i(TAG, `savePictureToSandBoxWithUrl error: ${JSON.stringify(e)}`);
      return '';
    }
  }

  async savePictureToSandBoxWithUrlOfEnhancedInfo(context: Context, url: string): Promise<string> {
    try {
      const originalName = FileUtil.getFileName(url);
      const fileNameExtension = originalName.slice(originalName.lastIndexOf('.') + 1);
      const fileName = `OriginImage_RCS_${Date.now()}.${fileNameExtension}`;
      const filePath = FileUtil.getFilePath(context, fileName);
      await fs.createRandomAccessFile(filePath, fs.OpenMode.CREATE);
      const filePathUrl = fileuri.getUriFromPath(filePath);
      let file = await fs.open(url, fs.OpenMode.READ_ONLY);
      let file2 = await fs.open(filePathUrl, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      await fs.copyFile(file.fd, file2.fd);
      fs.close(file);
      fs.close(file2);
      return filePathUrl;
    } catch (e) {
      HiLog.i(TAG, `savePictureToSandBoxWithUrlOfEnhancedInfo error: ${JSON.stringify(e)}`);
      return '';
    }
  }

  private getPhotoSelectOptionsOfEnhancedInfo() {
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE;
    photoSelectOptions.maxSelectNumber = 9;
    photoSelectOptions.isOriginalSupported = true;
    return photoSelectOptions;
  }

  /**
   * @param filePathOrURI
   * @returns
   */
  public static async checkFileOfEnhancedInfo(filePathOrURI: string) {
    let fileNameExtension = filePathOrURI.slice(filePathOrURI.lastIndexOf('.') + 1).toUpperCase();
    let supportedFileFormats = ['JPEG', 'JPG', 'PNG', 'GIF', 'BMP', 'VCF', 'MP4', 'HEIC', 'HEIF'];
    if (!fileNameExtension || supportedFileFormats.indexOf(fileNameExtension) === -1) {
      HiLog.iw(TAG, 'check EnhancedInfoFile format fail');
      promptAction.showToast({
        message: $r('app.string.audio_play_error'),
        duration: 3000
      });
      return false;
    }

    let fileName = FileUtil.getFileName(filePathOrURI);
    let urlEncodedFileName = encodeURIComponent(fileName);
    if (urlEncodedFileName.length > 255) {
      HiLog.iw(TAG, 'check EnhancedInfo file urlEncodedFileName fail');
      MmsUtil.showToast({
        message: $r('app.string.rcs_file_name_extra_long'),
        duration: 3000
      });
      return false;
    }

    return true;
  }
  /**
   * Check Gallery Image File
   *
   * @param imageGalleryPathOrURL
   * @returns
   */
  async checkGalleryImageFileOfEnhancedInfo(imageGalleryPathOrPath: string) {
    HiLog.i(TAG, 'start checkGalleryImageFileOfEnhancedInfo');
    if (!imageGalleryPathOrPath) {
      HiLog.i(TAG, 'imageGalleryPathOrPath is empty');
      return false;
    }
    let tempBol = await MMPictureController.checkFileOfEnhancedInfo(imageGalleryPathOrPath);
    if (tempBol === false) {
      return false;
    }
    return true;
  }

  async clickPictureCheckbox(context: Context, value: boolean, item: PictureListData, index: number) {
    HiLog.i(TAG, 'clickPictureCheckbox');

    if (value && this.mmAreaController.isAttachmentUpperLimit()) {
      // Indicates whether the upper limit of 20 is exceeded.
      item.selected = value;
      this.pictureDataSource.refresh(this.pictureList);
      setTimeout(() => {
        // Status of deselecting the check box
        item.selected = false;
        this.pictureDataSource.refresh(this.pictureList);
      }, 20);
    } else {
      item.selected = value;
      let mediaUri: string = item.mediaUri ? item.mediaUri : '';
      this.changeCheckBox(mediaUri, value);
      this.getSelectedCount(value);
      this.mmAreaController.handleCheckedChange(context, mediaUri, value, item.photoType, item.pixelMap, () => {
        setTimeout(() => {
          this.clickPictureCheckbox(context, false, item, index);
        }, 0);
      });
    }
  }

  getSelectedCount(value: boolean) {
    if(value) {
      this.selectedMsgCount ++;
    } else {
      this.selectedMsgCount --;
    }
  }

  changeCheckBox(mediaUri: string, value: boolean) {
    let selectedNumber : number = 0;
    this.pictureList.forEach((item) => {
      if (item.mediaUri === mediaUri) {
        item.selected = value;
      }
      if (item.selected) {
        selectedNumber ++;
      }
    });
    AppStorage.setOrCreate('pictureSelectedNumber', selectedNumber)
    this.pictureDataSource.refresh(this.pictureList);
  }

  resetPictureStatus() {
    HiLog.i(TAG, 'resetPictureStatus');
    this.pictureList.forEach((picture) => {
      picture.selected = false;
    });
    this.pictureDataSource.refresh(this.pictureList);
  }

  splitPhotoArray(arr: LooseObject[], size: number) {
    let result: LooseObject[] = [];
    HiLog.i(TAG, 'splitPhotoArray arr.length: ' + arr.length);
    while (arr.length > 0) {
      let currentChunk = arr.splice(0, size);
      result.push(currentChunk);
    }
    return result;
  }

  public setTextMms(isTextAsMms: boolean) {
    this.isTextAsMms = isTextAsMms
  }

  /**
   * 根据选择图片宽高，判断图片是否可以被发送
   * 只要图片有一边大于7680，提示用户“分辨率大于8k的图片无法发送”
   */
  async isAddNewImageFromCheckImageWidthAndHeight(imageUrl: string): Promise<boolean> {

    let imageWidth: number = 0;
    let imageHeight: number = 0;

    const file = await fs.open(imageUrl, fs.OpenMode.READ_ONLY);
    const stat = await fs.stat(file.fd);
    const buffer = new ArrayBuffer(stat.size);
    await fs.read(file.fd, buffer, { offset: 0, length: stat.size });
    await fs.close(file.fd);

    const imageSource = image.createImageSource(buffer);
    imageSource.getImageInfo().then(info => {
      imageSource.release()
      console.info('isAddImageFromCheckImageWidthAndHeight width:' + info.size.width, 'height:' + info.size.height);
      imageWidth = info.size.width;
      imageHeight = info.size.height;
      let numbers: number[] = [imageWidth, imageHeight];
      let maxNumber: number = Math.max(...numbers);
      if (maxNumber > IMAGE_MAX_WIDTH) {
        return false;
      }
      return true
    });
    imageSource.release()
    return true

    ///todo：这里有两种实现方式，待后续选择处理
    // try {
      // const file = await fs.open(imageUrl, fs.OpenMode.READ_ONLY);
      // const buffer = new ArrayBuffer(1024);
      // await fs.read(file.fd, buffer, { offset: 0, length: 1024 });
    //   const view = new DataView(buffer);
    //   HiLog.i(TAG, 'isAddNewImageFromCheckImageWidthAndHeight 1 imageWidth: ' + imageWidth + 'imageHeight:' + imageHeight)
    //   // 检查JPEG格式 (FF D8开头)
    //   if (view.getUint16(0) === 0xFFD8) {
    //     let offset = 2;
    //     while (offset + 4 < view.byteLength) {
    //       const marker = view.getUint16(offset);
    //       const segmentLength = view.getUint16(offset + 2);
    //
    //       if (marker === 0xFFC0 || marker === 0xFFC2) {
    //         if (offset + 7 >= view.byteLength) {
    //           throw new Error('Invalid JPEG segment');
    //         }
    //         imageWidth = view.getUint16(offset + 7);
    //         imageHeight = view.getUint16(offset + 5);
    //       }
    //       offset += segmentLength + 2;
    //     }
    //     HiLog.i(TAG, 'isAddNewImageFromCheckImageWidthAndHeight 2 imageWidth: ' + imageWidth + 'imageHeight:' + imageHeight)
    //   }
    //   // 检查PNG格式 (89 50 4E 47开头)
    //   else if (view.getUint32(0) === 0x89504E47) {
    //     imageWidth = view.getUint32(16);
    //     imageHeight = view.getUint32(20);
    //   }
    //   HiLog.i(TAG, 'isAddNewImageFromCheckImageWidthAndHeight 3 imageWidth: ' + imageWidth + 'imageHeight:' + imageHeight)
    //   let numbers: number[] = [imageWidth, imageHeight];
    //   let maxNumber: number = Math.max(...numbers);
    //   if (maxNumber > IMAGE_MAX_WIDTH) {
    //     return false;
    //   }
    //   return true
    // } catch (err) {
    //   HiLog.i(TAG, 'isAddNewImageFromCheckImageWidthAndHeight err:' + err)
    //   return true
    // }
  }

  async isAddImageFromCheckImageWidthAndHeight(context: Context, imageUrl: string): Promise<boolean> {
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    // 配置查询条件，使用PhotoViewPicker选择图片返回的URI进行查询
    predicates.equalTo('uri', imageUrl);
    let fetchOption: photoAccessHelper.FetchOptions = {
      fetchColumns: [photoAccessHelper.PhotoKeys.WIDTH, photoAccessHelper.PhotoKeys.HEIGHT,
        photoAccessHelper.PhotoKeys.TITLE, photoAccessHelper.PhotoKeys.DURATION],
      predicates: predicates
    };
    try {
      let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
        await phAccessHelper.getAssets(fetchOption);
      // 得到URI对应的PhotoAsset对象，读取文件的部分信息
      const asset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
      if (asset) {
        HiLog.i(TAG, 'select image width is: ' + asset.get(photoAccessHelper.PhotoKeys.WIDTH))
        HiLog.i(TAG, 'select image height is: ' + asset.get(photoAccessHelper.PhotoKeys.HEIGHT))
        HiLog.i(TAG, 'select image photoType is: ' + asset.photoType)
        let imageWidth: number = asset.get(photoAccessHelper.PhotoKeys.WIDTH) as number;
        let imageHeight: number = asset.get(photoAccessHelper.PhotoKeys.HEIGHT) as number;
        let numbers: number[] = [imageWidth, imageHeight];
        let maxNumber: number = Math.max(...numbers);
        if (maxNumber > IMAGE_MAX_WIDTH) {
          return false;
        }
        return true;
      }
    }catch (err) {
      HiLog.i(TAG, 'isAddImageFromCheckImageWidthAndHeight err:' + err)
      return await this.isAddNewImageFromCheckImageWidthAndHeight(imageUrl)
    }

    return true;
  }

  /**
   * 大图提示
   */
  toastShow() {
    let msg: Resource = $r('app.string.attachment_add_failed', IMAGE_MAX_SIZE);
    promptAction.openToast({
      message: msg,
      duration: 2000
    })
  }
}