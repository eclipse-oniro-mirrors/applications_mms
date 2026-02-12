/**
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
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
import lazy fileIo, { ListFileOptions } from '@ohos.file.fs';
import lazy fs from '@ohos.file.fs';
import lazy statSync from '@ohos.file.fs';
import FileUtil from './FileUtil';
import HiLog from './HiLog';
import { fileUri } from '@kit.CoreFileKit';
import StringUtil from './StringUtil';

const TAG = 'FileUtils';
const SUPPORT_VIDEO_FORMAT_LIST = ['.mp4', '.3gp'];
// 使用时间戳与_ 一起命名的文件夹，为收发消息时同一条消息下沙箱中的文件夹名称
const NUM_REG: RegExp = new RegExp('^[_0-9]+$');
/**
 * Handle file data
 */
export default class FileUtils {

  /**
   * Copy file util
   *
   * @param srcPath copy from this path
   * @param dstPath copy to this path
   * @returns if copy success
   */
  static copyFile(srcPath: string, dstPath: string): boolean {
    try {
      fileIo.copyFileSync(srcPath, dstPath);
      HiLog.i(TAG, 'copyFile success');
      return true;
    } catch (error) {
      HiLog.i(TAG, 'copyFile error: ' + JSON.stringify(error));
      return false;
    }
  }

  static copyDir(srcPath: string, dstPath: string): boolean {
    try {
      fileIo.copyDirSync(srcPath, dstPath, 1);
      HiLog.i(TAG, 'copyDir success');
      return true;
    } catch (error) {
      HiLog.i(TAG, 'copyDir error: ' + JSON.stringify(error));
      return false;
    }
  }

  static getFileInDir(srcPath: string): string[] {
    HiLog.i(TAG, 'getFileInDir start');
    let filesPath: string[] = [];
    try {
      let option: ListFileOptions = {
        filter: {
          suffix: ['.mp4'],
          fileSizeOver: 0
        }
      }
      let fileNames = fileIo.listFileSync(srcPath, option);
      fileNames.forEach((filename: string) => {
        let filePath = `${srcPath}/${filename}`;
        let fileStat = statSync.statSync(filePath);
        if (fileStat.isFile()) {
          filesPath.push(filePath)
        }
      })
    } catch (error) {
      HiLog.i(TAG, 'getFileInDir error: ' + JSON.stringify(error));
    }
    return filesPath;
  }

  static deleteFile(srcPath: string): boolean {
    try {
      fs.unlinkSync(srcPath);
      HiLog.i(TAG, 'deleteFile success');
      return true;
    } catch (error) {
      HiLog.e(TAG, 'deleteFile error: ' + JSON.stringify(error));
      return false;
    }
  }

  public static extractFileDir(filePath: string): string {
    const lastIndex = filePath.lastIndexOf('/');
    if (lastIndex !== -1) {
      return filePath.slice(0, lastIndex);
    } else {
      return '';
    }
  }

  public static extractFileName(filePath: string): string {
    const lastIndex = filePath.lastIndexOf('/');
    if (lastIndex !== -1) {
      return filePath.slice(lastIndex + 1);
    } else {
      return '';
    }
  }

  /**
   * 删除多个文件
   *
   * @param context 上下文
   * @param pathList 文件路径列表
   * @param isCleanDirFile 是否清理文件夹下文件场景
   * @returns 实际删除的文件数量
   */
  public static deleteListFileAfterDataBaseDelete(context: Context, filePathList: string[],
    isCleanDirPath: boolean = false): void {
    let deleteFileNum = 0;
    let deleteDirNum = 0;
    let dirPathList: Set<string> = new Set();
    if (!context || filePathList?.length === 0) {
      HiLog.w(TAG, 'deleteListFileAfterDataBaseDelete param invalid');
      return;
    }
    const sandBoxPath: string = FileUtil.getSandboxPath(context);
    filePathList.forEach(filePath => {
      try {
        filePath && fs.accessSync(filePath) && fs.unlinkSync(filePath);
        deleteFileNum++;
        // 视频类消息生成缩略图 (修改文件名称和前缀后存至沙箱)未存储至mms_part表,页面展示时根据原文件前后拼接截取直接从沙箱中获取需同步删除
        deleteFileNum = FileUtils.deleteVideoThumbImage(filePath, sandBoxPath, deleteFileNum);
      } catch (err) {
        HiLog.e(TAG, 'deleteListFileAfterDataBaseDelete delSandBox failed');
      }
      // 如果存在空文件夹需删除空文件夹(时间戳/时间戳与_ 命名的全为数字的文件夹)
      let dirPath = FileUtils.extractFileDir(filePath);
      let dirName = FileUtils.extractFileName(dirPath);
      if (dirPath && sandBoxPath?.length < dirPath?.length && NUM_REG.test(dirName)) {
        dirPathList.add(dirPath);
      }
    })
    if (isCleanDirPath) {
      return;
    }
    // 同一文件夹下为同一条消息的附件 为确保删除彻底需将同一文件夹下可能残留的文件彻底删除
    for (let dirPath of dirPathList) {
      if (dirPath && sandBoxPath !== dirPath && fs.accessSync(dirPath)) {
        try {
          let listPath: string[] = fs.listFileSync(dirPath);
          if (listPath?.length > 0) {
            FileUtils.deleteListFileAfterDataBaseDelete(context, listPath, true);
            deleteFileNum += listPath.length;
            HiLog.e(TAG, `deleteListFileAfterDataBaseDelete for dir has file.length:${listPath.length}`);
          }
          fs.rmdir(dirPath);
          deleteDirNum++;
        } catch (err) {
          HiLog.e(TAG, 'deleteListFileAfterDataBaseDelete for empty dir delSandBox failed');
        }
      }
    }
    HiLog.w(TAG, `deleteListFileAfterDataBaseDelete deleteFileNum :${deleteFileNum} deleteDirNum : ${deleteDirNum}`);
  }

