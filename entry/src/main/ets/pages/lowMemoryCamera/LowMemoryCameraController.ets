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
import { camera } from '@kit.CameraKit';
import { display, router } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import fileuri from '@ohos.file.fileuri';
import FileUtil from '../../utils/FileUtil';
import HiLog from '../../utils/HiLog';
import MMAttachmentAreaController from '../../views/AttachmentArea/MMAttachmentAreaController';
import commonData from '../../data/commonData';

const TAG = 'LowMemoryCameraController ';

export class LowMemoryCameraConstant {
  public static readonly IMAGE_QUALITY: number = 100;
  public static readonly CAMERA_HEIGHT: number = 480;
  public static readonly CAMERA_WIDTH: number = 640;
  public static readonly ROTATION_ANGLE: number = 180;
  public static readonly TOP_DISTANCE_VP: number = 78;
}

/* 低内存相机方法类 */
class LowMemoryCameraController {
  private mmAreaController: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
  public cameraDevice: camera.CameraDevice[] = [];
  private session?: camera.PhotoSession;
  private cameraManager?: camera.CameraManager;
  public xComponentController: XComponentController = new XComponentController();
  private surfaceId: string = '';
  public lensIndex: camera.CameraPosition = camera.CameraPosition.CAMERA_POSITION_BACK;

  /**
   * 保存图片到沙箱
   *
   * @param screenShot pixelMap对象
   * @param context 上下文
   */
  public async saveImageToSandbox(screenShot: image.PixelMap, context: Context): Promise<string> {
    let filePath: string = '';
    if (!screenShot || !context) {
      HiLog.w(TAG, `saveImageToSandbox input parameter is empty`);
      return filePath;
    }
    try {
      let packer = image.createImagePacker();
      let opt: image.PackingOption = { format: 'image/jpeg', quality: LowMemoryCameraConstant.IMAGE_QUALITY };
      let data = await packer.packing(screenShot, opt);
      let fileName = `IMG_${new Date().getTime()}.jpg`;
      filePath = FileUtil.getFilePath(context, commonData.STR.CAMERA_PREFIX + fileName);
      FileUtil.writeToSandBox(context, filePath, data);
      packer.release();
    } catch (e) {
      HiLog.e(TAG, `saveImageToSandbox fail, code: ${e?.code}, message: ${e?.message}`);
    }
    return filePath;
  }

  /**
   * 附件区设置图片
   *
   * @param screenShot pixelMap对象
   * @param context 上下文
   */
  public async setPicture(screenShot: image.PixelMap, context: Context) {
    if (!screenShot || !context) {
      HiLog.w(TAG, `setPicture input parameter is empty`);
      return;
    }
    let filePath: string = await this.saveImageToSandbox(screenShot, context);
    try {
      let uri = fileuri.getUriFromPath(filePath);
      if (await this.mmAreaController.isExceedSize(uri)) {
        // Over 300kb Deleted Data
        await this.mmAreaController.setTotalSize(false, uri);
        FileUtil.deleteFile(context, FileUtil.getFileName(uri));
      } else {
        this.mmAreaController.setPicture(context, uri);
        this.mmAreaController.convertMsgInfo(true);
      }
    } catch (e) {
      HiLog.e(TAG, `setPicture fail, code: ${e?.code}, message: ${e?.message}`);
    }
  }

  /**
   * 设置画布宽高
   *
   */
  private setSurfaceRect() {
    try {
      let surfaceWidth = display.getDefaultDisplaySync().width;
      let surfaceHeight = surfaceWidth * (LowMemoryCameraConstant.CAMERA_WIDTH / LowMemoryCameraConstant.CAMERA_HEIGHT);
      let surfaceRect: SurfaceRect =
        { offsetY: vp2px(LowMemoryCameraConstant.TOP_DISTANCE_VP), surfaceWidth, surfaceHeight };
      this.xComponentController.setXComponentSurfaceRect(surfaceRect);
    } catch (e) {
      HiLog.e(TAG, `setSurfaceRect fail, code: ${e?.code}, message: ${e?.message}`);
    }
  }

  /**
   * 打开相机
   *
   * @param context 上下文
   */
  public async openCamera(context: Context) {
    if (!context) {
      HiLog.w(TAG, `openCamera input parameter is empty`);
      return;
    }
    this.setSurfaceRect();
    this.surfaceId = this.xComponentController.getXComponentSurfaceId();
    let cameraDevice = this.getCameraDevice(context);
    if (cameraDevice.length !== 0) {
      this.cameraDevice = cameraDevice;
      await this.createCameraConfig();
    }
  }

