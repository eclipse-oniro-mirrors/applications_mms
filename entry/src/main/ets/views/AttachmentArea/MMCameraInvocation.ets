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
import HiLog from '../../utils/HiLog';
import common from '@ohos.app.ability.common';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import MMAttachmentAreaController from './MMAttachmentAreaController';
import MMPictureController from './MMPictureController'
import lazy picker from '@ohos.multimedia.cameraPicker';
import camera from '@ohos.multimedia.camera';
import ConversationController from '../../pages/conversation/conversationController';
import FileUtil from '../../utils/FileUtil';
import lazy fs from '@ohos.file.fs';
import fileuri from '@ohos.file.fileuri';
import { SystemMode } from '../../utils/SystemMode';
import { abilityAccessCtrl, PermissionRequestResult } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { media } from '@kit.MediaKit';
import CreateNewConversationViewModle from '../../pages/conversation/CreateNewConversationViewModle';
import commonData from '../../data/commonData';

const TAG = 'MMCameraController ';

class MMCameraController {
  private static uri: string;
  mmAreaController: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
  pictureCtrl: MMPictureController = MMPictureController.getInstance();
  private pickerRes: null | picker.PickerResult = null;

  //调用相机拍照
  public async invokeCamera(context: Context, isrcs: boolean, callback?:()=>void) {
    try {
      AppStorage.setOrCreate('invokeCamera', true);
      AppStorage.setOrCreate('selectPicFromGalleryDone', false);
      const photoProfile: picker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK,
        videoDuration: 90,
      }
      this.pickerRes =
        await picker.pick(context, isrcs ?
          [picker.PickerMediaType.VIDEO, picker.PickerMediaType.PHOTO] : [picker.PickerMediaType.PHOTO], photoProfile);
      AppStorage.setOrCreate('invokeCamera', false);
      if (!this.pickerRes) {
        return
      }
      HiLog.iw(TAG, 'invokeCamera:' + this.pickerRes.resultCode);
      if (this.mmAreaController.hasNeedReplaceVcard() && callback && this.pickerRes.resultCode === 0) {
        callback()
      } else {
        this.handlePickerRes(context)
      }
    } catch (err) {
      HiLog.e(TAG, 'selected imageList error '+ JSON.stringify(err));
    }
  }

  async handlePickerRes(context: Context, fromReplace?: boolean) {
    if (this.pickerRes?.resultCode === 0) {
      HiLog.iw(TAG, `pickerRes?: ${this.pickerRes?.resultCode}`);
      HiLog.iw(TAG, `pickerRes?: ${this.pickerRes?.resultUri}`);
      HiLog.iw(TAG, `pickerRes?: ${this.pickerRes?.mediaType}`);
      MMCameraController.uri = this.savePictureToSandBoxWithUrl(context, this.pickerRes.resultUri);
      HiLog.iw(TAG, `MMCameraController.uri: ${MMCameraController.uri}`);
      if (MMCameraController.uri.includes('.')) {
        let typeArr = MMCameraController.uri.split('.');
        if (typeArr.length >= 1) {
          let type = typeArr[typeArr.length - 1];
          HiLog.iw(TAG, `file type: ${type}`);
        }
        AppStorage.setOrCreate('selectPicFromGalleryDone', true);
        if (ConversationController.getInstance().isRcsMms === true) {
          let isCheckPass = await MMPictureController.checkFileOfEnhancedInfo(this.pickerRes.resultUri);
          if (isCheckPass === false) {
            FileUtil.deleteFile(context, FileUtil.getFileName(MMCameraController.uri));
            HiLog.iw(TAG, 'EnhancedInfo invokeCamera checkFileOfEnhancedInfo false');
            return;
          }
          this.mmAreaController.setPictureOrVideoOfEnhancedInfo(MMCameraController.uri, context, undefined, true,
            true);
        } else {
          if (await this.mmAreaController.isExceedSize(MMCameraController.uri)) {
            // Over 300kb Deleted Data
            HiLog.iw(TAG, 'saveImagePhotoAlbums exceed');
            await this.mmAreaController.setTotalSize(false, MMCameraController.uri);
            FileUtil.deleteFile(context, FileUtil.getFileName(MMCameraController.uri));
          } else {
            this.mmAreaController.setPicture(context, MMCameraController.uri);
            this.mmAreaController.convertMsgInfo(true, fromReplace);
          }
        }
      }
    } else {
      HiLog.e(TAG, 'camerapicker error,error code is: ' + this.pickerRes?.resultCode);
    }
  }

  savePictureToSandBoxWithUrl(context: Context, url: string): string {
    try {
      const originalName = FileUtil.getFileName(url);
      const fileNameExtension = originalName.slice(originalName.lastIndexOf('.') + 1);
      const fileName = `${commonData.STR.CAMERA_PREFIX}${Date.now()}.${fileNameExtension}`;
      let filePath = FileUtil.getFilePath(context, fileName)
      fs.createRandomAccessFileSync(filePath, fs.OpenMode.CREATE);
      let filePathuri = fileuri.getUriFromPath(filePath);
      let file = fs.openSync(url, fs.OpenMode.READ_ONLY)
      HiLog.iw(TAG, `file openSync succeed`);
      let file2 = fs.openSync(filePathuri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      HiLog.iw(TAG, `file2 openSync succeed`);
      fs.copyFileSync(file.fd, file2.fd)
      HiLog.iw(TAG, `copyFileSync succeed`);
      fs.closeSync(file);
      fs.closeSync(file2);
      return filePathuri;
    } catch (err) {
      HiLog.iw(TAG, `savePictureToSandBoxWithUrl-err:${JSON.stringify(err)}`);
      return ''
    }
  }

  // 低内存相机
  jumpLowMemoryCamera(context: Context) {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(context, ['ohos.permission.CAMERA'])
      .then((data: PermissionRequestResult) => {
        if (data?.authResults[0] === 0) {
          router.pushUrl({
            url: 'pages/lowMemoryCamera/LowMemoryCamera'
          })
        } else if (data?.authResults[0] === -1) {
          atManager.requestPermissionOnSetting(context, ['ohos.permission.CAMERA'])
            .then((data: Array<abilityAccessCtrl.GrantStatus>) => {
              if (data[0] === 0) {
                router.pushUrl({
                  url: 'pages/lowMemoryCamera/LowMemoryCamera'
                })
              }
            })
            .catch((err: BusinessError) => {
              HiLog.e(TAG, 'requestPermissionOnSetting error:' + JSON.stringify(err));
            });
        }
      })
      .catch((err: BusinessError) => {
        HiLog.e(TAG, 'requestPermissionsFromUser error:' + JSON.stringify(err));
      });
  }
}

export default new MMCameraController();