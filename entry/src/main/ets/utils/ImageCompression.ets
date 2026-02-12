/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import lazy fs from '@ohos.file.fs';
import image from '@ohos.multimedia.image';
import HiLog from './HiLog';

const TAG = 'IMAGE_COMPRESSION';
const BYTE_CONVERSION: number = 1024;
const MAX_TRY_CNT: number = 10;
const REDUCE_SCALE: number = 0.6;
const DEFAULT_REDUCE_SCALE: number = 0.9;
const REDUCE_SCALE_OFFSET: number = 0.1;
const FILE_SIZE_FIFTY: number = 50;
const FILE_SIZE_TWENTY: number = 20;
const FILE_SIZE_FIFTEEN: number = 15;
const FILE_SIZE_TWELVE: number = 12;

export class CompressedImageInfo {
  public imageUri: string = ''; // URI of the path for storing compressed images.
  public imageByteLength: number = 0; // Byte length of the image after compression
}

export class ImageCompression {
  /**
   * Image compression, saving
   * @param sourcePixelMap：PixelMap object of the original image to be compressed.
   * @param maxCompressedImageSize：Size of the image to be compressed, in KB.
   * @returns compressedImageInfo：Return the final compressed image information.
   */
  async compressedImage(sourcePixelMap: image.PixelMap, maxCompressedImageSize: number): Promise<CompressedImageInfo> {
    const imagePackerApi = image.createImagePacker();
    const IMAGE_QUALITY = 75;
    const packOpts: image.PackingOption = { format: 'image/jpeg', quality: IMAGE_QUALITY };
    let compressedImageData: ArrayBuffer = await imagePackerApi.packing(sourcePixelMap, packOpts);
    const maxCompressedImageByte = maxCompressedImageSize * BYTE_CONVERSION;
    HiLog.i(TAG,
      'compressedImage: maxCompressedImageByte ' + maxCompressedImageByte + 'compressedImageData.byteLength ' +
      compressedImageData.byteLength);
    if (maxCompressedImageByte > compressedImageData.byteLength) {
      compressedImageData =
        await this.packingImage(compressedImageData, sourcePixelMap, IMAGE_QUALITY, maxCompressedImageByte);
    } else {
      let imageScale = 1.0;
      let tryCnt = 0;
      while (compressedImageData.byteLength >= maxCompressedImageByte && tryCnt < MAX_TRY_CNT) {
        imageScale = await this.calculateRatio(compressedImageData.byteLength);
        HiLog.i(TAG, 'compressedImage imageScale ' + imageScale);
        await sourcePixelMap.scale(imageScale, imageScale);
        compressedImageData = await this.packing(sourcePixelMap, IMAGE_QUALITY);
        tryCnt++;
      }
    }

    const compressedImageInfo: CompressedImageInfo = await this.saveImage(compressedImageData);
    imagePackerApi.release();
    return compressedImageInfo;
  }

  async calculateRatio(dataLen: number): Promise<number> {
    if (dataLen > BYTE_CONVERSION * FILE_SIZE_FIFTY) {
      return REDUCE_SCALE - (REDUCE_SCALE_OFFSET + REDUCE_SCALE_OFFSET);
    }

    if (dataLen > BYTE_CONVERSION * FILE_SIZE_TWENTY) {
      return REDUCE_SCALE;
    }

    if (dataLen > BYTE_CONVERSION * FILE_SIZE_FIFTEEN) {
      return REDUCE_SCALE + REDUCE_SCALE_OFFSET;
    }

    if (dataLen > BYTE_CONVERSION * FILE_SIZE_TWELVE) {
      return REDUCE_SCALE + REDUCE_SCALE_OFFSET + REDUCE_SCALE_OFFSET;
    }

    return DEFAULT_REDUCE_SCALE;
  }

  /**
   * packing compression
   * @param sourcePixelMap：PixelMap of the original image to be compressed
   * @param imageQuality：Image quality parameters
   * @returns data：Compressed image data is returned.
   */
  async packing(sourcePixelMap: image.PixelMap, imageQuality: number): Promise<ArrayBuffer> {
    const imagePackerApi = image.createImagePacker();
    const packOpts: image.PackingOption = { format: 'image/jpeg', quality: imageQuality };
    const data: ArrayBuffer = await imagePackerApi.packing(sourcePixelMap, packOpts);
    imagePackerApi.release();
    return data;
  }

  /**
   * Packing two-way circulation compression
   * @param compressedImageData: ArrayBuffer for image compression
   * @param sourcePixelMap: PixelMap of the original image to be compressed
   * @param imageQuality: image quality parameters
   * @param maxCompressedImageByte: length of the compressed target image (in bytes)
   * @returns compressedImageData: Returns the image data compressed using binary packing.
   */
  async packingImage(compressedImageData: ArrayBuffer, sourcePixelMap: image.PixelMap, imageQuality: number,
    maxCompressedImageByte: number): Promise<ArrayBuffer> {
    const packingArray: number[] = [];
    const DICHOTOMY_ACCURACY = 10;
    for (let i = 0; i <= 100; i += DICHOTOMY_ACCURACY) {
      packingArray.push(i);
    }
    let left = 0;
    let right = packingArray.length - 1;
    while (left <= right) {
      const mid = Math.floor((left + right) / 2);
      imageQuality = packingArray[mid];
      compressedImageData = await this.packing(sourcePixelMap, imageQuality);
      if (compressedImageData.byteLength <= maxCompressedImageByte) {
        left = mid + 1;
        if (mid === packingArray.length - 1) {
          break;
        }
        compressedImageData = await this.packing(sourcePixelMap, packingArray[mid + 1]);
        if (compressedImageData.byteLength > maxCompressedImageByte) {
          compressedImageData = await this.packing(sourcePixelMap, packingArray[mid]);
          break;
        }
      } else {
        right = mid - 1;
      }
    }
    return compressedImageData;
  }

  /**
   * Image saving
   * @param compressedImageData: compressed image data
   * @returns compressedImageInfo: Returns the compressed image information.
   */
  async saveImage(compressedImageData: ArrayBuffer): Promise<CompressedImageInfo> {
    const context: Context = getContext();
    let currentTime = Date.now();
    const compressedImageUri: string = context.filesDir + '/' + currentTime + '.jpeg';
    try {
      const res = fs.accessSync(compressedImageUri);
      if (res) {
        fs.unlinkSync(compressedImageUri);
      }
    } catch (err) {
      HiLog.e(TAG, `AccessSync failed with error message: ${err.message}, error code: ${err.code}`);
    }
    const file: fs.File = fs.openSync(compressedImageUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.writeSync(file.fd, compressedImageData);
    fs.closeSync(file);
    let compressedImageInfo: CompressedImageInfo = new CompressedImageInfo();
    compressedImageInfo.imageUri = compressedImageUri;
    compressedImageInfo.imageByteLength = compressedImageData.byteLength;
    return compressedImageInfo;
  }
}

export default new ImageCompression()