  /**
   * 获取相机设备信息
   *
   * @param context 上下文
   */
  public getCameraDevice(context: Context) {
    let cameraDevice: camera.CameraDevice[] = []
    try {
      this.cameraManager = camera.getCameraManager(context);
      cameraDevice = this.cameraManager.getSupportedCameras();
    } catch (e) {
      HiLog.e(TAG, `getCameraDevice fail, code: ${e?.code}, message: ${e?.message}`);
    }
    return cameraDevice;
  }

  /**
   * 创建相机配置
   *
   */
  private async createCameraConfig() {
    let previewOutput = this.getPreviewOutput();
    let cameraInput = this.getCameraInput();
    if (previewOutput && cameraInput) {
      cameraInput.open();
      this.createSessionConfig(cameraInput, previewOutput);
    }
  }

  private getCameraInput() {
    let cameraInput: camera.CameraInput | undefined = undefined;
    try {
      cameraInput = this.cameraManager?.createCameraInput(this.cameraDevice[this.lensIndex]);
    } catch (e) {
      HiLog.e(TAG, `getCameraInput fail, code: ${e?.code}, message: ${e?.message}`);
    }
    return cameraInput;
  }

  private getPreviewOutput() {
    let previewOutput: camera.PreviewOutput | undefined = undefined;
    let index = this.lensIndex;
    if (!this.cameraManager) {
      return previewOutput;
    }
    try {
      let profiles: camera.CameraOutputCapability =
        this.cameraManager.getSupportedOutputCapability(this.cameraDevice[index], camera.SceneMode.NORMAL_VIDEO);
      let previewProfile: undefined | camera.Profile = profiles.previewProfiles.find((profile: camera.Profile) => {
        return profile.size.width === LowMemoryCameraConstant.CAMERA_WIDTH &&
          profile.size.height === LowMemoryCameraConstant.CAMERA_HEIGHT && profile.format === 1003;
      });
      previewOutput = this.cameraManager.createPreviewOutput(previewProfile, this.surfaceId);
    } catch (e) {
      HiLog.e(TAG, `getPreviewOutput fail, code: ${e?.code}, message: ${e?.message}`);
    }
    return previewOutput;
  }

  /**
   * 会话配置
   *
   * @param cameraInput 相机设备输入对象
   * @param previewOutput 预览输出类
   */
  private async createSessionConfig(cameraInput: camera.CameraInput, previewOutput: camera.PreviewOutput) {
    try {
      this.session =
        this.cameraManager?.createSession(camera.SceneMode.NORMAL_VIDEO) as camera.PhotoSession;
      this.session.beginConfig();
      this.session.addInput(cameraInput);
      this.session.addOutput(previewOutput);
      await this.session.commitConfig();
      await this.session.start();
    } catch (e) {
      HiLog.e(TAG, `createSessionConfig fail, code: ${e?.code}, message: ${e?.message}`);
    }
  }

  /**
   * 录像截图
   *
   */
  public videoScreenshot() {
    let cameraOrientation: number = 0;
    if (this.cameraDevice) {
      cameraOrientation = this.cameraDevice[this.lensIndex]?.cameraOrientation;
    }
    try {
      let region: image.Region = {
        x: 0,
        y: 0,
        size: { height: LowMemoryCameraConstant.CAMERA_HEIGHT, width: LowMemoryCameraConstant.CAMERA_WIDTH }
      };
      let screenShot = image.createPixelMapFromSurfaceSync(this.surfaceId, region);
      //前置旋转
      if (this.lensIndex === camera.CameraPosition.CAMERA_POSITION_BACK) {
        screenShot.flipSync(true, false);
        screenShot.rotateSync(cameraOrientation - LowMemoryCameraConstant.ROTATION_ANGLE);
      } else {
        screenShot.rotateSync(cameraOrientation);
      }
      AppStorage.setOrCreate('pixelMaps', screenShot);
      // 跳转到截图页面
      router.pushUrl({
        url: 'pages/lowMemoryCamera/LowMemoryPhotoPreview'
      })
    } catch (e) {
      HiLog.e(TAG, `videoScreenshot fail, code: ${e?.code}, message: ${e?.message}`);
    }
  }

  /**
   * 翻转镜头
   *
   */
  public async flipLens() {
    this.releaseSession();
    this.lensIndex =
      this.lensIndex === camera.CameraPosition.CAMERA_POSITION_BACK ?
      camera.CameraPosition.CAMERA_POSITION_FRONT : camera.CameraPosition.CAMERA_POSITION_BACK
    await this.createCameraConfig();
  }

  /**
   * 释放会话
   *
   */
  public releaseSession() {
    if (this.session) {
      try {
        this.session.release();
      } catch (e) {
        HiLog.e(TAG, `session release fail, code: ${e?.code}, message: ${e?.message}`);
      }
    }
  }
}

export default new LowMemoryCameraController();