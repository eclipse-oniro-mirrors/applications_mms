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

import { GlobalContext } from '../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import HiLog from './HiLog';
import lazy fs from '@ohos.file.fs';
import fileuri from '@ohos.file.fileuri';
import common from '../data/commonData';
import commonData from '../data/commonData';
import image from '@ohos.multimedia.image';
import { packingItem } from './TypesUtils';
import OperatorConfigUtil from '../../cust/utils/OperatorConfigUtil';
import ImageUtil from '../utils/ImageUtil';
import ConversationController from '../pages/conversation/conversationController';
import StringUtil from './StringUtil';
import { ReadTextOptions } from '@kit.CoreFileKit';
import { OBLIQUE } from '../chatbot/utils/ChatbotFileUtils';
import { fileUri, picker } from '@kit.CoreFileKit';
import prompt from '@ohos.promptAction';
import { BusinessError } from '@ohos.base';
import LocationUtil from './LocationUtil';

const TAG = 'FileUtil ';
//Supported Compressed File Types
const SUPPORTED_PACK_TYPE: string[] = ['.jpg', '.png', '.gif', '.bmp', '.webp', 'RAW', '.jpeg', '.heic', '.heif'];
//每次减少的压缩质量
const PACKING_SUBTRACT_EACH: number = 20;
const IMAGE_ADJUST_MIN_WIDTH: number = 1080;
const IMAGE_ADJUST_MIN_HEIGHT: number = 1920;

export const ENHANCED_INFO_SUPPORT_FORWARD_FILE_TYPES: Map<number, string> = new Map([
    [commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE, 'IMAGE'],
    [commonData.ENHANCED_INFO_ITEM_TYPE.VCARD, 'VCARD'],
    [commonData.ENHANCED_INFO_ITEM_TYPE.FILE, 'FILE'],
    [commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE, 'AUDIO_FILE'],
    [commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO, 'VIDEO'],
    [commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO_THUMBNAIL, 'IMAGE']
])

export const mapSuffixNameToMiME = new Map<string, string>([
  ['txt', 'text/plain'],
  ['mp3', 'audio/mpeg'],
  ['aac', 'audio/aac'],
  ['m4a', 'audio/mpeg'],
  ['amr', 'audio/amr'],
  ['gif', 'image/gif'],
  ['png', 'image/png'],
  ['bmp', 'image/bmp'],
  ['jpg', 'image/jpeg'],
  ['jpeg', 'image/jpeg'],
  ['heic', 'image/heic'],
  ['heif', 'image/heif'],
  ['webp', 'image/webp'],
  ['svg', 'image/svg+xml'],
  ['heic', 'image/heic'],
  ['mp4', 'video/mp4']
])

class FileUtil {
  public getSandboxPath(context: Context) {
    HiLog.i(TAG, 'getSandboxPath');
    if (context == undefined) {
      HiLog.w(TAG, 'parameter context empty, can only use global context');
    }
    return context.filesDir;
  }

  public hasSandAccess(context: Context): boolean {
    return fs.accessSync(this.getSandboxPath(context), fs.AccessModeType.READ_WRITE);
  }

  public getFileUrl(context: Context, name: string) {
    HiLog.d(TAG, 'getFileUrl');
    try {
      let filesDir: string = this.getSandboxPath(context);
      let path = filesDir + '/' + name;
      let file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let fdNumber = file.fd;
      let fileFd = commonData.STR.FILE_FD + fdNumber.toString();
      let obj: Record<string, fs.File | string> = {
        'file': file,
        'fileFd': fileFd
      };
      return obj;
    } catch (err) {
      HiLog.e(TAG, `getFileUrl err: ${err}` );
      let obj: Record<string, string> = {
        'fileFd': ''
      };
      return obj;
    }
  }

  getFileFd(path: string): number {
    HiLog.d(TAG, 'getFileFd');
    try {
      let file = fs.openSync(path, fs.OpenMode.READ_WRITE);
      let fdNumber = file.fd;
      HiLog.i(TAG, 'fdNumber: ' + fdNumber);
      this.closeFile(file);
      return fdNumber;
    } catch (err) {
      HiLog.e(TAG, `getFileUrl err: ${err}` );
      return -1;
    }
  }

