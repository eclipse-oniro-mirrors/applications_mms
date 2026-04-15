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

import image from '@ohos.multimedia.image';
import media from '@ohos.multimedia.media';
import HiLog from './HiLog';
import lazy fs from '@ohos.file.fs';
import FileUtil, { getMineTypeFromFileName, getMineTypeFromFileNameAndCt } from './FileUtil';
import MmsUtil from './MmsUtil';
import commonData from '../data/commonData';
import Want from '@ohos.app.ability.Want';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import ImageCompression, { CompressedImageInfo } from './ImageCompression';
//import { filePreview } from '@kit.PreviewKit';
import fileUri from '@ohos.file.fileuri';
import { IPhotoProp } from '../pages/photoBrowser/photoBrowser';
import { BusinessError } from '@kit.BasicServicesKit';
import fileuri from '@ohos.file.fileuri';
import StringUtil from './StringUtil';
import { GlobalContextKey } from '../data/commonData';
import { Mms } from './TypesUtils';
import { HOSBase64 } from './HOSBase64';

const TAG = 'ImageUtil ';
const MAX_COMPRESSION_SIZE: number = 10;
const MAX_IMAGE_WIDTH: number = 1920;

class ImageUtil {
  async convertImageToPixmap(path: string) {
    let imageSource: image.ImageSource = image.createImageSource(path);
    let size = imageSource.getImageInfoSync().size;
    HiLog.i(TAG, `convertImageToPixmap ${JSON.stringify(size)}`);
    const scale = (size.width > size.height ? size.width / MAX_IMAGE_WIDTH : size.height / MAX_IMAGE_WIDTH);
    if (scale > 1) {
      size.width = Math.round(size.width / scale);
      size.height = Math.round(size.height / scale);
    }
    let pixelMap: image.PixelMap = await imageSource.createPixelMap({desiredSize: size});
    const orientation =
      await imageSource.getImageProperty(image.PropertyKey.ORIENTATION).catch((err: BusinessError) => {
        HiLog.d(TAG, 'get image property failed, code=' + err.code);
      })
    switch (orientation) {
      case 'Right-top': // 顺时针旋转90°
        pixelMap.rotateSync(90);
        break;
      case 'Bottom-right': // 图像旋转180°
        pixelMap.rotateSync(180);
        break;
      case 'Left-bottom': // 顺时针旋转270°
        pixelMap.rotateSync(270);
        break;
      default:
        break;
    }
    imageSource.release();
    return pixelMap;
  }

  /**
   * base64转换为pixelMap
   *
   * @param code base64 code
   * @param size Width and height of the image pixel map.
   * @returns pixelMap of image
   */
  public async convertBase64ToPixmap(code: string, size: Size): Promise<image.PixelMap | null> {
    HiLog.i(TAG, `convertBase64ToPixmap code.size: ${code?.length}`);
    if (StringUtil.isEmpty(code) || !size) {
      HiLog.e(TAG, `convertBase64ToPixmap code is empty or size is null`);
      return null;
    }
    let bit = new HOSBase64().decode(code || '');
    let imageSource = image.createImageSource(bit?.buffer);
    let pixelMap: image.PixelMap = await imageSource.createPixelMap({ desiredSize: size });
    imageSource.release();
    return pixelMap;
  }

  // Obtains the thumbnail of a video at a specified time.
  async getFetchFrameByTime(path: string, callback: Function) {
    HiLog.i(TAG, 'getFetchFrameByTime');
    if (path === '') {
      HiLog.i(TAG, 'getFetchFrameByTime path is empty');
      callback();
      return;
    }
    try {
      const fileInfo = new fileUri.FileUri(path);
      let obj: Record<string, number | fs.File> | undefined = FileUtil.getFileSizeAndFile(fileInfo.path);
      if (obj) {
        let file: fs.File = obj.file as fs.File;
        let size: number = obj.size as number;
        let avImageGenerator: media.AVImageGenerator = await media?.createAVImageGenerator();
        HiLog.i(TAG, 'createAVImageGenerator');
        // File Descriptor
        let fdSrc: media.AVFileDescriptor = {
          fd: file.fd,
          offset: 0,
          length: size
        }
        avImageGenerator.fdSrc = fdSrc;
        let timeUs = 0;
        // Correspondence between the obtained thumbnail time point and the video frame
        let queryOption = 0;
        let param: media.PixelMapParams = {
          width: -1,
          height: -1,
          colorFormat: 3
        }
        let pixmap = await avImageGenerator?.fetchFrameByTime(timeUs, queryOption, param);
        HiLog.i(TAG, 'fetchFrameByTime');
        avImageGenerator.release();
        fs.closeSync(file);
        callback(pixmap);
      } else {
        callback();
      }
    } catch (err) {
      HiLog.i(TAG, 'getFetchFrameByTime err: ' + JSON.stringify(err));
      callback();
    }
  }

  public async goToOpenMediaLibrary(path: string, type: number) {
    HiLog.i(TAG, 'goToOpenMediaLibrary');
    if (path && path !== '') {
      let format: string = '*';
      if (path.indexOf('.') > -1) {
        let pathSplits: Array<string> = path.split('.');
        format = pathSplits[1];
      }
      let typeStr = '';
      if (type === commonData.MM_ATTACHMENT_TYPE.IMAGE) {
        typeStr = 'image/' + format;
      } else if (type === commonData.MM_ATTACHMENT_TYPE.VIDEO) {
        typeStr = 'video/' + format;
      }

      let want: Want = {
        'action': 'ohos.want.action.viewData',
        'type': typeStr,
        'parameters': {
          'uri': path ? path : '',
          'isShowMenu': true
        }
      }
      await (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext).startAbility(want);
    }
  }

