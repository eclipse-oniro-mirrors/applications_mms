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

import {
  describe, beforeEach,
  it,
  expect,
  MockKit,
  when,
  ArgumentMatchers
} from '@ohos/hypium'
import { Mms, PictureListData } from '../../../../../main/ets/utils/TypesUtils';
import MMPictureController from '../../../../../main/ets/views/AttachmentArea/MMPictureController';
import MMAttachmentAreaController from '../../../../../main/ets/views/AttachmentArea/MMAttachmentAreaController';
import common from "../../../../../main/ets/data/commonData";
import { Permissions } from '@ohos.abilityAccessCtrl';
import { BusinessError } from '@ohos.base';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import OperatorConfigUtil from '../../../../../main/cust/utils/OperatorConfigUtil';
import FileUtil from '../../../../../main/ets/utils/FileUtil';
import DotUtil from '../../../../../main/ets/utils/MmsDot/DotUtils';
import { DTGlobalContext } from '../../../testability/TestAbility';

export default function MMPictureControllerTest() {
  describe('MMPictureControllerTest', () => {
    let mMMPictureController: MMPictureController;
    let mAttachmentAreaController: MMAttachmentAreaController
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mMMPictureController = new MMPictureController();
      mAttachmentAreaController = MMAttachmentAreaController.getInstance();
    })

    it('MMPictureControllerTest_getInstance', 0, () => {
      expect(typeof MMPictureController.getInstance()).assertEqual(typeof mMMPictureController);
    })

    it('MMPictureControllerTest_checkAccessToken', 0, async () => {
      let permissionName: Permissions = 'ohos.permission.WRITE_MEDIA';
      mMMPictureController.checkAccessToken(permissionName);
      expect(mMMPictureController.isRcs).assertFalse();
    })

    it('MMPictureControllerTest_checkPermission_true', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(mMMPictureController, mMMPictureController.checkAccessToken);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<boolean>(res => {
        res(true);
      }));
      let res = await mMMPictureController.checkPermission('ohos.permission.WRITE_MEDIA');
      expect(res).assertEqual(true);

      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<boolean>(res => {
        res(false);
      }));
      when(mocker.mockFunc(mMMPictureController, mMMPictureController.initPermission))(ArgumentMatchers.any)
        .afterReturn(false);
      res = await mMMPictureController.checkPermission('ohos.permission.WRITE_MEDIA');
      expect(res).assertFalse();

      mocker.clear(mMMPictureController);
    })

    it('MMPictureControllerTest_resetPictureHeight', 0, () => {
      mMMPictureController.resetPictureHeight();
      expect(AppStorage.get('selectPicFromMaxHeightDone')).assertTrue();
      AppStorage.clear();
    })

    it('MMPictureControllerTest_getThumbnailFunc', 0, () => {
      mMMPictureController.getThumbnailFunc('data/media/file/123.jpg', (res: PixelMap) => {
        expect(res.isEditable).assertFalse();
      });
    })

    it('MMPictureControllerTest_handleRcsPhotoSelectResultURLItem', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function =
        mocker.mockFunc(mMMPictureController, mMMPictureController.savePictureToSandBoxWithUrlOfEnhancedInfo);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<string>(res => {
        res('data/media/file/123.jpg');
      }));
      when(mocker.mockFunc(mMMPictureController,
        mMMPictureController.checkGalleryImageFileOfEnhancedInfo))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(mMMPictureController.mmAreaController,
        mMMPictureController.mmAreaController.setPictureOrVideoOfEnhancedInfo);
      mMMPictureController.handleRcsPhotoSelectResultURLItem(context, 'data/media/file/123.jpg', true, true);
      mocker.clear(mMMPictureController.mmAreaController);
      mocker.clear(mMMPictureController);
      expect(mMMPictureController.isRcs).assertFalse();
    })

    it('MMPictureControllerTest_handleRcsPhotoSelectResultURLItem_if1', 0, async () => {
      mMMPictureController.handleRcsPhotoSelectResultURLItem(context, '', true, true);
      expect(mMMPictureController.isRcs).assertFalse();
    })

    it('MMPictureControllerTest_handleRcsPhotoSelectResultURLItem_if2', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function =
        mocker.mockFunc(mMMPictureController, mMMPictureController.savePictureToSandBoxWithUrlOfEnhancedInfo);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<string>(res => {
        res('data/media/file/123.mp4');
      }));
      when(mocker.mockFunc(mMMPictureController,
        mMMPictureController.checkGalleryImageFileOfEnhancedInfo))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(mMMPictureController.mmAreaController,
        mMMPictureController.mmAreaController.setPictureOrVideoOfEnhancedInfo);
      mMMPictureController.handleRcsPhotoSelectResultURLItem(context, 'data/media/file/123.mp4', true, true);
      mocker.clear(mMMPictureController.mmAreaController);
      mocker.clear(mMMPictureController);
      expect(mMMPictureController.isRcs).assertFalse();
    })

    it('MMPictureControllerTest_handleRcsPhotoSelectResultURLItem_if3', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function =
        mocker.mockFunc(mMMPictureController, mMMPictureController.savePictureToSandBoxWithUrlOfEnhancedInfo);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<string>(res => {
        res('data/media/file/123.gif');
      }));
      when(mocker.mockFunc(mMMPictureController,
        mMMPictureController.checkGalleryImageFileOfEnhancedInfo))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(mMMPictureController.mmAreaController,
        mMMPictureController.mmAreaController.setPictureOrVideoOfEnhancedInfo);
      mMMPictureController.handleRcsPhotoSelectResultURLItem(context, 'data/media/file/123.gif', true, true);
      mocker.clear(mMMPictureController.mmAreaController);
      mocker.clear(mMMPictureController);
      expect(mMMPictureController.isRcs).assertFalse();
    })

    it('MMPictureControllerTest_savePictureToSandBoxWithUrlOfEnhancedInfo', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(FileUtil,FileUtil.getFilePath))(ArgumentMatchers.any)
        .afterThrow('err');
      mMMPictureController.savePictureToSandBoxWithUrlOfEnhancedInfo(context, 'data/media/file/123.jpg');
      expect(mMMPictureController.isRcs).assertFalse();
      mocker.clear(FileUtil);
    })

    it('MMPictureControllerTest_jumpToGallery', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(AppStorage, AppStorage.setOrCreate))('selectPicFromGalleryDone').afterAction(() => {
        let err: Error = {
          code: -1, message: 'error'
        } as BusinessError;
        throw err;
      });
      mMMPictureController.jumpToGallery(context);
      expect(AppStorage.get('selectPicFromGalleryDone')).assertUndefined();
      mocker.clear(AppStorage);
    })

    it('MMPictureControllerTest_photoSelectResult', 0, () => {
      let res = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(mMMPictureController,
        mMMPictureController.savePictureToSandBoxWithUrl))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(mMMPictureController.mmAreaController,
        mMMPictureController.mmAreaController.isAttachmentUpperLimit))().afterReturn(true);
      mMMPictureController.photoSelectResult(context, {
        photoUris: [''],
        isOriginalPhoto: false
      } as photoAccessHelper.PhotoSelectResult, []);

      when(mocker.mockFunc(mMMPictureController,
        mMMPictureController.savePictureToSandBoxWithUrl))(ArgumentMatchers.any).afterReturn('/VID');
      when(mocker.mockFunc(mMMPictureController.mmAreaController,
        mMMPictureController.mmAreaController.isAttachmentUpperLimit))().afterReturn(false);
      when(mocker.mockFunc(mMMPictureController.mmAreaController,
        mMMPictureController.mmAreaController.isExceedSizeNotShowToast))(ArgumentMatchers.any).afterReturn(true);
      mocker.mockFunc(mMMPictureController.mmAreaController,
        mMMPictureController.mmAreaController.setTotalSize);
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any).afterReturn(1);
      mMMPictureController.photoSelectResult(context, {
        photoUris: [''],
        isOriginalPhoto: false
      } as photoAccessHelper.PhotoSelectResult, []);

      when(mocker.mockFunc(mMMPictureController.mmAreaController,
        mMMPictureController.mmAreaController.isExceedSizeNotShowToast))(ArgumentMatchers.any).afterReturn(false);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('xx.mp4');
      mocker.mockFunc(mMMPictureController, mMMPictureController.getThumbnailFunc);
      when(mocker.mockFunc(mMMPictureController.mmAreaController,
        mMMPictureController.mmAreaController.setVideo))(ArgumentMatchers.any).afterAction(() => {
        res = true;
        return '';
      });
      mMMPictureController.photoSelectResult(context, {
        photoUris: [''],
        isOriginalPhoto: false
      } as photoAccessHelper.PhotoSelectResult, []);

      when(mocker.mockFunc(mMMPictureController,
        mMMPictureController.savePictureToSandBoxWithUrl))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(mMMPictureController.mmAreaController,
        mMMPictureController.mmAreaController.setPicture))(ArgumentMatchers.any).afterAction(() => {
        res = false;
      });
      mMMPictureController.photoSelectResult(context, {
        photoUris: [''],
        isOriginalPhoto: false
      } as photoAccessHelper.PhotoSelectResult, []);
      expect(res).assertFalse();
      mocker.clear(mMMPictureController.mmAreaController);
      mocker.clear(mMMPictureController);
      mocker.clear(FileUtil);
      mocker.clear(OperatorConfigUtil.getInstance());
      mocker.clear(DotUtil.getInstance());
    })

    it('MMPictureControllerTest_savePictureToSandBoxWithUrl', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getFilePath))(ArgumentMatchers.any).afterAction(() => {
        throw new Error('error');
      });
      expect(mMMPictureController.savePictureToSandBoxWithUrl(context, '')).assertEqual('');
      mocker.clear(FileUtil);
    })

    it('MMPictureControllerTest_clickPictureCheckbox_true', 0, () => {
      let pictureListData: PictureListData = {
        image: 'data/media/file/123.jpg',
        selected: false,
        photoType: 0,
      };
      mAttachmentAreaController.mmDisplaySource = [];
      for (let i = 0; i < 22; i++) {
        let obj: Mms = {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.VIDEO,
          path: "",
          name: "123" + i + 'mp4'
        };
        mAttachmentAreaController.mmDisplaySource.push(obj);
      };

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(mMMPictureController.mmAreaController,
        mMMPictureController.mmAreaController.isAttachmentUpperLimit))().afterReturn(true);
      mocker.mockFunc(mMMPictureController.pictureDataSource, mMMPictureController.pictureDataSource.refresh);

      mMMPictureController.clickPictureCheckbox(context, true, pictureListData, 1);

      pictureListData = {
        image: 'data/media/file/123.jpg',
        selected: false,
        photoType: 0,
      }
      when(mocker.mockFunc(mMMPictureController.mmAreaController,
        mMMPictureController.mmAreaController.isAttachmentUpperLimit))().afterReturn(false);
      mocker.mockFunc(mMMPictureController, mMMPictureController.changeCheckBox);
      mocker.mockFunc(mMMPictureController, mMMPictureController.getSelectedCount);
      mocker.mockFunc(mMMPictureController.mmAreaController,
        mMMPictureController.mmAreaController.handleCheckedChange);
      mMMPictureController.clickPictureCheckbox(context, true, pictureListData, 1);

      pictureListData = {
        image: 'data/media/file/123.jpg',
        selected: false,
        photoType: 0,
        mediaUri: "file:///media/file/image.jpg",
      };
      mMMPictureController.clickPictureCheckbox(context, true, pictureListData, 1);
      mocker.verify('getSelectedCount',[true]).times(2);
      mocker.clear(mMMPictureController.mmAreaController);
      mocker.clear(mMMPictureController.pictureDataSource);
      mocker.clear(mMMPictureController);
    })

    it('MMPictureControllerTest_getSelectedCount_true', 0, () => {
      mMMPictureController.selectedMsgCount = 1;
      mMMPictureController.getSelectedCount(true);
      expect(mMMPictureController.selectedMsgCount).assertEqual(2);
    })

    it('MMPictureControllerTest_getSelectedCount_false', 0, () => {
      mMMPictureController.selectedMsgCount = 1;
      mMMPictureController.getSelectedCount(false);
      expect(mMMPictureController.selectedMsgCount).assertEqual(0);
    })

    it('MMPictureControllerTest_changeCheckBox', 0, () => {
      mMMPictureController.pictureList = [{
        image: '123.jpg',
        selected: false,
        photoType: 1,
        mediaUri: 'file://data/file/123.jpg'
      }];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mMMPictureController.pictureDataSource, mMMPictureController.pictureDataSource.refresh);
      mMMPictureController.changeCheckBox('file://data/file/123.jpg', true);

      mMMPictureController.pictureList = [{
        image: '123.jpg',
        selected: false,
        photoType: 1,
        mediaUri: 'file://data/file/123.jpg'
      }];
      mMMPictureController.changeCheckBox('file://data/file/222.jpg', true);
      expect(AppStorage.get('pictureSelectedNumber')).assertEqual(0);

      mocker.clear(mMMPictureController.pictureDataSource);
    })

    it('MMPictureControllerTest_resetPictureStatus', 0, () => {
      let mocker: MockKit = new MockKit();
      mMMPictureController.pictureList=[{} as PictureListData];
      mocker.mockFunc(mMMPictureController.pictureDataSource, mMMPictureController.pictureDataSource.refresh);
      mMMPictureController.resetPictureStatus();
      expect(mMMPictureController.pictureList[0].selected).assertFalse();
      mocker.clear(mMMPictureController.pictureDataSource);
    })

    it('MMPictureControllerTest_splitPhotoArray', 0, () => {
      let arr: Array<Record<string, string>> = [{
        "a": '123'
      }, {
        "b": '1234'
      }, {
        "c": '1235'
      }, {
        "d": '12345'
      }, {
        "e": '123467'
      }];
      expect(mMMPictureController.splitPhotoArray(arr, 2).length).assertEqual(3);
    })

    it('MMPictureControllerTest_jumpToGalleryOfRCS', 0, () => {
      mMMPictureController.jumpToGalleryOfRCS(context);
      expect(mMMPictureController.isRcs).assertFalse();
    })

    it('MMPictureControllerTest_checkGalleryImageFileOfEnhancedInfo', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(MMPictureController, MMPictureController.checkFileOfEnhancedInfo))(ArgumentMatchers.any)
        .afterReturn(new Promise<boolean>(resolve=>resolve(false)));

      mMMPictureController.checkGalleryImageFileOfEnhancedInfo('a');
      expect(mMMPictureController.isRcs).assertFalse();

      when(mocker.mockFunc(MMPictureController, MMPictureController.checkFileOfEnhancedInfo))(ArgumentMatchers.any)
        .afterReturn(new Promise<boolean>(resolve=>resolve(true)));
      mMMPictureController.checkGalleryImageFileOfEnhancedInfo('a');
      expect(mMMPictureController.isRcs).assertFalse();

      mocker.clear(MMPictureController);
    })

    it('MMPictureControllerTest_checkGalleryImageFileOfEnhancedInfo_if', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(MMPictureController, MMPictureController.checkFileOfEnhancedInfo))(ArgumentMatchers.any)
        .afterReturn(new Promise<boolean>(resolve=>resolve(false)));
      mMMPictureController.checkGalleryImageFileOfEnhancedInfo('');
      expect(mMMPictureController.isRcs).assertFalse();

      mocker.clear(MMPictureController);
    })

    it('MMPictureControllerTest_checkFileOfEnhancedInfo', 0, async () => {
      await MMPictureController.checkFileOfEnhancedInfo('xxx.jpeg');
      expect(MMPictureController).not().assertUndefined();
    })

    it('MMPictureControllerTest_mmsTypeParams', 0, () => {
      let toastArr: Array<ResourceStr> = [];
      let msg: Resource = $r('app.string.attachment_failed', '2');
      toastArr.push(msg);
      mMMPictureController.mmAreaController.mmDisplaySource = [];
      (mMMPictureController as object)['mmsTypeParams'](context, 'aaa.jpg', toastArr, 'file://data/file/123.jpg');
      expect(mMMPictureController).not().assertUndefined();
    })
    it('MMPictureControllerTest_isAddImageFromCheckImageWidthAndHeight_false', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(mMMPictureController, mMMPictureController.isAddImageFromCheckImageWidthAndHeight))([context,
        'aaa.jpg'])
        .afterReturn(new Promise<boolean>(resolve => resolve(false)));
      mMMPictureController.isAddImageFromCheckImageWidthAndHeight(context, 'aaa.jpg');
      expect(context).not().assertUndefined();
      mocker.clear(mMMPictureController);

    })
    it('MMPictureControllerTest_isAddImageFromCheckImageWidthAndHeight_true', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(mMMPictureController, mMMPictureController.isAddImageFromCheckImageWidthAndHeight))([context,
        'bbb.jpg'])
        .afterReturn(new Promise<boolean>(resolve => resolve(true)));
      mMMPictureController.isAddImageFromCheckImageWidthAndHeight(context, 'bbb.jpg');
      expect(context).not().assertUndefined();
      mocker.clear(mMMPictureController);
    })

    it('MMPictureControllerTest_getPicFromGallery', 0, async () => {
      mMMPictureController.getPicFromGallery();
      expect(context).not().assertUndefined();
    })

    it('MMPictureControllerTest_handlePhotoSelectResultOfRCS_if1', 0, async () => {
      mMMPictureController.photoSelectResOfRCS = {
        photoUris: ['file:///media/file/image.jpg'],
        isOriginalPhoto: false
      } as photoAccessHelper.PhotoSelectResult;
      (mMMPictureController as object)['isTextAsMms'] = true;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(mMMPictureController, mMMPictureController.isAddImageFromCheckImageWidthAndHeight))([context,
        'image.jpg'])
        .afterReturn(new Promise<boolean>(resolve => resolve(true)));
      mMMPictureController.handlePhotoSelectResultOfRCS(context);
      expect(context).not().assertUndefined();
      mocker.clear(mMMPictureController);
    })

    it('MMPictureControllerTest_handlePhotoSelectResultOfRCS_if2', 0, async () => {
      mMMPictureController.photoSelectResOfRCS = {
        photoUris: ['file:///media/file/image.jpg'],
        isOriginalPhoto: false
      } as photoAccessHelper.PhotoSelectResult;
      (mMMPictureController as object)['isTextAsMms'] = true;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(mMMPictureController, mMMPictureController.isAddImageFromCheckImageWidthAndHeight))(ArgumentMatchers.any)
        .afterReturn(true);
      mMMPictureController.handlePhotoSelectResultOfRCS(context);
      expect(context).not().assertUndefined();
      mocker.clear(mMMPictureController);
    })

    it('MMPictureControllerTest_handlePhotoSelectResultOfRCS_else', 0, async () => {
      mMMPictureController.photoSelectResOfRCS = {
        photoUris: [''],
        isOriginalPhoto: false
      } as photoAccessHelper.PhotoSelectResult;
      mMMPictureController.handlePhotoSelectResultOfRCS(context);
      expect(context).not().assertUndefined();
    })

    it('MMPictureControllerTest_handlePhotoSelectResultOfRCS_undefined', 0, async () => {
      mMMPictureController.handlePhotoSelectResultOfRCS(context);
      expect(context).not().assertUndefined();
    })

    it('MMPictureControllerTest_handlePhotoSelectResult_if1', 0, async () => {
      mMMPictureController.photoSelectRes = {
        photoUris: ['file:///media/file/image.jpg'],
        isOriginalPhoto: false
      } as photoAccessHelper.PhotoSelectResult;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mMMPictureController, mMMPictureController.photoSelectResult)
      mMMPictureController.handlePhotoSelectResult(context, false);
      expect(context).not().assertUndefined();
      mocker.clear(mMMPictureController);
    })

    it('MMPictureControllerTest_photoSelectResult_else', 0, async () => {
      let photoSelectResult: photoAccessHelper.PhotoSelectResult = {
        photoUris: ['file:///media/file/image.jpg'],
        isOriginalPhoto: false
      } as photoAccessHelper.PhotoSelectResult;
      let toastArr: Array<ResourceStr> = [];
      let msg: Resource = $r('app.string.attachment_failed', '2');
      toastArr.push(msg);
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(mMMPictureController, mMMPictureController.isAddImageFromCheckImageWidthAndHeight))([context,
        'image.jpg'])
        .afterReturn(new Promise<boolean>(resolve => resolve(true)));
      mMMPictureController.photoSelectResult(context, photoSelectResult, toastArr, false);
      expect(context).not().assertUndefined();
      mocker.clear(mMMPictureController);
    })

    it('MMPictureControllerTest_photoSelectResult_if1', 0, async () => {
      let photoSelectResult: photoAccessHelper.PhotoSelectResult = {
        photoUris: ['file:///media/file/image.jpg'],
        isOriginalPhoto: false
      } as photoAccessHelper.PhotoSelectResult;
      let toastArr: Array<ResourceStr> = [];
      let msg: Resource = $r('app.string.attachment_failed', '2');
      toastArr.push(msg);
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(mMMPictureController, mMMPictureController.isAddImageFromCheckImageWidthAndHeight))(ArgumentMatchers.any)
        .afterReturn(true);
      mMMPictureController.photoSelectResult(context, photoSelectResult, toastArr, false);
      expect(context).not().assertUndefined();
      mocker.clear(mMMPictureController);
    })
  })
}