  public getFilePath(context: Context, name: string): string {
    HiLog.d(TAG, 'getFilePath');
    let filesDir: string = this.getSandboxPath(context);
    let path: string = filesDir + '/' + name;
    return path;
  }

  public closeFile(file: fs.File) {
    HiLog.d(TAG, 'closeFile');
    if (file) {
      fs.closeSync(file);
    }
  }

  public getFileSize(fd: number): number {
    HiLog.d(TAG, 'getFileSize');
    try {
      let size: number = fs.statSync(fd).size;
      return size;
    } catch (err) {
      HiLog.e(TAG, `getFileSize err: ${err}` );
      return 0;
    }
  }

  public writeToSandBox(context: Context, path: string, data: ArrayBufferLike, name?: string) {
    HiLog.i(TAG, 'writeToSandBox');
    try {
      if (name && name !== '') {
        this.deleteFile(context, name);
      }
      let file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let fd = file.fd;
      fs.writeSync(fd, data);
      fs.closeSync(file);
    } catch (err) {
      HiLog.e(TAG, `writeToSandBox err: ${err}` );
    }
  }

  public getFileName(path: string) {
    if (!path || path === '') {
      HiLog.w(TAG, 'getFileName path is null');
      return '';
    }
    try {
      let file = new fileuri.FileUri(path);
      let name = file.name;
      HiLog.d(TAG, `getFileName name: ${name}`);
      return name;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      HiLog.e(TAG, `getFileName err: Code: ${e?.code}, message: ${e?.message}`);
    }
    return '';
  }

  public getTextFileContent(uri: string) {
    HiLog.d(TAG, 'getTextFileContent');
    try {
      let file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      let readTextOptions: ReadTextOptions = {
        offset: 0,
        length: 1600,
        // encoding: 'utf-8'
      };
      let content = fs.readTextSync(file.path, readTextOptions);
      fs.closeSync(file);
      return content
    } catch (err) {
      HiLog.e(TAG, `getTextFileContent err: ${err}` );
      return ''
    }
  }

  public getFileFullDirectoryUri(path: string) {
    HiLog.d(TAG, 'getFileFullDirectoryUri');
    if (!path || path === '') {
      HiLog.w(TAG, 'getFileFullDirectoryUri path is null');
      return '';
    }
    try {
      let file = new fileuri.FileUri(path);
      let uri = file.getFullDirectoryUri();
      return uri;
    } catch (err) {
      HiLog.e(TAG, 'getFileFullDirectoryUri error ' + JSON.stringify(err));
      return '';
    }

  }

  public writeTextToSandBox(context: Context, text: string, isSmil: boolean,
    basePath?: string, isSource?: boolean, transmitContent?: string): Record<string, string> {
    HiLog.i(TAG, 'writeTextToSandBox');
    let obj: Record<string, string> = {
      'path': '',
      'name': ''
    };
    try {
      let filesDir: string = basePath || this.getSandboxPath(context);
      let name: string = '';
      if (isSmil) {
        // According to the test result, if the file name is too long, the receiver cannot receive complete data.
        // So don't add Data.now()
        name = 'smil' + Date.now() + Math.random().toString(36).slice(2) + '.xml';
      } else {
        name = 'text' + Date.now() + Math.random().toString(36).slice(2) + '.txt';
      }
      if (name && name !== '') {
        this.deleteFile(context, name);
      }
      let filePath = filesDir + '/' + name;
      let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      if (isSource) {
        HiLog.i(TAG, 'text need to contain source, add transmitcontent');
        text = transmitContent + '\n' + text;
      }
      fs.writeSync(file.fd, text);
      fs.closeSync(file);
      obj.path = filePath;
      obj.name = name;
      return obj;
    } catch (err) {
      HiLog.e(TAG, `writeTextToSandBox err: ${err}`);
      return obj;
    }
  }