  async convertImageToThumbnails(path: string) {
    HiLog.i(TAG, 'convertImageToThumbnails ');

    const imageSource: image.ImageSource = image.createImageSource(path);
    let pixMap = await imageSource.createPixelMap();
    if (pixMap === undefined) {
      return '';
    }

    const compressedImageInfo: CompressedImageInfo =
      await ImageCompression.compressedImage(pixMap, MAX_COMPRESSION_SIZE);
    imageSource.release();
    pixMap.release();
    HiLog.i(TAG,
      'convertImageToThumbnails ' + compressedImageInfo.imageUri + 'size ' + compressedImageInfo.imageByteLength);
    return compressedImageInfo.imageUri;
  }

  async convertVideoImageToThumbnails(path: string) {
    const avImageGenerator: media.AVImageGenerator = await media.createAVImageGenerator()
    avImageGenerator.fdSrc = await fs.open(path)
    let pixMap = await avImageGenerator.fetchFrameByTime(0, media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC,
      { width: -1, height: -1 })
    if (pixMap === undefined) {
      return '';
    }
    const compressedImageInfo: CompressedImageInfo =
      await ImageCompression.compressedImage(pixMap, MAX_COMPRESSION_SIZE);
    fs.close(avImageGenerator.fdSrc.fd)
    avImageGenerator.release();
    pixMap.release();
    HiLog.i(TAG,
      'convertImageToThumbnails ' + compressedImageInfo.imageUri + 'size ' + compressedImageInfo.imageByteLength);
    return compressedImageInfo.imageUri;
  }

  //图片预览
  public async openPhotoPreview(param: IPhotoProp) {
    let path = param.uri;
    let uri = fileUri.getUriFromPath(path);
    let pathArr = path.split('/');
    let name = pathArr[pathArr.length - 1];
    let ct = param.ct ? param.ct : this.addCt(name);
    if (await this.fileCanPreview(uri, ct)) {
      this.openPreviewWindow(name, uri, getMineTypeFromFileNameAndCt(name, ct));
    } else {
      MmsUtil.showToast({
        message: $r('app.string.attachment_unsupport_toast_image'),
        duration: 3000
      });
    }
    GlobalContext.getContext().setObject(GlobalContextKey.IS_JUMP_TO_PREVIEW, true);
  }

  public async openVideoPreview(item: Mms) {
    let uiContext = getContext(this);
    let index = item.path.lastIndexOf('/');
    let filePath = item.path.substring(0, index);
    let videoPath = filePath + '/' + item.name;
    if (fs.accessSync(videoPath)) {
      videoPath = fileuri.getUriFromPath(videoPath);
    }
    // let fileInfo: filePreview.PreviewInfo = {
    //   title: item.name,
    //   uri: videoPath,
    //   mimeType: 'video/mp4'
    // };
    GlobalContext.getContext().setObject(GlobalContextKey.IS_JUMP_TO_PREVIEW, true);
    // filePreview.openPreview(uiContext, fileInfo).then(() => {
    //   HiLog.i(TAG, 'previewMmsVideo success');
    // }).catch((err: BusinessError) => {
    //   HiLog.i(TAG, 'previewMmsVideo openPreview failed, err = ' + JSON.stringify(err));
    // });
  }

  private addCt(fileName: string) {
    let temps = fileName.split('.');
    let suffixName = temps[1];
    if (!suffixName) {
      return 'image/gif';
    }
    return suffixName.toLowerCase();
  }

  //判断是否可以预览
  private async fileCanPreview(uri: string, ct: string | undefined) {
    let uiContext = getContext(this) as myCommon.UIAbilityContext;
    // let result: boolean = await filePreview.canPreview(uiContext, uri);
    // let resultCt: boolean = false;
    // if (!StringUtil.isEmpty(ct)) {
    //   resultCt = true;
    // }
    // return result || resultCt;
    return true;
  }

  //打开预览窗口
  private openPreviewWindow(title: string, uri: string, mimeType: string) {
    let uiContext = getContext(this) as myCommon.UIAbilityContext;
    // let displayInfo: filePreview.DisplayInfo = {
    //   x: 100,
    //   y: 100,
    //   width: 800,
    //   height: 800
    // }
    // let fileInfo: filePreview.PreviewInfo = {
    //   title: title,
    //   uri: uri,
    //   mimeType: mimeType
    // }
    // filePreview.openPreview(uiContext, fileInfo, displayInfo).then(() => { //仅当预览窗口存在时起效
    // }).catch((err:BusinessError) => {
    //
    // });
  }

  /**
   *
   * @param imagePath
   * @param pixelMap image pixelMap
   */
  public encodePixelMapToFile = async (imagePath: string, pixelMap: image.PixelMap) => {
    if (!imagePath || !pixelMap) {
      HiLog.e(TAG, 'encodePixelMapToFile: params are empty');
      return;
    }
    try {
      let file = await fs.open(imagePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      const imagePackerApi = image.createImagePacker();
      let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 80 };
      await imagePackerApi.packToFile(pixelMap, file.fd, packOpts).then(() => {
        HiLog.i(TAG, 'encodePixelMapToFile: encodePixelMapToFile success');
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'encodePixelMapToFile: Failed to pack the image. And the error is: ' + error);
      })
      fs.close(file.fd);
      imagePackerApi.release();
    } catch (e) {
      HiLog.e(TAG, 'encodePixelMapToFile failed, error:' + JSON.stringify(e));
    }
  }
}

export default new ImageUtil();