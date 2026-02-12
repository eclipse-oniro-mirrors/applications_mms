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
  describe,
  beforeEach,
  afterEach,
  it,
  expect,
  MockKit,
  when,
  ArgumentMatchers
} from '@ohos/hypium'
import { AddressInfo, ContactType, Mms, packingItem } from '../../../../../main/ets/utils/TypesUtils';
import MMAttachmentAreaController from '../../../../../main/ets/views/AttachmentArea/MMAttachmentAreaController';
import common from "../../../../../main/ets/data/commonData";
import FileUtil, { SavedFileInfo } from '../../../../../main/ets/utils/FileUtil';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import { rcsFileInfo } from '../../../../../main/ets/pages/conversation/conversationController';
import ConversationController from '../../../../../main/ets/pages/conversation/conversationController';
import ObjectUtil from '../../../../../main/ets/utils/ObjectUtil';
import DotUtil from '../../../../../main/ets/utils/MmsDot/DotUtils';
import OperatorConfigUtil from '../../../../../main/cust/utils/OperatorConfigUtil';
import { image } from '@kit.ImageKit';
import MmsUtil from '../../../../../main/ets/utils/MmsUtil';
import { VCardUtil } from '../../../../../main/ets/utils/VCardUtil';
import MMPictureController from '../../../../../main/ets/views/AttachmentArea/MMPictureController';
import StringUtil from '../../../../../main/ets/utils/StringUtil';
import { AudioPlayerService } from '../../../../../main/ets/service/AudioPlayerService';
import { DTGlobalContext } from '../../../testability/TestAbility';

