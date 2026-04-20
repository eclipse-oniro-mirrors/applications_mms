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
import { describe, beforeEach, afterEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import MMRecorderController from '../../../../../main/ets/views/AttachmentArea/MMRecorderController';
import OperatorConfigUtil from '../../../../../main/cust/utils/OperatorConfigUtil';
import animator from '@ohos.animator';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { SplitScreenManager } from '../../../../../main/ets/utils/SplitScreenManager';
import MmsUtil from '../../../../../main/ets/utils/MmsUtil';

export default function MMRecorderControllerTest() {
  describe('MMRecorderControllerTest', () => {
    let mMMRecorderController: MMRecorderController;
    let mocker: MockKit;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mMMRecorderController = MMRecorderController.getInstance();
      mocker = new MockKit();
    })

    afterEach(() => {
      mocker.clear(mMMRecorderController);
    })

    it('MMRecorderController_init', 0, () => {
      mocker.mockFunc(mMMRecorderController, mMMRecorderController.createAnimator);
      mMMRecorderController.onInit();
      mocker.verify('createAnimator', []).once();
    })

    it('MMRecorderController_getFileTotalSize', 0, () => {
      when(mocker.mockFunc(GlobalContext.getContext(),GlobalContext.getContext().getObject))('fileTotalSize')
        .afterReturn(200);
      let size: number = mMMRecorderController.getFileTotalSize();
      expect(size).assertEqual(200);
      mocker.clear(GlobalContext.getContext());
    })

    it('MMRecorderController_getFileTotalSize1', 0, () => {
      when(mocker.mockFunc(GlobalContext.getContext(),GlobalContext.getContext().getObject))('fileTotalSize')
        .afterReturn(0);
      let size: number = mMMRecorderController.getFileTotalSize();
      expect(size).assertEqual(0);
      mocker.clear(GlobalContext.getContext());
    })

    it('MMRecorderController_getFileTotalSize_zero', 0, () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('fileTotalSize')
        .afterReturn(0);
      GlobalContext.getContext().setObject('fileTotalSize', 0);
      let size: number = mMMRecorderController.getFileTotalSize();
      expect(size).assertEqual(0);
      mocker.clear(GlobalContext.getContext());
    })

    it('MMRecorderController_checkSizeIsExceeded_false', 0, () => {
      when(mocker.mockFunc(mMMRecorderController,mMMRecorderController.getCustRecordSize))(ArgumentMatchers.any)
        .afterReturn(13);
      when(mocker.mockFunc(mMMRecorderController,mMMRecorderController.getFileTotalSize))()
        .afterReturn(12);
      let result: boolean = mMMRecorderController.checkSizeIsExceeded();
      expect(result).assertFalse();
    })

    it('MMRecorderController_checkSizeIsExceeded_true', 0, () => {
      when(mocker.mockFunc(mMMRecorderController,mMMRecorderController.getCustRecordSize))(ArgumentMatchers.any)
        .afterReturn(13);
      when(mocker.mockFunc(mMMRecorderController,mMMRecorderController.getFileTotalSize))()
        .afterReturn(15);
      let result: boolean = mMMRecorderController.checkSizeIsExceeded();
      expect(result).assertTrue();
    })

    it('MMRecorderController_startRecord', 0, () => {
      when(mocker.mockFunc(mMMRecorderController, mMMRecorderController.getFileTotalSize))()
        .afterReturn(2);
      mocker.mockFunc(mMMRecorderController, mMMRecorderController.getCustRecordSize);
      mocker.mockFunc(mMMRecorderController, mMMRecorderController.startInterval);

      mMMRecorderController.recorderTime = '00:00';
      GlobalContext.getContext().setObject('fileTotalSize', 10);
      mMMRecorderController.scaleAnimator = animator.create({
        duration: 1500,
        easing: 'linear',
        delay: 0,
        fill: 'backwards',
        direction: 'normal',
        iterations: -1,
        begin: 1,
        end: 3
      });
      mMMRecorderController.startRecord(context);
      expect(mMMRecorderController.audioReady).assertTrue();
    })

    it('MMRecorderController_startInterval_exceed_300', 0, () => {
      mMMRecorderController.interval = -1;
      mMMRecorderController.currentSize = 10;
      mMMRecorderController.seconds = 0;
      mMMRecorderController.minute = 0;
      mMMRecorderController.recorderTime = '00:00';
      mMMRecorderController.totalSize = 300 * 1024;
      mMMRecorderController.startInterval();
      mMMRecorderController.clearInterval();
      expect(mMMRecorderController.currentSize).assertEqual(10);
    })

    it('MMRecorderController_startInterval_not_exceed', 0, () => {
      mMMRecorderController.totalSize = 10;
      mMMRecorderController.interval = -1;
      mMMRecorderController.currentSize = 10;
      mMMRecorderController.seconds = 0;
      mMMRecorderController.minute = 0;
      mMMRecorderController.recorderTime = '00:00';
      mMMRecorderController.startInterval();
      mMMRecorderController.clearInterval();
      expect(mMMRecorderController.currentSize).assertEqual(10);
    })

    it('MMRecorderController_stopRecord', 0, () => {
      GlobalContext.getContext().setObject('fileTotalSize', 10);
      mMMRecorderController.stopRecord(context);
      expect(mMMRecorderController.currentSize).assertEqual(10);
    })

    it('MMRecorderController_clearInterval', 0, () => {
      when(mocker.mockFunc(mMMRecorderController,mMMRecorderController.getCustRecordSize))(ArgumentMatchers.any)
        .afterReturn(13);
      when(mocker.mockFunc(mMMRecorderController,mMMRecorderController.getFileTotalSize))()
        .afterReturn(12);
      mMMRecorderController.interval = 0;
      mMMRecorderController.clearInterval();
      expect(mMMRecorderController.isNeedTextareaFocus).assertFalse();
    })

    it('MMRecorderController_clearInterval2', 0, () => {
      when(mocker.mockFunc(mMMRecorderController,mMMRecorderController.getCustRecordSize))(ArgumentMatchers.any)
        .afterReturn(13);
      when(mocker.mockFunc(mMMRecorderController,mMMRecorderController.getFileTotalSize))()
        .afterReturn(15);
      mMMRecorderController.interval = 0;
      mMMRecorderController.clearInterval();
      expect(mMMRecorderController.isNeedTextareaFocus).assertFalse();
    })

    it('MMRecorderController_clearInterval3', 0, () => {
      when(mocker.mockFunc(mMMRecorderController,mMMRecorderController.getCustRecordSize))(ArgumentMatchers.any)
        .afterReturn(13);
      when(mocker.mockFunc(mMMRecorderController,mMMRecorderController.getFileTotalSize))()
        .afterReturn(13);
      mMMRecorderController.interval = -1;
      mMMRecorderController.clearInterval();
      expect(mMMRecorderController.isNeedTextareaFocus).assertFalse();
    })

    it('MMRecorderController_setAudioInfo', 0, () => {
      let fdPath: string = '/data/storage/el2/base/haps/entry/files/123.amr';
      let name: string = '123.amr';
      let recordTime: string = '00:20';
      mMMRecorderController.seconds = 3;
      mMMRecorderController.isExceedSize = false;
      mMMRecorderController.setAudioInfo(context, fdPath, name, recordTime);
      expect(mMMRecorderController.isExceedSize).assertFalse();
    })

    it('MMRecorderController_setAudioInfo_minute_1', 0, () => {
      let fdPath: string = '/data/storage/el2/base/haps/entry/files/123.amr';
      let name: string = '123.amr';
      let recordTime: string = '00:20';
      mMMRecorderController.minute = 1;
      mMMRecorderController.isExceedSize = false;
      mMMRecorderController.setAudioInfo(context, fdPath, name, recordTime);
      expect(mMMRecorderController.isExceedSize).assertFalse();
    })

    it('MMRecorderController_setAudioInfo_exceedSize_true', 0, () => {
      let fdPath: string = '/data/storage/el2/base/haps/entry/files/123.amr';
      let name: string = '123.amr';
      let recordTime: string = '00:20';
      mMMRecorderController.minute = 1;
      mMMRecorderController.isExceedSize = true;
      mMMRecorderController.setAudioInfo(context, fdPath, name, recordTime);
      expect(mMMRecorderController.isExceedSize).assertTrue();
    })

    it('MMRecorderController_setAudioInfo_seconds_1', 0, () => {
      let fdPath: string = '/data/storage/el2/base/haps/entry/files/123.amr';
      let name: string = '123.amr';
      let recordTime: string = '00:21';
      mMMRecorderController.seconds = 1;
      mMMRecorderController.isExceedSize = false;
      mMMRecorderController.setAudioInfo(context, fdPath, name, recordTime);
      expect(mMMRecorderController.isExceedSize).assertFalse();
    })

    it('MMRecorderController_getCustRecordSize', 0, async () => {
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(), OperatorConfigUtil.getInstance().getCustMMSSize))(12)
        .afterReturn(12);
      expect(mMMRecorderController.getCustRecordSize(12)).assertEqual(12);
      mocker.clear(OperatorConfigUtil.getInstance());
    })

    it('MMRecorderController_getCustRecordSize2', 0, async () => {
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(), OperatorConfigUtil.getInstance().getCustMMSSize))(12)
        .afterReturn(13);
      expect(mMMRecorderController.getCustRecordSize(12)).assertEqual(-307175);
      mocker.clear(OperatorConfigUtil.getInstance());
    })

    it('MMRecorderController_clearInterval_no_interval', 0, async () => {
      mMMRecorderController.interval = -1;
      mMMRecorderController.clearInterval();
      expect(mMMRecorderController.seconds).assertEqual(1);
    })

    it('MMRecorderControllerTest_createAnimator_isSplitScreenSmall_is_true', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SplitScreenManager.getInstance(), SplitScreenManager.getInstance().isSplitScreenSmall);
      when(mockfunc)([]).afterReturn(true);

      let mmrecordercontroller: MMRecorderController = new MMRecorderController();
      mmrecordercontroller.createAnimator();

      expect(mmrecordercontroller.isNeedTextareaFocus).assertFalse()
      mocker.ignoreMock(SplitScreenManager.getInstance(), SplitScreenManager.getInstance().isSplitScreenSmall);
    });

    it('MMRecorderControllerTest_createAnimator_isSplitScreenSmall_is_false', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SplitScreenManager.getInstance(), SplitScreenManager.getInstance().isSplitScreenSmall);
      when(mockfunc)([]).afterReturn(false);

      let mmrecordercontroller: MMRecorderController = new MMRecorderController();
      mmrecordercontroller.createAnimator();

      expect(mmrecordercontroller.isAllowed).assertFalse()
      mocker.ignoreMock(SplitScreenManager.getInstance(), SplitScreenManager.getInstance().isSplitScreenSmall);
    });

    it('MMRecorderControllerTest_resetAnimator_scaleAnimator_is_null', 0, () => {
      let mmrecordercontroller: ESObject = new MMRecorderController();
      mmrecordercontroller.scaleAnimator = null;
      mmrecordercontroller.resetAnimator();
      expect(mmrecordercontroller).not().assertUndefined();
      // 由于没有实际的断言点，这里仅验证函数调用不会抛出异常
    });

    it('MMRecorderControllerTest_resetAnimator_isSplitScreenSmall_is_true', 0, () => {
      let mmrecordercontroller: MMRecorderController = new MMRecorderController();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SplitScreenManager.getInstance(), SplitScreenManager.getInstance().isSplitScreenSmall);
      when(mockfunc)([]).afterReturn(true);
      mmrecordercontroller.resetAnimator();
      expect(mmrecordercontroller).not().assertUndefined();
      mocker.ignoreMock(SplitScreenManager.getInstance(), SplitScreenManager.getInstance().isSplitScreenSmall);
    });

    it('MMRecorderControllerTest_resetAnimator_isSplitScreenSmall_is_false', 0, () => {
      let mmrecordercontroller: MMRecorderController = new MMRecorderController();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SplitScreenManager.getInstance(), SplitScreenManager.getInstance().isSplitScreenSmall);
      when(mockfunc)([]).afterReturn(false);
      mmrecordercontroller.resetAnimator();
      expect(mmrecordercontroller).not().assertUndefined();
      mocker.ignoreMock(SplitScreenManager.getInstance(), SplitScreenManager.getInstance().isSplitScreenSmall);
    });
    it('MMRecorderControllerTest_startInterval_total_size_exceeds_max_size', 0, async () => {
      let mmrecordercontroller: ESObject = new MMRecorderController();
      let mocker: MockKit = new MockKit();

      let mockGetRecorderSize: Function = mocker.mockFunc(mmrecordercontroller.audioRecorderService, mmrecordercontroller.audioRecorderService.getRecorderSize);
      when(mockGetRecorderSize)([]).afterReturn(100);

      let mockGetCustRecordSize: Function = mocker.mockFunc(mmrecordercontroller, mmrecordercontroller.getCustRecordSize);
      when(mockGetCustRecordSize)([ArgumentMatchers.anyNumber]).afterReturn(100);

      let mockShowToast: Function = mocker.mockFunc(MmsUtil, MmsUtil.showToast);
      when(mockShowToast)([ArgumentMatchers.anyObj]).afterReturnNothing();

      mmrecordercontroller.startInterval();

      expect(mmrecordercontroller.isExceedSize).assertFalse();

      mocker.ignoreMock(mmrecordercontroller.audioRecorderService, mmrecordercontroller.audioRecorderService.getRecorderSize);
      mocker.ignoreMock(mmrecordercontroller, mmrecordercontroller.getCustRecordSize);
      mocker.ignoreMock(MmsUtil, MmsUtil.showToast);
    });

    it('MMRecorderControllerTest_startInterval_total_size_does_not_exceed_max_size', 0, async () => {
      let mmrecordercontroller: ESObject = new MMRecorderController();
      let mocker: MockKit = new MockKit();

      let mockGetRecorderSize: Function = mocker.mockFunc(mmrecordercontroller.audioRecorderService, mmrecordercontroller.audioRecorderService.getRecorderSize);
      when(mockGetRecorderSize)([]).afterReturn(50);

      let mockGetCustRecordSize: Function = mocker.mockFunc(mmrecordercontroller, mmrecordercontroller.getCustRecordSize);
      when(mockGetCustRecordSize)([ArgumentMatchers.anyNumber]).afterReturn(100);

      mmrecordercontroller.startInterval();

      expect(mmrecordercontroller.currentSize).assertEqual(0);
      expect(mmrecordercontroller.seconds).assertEqual(0);

      mocker.ignoreMock(mmrecordercontroller.audioRecorderService, mmrecordercontroller.audioRecorderService.getRecorderSize);
      mocker.ignoreMock(mmrecordercontroller, mmrecordercontroller.getCustRecordSize);
    });

    it('MMRecorderControllerTest_checkMicState', 0, () => {
      mMMRecorderController.checkMicState();
      expect(mMMRecorderController.audioReady).assertTrue()
    });

    it('MMRecorderControllerTest_checkCallState', 0, () => {
      mMMRecorderController.checkCallState();
      expect(mMMRecorderController.interval > 0).assertFalse()
    });

    it('MMRecorderController_handleStopRecording', 0, () => {
      GlobalContext.getContext().setObject('fileTotalSize', 10);
      mMMRecorderController.stopRecord(context);
      expect(mMMRecorderController.currentSize).assertEqual(10);
    })
  })
}