  public writeSmilToSandBox(text: string, path: string, mid: number, id: number) {
    HiLog.i(TAG, 'clone smil file: old db id: ' + id + ' mid: ' + mid);
    try {
      if (!fs.accessSync(path)) {
        HiLog.i(TAG, 'writeSmilToSandBox path no exist, create smil file with mid: ' + mid + ' and id: ' + id);
        let file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        if (!fs.writeSync(file.fd, text)) {
          HiLog.e(TAG, 'writeSmilToSandBox fail, create smil file with mid: ' + mid + ' and id: ' + id);
        }
        fs.closeSync(file);
      } else {
        HiLog.e(TAG, 'writeSmilToSandBox path exist');
      }
    } catch (err) {
      HiLog.e(TAG, `writeSmilToSandBox err: ${err}`);
    }
  }

  public writeVideoFirstFrameImageToSandBox(context: Context, videoPath: string, videoName: string,
    callBack?: (imagePath: string) => void) {
    HiLog.i(TAG, 'writeVideoFirstFrameImageToSandBox');
    let packOpts: image.PackingOption = {
      format: 'image/jpeg',
      quality: 20,
      bufferSize: 1024 * 300
    }
    ImageUtil.getFetchFrameByTime(videoPath, (pixMap: PixelMap) => {
      const imagePacker = image.createImagePacker();
      imagePacker.packing(pixMap, packOpts).then((data) => {
        let imageName: string = 'IMG_' + videoName.replace('mp4', 'jpeg');
        let imagePath: string = this.getSandboxPath(context) + '/' + imageName;
        this.writeToSandBox(context, imagePath, data, imageName);
        pixMap.release();
        imagePacker.release();
        if (callBack) {
          callBack(imagePath);
        }
      }).catch((error: Error) => {
        HiLog.e(TAG, 'writeVideoFirstFrameImageToSandBox packing fail error: ' + JSON.stringify(error));
      });
    });
  }