export default function MMAttachmentAreaControllerTest() {
  describe('MMAttachmentAreaControllerTest', () => {
    let mAttachmentAreaController: MMAttachmentAreaController;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mAttachmentAreaController = MMAttachmentAreaController.getInstance()
    })

    afterEach(() => {
      AppStorage.clear();
    })

    it('MMAttachmentAreaController_refreshDisplay', 0, () => {
      AppStorage.setOrCreate('isAreaDisplayChange', false);
      mAttachmentAreaController.refreshDisplay();
      expect(AppStorage.get('isAreaDisplayChange')).assertTrue();
    })

    it('MMAttachmentAreaController_refreshConversation', 0, () => {
      mAttachmentAreaController.mmDisplaySource = [];
      mAttachmentAreaController.refreshConversation();
      expect(AppStorage.get('isConversationNeedChange')).assertTrue();
    })

    it('MMAttachmentAreaController_initSource', 0, async () => {
      mAttachmentAreaController.mmDisplaySource = [{} as Mms];
      await mAttachmentAreaController.initSource(context, false, 1);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
    })

    it('MMAttachmentAreaController_initSource_type_2', 0, async () => {
      mAttachmentAreaController.mmDisplaySource = [{
        type: 2
      } as Mms];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
        .afterReturn({
          type: 2,
          galleryPath: '',
          path: ''
        } as Mms);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any).afterReturn(1024);
      when(mocker.mockFunc(JSON, JSON.stringify))(ArgumentMatchers.any).afterReturn('1024');

      mAttachmentAreaController.mmDisplaySource = [{} as Mms];
      await mAttachmentAreaController.initSource(context, false, 0);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
      mocker.clear(FileUtil);
      mocker.clear(ObjectUtil);
      mocker.clear(JSON);
    })

    it('MMAttachmentAreaController_initSource_type_2_galleryPath_undefined', 0, async () => {
      mAttachmentAreaController.mmDisplaySource = [{
        type: 2
      } as Mms];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
        .afterReturn({
          type: 2,
          galleryPath: undefined,
          path: ''
        } as Mms);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any).afterReturn(1024);
      when(mocker.mockFunc(JSON, JSON.stringify))(ArgumentMatchers.any).afterReturn('1024');

      mAttachmentAreaController.mmDisplaySource = [{} as Mms];
      await mAttachmentAreaController.initSource(context, false, 0);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
      mocker.clear(FileUtil);
      mocker.clear(ObjectUtil);
      mocker.clear(JSON);
    })

    it('MMAttachmentAreaController_initSource_type_1', 0, async () => {
      mAttachmentAreaController.mmDisplaySource = [{
        type: 1
      } as Mms, {
        type: 1
      } as Mms];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
        .afterReturn({
          type: 1,
          galleryPath: '',
          path: ''
        } as Mms);
      when(mocker.mockFunc(FileUtil, FileUtil.packingSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<packingItem>(resolve => resolve({
          data: new ArrayBuffer(0),
          size: 0
        } as packingItem)));
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any).afterReturn(1024);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(JSON, JSON.stringify))(ArgumentMatchers.any).afterReturn('1024');

      mAttachmentAreaController.mmDisplaySource = [{} as Mms];
      await mAttachmentAreaController.initSource(context, false, 0);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);

      mocker.clear(ObjectUtil);
      mocker.clear(FileUtil);
      mocker.clear(JSON);
    })

    it('MMAttachmentAreaController_initSource_type_1_galleryPath_undefined', 0, async () => {
      mAttachmentAreaController.mmDisplaySource = [{
        type: 1
      } as Mms, {
        type: 1
      } as Mms];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
        .afterReturn({
          type: 1,
          galleryPath: undefined,
          path: ''
        } as Mms);
      when(mocker.mockFunc(FileUtil, FileUtil.packingSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<packingItem>(resolve => resolve({
          data: new ArrayBuffer(0),
          size: 0
        } as packingItem)));
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any).afterReturn(1024);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(JSON, JSON.stringify))(ArgumentMatchers.any).afterReturn('1024');

      mAttachmentAreaController.mmDisplaySource = [{} as Mms];
      await mAttachmentAreaController.initSource(context, false, 0);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);

      mocker.clear(ObjectUtil);
      mocker.clear(FileUtil);
      mocker.clear(JSON);
    })

    it('MMAttachmentAreaController_initSourceOfEnhancedInfo', 0, async () => {
      mAttachmentAreaController.mmDisplaySource = [{} as Mms];
      await mAttachmentAreaController.initSourceOfEnhancedInfo(context, false, 1, []);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
    })

    it('MMAttachmentAreaController_initSourceOfEnhancedInfo_type_1_isOriginalImage', 0, async () => {
      mAttachmentAreaController.mmDisplaySource = [{} as Mms];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
        .afterReturn({
          type: 1,
          galleryPath: '',
          path: '',
          name: 'name.png',
          isOriginalImage: true,
          copyPath: ''
        } as Mms);
      mocker.mockFunc(FileUtil, FileUtil.deleteFile);
      when(mocker.mockFunc(FileUtil, FileUtil.getSandboxPath))(ArgumentMatchers.any).afterReturn('');
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.copySrcFileToTargetSync);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any).afterReturn(1024);
      await mAttachmentAreaController.initSourceOfEnhancedInfo(context, false, 0, []);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
      mocker.clear(FileUtil);
      mocker.clear(ObjectUtil);
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_initSourceOfEnhancedInfo_type_1_isOriginalImage_false', 0, async () => {
      mAttachmentAreaController.mmDisplaySource = [{
        type: 1
      } as Mms, {
        type: 1
      } as Mms];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
        .afterReturn({
          type: 1,
          galleryPath: '',
          path: '',
          name: 'name.png',
          isOriginalImage: false,
          copyPath: ''
        } as Mms);
      when(mocker.mockFunc(FileUtil, FileUtil.packingSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<packingItem>(resolve => resolve({
          data: new ArrayBuffer(0),
          size: 0
        } as packingItem)));
      mocker.mockFunc(FileUtil, FileUtil.deleteFile);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any).afterReturn(1024);
      when(mocker.mockFunc(FileUtil, FileUtil.getSandboxPath))(ArgumentMatchers.any).afterReturn('');
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.copySrcFileToTargetSync);
      await mAttachmentAreaController.initSourceOfEnhancedInfo(context, false, 0, []);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(2);
      mocker.clear(FileUtil);
      mocker.clear(ObjectUtil);
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_setDisplaySource_length_1', 0, () => {
      mAttachmentAreaController.mmDisplaySource = [];
      let mms: Mms = {
        duration: "",
        type: common.MM_ATTACHMENT_TYPE.VIDEO,
        path: "",
        name: "123.mp4"
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.initSource);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      mAttachmentAreaController.setDisplaySource(context, mms);
      expect(AppStorage.get('isConversationNeedChange')).assertTrue();
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_setDisplaySource_length_2', 0, () => {
      let mms: Mms = {
        duration: "",
        type: common.MM_ATTACHMENT_TYPE.VIDEO,
        path: "",
        name: "123.mp4"
      };
      mAttachmentAreaController.mmDisplaySource = [mms];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      mAttachmentAreaController.setDisplaySource(context, mms);
      expect(AppStorage.get('isConversationNeedChange')).assertTrue();
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_setDisplaySourceOfEnhancedInfo', 0, () => {
      let obj: Mms = {
        duration: '',
        type: 1,
        path: '',
        name: '',
        text: '',
        isOnAudio: true,
        imagePath: '',
        size: '',
        copyPath: '',
        index: 1,
        galleryPath: '',
        isRcs: true,
        pageNum: 1,
        pageCount: 1,
        content: '',
        isOriginalImage: true,
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      mAttachmentAreaController.setDisplaySourceOfEnhancedInfo(obj);
      expect(AppStorage.get('isConversationNeedChange')).assertTrue();
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_deleteTabDisplay_audio', 0, () => {
      let mms: Mms = {
        duration: "",
        type: common.MM_ATTACHMENT_TYPE.AUDIO,
        path: "",
        name: "123.amr",
        size: '1'
      };
      mAttachmentAreaController.mmDisplaySource = [];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController.audioPlayerService,
        mAttachmentAreaController.audioPlayerService.stopAudio);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      mocker.mockFunc(Number, Number.parseFloat);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize);
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.convertMsgInfo);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mocker.mockFunc(FileUtil, FileUtil.deleteFile);
      mAttachmentAreaController.deleteTabDisplay(context, mms);
      expect(AppStorage.get('isConversationNeedChange')).assertTrue();
      mocker.clear(mAttachmentAreaController.audioPlayerService);
      mocker.clear(mAttachmentAreaController);
      mocker.clear(FileUtil);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('MMAttachmentAreaController_deleteTabDisplay_image', 0, () => {
      let mms: Mms = {
        duration: "",
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: "",
        name: "123.jpg"
      };
      mAttachmentAreaController.mmDisplaySource = [mms];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController.audioPlayerService,
        mAttachmentAreaController.audioPlayerService.stopAudio);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      mocker.mockFunc(Number, Number.parseFloat);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize);
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.convertMsgInfo);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mocker.mockFunc(FileUtil, FileUtil.deleteFile);
      mAttachmentAreaController.deleteTabDisplay(context, mms);
      expect(AppStorage.get('isConversationNeedChange')).assertTrue();
      mocker.clear(mAttachmentAreaController.audioPlayerService);
      mocker.clear(mAttachmentAreaController);
      mocker.clear(FileUtil);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('MMAttachmentAreaController_deleteTabDisplay_video', 0, () => {
      let mms: Mms = {
        duration: "",
        type: common.MM_ATTACHMENT_TYPE.VIDEO,
        path: "",
        name: "123.jpg"
      };
      mAttachmentAreaController.mmDisplaySource = [mms];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController.audioPlayerService,
        mAttachmentAreaController.audioPlayerService.stopAudio);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      mocker.mockFunc(Number, Number.parseFloat);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize);
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.convertMsgInfo);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mocker.mockFunc(FileUtil, FileUtil.deleteFile);
      mAttachmentAreaController.deleteTabDisplay(context, mms);
      expect(AppStorage.get('isConversationNeedChange')).assertTrue();
      mocker.clear(mAttachmentAreaController.audioPlayerService);
      mocker.clear(mAttachmentAreaController);
      mocker.clear(FileUtil);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('MMAttachmentAreaController_handleEnhancedInfoCheckedChange_selected_1', 0, () => {
      let mediaPath: string = 'file://media/file/image.jpg';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setPictureOrVideoOfEnhancedInfo);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.changeSource);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(10);
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(10);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.convertMsgInfo);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('');
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize);
      mocker.mockFunc(FileUtil, FileUtil.deleteFile);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      mAttachmentAreaController.handleEnhancedInfoCheckedChange(context, mediaPath, true, 1);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
      mocker.clear(FileUtil);
      mocker.clear(mAttachmentAreaController);
      mocker.clear(OperatorConfigUtil.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('MMAttachmentAreaController_handleEnhancedInfoCheckedChange_selected_2', 0, () => {
      let mediaPath: string = 'file://media/file/image.jpg';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.changeSource);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(10);
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(10);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.convertMsgInfo);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('');
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize);
      mocker.mockFunc(FileUtil, FileUtil.deleteFile);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      mAttachmentAreaController.handleEnhancedInfoCheckedChange(context, mediaPath, true, 2);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
      mocker.clear(FileUtil);
      mocker.clear(mAttachmentAreaController);
      mocker.clear(OperatorConfigUtil.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('MMAttachmentAreaController_handleEnhancedInfoCheckedChange_unselected', 0, () => {
      let mediaPath: string = 'file://media/file/image.jpg';
      mAttachmentAreaController.mmDisplaySource = [{
        duration: "",
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: "",
        name: "123.jpg",
        galleryPath: 'file://media/file/image.jpg'
      }, {
        duration: "",
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: "",
        name: "123.jpg",
        galleryPath: 'file://media/file/image1.jpg'
      }];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.changeSource);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('');
      mocker.mockFunc(FileUtil, FileUtil.deleteFile);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(10);
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(10);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.convertMsgInfo);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mAttachmentAreaController.handleEnhancedInfoCheckedChange(context, mediaPath, false, 1, undefined);
      mocker.verify('refreshDisplay', []).times(1);
      mocker.clear(FileUtil);
      mocker.clear(mAttachmentAreaController);
      mocker.clear(OperatorConfigUtil.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('MMAttachmentAreaController_handleEnhancedInfoCheckedChange_unselected2', 0, () => {
      let mediaPath: string = 'file://media/file/image.jpg';
      mAttachmentAreaController.mmDisplaySource = [{
        duration: "",
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: "",
        name: "123.jpg",
        galleryPath: 'file://media/file/image2.jpg'
      }, {
        duration: "",
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: "",
        name: "123.jpg",
        galleryPath: 'file://media/file/image1.jpg'
      }];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('');
      mocker.mockFunc(FileUtil, FileUtil.deleteFile);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.changeSource);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(10);
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(10);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.convertMsgInfo);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mAttachmentAreaController.handleEnhancedInfoCheckedChange(context, mediaPath, false, 2, undefined);
      mocker.verify('refreshDisplay', []).times(1);
      mocker.clear(FileUtil);
      mocker.clear(mAttachmentAreaController);
      mocker.clear(OperatorConfigUtil.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('MMAttachmentAreaController_handleCheckedChange_video_selected_true', 0, () => {
      let mediaPath: string = 'file://media/file/1223.mp4';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.isExceedSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<boolean>(resolve => resolve(true)));
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.changeSource);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(10);
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(10);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.convertMsgInfo);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('');
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize);
      mocker.mockFunc(FileUtil, FileUtil.deleteFile);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      mAttachmentAreaController.handleCheckedChange(context, mediaPath, true, 2, undefined, () => {
      });
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(2);
      mocker.clear(FileUtil);
      mocker.clear(mAttachmentAreaController);
      mocker.clear(OperatorConfigUtil.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('MMAttachmentAreaController_handleCheckedChange_video_selected_false_1', 0, () => {
      let mediaPath: string = 'file://media/file/1223.mp4';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.isExceedSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<boolean>(resolve => resolve(false)));
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setPicture);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.convertMsgInfo);
      mAttachmentAreaController.handleCheckedChange(context, mediaPath, true, 1, undefined, () => {
      });
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.changeSource);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(10);
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(10);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('');
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize);
      mocker.mockFunc(FileUtil, FileUtil.deleteFile);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(2);
      mocker.clear(FileUtil);
      mocker.clear(mAttachmentAreaController);
      mocker.clear(OperatorConfigUtil.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('MMAttachmentAreaController_handleCheckedChange_video_selected_false_2', 0, () => {
      let mediaPath: string = 'file://media/file/1223.mp4';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.isExceedSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<boolean>(resolve => resolve(false)));
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setVideo);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.convertMsgInfo);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.changeSource);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(10);
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(10);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('');
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize);
      mocker.mockFunc(FileUtil, FileUtil.deleteFile);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      mAttachmentAreaController.handleCheckedChange(context, mediaPath, true, 2, undefined, () => {
      });
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(3);
      mocker.clear(FileUtil);
      mocker.clear(mAttachmentAreaController);
      mocker.clear(OperatorConfigUtil.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('MMAttachmentAreaController_handleCheckedChange_video_unselected_idx_0', 0, () => {
      let mediaPath: string = 'file://media/file/1223.mp4';
      mAttachmentAreaController.mmDisplaySource = [{
        duration: "",
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: "",
        name: "1223.mp4",
        galleryPath: 'file://media/file/1223.mp4'
      }];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.changeSource);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(10);
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(10);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.convertMsgInfo);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('');
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize);
      mocker.mockFunc(FileUtil, FileUtil.deleteFile);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      mAttachmentAreaController.handleCheckedChange(context, mediaPath, false, 2, undefined);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(0);
      mocker.clear(FileUtil);
      mocker.clear(mAttachmentAreaController);
      mocker.clear(OperatorConfigUtil.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('MMAttachmentAreaController_handleCheckedChange_video_unselected_idx_1', 0, () => {
      let mediaPath: string = 'file://media/file/1223.mp4';
      mAttachmentAreaController.mmDisplaySource = [{
        duration: "",
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: "",
        name: "12232.mp4",
        galleryPath: 'file://media/file/12232.mp4'
      }, {
        duration: "",
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: "",
        name: "1223.mp4",
        galleryPath: 'file://media/file/1223.mp4'
      }];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.changeSource);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(10);
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(10);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.convertMsgInfo);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('');
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize);
      mocker.mockFunc(FileUtil, FileUtil.deleteFile);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      mAttachmentAreaController.handleCheckedChange(context, mediaPath, false, 2, undefined);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
      mocker.clear(FileUtil);
      mocker.clear(mAttachmentAreaController);
      mocker.clear(OperatorConfigUtil.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('MMAttachmentAreaController_handleCheckedChange_video_unselected_idx_minus1', 0, () => {
      let mediaPath: string = 'file://media/file/1223.mp4';
      mAttachmentAreaController.mmDisplaySource = [{
        duration: "",
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: "",
        name: "12232.mp4",
        galleryPath: 'file://media/file/12232.mp4'
      }];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.changeSource);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(11);
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(10);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.convertMsgInfo);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('');
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize);
      mocker.mockFunc(FileUtil, FileUtil.deleteFile);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      mAttachmentAreaController.handleCheckedChange(context, mediaPath, false, 2, undefined);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
      mocker.clear(FileUtil);
      mocker.clear(mAttachmentAreaController);
      mocker.clear(OperatorConfigUtil.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('MMAttachmentAreaController_changeSource', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.initSource);
      mAttachmentAreaController.changeSource(context);
      expect(mAttachmentAreaController).not().assertUndefined();
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_setPicture_flag_true', 0, () => {
      let mediaPath: string = 'file://media/file/image.jpg';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(FileUtil, FileUtil.writeMediaToSandBox))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('');
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setDisplaySource);
      mAttachmentAreaController.setPicture(context, mediaPath, undefined, true);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
      mocker.clear(FileUtil);
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_setPicture_flag_false', 0, () => {
      let mediaPath: string = 'file://media/file/image.jpg';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(FileUtil, FileUtil.writeMediaToSandBox))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('');
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setDisplaySource);
      mAttachmentAreaController.setPicture(context, mediaPath, {} as image.PixelMap, false);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
      mocker.clear(FileUtil);
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_setPicture_empty', 0, () => {
      let mediaPath: string = '';
      mAttachmentAreaController.setPicture(context, mediaPath);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
    })

    it('MMAttachmentAreaController_setPictureOfEnhancedInfo', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('');
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setDisplaySourceOfEnhancedInfo);
      mAttachmentAreaController.setPictureOrVideoOfEnhancedInfo('/a', context, undefined, true, true);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(FileUtil);
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_setPictureOfEnhancedInfo_isRefreshDisplay_false', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('');
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setDisplaySourceOfEnhancedInfo);
      mAttachmentAreaController.setPictureOrVideoOfEnhancedInfo('/a', context, {} as image.PixelMap, true, false);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(FileUtil);
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_setVideo', 0, () => {
      let mediaPath: string = 'file://media/file/12333.mp4';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(FileUtil, FileUtil.writeMediaToSandBox))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('');
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setDisplaySource);
      mAttachmentAreaController.setVideo(context, mediaPath);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(FileUtil);
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_setVideo_empty', 0, () => {
      let mediaPath: string = '';
      mAttachmentAreaController.setVideo(context, mediaPath);
      expect(mAttachmentAreaController.isRcs).assertFalse();
    })

    it('MMAttachmentAreaController_setAudio', 0, () => {
      let time: string = '1: 00';
      let path: string = '/data/storage/el2/base/haps/entry/files/123.amr';
      let name: string = '123.amr';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setDisplaySource);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.convertMsgInfo);
      mAttachmentAreaController.setAudio(context, time, path, name);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_setAudio_path_empty', 0, () => {
      let path: string = '';
      let time: string = '1: 00';
      let name: string = '';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.convertMsgInfo);
      mAttachmentAreaController.setAudio(context, time, path, name);
      mocker.verify('convertMsgInfo', [true]).never();
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_setAudio_time_empty', 0, () => {
      let path: string = '/data/storage/el2/base/haps/entry/files/123.amr';
      let time: string = '';
      let name: string = '123.amr';
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.convertMsgInfo);
      mAttachmentAreaController.setAudio(context, time, path, name);
      mocker.verify('convertMsgInfo', [true]).never();
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_setRcsAudio', 0, () => {
      let time: string = '1: 00';
      let path: string = '/data/storage/el2/base/haps/entry/files/123.amr';
      let name: string = '123.amr';
      mAttachmentAreaController.setRcsAudio(time, path, name);
      expect(mAttachmentAreaController.rcsDisplaySource.length).assertEqual(1);
    })

    it('MMAttachmentAreaController_setRcsAudio_path_empty', 0, () => {
      let path: string = '';
      let time: string = '1: 00';
      let name: string = '';
      mAttachmentAreaController.setRcsAudio(time, path, name);
      expect(mAttachmentAreaController.rcsDisplaySource.length).assertEqual(1);
    })

    it('MMAttachmentAreaController_setRcsAudio_time_empty', 0, () => {
      let path: string = '/data/storage/el2/base/haps/entry/files/123.amr';
      let time: string = '';
      let name: string = '123.amr';
      mAttachmentAreaController.setRcsAudio(time, path, name);
      expect(mAttachmentAreaController.rcsDisplaySource.length).assertEqual(1);
    })

    it('MMAttachmentAreaController_setTotalSize_fileSize_minus1', 0, async () => {
      let path: string = '/data/storage/el2/base/haps/entry/files/123.amr';
      GlobalContext.getContext().setObject("fileTotalSize", 500);
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(-1);
      await mAttachmentAreaController.setTotalSize(true, path);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(GlobalContext.getContext());
    })

    it('MMAttachmentAreaController_setTotalSize_resSize_0', 0, async () => {
      let path: string = '/data/storage/el2/base/haps/entry/files/123.amr';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(1);
      when(mocker.mockFunc(FileUtil, FileUtil.packingSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<packingItem>(resolve => resolve({
          data: new ArrayBuffer(0),
          size: 0
        } as packingItem)));
      await mAttachmentAreaController.setTotalSize(true, path);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(GlobalContext.getContext());
      mocker.clear(FileUtil);
    })

    it('MMAttachmentAreaController_setTotalSize_resSize_10', 0, async () => {
      let path: string = 'files/123.amr';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(10);
      when(mocker.mockFunc(FileUtil, FileUtil.packingSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<packingItem>(resolve => resolve({
          data: new ArrayBuffer(10),
          size: 10
        } as packingItem)));
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(10);
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      await mAttachmentAreaController.setTotalSize(true, path);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(GlobalContext.getContext());
      mocker.clear(FileUtil);
      mocker.clear(OperatorConfigUtil.getInstance());
    })

    it('MMAttachmentAreaController_setTotalSize_resSize_10_custSize_50', 0, async () => {
      let path: string = 'files/123.amr';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(10);
      when(mocker.mockFunc(FileUtil, FileUtil.packingSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<packingItem>(resolve => resolve({
          data: new ArrayBuffer(10),
          size: 10
        } as packingItem)));
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(50);
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      await mAttachmentAreaController.setTotalSize(true, path);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(GlobalContext.getContext());
      mocker.clear(FileUtil);
      mocker.clear(OperatorConfigUtil.getInstance());
    })

    it('MMAttachmentAreaController_setTotalSize_isAdd_false', 0, async () => {
      let path: string = 'files/123.amr';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(10);
      when(mocker.mockFunc(FileUtil, FileUtil.packingSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<packingItem>(resolve => resolve({
          data: new ArrayBuffer(10),
          size: 10
        } as packingItem)));
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(50);
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
       await mAttachmentAreaController.setTotalSize(false, path);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(GlobalContext.getContext());
      mocker.clear(FileUtil);
      mocker.clear(OperatorConfigUtil.getInstance());
    })

    it('MMAttachmentAreaController_setTotalSize_indexOf_not0', 0, async () => {
      let path: string = '/data/storage/el2/base/haps/entry/files/123.amr';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(10);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSize))(ArgumentMatchers.any)
        .afterReturn(10);
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(50);
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      await mAttachmentAreaController.setTotalSize(false, path);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(GlobalContext.getContext());
      mocker.clear(FileUtil);
      mocker.clear(OperatorConfigUtil.getInstance());
    })

    it('MMAttachmentAreaController_getFileSize', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any)
        .afterReturn(10);
      let size: number = mAttachmentAreaController.getFileSize('/a/b', 10);
      expect(size).assertEqual(10);
      mocker.clear(FileUtil);
    })

    it('MMAttachmentAreaController_getFileSize_size_0', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any)
        .afterReturn(0);
      let size: number = mAttachmentAreaController.getFileSize('/a/b', 10);
      expect(size).assertEqual(10);
      mocker.clear(FileUtil);
    })

    it('MMAttachmentAreaController_resetMms_image', 0, () => {
      mAttachmentAreaController.mmDisplaySource = [{
        duration: "",
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: "",
        name: "123.jpg"
      }];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      mAttachmentAreaController.resetMms();
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(0);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_convertMsgInfo_true', 0, () => {
      mAttachmentAreaController.mmDisplaySource = [{
        duration: "",
        type: common.MM_ATTACHMENT_TYPE.VIDEO,
        path: "",
        name: "123.mp4"
      }];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.showToast);
      mAttachmentAreaController.convertMsgInfo(true);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_convertMsgInfo_false', 0, () => {
      mAttachmentAreaController.mmDisplaySource = [{
        duration: "",
        type: common.MM_ATTACHMENT_TYPE.VIDEO,
        path: "",
        name: "123.mp4"
      }];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.showToast);
      mAttachmentAreaController.convertMsgInfo(false);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_isExceedSize_true', 0, async () => {
      let path: string = 'file://media/file/12333.mp4';
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<boolean>(res => {
        res(true);
      }));
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(10);
      mocker.mockFunc(MmsUtil, MmsUtil.showToast);
      await mAttachmentAreaController.isExceedSize(path);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
      mocker.clear(mAttachmentAreaController);
      mocker.clear(OperatorConfigUtil.getInstance());
      mocker.clear(MmsUtil);
    })

    it('MMAttachmentAreaController_isExceedSize_false', 0, async () => {
      let path: string = 'file://media/file/12333.mp4';
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<boolean>(res => {
        res(false);
      }));
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(10);
      mocker.mockFunc(MmsUtil, MmsUtil.showToast);
      await mAttachmentAreaController.isExceedSize(path);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
      mocker.clear(mAttachmentAreaController);
      mocker.clear(OperatorConfigUtil.getInstance());
      mocker.clear(MmsUtil);
    })

    it('MMAttachmentAreaController_isExceedSizeNotShowToast', 0, async () => {
      let path: string = 'file://media/file/12333.mp4';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setTotalSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<boolean>(resolve => resolve(true)));
      let res: boolean = await mAttachmentAreaController.isExceedSizeNotShowToast(path);
      expect(res).assertTrue();
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_isAttachmentUpperLimit_upper', 0, () => {
      mAttachmentAreaController.mmDisplaySource.length = 100;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.showToast);
      let res: boolean = mAttachmentAreaController.isAttachmentUpperLimit();
      expect(res).assertTrue();
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_isAttachmentUpperLimit_not_upper', 0, () => {
      mAttachmentAreaController.mmDisplaySource = [];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.showToast);
      let res: boolean = mAttachmentAreaController.isAttachmentUpperLimit();
      expect(res).assertFalse();
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_checkImageNumOfEnhancedInfo', 0, () => {
      mAttachmentAreaController.mmDisplaySource.length = 20;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.showToast);
      mAttachmentAreaController.checkImageNumOfEnhancedInfo();
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_checkImageNumOfEnhancedInfo_length_0', 0, () => {
      mAttachmentAreaController.checkImageNumOfEnhancedInfo();
      expect(mAttachmentAreaController.isRcs).assertFalse();
    })

    it('MMAttachmentAreaController_initRcsSource_video', 0, () => {
      let obj: Mms = {
        type: 2,
        name: '12345.jpg',
        path: '/data/storage/el2/base/haps/entry/files/12345.jpg',
        duration: '',
        galleryPath: 'aaaa'
      };
      mAttachmentAreaController.rcsDisplaySource = [obj];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
        .afterReturn({
          type: 2,
          galleryPath: '',
          path: ''
        } as Mms);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any).afterReturn(1024);
      when(mocker.mockFunc(JSON, JSON.stringify))(ArgumentMatchers.any).afterReturn('1024');
      mAttachmentAreaController.rcsDisplaySource.push(obj);
      mAttachmentAreaController.initRcsSource(context, false, 0);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mAttachmentAreaController.rcsDisplaySource.pop();
      mocker.clear(FileUtil);
      mocker.clear(ObjectUtil);
      mocker.clear(JSON);
    })

    it('MMAttachmentAreaController_initRcsSource_video_galleryPath_undefined', 0, () => {
      let obj: Mms = {
        type: 2,
        name: '12345.jpg',
        path: '/data/storage/el2/base/haps/entry/files/12345.jpg',
        duration: '',
        galleryPath: 'aaaa'
      };
      mAttachmentAreaController.rcsDisplaySource = [obj];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
        .afterReturn({
          type: 2,
          galleryPath: undefined,
          path: ''
        } as Mms);
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any).afterReturn(1024);
      when(mocker.mockFunc(JSON, JSON.stringify))(ArgumentMatchers.any).afterReturn('1024');
      mAttachmentAreaController.rcsDisplaySource.push(obj);
      mAttachmentAreaController.initRcsSource(context, false, 0);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mAttachmentAreaController.rcsDisplaySource.pop();
      mocker.clear(FileUtil);
      mocker.clear(ObjectUtil);
      mocker.clear(JSON);
    })

    it('MMAttachmentAreaController_initRcsSource_image', 0, () => {
      let obj: Mms = {
        type: 1,
        name: '12345.jpg',
        path: '/data/storage/el2/base/haps/entry/files/12345.jpg',
        duration: '',
        galleryPath: 'aaaa'
      };
      mAttachmentAreaController.rcsDisplaySource = [obj, obj];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
        .afterReturn({
          type: 1,
          galleryPath: '',
          path: ''
        } as Mms);
      when(mocker.mockFunc(FileUtil, FileUtil.packingSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<packingItem>(resolve => resolve({
          data: new ArrayBuffer(0),
          size: 0
        } as packingItem)));
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByPath))(ArgumentMatchers.any).afterReturn(1024);
      when(mocker.mockFunc(JSON, JSON.stringify))(ArgumentMatchers.any).afterReturn('1024');
      mAttachmentAreaController.rcsDisplaySource.push(obj);
      mAttachmentAreaController.initRcsSource(context, false, 0);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mAttachmentAreaController.rcsDisplaySource.pop();
      mocker.clear(FileUtil);
      mocker.clear(ObjectUtil);
      mocker.clear(JSON);
    })

    it('MMAttachmentAreaController_refreshRcsConversation', 0, () => {
      AppStorage.setOrCreate('isConversationNeedChange', false);
      mAttachmentAreaController.refreshRcsConversation();
      expect(AppStorage.get('isConversationNeedChange')).assertFalse();
    })

    it('MMAttachmentAreaController_refreshRcsConversation_length_1', 0, () => {
      AppStorage.setOrCreate('isConversationNeedChange', false);
      mAttachmentAreaController.rcsDisplaySource = [{} as Mms];
      mAttachmentAreaController.refreshRcsConversation();
      expect(AppStorage.get('isConversationNeedChange')).assertFalse();
    })

    it('MMAttachmentAreaController_setVcard', 0, () => {
      let contact: ContactType = {
        contactName: '',
        telephone: '',
        telephoneFormat: '',
        headImage: '',
        select: true,
        rawContactId: '',
        id: 1,
        index: 0
      };
      let contacts: ContactType[] = [contact];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(VCardUtil.getInstance(), VCardUtil.getInstance().dealSelectedContactsToVcfItems))(ArgumentMatchers.any)
        .afterReturn([]);
      when(mocker.mockFunc(VCardUtil.getInstance(), VCardUtil.getInstance().generateVcf))(ArgumentMatchers.any)
        .afterReturn({
          name: '',
          path: ''
        } as SavedFileInfo);
      when(mocker.mockFunc(MMPictureController, MMPictureController.checkFileOfEnhancedInfo))(ArgumentMatchers.any)
        .afterReturn(new  Promise<boolean>(resolve => resolve(true)));
      when(mocker.mockFunc(StringUtil, StringUtil.isEmpty))(ArgumentMatchers.any)
        .afterReturn(false);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshConversation);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      mAttachmentAreaController.setVcard(context, contacts);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(VCardUtil.getInstance());
      mocker.clear(MMPictureController);
      mocker.clear(mAttachmentAreaController);
      mocker.clear(StringUtil);
    })

    it('MMAttachmentAreaController_setVcard_isEmpty_true', 0, () => {
      let contact: ContactType = {
        contactName: '',
        telephone: '',
        telephoneFormat: '',
        headImage: '',
        select: true,
        rawContactId: '',
        id: 1,
        index: 0
      };
      let contacts: ContactType[] = [contact];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(VCardUtil.getInstance(), VCardUtil.getInstance().dealSelectedContactsToVcfItems))(ArgumentMatchers.any)
        .afterReturn([]);
      when(mocker.mockFunc(VCardUtil.getInstance(), VCardUtil.getInstance().generateVcf))(ArgumentMatchers.any)
        .afterReturn({
          name: '',
          path: ''
        } as SavedFileInfo);
      when(mocker.mockFunc(MMPictureController, MMPictureController.checkFileOfEnhancedInfo))(ArgumentMatchers.any)
        .afterReturn(new  Promise<boolean>(resolve => resolve(true)));
      when(mocker.mockFunc(StringUtil, StringUtil.isEmpty))(ArgumentMatchers.any)
        .afterReturn(true);
      mAttachmentAreaController.setVcard(context, contacts);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(VCardUtil.getInstance());
      mocker.clear(MMPictureController);
      mocker.clear(StringUtil);
    })

    it('MMAttachmentAreaController_setVcard_isCheckPass_false', 0, () => {
      let contact: ContactType = {
        contactName: '',
        telephone: '',
        telephoneFormat: '',
        headImage: '',
        select: true,
        rawContactId: '',
        id: 1,
        index: 0
      };
      let contacts: ContactType[] = [contact];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(VCardUtil.getInstance(), VCardUtil.getInstance().dealSelectedContactsToVcfItems))(ArgumentMatchers.any)
        .afterReturn([]);
      when(mocker.mockFunc(VCardUtil.getInstance(), VCardUtil.getInstance().generateVcf))(ArgumentMatchers.any)
        .afterReturn({
          name: '',
          path: ''
        } as SavedFileInfo);
      when(mocker.mockFunc(MMPictureController, MMPictureController.checkFileOfEnhancedInfo))(ArgumentMatchers.any)
        .afterReturn(new  Promise<boolean>(resolve => resolve(false)));
      mAttachmentAreaController.setVcard(context, contacts);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(VCardUtil.getInstance());
      mocker.clear(MMPictureController);
    })

    it('MMAttachmentAreaController_handleAndSendAudioFile', 0, () => {
      let fileInfo: rcsFileInfo = {
        name: '12345.amr',
        filePath: 'file://media/file/12345.amr',
        sandBoxPath: '/data/storage/el2/base/haps/entry/files/12345.amr',
        size: 300,
        isAMRAudioFile: true
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setAudioFileInfo);
      mocker.mockFunc(ConversationController.getInstance(), ConversationController.getInstance().sendAudio);
      mAttachmentAreaController.handleAndSendAudioFile(context, fileInfo, false, () => {
      });
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(mAttachmentAreaController);
      mocker.clear(ConversationController.getInstance());
    })

    it('MMAttachmentAreaController_setAudioFileInfo_empty', 0, () => {
      let fileInfo: rcsFileInfo = {
        name: '123.mp4',
        filePath: 'file://media/file/123.mp4',
        sandBoxPath: '',
        size: 1024,
        isAMRAudioFile: false
      };
      mAttachmentAreaController.setAudioFileInfo(fileInfo);
      expect(mAttachmentAreaController.isRcs).assertFalse();
    })

    it('MMAttachmentAreaController_setAudioFileInfo', 0, () => {
      let fileInfo: rcsFileInfo = {
        name: '123.mp4',
        filePath: 'file://media/file/123.mp4',
        sandBoxPath: '/data/storage/el2/base/haps/entry/files/123.mp4',
        size: 1024,
        isAMRAudioFile: false
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(AudioPlayerService.getInstance(),
        AudioPlayerService.getInstance().getAudioDuration))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(AudioPlayerService.getInstance(),
        AudioPlayerService.getInstance().realseAvPlayerForParseAudio))()
        .afterReturn('');
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshRcsConversation);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      mAttachmentAreaController.setAudioFileInfo(fileInfo);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(AudioPlayerService.getInstance());
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_setFileInfo_empty', 0, () => {
      let fileInfo: rcsFileInfo = {
        name: '123.mp4',
        filePath: 'file://media/file/123.mp4',
        sandBoxPath: '',
        size: 1024,
        isAMRAudioFile: false
      };
      mAttachmentAreaController.setFileInfo(fileInfo);
      expect(mAttachmentAreaController.isRcs).assertFalse();
    })

    it('MMAttachmentAreaController_setFileInfo', 0, () => {
      let fileInfo: rcsFileInfo = {
        name: '123.mp4',
        filePath: 'file://media/file/123.mp4',
        sandBoxPath: '/data/storage/el2/base/haps/entry/files/123.mp4',
        size: 1024,
        isAMRAudioFile: false
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshRcsConversation);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.refreshDisplay);
      mAttachmentAreaController.setFileInfo(fileInfo);
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(mAttachmentAreaController);
    })

    it('MMAttachmentAreaController_previewRcsMessageWithPathOrUri', 0, () => {
      let path: string = 'file://media/file/12333.mp4';
      let name: string = '12333.mp4';
      mAttachmentAreaController.previewRcsMessageWithPathOrUri(path, name, true);
      expect(mAttachmentAreaController.isRcs).assertFalse();
    })

    it('MMAttachmentAreaController_setMap', 0, () => {
      let address: AddressInfo = new AddressInfo(10, 10, '', '');
      mAttachmentAreaController.setMap(address, '123', 'data/123');
      expect(mAttachmentAreaController.isRcs).assertFalse();
    })

    it('MMAttachmentAreaController_setMap_pixelMap', 0, () => {
      let address: AddressInfo = new AddressInfo(10, 10, '', '');
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(address, address.buildMapImgName);
      when(mocker.mockFunc(FileUtil, FileUtil.getSandboxPath))(ArgumentMatchers.any).afterReturn('');
      mocker.mockFunc(FileUtil, FileUtil.packPixelMapToSandBox);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.isExceedSize);
      mocker.mockFunc(mAttachmentAreaController, mAttachmentAreaController.setDisplaySource);
      mAttachmentAreaController.setMap(address, '123', 'data/123');
      expect(mAttachmentAreaController.isRcs).assertFalse();
      mocker.clear(mAttachmentAreaController);
      mocker.clear(FileUtil);
    })

    it('MMAttachmentAreaController_hasNeedReplaceVcard_true', 0, () => {
      mAttachmentAreaController.mmDisplaySource = [{
        type: 4
      } as Mms];
      mAttachmentAreaController.hasNeedReplaceVcard();
      expect(mAttachmentAreaController.hasNeedReplaceVcard()).assertEqual(true);
    })

    it('MMAttachmentAreaController_hasNeedReplaceVcard_false', 0, () => {
      mAttachmentAreaController.mmDisplaySource = [{} as Mms];
      mAttachmentAreaController.hasNeedReplaceVcard();
      expect(mAttachmentAreaController.hasNeedReplaceVcard()).assertEqual(false);
    })

    it('MMAttachmentAreaController_setMmsVcard', 0, () => {
      let contact: ContactType = {
        contactName: '',
        telephone: '',
        telephoneFormat: '',
        headImage: '',
        select: true,
        rawContactId: '',
        id: 1,
        index: 0
      };
      let contacts: ContactType[] = [contact];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(VCardUtil.getInstance(), VCardUtil.getInstance().dealSelectedContactsToVcfItems))(ArgumentMatchers.any)
        .afterReturn([]);
      when(mocker.mockFunc(VCardUtil.getInstance(), VCardUtil.getInstance().generateVcf))(ArgumentMatchers.any)
        .afterReturn({
          name: '',
          path: ''
        } as SavedFileInfo);
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(), OperatorConfigUtil.getInstance().getCustMMSSize))(ArgumentMatchers.any)
        .afterReturn(0 as number);
      mAttachmentAreaController.setMmsVcard(context, contacts, false);
      expect(mAttachmentAreaController.mmDisplaySource.length).assertEqual(1);
      mocker.clear(VCardUtil.getInstance());
      mocker.clear(OperatorConfigUtil.getInstance());
    })
  })
}