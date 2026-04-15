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
import { describe, expect, it, MockKit, when, } from '@ohos/hypium';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import ImageUtil from '../../../../main/ets/utils/ImageUtil';
import { DTGlobalContext } from '../../testability/TestAbility';
import HiLog from '../../../../main/ets/utils/HiLog';
import { window } from '@kit.ArkUI';
import { StartOptions } from '@kit.AbilityKit';
import { Mms } from '../../../../main/ets/utils/TypesUtils';
import { GlobalContextKey } from '../../../../main/ets/data/commonData';
import { IPhotoProp } from '../../../../main/ets/pages/photoBrowser/photoBrowser';
import { image } from '@kit.ImageKit';
import { AsyncCallback } from '@ohos.base';

export default function ImageUtilTest() {
  describe('ImageUtilTest', () => {

    const TAG = 'ImageUtil ';

    it('ImageUtil_getFetchFrameByTime_null', 0, () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext");
      GlobalContext.getContext().setObject("mmsContext", context);
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);
      ImageUtil.getFetchFrameByTime('', () => {
        mocker.verify('i',[TAG, 'getFetchFrameByTime']).once();
      });
      mocker.clear(HiLog);
    })

    it('ImageUtil_goToOpenMediaLibrary_path_empty', 0, async () => {
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      await ImageUtil.goToOpenMediaLibrary('', 1);
      mocker.verify('i', [TAG, 'goToOpenMediaLibrary']).once();
      mocker.clear(HiLog);
    })

    it('ImageUtil_goToOpenMediaLibrary_type_0', 0, async () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext");
      GlobalContext.getContext().setObject("mmsContext", context);
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);
      when(mocker.mockFunc(GlobalContext.getContext(),GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility:(want: Want, options?: StartOptions | undefined): Promise<void> => new Promise<void>(
            resolve => resolve()
          )
        } as  Object | window.WindowStage);
      let path = 'file:///data/image/abc';
      await ImageUtil.goToOpenMediaLibrary(path, 0);
      mocker.verify('i',[TAG, 'goToOpenMediaLibrary']).once();
      mocker.clear(HiLog);
      mocker.clear(GlobalContext.getContext());
    })

    it('ImageUtil_goToOpenMediaLibrary_image', 0, async () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext");
      GlobalContext.getContext().setObject("mmsContext", context);
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);
      when(mocker.mockFunc(GlobalContext.getContext(),GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility:(want: Want, options?: StartOptions | undefined): Promise<void> => new Promise<void>(
            resolve => resolve()
          )
        } as  Object | window.WindowStage);
      let path = 'file:///data/image/123.jpg';
      await ImageUtil.goToOpenMediaLibrary(path, 1);
      mocker.verify('i',[TAG, 'goToOpenMediaLibrary']).once();
      mocker.clear(HiLog);
      mocker.clear(GlobalContext.getContext());
    })

    it('ImageUtil_goToOpenMediaLibrary_video', 0, async () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext");
      GlobalContext.getContext().setObject("mmsContext", context);
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);
      when(mocker.mockFunc(GlobalContext.getContext(),GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility:(want: Want, options?: StartOptions | undefined): Promise<void> => new Promise<void>(
            resolve => resolve()
          )
        } as  Object | window.WindowStage);
      let path = 'file:///data/image/234.mp4';
      await ImageUtil.goToOpenMediaLibrary(path, 2);
      mocker.verify('i',[TAG, 'goToOpenMediaLibrary']).once();
      mocker.clear(HiLog);
      mocker.clear(GlobalContext.getContext());
    })
    
    it('ImageUtil_convertImageToPixmap_null', 0, () => {
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);
      when(mocker.mockFunc(ImageUtil, ImageUtil.convertImageToPixmap))('1').afterReturnNothing
      let result = ImageUtil.convertImageToPixmap('1');
      expect(result).assertUndefined()
      mocker.clear(HiLog);
      mocker.clear(ImageUtil);
    })

    it('ImageUtil_convertBase64ToPixmap_null', 0, async () => {
      let isError = 0;
      let result: null | image.PixelMap = null;
      try {
        result = await ImageUtil.convertBase64ToPixmap('', { height: 128, width: 128 });
      } catch (e) {
        isError = 1;
      }
      expect(result).assertNull();
      expect(isError).assertEqual(0);
    })

    it("ImageUtil_openPhotoPreview_preview", 0, async () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext");
      GlobalContext.getContext().setObject("mmsContext", context);
      let param = {
        uri : '/path/image.jpg',
        ct : 'name'
      } as IPhotoProp;
      await ImageUtil.openPhotoPreview(param);
      expect(AppStorage.get(GlobalContextKey.IS_JUMP_TO_PREVIEW)).assertUndefined();
    })

    it("ImageUtil_openPhotoPreview_preview_ct_empty", 0, async () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext");
      GlobalContext.getContext().setObject("mmsContext", context);
      let param = {
        uri : '/path/ ',
        ct : ''
      } as IPhotoProp;
      await ImageUtil.openPhotoPreview(param);
      expect(AppStorage.get(GlobalContextKey.IS_JUMP_TO_PREVIEW)).assertUndefined();
    })

    it("ImageUtil_openVideoPreview_error", 0, async () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext");
      GlobalContext.getContext().setObject("mmsContext", context);
      let param = {
        duration: 'duration',
        type: 1,
        path: 'v/',
        name: 'video'
      } as Mms;
      await ImageUtil.openVideoPreview(param);
      expect(AppStorage.get(GlobalContextKey.IS_JUMP_TO_PREVIEW)).assertUndefined();
    })

    it("ImageUtil_openVideoPreview_preview", 0, async () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext");
      GlobalContext.getContext().setObject("mmsContext", context);
      let param = {
        duration: 'duration',
        type: 1,
        path: 'path/video/',
        name: 'video'
      } as Mms;
      await ImageUtil.openVideoPreview(param);
      expect(AppStorage.get(GlobalContextKey.IS_JUMP_TO_PREVIEW)).assertUndefined();
    })

    it("ImageUtil_encodePixelMapToFile_null", 0, async () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext");
      GlobalContext.getContext().setObject("mmsContext", context);
      await ImageUtil.encodePixelMapToFile('/path/to/image.jpg', null);
      expect(AppStorage.get(GlobalContextKey.IS_JUMP_TO_PREVIEW)).assertUndefined();
    })

    it("ImageUtil_encodePixelMapToFile", 0, async () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext");
      GlobalContext.getContext().setObject("mmsContext", context);
      let pixelMap: image.PixelMap = {
        release: (callback: AsyncCallback<void, void>): void => {
        }
      } as image.PixelMap
      await ImageUtil.encodePixelMapToFile('/path/to/image.jpg', pixelMap);
      expect(AppStorage.get(GlobalContextKey.IS_JUMP_TO_PREVIEW)).assertUndefined();
    })

    it("ImageUtilTest_addCt", 0, async () => {
      let res = (ImageUtil as object)['addCt']('123.ABC') as string;
      expect(res).assertEqual('abc');
    })

    it("ImageUtilTest_addCt_suffixName_null", 0, async () => {
      let res = (ImageUtil as object)['addCt']('123.') as string;
      expect(res).assertEqual('image/gif');
    })
  })
}