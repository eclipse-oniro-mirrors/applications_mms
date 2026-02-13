/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import { image } from '@kit.ImageKit';
import { JSON, LightWeightMap, LightWeightSet } from '@kit.ArkTS';
import Stack from '@ohos.util.Stack';
import HiLog from './HiLog';
import StringUtil from './StringUtil';
import { ChatbotUtils } from '../chatbot/utils/ChatbotUtils';
import lazy fs from '@ohos.file.fs';

const TAG: string = 'AiFaceChangeUtils';

// 定义完整的登录回调类型
export type aiDetectCallback = (result: string, fileId: number) => void;

export class AiFaceChangeUtils {
  private static instance = new AiFaceChangeUtils();
  // 是否已经初始化
  private isInit = false;
  // 模型检测中
  private isDetecting = false;
  // 图片检测栈
  private detectStack: Stack<number> = new Stack();
  // 需要参与图片检测的图片信息集合
  private detectContainer: LightWeightMap<number, string> = new LightWeightMap();
  // 已经处理过的图片信息集合
  private detectedSet: LightWeightSet<number> = new LightWeightSet();


  private constructor() {
  }


  /**
   * 获取AI人脸检测实例
   *
   * @returns AI人脸检测实例
   */
  public static getInstance() {
    return AiFaceChangeUtils.instance || (AiFaceChangeUtils.instance = new AiFaceChangeUtils());
  }

  public async startAiFaceChange(fileLocalPath: string, fileId: number, callBack: aiDetectCallback) {
    if (!this.isInit) {
      // 模型没有初始化则初始化反诈SA
      await this.initializeModel();
    }
    let filePath = fileLocalPath;
    const FILE_PREFIX = 'file://';
    if (fileLocalPath.startsWith(FILE_PREFIX)) {
      filePath = fileLocalPath.replace(FILE_PREFIX, '');
    }
    if (!ChatbotUtils.isExistFile(filePath)) {
      HiLog.e(TAG, `[detectAiFaceChange] fail, flie path not exit`);
      return;
    }
    if (typeof fileId !== 'number' || fileId < 0) {
      HiLog.e(TAG, `[detectAiFaceChange] fail, flie path not exit`);
      return;
    }
    if (this.detectedSet.has(fileId)) {
      HiLog.i(TAG, `[detectAiFaceChange] Has been dealt with this image`);
      return;
    }
    HiLog.i(TAG, `shike [detectAiFaceChange] start`);
    this.detectStack.push(fileId);
    this.detectContainer.set(fileId, fileLocalPath)
    if (!this.isDetecting) {
      // 模型没有在运行则开启运行
      await this.handelDetect(callBack);
    }
  }

  private async handelDetect(callBack: aiDetectCallback) {
    let imageSource: image.ImageSource | undefined;
    let pixelMap: image.PixelMap | undefined;
    while (!this.detectStack.isEmpty()) {
      this.isDetecting = true;
      const fileId = this.detectStack.pop();
      this.detectedSet.add(fileId);
      const fileLocalPath = this.detectContainer.get(fileId);
      // 取出来之后需要删除元素，减少缓存开销
      this.detectContainer.remove(fileId);
      try {
        let file = fs.openSync(fileLocalPath, fs.OpenMode.READ_ONLY);
        imageSource = image.createImageSource(file.fd);

        // 图片解码设置选项
        let decodingOptions: image.DecodingOptions = {
          editable: false
        }
        pixelMap = await imageSource.createPixelMap(decodingOptions);
        imageSource.release();
        // const detectionData: antiFraudDetect.DetectionData = {
        //   pixelMap: pixelMap
        // }
        // const detectionResult: antiFraudDetect.DetectionResult = await antiFraudDetect.detectPicture(detectionData);
        // const result = JSON.stringify(detectionResult);
        // HiLog.i(TAG, `shike [detectAiFaceChange] result: ${result}`);
        // if (callBack) {
        //   callBack(result, fileId);
        // }
      } catch (error) {
        HiLog.e(TAG, 'detectAiFaceChange' + JSON.stringify(error));
        HiLog.e(TAG, `[detectAiFaceChange] error, error code: ${error?.code}, error message: ${error?.message}`);
        if (callBack) {
          callBack('', fileId);
        }
      }
    }
    this.isDetecting = false;
    pixelMap?.release();
    imageSource?.release();
  }

  public async initializeModel() {
    HiLog.i(TAG, `[initializeModel] start`);
    if (!this.isInit) {
      // const initResult: boolean = await antiFraudDetect.initialize(antiFraudDetect.ModelType.PICTURE);
      // if (!initResult) {
      //   HiLog.e(TAG, `[initializeModel] initialize fail`);
      // }
    } else {
      HiLog.e(TAG, `[initializeModel] model not finalize, need not initialize`);
    }
  }

  public async finalizeModel() {
    if (this.isInit) {
      HiLog.i(TAG, `[finalizeModel] start`);
      // await antiFraudDetect.finalize(antiFraudDetect.ModelType.PICTURE);
      this.isInit = false;
      this.isDetecting = false;
    } else {
      HiLog.w(TAG, `[finalizeModel] model not initialize, need not finalize`);
    }
  }

  public getDetectionResult(fileNote: string): boolean {
    let detectionResult: boolean = false;
    if (StringUtil.isEmpty(fileNote)) {
      return detectionResult;
    }
    //
    // const aiResult: antiFraudDetect.DetectionResult = JSON.parse(fileNote) as antiFraudDetect.DetectionResult;
    // if (aiResult) {
    //   detectionResult = aiResult.detectionResult as boolean;
    // }
    return detectionResult;
  }
}