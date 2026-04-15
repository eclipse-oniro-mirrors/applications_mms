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
  beforeAll,
  beforeEach,
  afterEach,
  afterAll,
  it,
  expect,
  MockKit,
  when,
  ArgumentMatchers
} from '@ohos/hypium'
import { DragUtil } from '../../../../main/ets/utils/DragUtil'
import { DTGlobalContext } from '../../testability/TestAbility';
import HiLog from '../../../../main/ets/utils/HiLog';
import MMAttachmentAreaController from '../../../../main/ets/views/AttachmentArea/MMAttachmentAreaController';
import { Context } from '@kit.AbilityKit';
import UDC from '@ohos.data.unifiedDataChannel';
import unifiedDataChannel from '@ohos.data.unifiedDataChannel';
import CreateNewConversationViewModle from '../../../../main/ets/pages/conversation/CreateNewConversationViewModle';

const TAG = 'DragUtil'

export default function DragUtilTest() {
  describe('DragUtilTest', () => {
    let dragUtil: DragUtil
    let mocker: MockKit
    let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeAll(() => {
    })
    beforeEach(() => {
      dragUtil = DragUtil.getInstance();
      mocker = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
    })

    afterEach(() => {
      mocker.clear(HiLog)
      mocker.clear(MMAttachmentAreaController.getInstance());
      AppStorage.clear();
    })

    it('DragUtil_getInstance', 0, () => {
      expect(typeof DragUtil.getInstance()).assertEqual(typeof dragUtil);
    })

    it('DragUtil_dragHandle', 0, async () => {
      dragUtil.dragHandle({
        getRecords: () => {
          return [
            {getType: () => {return 'general.plain-text'}, textContent: 'textContent1'} as unifiedDataChannel.PlainText,
            {getType: () => {return 'general.image'}, imageUri: 'imageUri'} as UDC.Image,
            {getType: () => {return 'general.tiff'}} as UDC.UnifiedRecord,
            {getType: () => {return 'general.plain-text'}, textContent: 'textContent2'} as unifiedDataChannel.PlainText
          ]
        }
      } as UnifiedData, context);
      expect(context).not().assertUndefined();
    });

    it('DragUtil_dragHandle_textContent_5001', 0, async () => {
      dragUtil.dragHandle({
        getRecords: () => {
          return [
            {
              getType: () => {
                return 'general.plain-text'
              },
              textContent: 'textContent1_length>5000,__abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijk'
            } as unifiedDataChannel.PlainText,
            {
              getType: () => {
                return 'general.tiff'
              }
            } as UDC.UnifiedRecord,
            {
              getType: () => {
                return 'general.plain-text'
              }, textContent: 'textContent2'
            } as unifiedDataChannel.PlainText
          ]
        }
      } as UnifiedData, context);
      expect(context).not().assertUndefined();
    });

    it('DragUtil_dragHandle_mCreateNewConversationViewModle', 0, async () => {
      dragUtil.dragHandle({
        getRecords: () => {
          return [
            {getType: () => {return 'general.plain-text'}, textContent: 'textContent1'} as unifiedDataChannel.PlainText,
            {getType: () => {return 'general.tiff'}} as UDC.UnifiedRecord,
            {getType: () => {return 'general.plain-text'}, textContent: 'textContent2'} as unifiedDataChannel.PlainText
          ]
        }
      } as UnifiedData, context);
      expect(context).not().assertUndefined();
    });

    it('DragUtil_dragHandle_messageText_empty', 0, async () => {
      dragUtil.dragHandle({
        getRecords: () => {
          return [
            {
              getType: () => {
                return 'general.plain-text'
              }, textContent: 'textContent'
            } as unifiedDataChannel.PlainText,
            {
              getType: () => {
                return 'general.image'
              }, imageUri: 'imageUri'
            } as UDC.Image,
            {
              getType: () => {
                return 'general.tiff'
              }
            } as UDC.UnifiedRecord,
            {
              getType: () => {
                return 'general.plain-text'
              }, textContent: ''
            } as unifiedDataChannel.PlainText
          ]
        }
      } as UnifiedData, context);
      expect(context).not().assertUndefined();
    });

    it('DragUtil_dropImageTriggering', 0, () => {
      let imageUris: string[] = ['file:///media/file/image1.jpg', 'file:///media/file/image2.jpg']
      let isAttachmentUpperLimit: Function = mocker.mockFunc(MMAttachmentAreaController.getInstance(),
        MMAttachmentAreaController.getInstance().isAttachmentUpperLimit)
      when(isAttachmentUpperLimit)().afterReturn(true);
      dragUtil.dropImageTriggering(context, imageUris)
      expect(context).not().assertUndefined();
    });

    it('DragUtil_dropImageTriggering2', 0, async () => {
      let imageUris: string[] = ['file:///media/file/image1.jpg']
      let isAttachmentUpperLimit: Function = mocker.mockFunc(MMAttachmentAreaController.getInstance(),
        MMAttachmentAreaController.getInstance().isAttachmentUpperLimit)
      when(isAttachmentUpperLimit)(ArgumentMatchers.any).afterReturn(false);
      let isExceedSizeNotShowToast: Function =  mocker.mockFunc(MMAttachmentAreaController.getInstance(),
        MMAttachmentAreaController.getInstance().isExceedSizeNotShowToast)
      when(isExceedSizeNotShowToast)(ArgumentMatchers.any).afterReturn(new Promise<boolean>(resolve => resolve(true)));
      dragUtil.dropImageTriggering(context, imageUris)
      expect(context).not().assertUndefined();
    });

    it('DragUtil_dropImageTriggering_else', 0, async () => {
      let imageUris: string[] = ['file:///media/file/image1.jpg']
      let isAttachmentUpperLimit: Function = mocker.mockFunc(MMAttachmentAreaController.getInstance(),
        MMAttachmentAreaController.getInstance().isAttachmentUpperLimit)
      when(isAttachmentUpperLimit)(ArgumentMatchers.any).afterReturn(false);
      let isExceedSizeNotShowToast: Function =  mocker.mockFunc(MMAttachmentAreaController.getInstance(),
        MMAttachmentAreaController.getInstance().isExceedSizeNotShowToast)
      when(isExceedSizeNotShowToast)(ArgumentMatchers.any).afterReturn(new Promise<boolean>(resolve => resolve(false)));
      when(mocker.mockFunc(MMAttachmentAreaController.getInstance(),
        MMAttachmentAreaController.getInstance().setPicture))(ArgumentMatchers.any).afterReturnNothing();
      dragUtil.mmAttachmentAreaController.mmDisplaySource = [{
        duration: 'string',
        type: 1,
        path: 'string',
        name: 'string'
      }];
      dragUtil.dropImageTriggering(context, imageUris);
      expect(context).not().assertUndefined();
    });

    it('DragUtil_dropImageTriggering_else_mmDisplaySource_empty', 0, async () => {
      let imageUris: string[] = ['file:///media/file/image1.jpg']
      let isAttachmentUpperLimit: Function = mocker.mockFunc(MMAttachmentAreaController.getInstance(),
        MMAttachmentAreaController.getInstance().isAttachmentUpperLimit)
      when(isAttachmentUpperLimit)(ArgumentMatchers.any).afterReturn(false);
      let isExceedSizeNotShowToast: Function =  mocker.mockFunc(MMAttachmentAreaController.getInstance(),
        MMAttachmentAreaController.getInstance().isExceedSizeNotShowToast)
      when(isExceedSizeNotShowToast)(ArgumentMatchers.any).afterReturn(new Promise<boolean>(resolve => resolve(false)));
      dragUtil.mmAttachmentAreaController.mmDisplaySource = [];
      dragUtil.dropImageTriggering(context, imageUris);
      expect(context).not().assertUndefined();
    });
  })
}