  public writeMediaToSandBox(context: Context, imageUriData: string | transmitUriInfo, mediaType: number,
    flag: boolean = false, isOriginalMms: boolean = false, isFromTransmit: boolean = false): string {
    HiLog.i(TAG, 'writePictureToSandBox');
    const randomStr = Date.now() + Math.random().toString(36).slice(2);
    let imageUri = imageUriData as string;
    let basePath = this.getSandboxPath(context);
    if (typeof imageUriData === 'object') {
      imageUri = imageUriData?.imageUri || '';
      basePath = imageUriData?.basePath || '';
    }
    try {
      let file: fs.File
      if (flag) {
        file = fs.openSync(imageUri, fs.OpenMode.READ_ONLY);
      } else {
        file = fs.openSync(imageUri, fs.OpenMode.READ_WRITE);
      }
      let size = fs.statSync(file.fd).size;
      let buffer = new ArrayBuffer(size);
      fs.readSync(file.fd, buffer);
      HiLog.i(TAG, `writePictureToSandBox size: ${size}`);
      let name = this.getFileName(imageUri);
      let dotPosition = name.indexOf('.');
      let fileFormat: string = name.substring(dotPosition + 1);
      let mediaName: string = '';
      // isOriginalMms 转发场景下被转发消息是否为增强信息
      if (ConversationController.getInstance().isRcsMms && !isOriginalMms && typeof imageUriData === 'string') {
        // 转发时在资源沙箱路径下新增一个时间戳文件夹来保存同名文件，不修改文件名。
        let newDir = isFromTransmit ? Date.now() + '' : '';
        mediaName = this.createNewMediaNameforEnhancedInfo(context, fileFormat, mediaType, name, newDir);
      } else if (mediaType === common.MM_ATTACHMENT_TYPE.IMAGE || mediaType === common.MM_ATTACHMENT_TYPE.MAP) {
        if (flag) {
          mediaName = 'DRAG_IMG_' + randomStr + '.' + fileFormat;
        } else {
          if (dotPosition === -1) {
            HiLog.w(TAG, 'dotposition is -1, original file have no suffix');
            mediaName = fileFormat;
          } else {
            mediaName = 'IMG_' + randomStr + '.' + fileFormat;
          }
        }
      } else if (mediaType === common.MM_ATTACHMENT_TYPE.VIDEO) {
        mediaName = 'VIDEO_' + randomStr + '.' + fileFormat;
      } else if (mediaType === common.MM_ATTACHMENT_TYPE.AUDIO) {
        mediaName = 'RECORD_' + randomStr + '.' + fileFormat;
      } else if (mediaType === common.MM_ATTACHMENT_TYPE.VCARD) {
        mediaName = 'VCARD_' + randomStr + '.' + fileFormat;
      }
      let dest = basePath + '/' + mediaName;
      let destFile = fs.openSync(dest, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      fs.writeSync(destFile.fd, buffer);
      fs.closeSync(file);
      fs.closeSync(destFile);
      if (mediaType === common.MM_ATTACHMENT_TYPE.VIDEO) {
        this.writeVideoFirstFrameImageToSandBox(context, dest, mediaName);
      }
      return dest;
    } catch (err) {
      HiLog.i(TAG, `writeMediaToSandBox err: ${err}` );
      return '';
    }
  }

  async saveFileToFileManager(context: Context, sandBoxPath: string, name: string) {
    HiLog.i(TAG, 'saveFileToFileManager');
    const documentViewPicker = new picker.DocumentViewPicker(context);
    const documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
    try {
      //get fileSandbox.fd
      let fileSandbox = await fs.open(sandBoxPath, fs.OpenMode.READ_ONLY);
      let size = fs.statSync(fileSandbox.fd).size;
      let fileSandboxBuffer = new ArrayBuffer(size);
      fs.readSync(fileSandbox.fd, fileSandboxBuffer);
      //write to fileManager
      let uri = (await documentViewPicker.save(documentSaveOptions))[0]
      const testFilePath = new fileUri.FileUri(uri + '/' + name).path;
      let file = await fs.open(testFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      await fs.write(file.fd, fileSandboxBuffer);
      fs.close(fileSandbox.fd);
      fs.close(file.fd);
      prompt.showToast({ message: $r('app.string.Saved_to_folders', uri), duration: 200 });
    } catch (err) {
      let error = err as BusinessError;
      HiLog.i(TAG, `saveFileToFileManager: ${error}`);
    }
  }

  private createNewMediaNameforEnhancedInfo(context: Context, fileFormat: string, mediaType: number,
    fileName: string, newDir: string) {
    HiLog.i(TAG, `createNewMediaNameforEnhancedInfo newDir :${newDir}`);
    // 转发时在资源沙箱路径下新增一个时间戳文件夹来保存同名文件，不修改文件名。
    let isNewDir: boolean = !StringUtil.isEmpty(newDir);
    if (isNewDir) {
    let sandPath = this.getSandboxPath(context) + '/' + newDir;
    fs.mkdirSync(sandPath);
    }
    let mediaName = '';
    let prefixName = isNewDir ? newDir + '/' : '';
    if (fileName) {
      let names = fileName.split('.');
      mediaName = prefixName + `${names[0]}.${fileFormat}`;
    } else {
      mediaName = prefixName + `${ENHANCED_INFO_SUPPORT_FORWARD_FILE_TYPES.get(mediaType) || 'UNKNOWN'}.${fileFormat}`;
    }
    return mediaName;
  }

  deleteFile(context: Context, name: string) {
    HiLog.i(TAG, 'deleteFile');
    try {
      let path = this.getSandboxPath(context);
      let filePath = path + '/' + name;
      if (fs.accessSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    } catch (err) {
      HiLog.e(TAG, `deleteFile err: ${err}` );
    }
  }

  getFileSizeByPath(path: string): number {
    try {
      HiLog.i(TAG, 'getFileSizeByName');
      if (!fs.accessSync(path)) {
        HiLog.i(TAG, 'getFileSizeByName failed');
        return 0;
      }
      let file = fs.openSync(path, fs.OpenMode.READ_WRITE);
      let size = this.getFileSize(file.fd);
      fs.closeSync(file);
      return size;
    } catch (err) {
      HiLog.e(TAG, `getFileSizeByPath err: ${err}` );
      return 0;
    }
  }

  getFileSizeByUri(uri: string): number {
    try {
      HiLog.i(TAG, 'getFileSizeByUri');
      let file = fs.openSync(uri, fs.OpenMode.READ_WRITE);
      let size = this.getFileSize(file.fd);
      fs.closeSync(file);
      return size;
    } catch (err) {
      HiLog.e(TAG, `getFileSizeByPath err: ${err}` );
      return 0;
    }
  }

  getFileSizeAndFile(path: string): Record<string, number | fs.File> | undefined {
    try {
      HiLog.i(TAG, 'getFileSizeByName');
      if (!fs.accessSync(path)) {
        HiLog.i(TAG, 'getFileSizeByName failed');
        return;
      }
      let file = fs.openSync(path, fs.OpenMode.READ_WRITE);
      let size = this.getFileSize(file.fd);
      let obj: Record<string, number | fs.File> = {
        'file': file,
        'size': size
      }
      return obj;
    } catch (err) {
      HiLog.e(TAG, `getFileSizeByPath err: ${err}` );
      return;
    }
  }

  getTransitStationFileSizeByUri(uri: string): number {
    try {
      HiLog.i(TAG, 'getFileSizeByUri');
      let file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      let size = this.getFileSize(file.fd);
      fs.closeSync(file);
      return size;
    } catch (err) {
      HiLog.e(TAG, `getFileSizeByPath err: ${err}` );
      return 0;
    }
  }

  async packingSize(item: string, faceDetectFlag?: number, isDragImage?: boolean) {
    let obj: packingItem = {
      size: 0,
      data: new ArrayBuffer(0)
    }
    let file:fs.File ;
    try {
      if (isDragImage) {
        file = fs.openSync(item, fs.OpenMode.READ_ONLY);
      } else {
        file = fs.openSync(item, fs.OpenMode.READ_WRITE);
      }
    } catch (error) {
      HiLog.i(TAG, 'packingSize openSync is error:' + JSON.stringify(error));
      return obj;
    }
    let fd = file.fd;
    let originSize = fs.statSync(fd).size;
    if (SUPPORTED_PACK_TYPE.some(ele => file.name?.toLowerCase()?.includes(ele))) {
      let resultSize = originSize;
      let constMaxSize = 0;
      if (faceDetectFlag && faceDetectFlag == 1) {
        constMaxSize = commonData.int.RCS_IMAGE_FACE_DETECT_MAX_SIZE;
      } else {
        constMaxSize = commonData.int.MMS_FILE_MAX_SIZE;
      }
      let maxSize: number = OperatorConfigUtil.getInstance().getCustMMSSize(
        constMaxSize)
      let imageSource = image.createImageSource(fd);
      let imageInfo = await imageSource.getImageInfo();
      let width: number = imageInfo.size.width;
      let height: number = imageInfo.size.height;
      let scaleFactor: number = 1;
      while ((width * scaleFactor > IMAGE_ADJUST_MIN_WIDTH) || (height * scaleFactor > IMAGE_ADJUST_MIN_HEIGHT)) {
        scaleFactor *= 0.75
      }
      if (originSize > maxSize) {
        let reSizeCount = 0;
        while (resultSize > maxSize && reSizeCount < 3) {
          let packOpts: image.PackingOption = {
            format: 'image/jpeg', quality: 90
          }
          if (faceDetectFlag && faceDetectFlag == 1) {
            packOpts.quality = 100;
          }
          HiLog.i(TAG,'packingSize createPixelMap');
          await imageSource.createPixelMap({
            desiredSize: { width: width * scaleFactor, height: height * scaleFactor }
          }).then(async data => {
            const imagePackerApi = image.createImagePacker();
            packOpts.quality -= (PACKING_SUBTRACT_EACH * reSizeCount)
            await imagePackerApi.packing(data, packOpts)
              .then(res => {
                data.release();
                resultSize = res.byteLength
                obj.size = resultSize;
                obj.data = res;
                reSizeCount++
                imagePackerApi.release();
              })
          })
        }
        imageSource.release()
        fs.closeSync(file);
        HiLog.i(TAG,`obj.data.byteLength:${obj.data.byteLength}`)
        return obj;
      } else {
        obj.size = resultSize;
        HiLog.i(TAG,`obj.data.byteLength:${obj.data.byteLength}`)
        fs.closeSync(file);
        imageSource.release()
        return obj;
      }

    } else {
      obj.size = originSize;
      fs.closeSync(file);
      return obj;
    }
  }

  async writeVideoFirstFrameImageToSandBoxSync(context: Context, sourcePath: string,
    videoPath: string, videoName: string):
    Promise<void> {
    HiLog.i(TAG, 'writeVideoFirstFrameImageToSandBoxSync');
    let packOpts: image.PackingOption = {
      format: 'image/jpeg',
      quality: 20,
      bufferSize: 1024 * 300
    }
    await ImageUtil.getFetchFrameByTime(videoPath, async (pixelMap: PixelMap) => {
      const imagePacker = image.createImagePacker();
      await imagePacker.packing(pixelMap, packOpts).then(async (data) => {
        let imageName: string = 'IMG_' + videoName.replace('mp4', 'jpeg');
        let imagePath: string = sourcePath + '/' + imageName
        await this.writeToSandBoxSync(context, imagePath, data, imageName);
        pixelMap.release();
        imagePacker.release();
      }).catch((error: Error) => {
        HiLog.e(TAG, 'writeVideoFirstFrameImageToSandBoxSync packing fail error: ' + JSON.stringify(error));
      });
    });
  }

  async writeToSandBoxSync(context: Context, path: string, data: ArrayBufferLike, name?: string): Promise<void> {
    HiLog.i(TAG, 'writeToSandBoxSync');
    try {
      if (name && name !== '') {
        this.deleteFile(context, name);
      }
      let file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let fd = file.fd;
      fs.writeSync(fd, data);
      fs.closeSync(file);
    } catch (err) {
      HiLog.e(TAG, `writeToSandBoxSync err: ${err}`);
    }
  }


  /**
   * Save text to sandbox
   *
   * @param text
   * @param textType
   * @returns
   */
  public saveTextToSandBox(context: Context, text: string, textType: SaveTextType): SavedFileInfo {
    let fileInfo: Record<string, string> = this.writeTextToSandBox(context, text, false);
    if (textType === SaveTextType.TXT) {
      return {
        name: fileInfo.name,
        path: fileInfo.path
      };
    } else {
      return {
        name: fileInfo.name.substring(0, fileInfo.name.lastIndexOf('.txt')) + textType,
        path: this.renameFile(fileInfo.path, fileInfo.path.substring(0, fileInfo.path.lastIndexOf('.txt')) + textType)
      }
    }
  }

  /**
   * Rename file
   *
   * @param oldPath
   * @param newPath
   * @returns final path. If rename success, return newPath, otherwise return oldPath.
   */
  public renameFile(oldPath: string, newPath: string): string {
    let finalPath: string = oldPath;
    try {
      fs.renameSync(oldPath, newPath);
      finalPath = newPath;
      HiLog.d(TAG, 'Rename succeed.');
    } catch (err) {
      HiLog.e(TAG, 'Rename failed. ' + JSON.stringify(err));
    }
    return finalPath;
  }

  /**
   * Remove the timestamp from the downloaded file name.
   *
   * @param fileName
   * @returns
   */
  public fileNameRemoveTimestamp(fileName: string): string {
    let dotIndex: number = fileName.lastIndexOf('.');
    if (dotIndex === -1) {
      fileName = fileName.substring(0, fileName.lastIndexOf('_'));
    } else {
      fileName = fileName.substring(0, fileName.lastIndexOf('_')) + fileName.substring(dotIndex);
    }
    return fileName;
  }

  public async packPixelMapToSandBox(context: Context, path: string, pixelMap: PixelMap, delFile?: string,
    isReturnSize?: boolean) {
    HiLog.i(TAG, 'packPixelMapToSandBox');
    try {
      let packer: image.ImagePacker = image.createImagePacker()
      let option: image.PackingOption = {
        format: 'image/jpeg',
        quality: 90
      }
      let buffer: ArrayBuffer = await packer.packing(pixelMap, option)
      HiLog.i(TAG, 'packPixelMapToSandBox buffer size: ' + buffer.byteLength);
      if (delFile && delFile !== '') {
        this.deleteFile(context, delFile);
      }
      let file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let fd = file.fd;
      fs.writeSync(fd, buffer);
      let size = 0;
      if (isReturnSize) {
        size = fs.statSync(fd).size;
      }
      fs.closeSync(file);
      packer.release();
      return size;
    } catch (err) {
      HiLog.e(TAG, `packPixelMapToSandBox err: ${err}` );
    } finally {
      if (pixelMap) {
        await pixelMap.release();
      }
    }
    return 0;
  }

  /**
   * 首选项新增迁移xml到db后可删除
   */
  private getSandboxPathPreferencesDir(context: Context) {
    HiLog.i(TAG, 'getSandboxPath start');
    let preferencesDir: string = context.preferencesDir;
    if (preferencesDir.endsWith('/haps/entry/preferences')) {
      preferencesDir = preferencesDir.replace('/haps/entry/preferences', '/preferences');
    }
    return preferencesDir;
  }

  public getMmsStoreDir(context: Context) {
    let filesDir: string = this.getSandboxPathPreferencesDir(context);
    let mmsStoreSrc: string = filesDir + '/' + 'MmsStore';
    return mmsStoreSrc;
  }

  public getMmsStoreCopyDir(context: Context) {
    let filesDir: string = this.getSandboxPathPreferencesDir(context);
    let mmsStoreCopySrc: string = filesDir + '/' + 'MmsStoreCopy';
    return mmsStoreCopySrc;
  }

  public formatFileName(fileName: string): string {
    if (StringUtil.isEmpty(fileName)) {
      HiLog.e(TAG, 'formatFileName string empty error');
      return '';
    }
    let formatFileName: string = fileName;
    return formatFileName.replaceAll('/', '').replaceAll('\\', '').replaceAll('~', '');
  }

  public checkFileAccess(path: string): boolean {
    try {
      HiLog.i(TAG, 'checkFileAccess');
      if (!fs.accessSync(path)) {
        HiLog.w(TAG, 'checkFileAccess failed');
        return false;
      }
      return true;
    } catch (err) {
      HiLog.e(TAG, `checkFileAccess err: ${err}`);
      return false;
    }
  }
}

export interface SavedFileInfo {
  name: string,
  path: string
}

export interface transmitUriInfo {
  imageUri?: string,
  basePath?: string
}

export enum SaveTextType {
  XML = '.xml',
  TXT = '.txt',
  VCF = '.vcf',
}

/**
 * formatFileSize
 *
 * @param fileByteSize
 * @param remainDecimalPlacesNum [0, 10]
 * @returns
 */
export function formatFileSize(fileByteSize: number, remainDecimalPlacesNum: number) {
  HiLog.i(TAG, 'fileByteSize :' + fileByteSize);
  if (!fileByteSize || fileByteSize < 0) {
    return LocationUtil.numFormat(0, 'byte');
  }
  let decimalPlacesNum = (remainDecimalPlacesNum >= 10) ? 10 :
    ((remainDecimalPlacesNum <= 0) ? 0 : remainDecimalPlacesNum);
  if (fileByteSize < 1000) {
    return LocationUtil.numFormat(fileByteSize, 'byte');
  } else if (fileByteSize < (1000 * 1000)) {
    let temp = fileByteSize / 1000;
    return LocationUtil.numFormat(Number.parseFloat(temp.toFixed(decimalPlacesNum)), 'kilobyte');
  } else {
    let temp = fileByteSize / (1000 * 1000);
    return LocationUtil.numFormat(Number.parseFloat(temp.toFixed(decimalPlacesNum)), 'megabyte');
  }
}

export function getMineTypeFromFileName(fileName: string) {
  if (!fileName) {
    return 'text/plain';
  }
  let temps = fileName.split('.');
  let suffixName = temps[temps.length - 1];
  if (!suffixName) {
    return 'text/plain';
  }
  suffixName = suffixName.toLowerCase();
  let mimeType = mapSuffixNameToMiME.get(suffixName) || 'text/plain';
  return mimeType;
}

export function getMineTypeFromFileNameAndCt(fileName: string, ct: string | undefined) {
  if (!fileName) {
    return 'text/plain';
  }
  let temps = fileName.split('.');
  let suffixName = temps[1];
  if (!suffixName) {
    if (!StringUtil.isEmpty(ct) && ct !== undefined) {
      return ct;
    } else {
      return 'text/plain';
    }
  }
  suffixName = suffixName.toLowerCase();
  let mimeType = mapSuffixNameToMiME.get(suffixName) || 'text/plain';
  return mimeType;
}

export default new FileUtil();