  private static isVideoType(fileName: string) {
    let isSupport = false;
    for (let supportFormat of SUPPORT_VIDEO_FORMAT_LIST) {
      if (fileName.toLowerCase().endsWith(supportFormat)) {
        isSupport = true;
        break;
      }
    }
    HiLog.d(TAG, `isVideoType :${isSupport}`);
    return isSupport;
  }

  private static deleteVideoThumbImage(filePath: string, sandBoxPath: string, deleteFileNum: number) {
    // 视频类消息生成缩略图 (修改文件名称和前缀后存至沙箱)未存储至mms_part表,页面展示时根据原文件前后拼接截取直接从沙箱中获取需同步删除
    let videoName = FileUtil.getFileName(filePath);
    if (FileUtils.isVideoType(videoName)) {
      let imageName = '';
      if (videoName.endsWith('.mp4')) {
        imageName = 'IMG_' + videoName.replace('mp4', 'jpeg');
      } else {
        imageName = 'IMG_' + videoName.replace('3gp', 'jpeg');
      }
      HiLog.w(TAG, `deleteListFileAfterDataBaseDelete video thumb imageName: ${imageName}`);
      let thumbPath: string = sandBoxPath + '/' + imageName;
      if (thumbPath && fs.accessSync(thumbPath)) {
        fs.unlinkSync(thumbPath);
        deleteFileNum++;
      }
    }
    return deleteFileNum;
  }

  //从本地获取沙盒图片
  static getSandboxPath(context: Context, pubNum: string): string {
    let sandboxPath = context.filesDir + `/${pubNum}.jpg`
    //先从本地沙箱获取，如果没有，则从接口取
    try {
      if (FileUtils.isHasLocationImage(context, pubNum)) {
        let uri = fileUri.getUriFromPath(sandboxPath);
        HiLog.i(TAG, `success to getFullDirectoryUri, pubNum is ${StringUtil.phoneMask(pubNum)}`);
        return uri;
      } else {
        return '';
      }
    } catch (error) {
      return '';
    }
  }

  static isHasLocationImage(context: Context, pubNum: string): boolean {
    try {
      let sandboxPath = context.filesDir + `/${pubNum}.jpg`
      let isHasLocationImage: boolean = fs.accessSync(sandboxPath);
      if (isHasLocationImage) {
        HiLog.w(TAG, `has image, pubNum is ${StringUtil.phoneMask(pubNum)}`);
        return true;
      } else {
        HiLog.e(TAG, `no has image, pubNum is ${StringUtil.phoneMask(pubNum)}`);
        return false;
      }
    } catch (error) {
      HiLog.e(TAG, `no has image: ${JSON.stringify(error)}, pubNum is ${StringUtil.phoneMask(pubNum)}`);
      return false;
    }
  }

  static removeLocationImage(context: Context, pubNum: string) {
    try {
      let sandboxPath = context.filesDir + `/${pubNum}.jpg`
      if (FileUtils.isHasLocationImage(context, pubNum)) {
        if (FileUtils.deleteFile(sandboxPath)) {
          HiLog.i(TAG, `delete location image success`);
        } else {
          HiLog.e(TAG, `delete location image false`);
        }
      }
    } catch (error) {
      HiLog.e(TAG, `no has image: ${JSON.stringify(error)}`);
    }
  }

  public static deleteFileByPathOrUri(pathOrUri: string) {
    HiLog.i(TAG, 'deleteFileByPathOrUri');
    try {
      fileIo.unlink(new fileUri.FileUri(pathOrUri).path);
    } catch (e) {
      HiLog.e(TAG, `deleteFileByPathOrUri error: ${e?.code} ${e?.message}`);
    }
  }

  /**
   * 视频类消息生成缩略图在视频类消息删除时需同步删除
   *
   * @param filePath 文件路径
   * @param context 上下文
   */
  public static deleteVideoThumb(filePath: string, context: Context): void{
    let deleteNum: number = 0;
    deleteNum = FileUtils.deleteVideoThumbImage(filePath, FileUtil.getSandboxPath(context), deleteNum);
    HiLog.i(TAG, `deleteVideoThumb deleteNum is: ${deleteNum}`);
  }
}