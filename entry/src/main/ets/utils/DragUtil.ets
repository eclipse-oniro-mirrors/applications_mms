/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import HiLog from './HiLog';
import UDC from '@ohos.data.unifiedDataChannel';
import unifiedDataChannel from '@ohos.data.unifiedDataChannel';
import lazy uniformTypeDescriptor from '@ohos.data.uniformTypeDescriptor';
import MMAttachmentAreaController from '../views/AttachmentArea/MMAttachmentAreaController';
import CreateNewConversationViewModle from '../pages/conversation/CreateNewConversationViewModle';
import OperatorConfigUtil from '../../cust/utils/OperatorConfigUtil';
import { i18n, intl } from '@kit.LocalizationKit';
import commonData from '../data/commonData';
import ConversationController from '../pages/conversation/conversationController';
import lazy fs from '@ohos.file.fs';
import fileuri from '@ohos.file.fileuri';
import Prompt from '@ohos.promptAction';
import FileUtil from './FileUtil';

const TAG = 'DragUtil'
const TEXT_MAX_LENGTH: number = 5000;

export class DragUtil {
  private static sInstance: DragUtil;
  public mmAttachmentAreaController: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
  public mConversationCtrl: ConversationController = ConversationController.getInstance()

  static getInstance() {
    if (DragUtil.sInstance == null) {
      HiLog.i(TAG, 'getInstance');
      DragUtil.sInstance = new DragUtil();
    }
    return DragUtil.sInstance;
  }

  public dragHandle(dragData: UnifiedData, context: Context): string {
    let records: UDC.UnifiedRecord[] = dragData.getRecords();
    HiLog.i(TAG, 'drag dragHandle invoke, records size:' + records.length);
    const allowDragData: UDC.UnifiedRecord[] = [];
    let textNumFromTransit: number = -1
    // 拖拽校验
    for (let record of records) {
      HiLog.i(TAG, 'drag dragHandle record.getType: ' + record.getType())
      if (record.getType() === uniformTypeDescriptor.UniformDataType.PLAIN_TEXT) {
        const messageText: string = (record as unifiedDataChannel.PlainText).textContent;
        if (!messageText || messageText.length <= 0) {
          return '';
        }
        HiLog.i(TAG, 'drag dragHandle messageText length:' + messageText.length);
        textNumFromTransit++;
        allowDragData.push(record);
      } else if (record.getType() === uniformTypeDescriptor.UniformDataType.IMAGE) {
        allowDragData.push(record);
      }
    }

    let textContent: string = '';
    let imageUris: string[] = []
    for (let record of allowDragData) {
      if (record.getType() === uniformTypeDescriptor.UniformDataType.PLAIN_TEXT) {
        const messageText: string = (record as unifiedDataChannel.PlainText).textContent;
        if (textNumFromTransit > 0) {
          textContent += messageText + '\n';
          textNumFromTransit--;
        } else {
          textContent += messageText;
        }
        if (textContent.length > TEXT_MAX_LENGTH) {
          return '';
        }
      } else if (record.getType() === uniformTypeDescriptor.UniformDataType.IMAGE) {
        let imageUri = (record as UDC.Image).imageUri
        imageUris.push(imageUri)
      }
    }
    if (imageUris.length > 0) {
      this.dropImageTriggering(context, imageUris)
    }
    return textContent;
  }

  public async dropImageTriggering(context: Context, imageUris: string[]) {
    HiLog.i(TAG, 'dropImageTriggering imageLength: ' + imageUris.length)
    for (let i = 0; i < imageUris.length; i++) {
      if (this.mmAttachmentAreaController.isAttachmentUpperLimit()) {
        HiLog.i(TAG, 'saveVideoAlbums AttachmentUpperLimit');
        break;
      } else if (await this.mmAttachmentAreaController.isExceedSizeNotShowToast(imageUris[i], true)) {
        // Over 300kb Deleted Data
        await this.mmAttachmentAreaController.setTotalSize(false, imageUris[i], undefined, true);
        let maxSize: number = OperatorConfigUtil.getInstance().getCustMMSSize(
          commonData.int.MMS_FILE_MAX_SIZE) / commonData.int.BYTE_CONVERSION_UNIT;
        let countryId = i18n.System.getSystemRegion();
        let numberFormat = new intl.NumberFormat(countryId, {
          style: 'unit', unit: 'kilobyte'
        });
        let masxSiseStr = numberFormat.format(maxSize);
        let msg: Resource = $r('app.string.attachment_failed', masxSiseStr);
        this.showToast(msg);
        break;
      } else {
        if (this.mmAttachmentAreaController.mmDisplaySource.length == 0) {
          let msg: Resource = $r('app.string.converting_mms');
          this.showToast(msg);
        }
        let item = this.savePictureToSandBoxWithUrl(context, imageUris[i]);
        this.mmAttachmentAreaController.setPicture(context, item, undefined, true)
      }
    }
    AppStorage.setOrCreate('isAreaDisplayChange', true);
  }

  savePictureToSandBoxWithUrl(context: Context, url: string): string {
    try {
      let fileName = FileUtil.getFileName(url);
      let dotPosition = fileName.indexOf('.');
      let fileFormat: string = fileName.substring(dotPosition + 1);
      const randomStr = Date.now() + Math.random().toString(36).slice(2);
      let mediaName = commonData.STR.DRAG_IMG_PREFIX + randomStr + '.' + fileFormat;
      let filePath = FileUtil.getFilePath(context, mediaName)
      fs.createRandomAccessFileSync(filePath, fs.OpenMode.CREATE);
      let filePathuri = fileuri.getUriFromPath(filePath);
      let file = fs.openSync(url, fs.OpenMode.READ_ONLY);
      try {
        let file2 = fs.openSync(filePathuri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
        fs.copyFileSync(file.fd, file2.fd)
        fs.closeSync(file);
        fs.closeSync(file2);
      } catch (e) {
        HiLog.e(TAG, `openSync or copyFileSync error: ${JSON.stringify(e)}`);
      }
      return filePathuri;
    } catch (e) {
      HiLog.e(TAG, `savePictureToSandBoxWithUrl error: ${JSON.stringify(e)}`);
      return '';
    }
  }

  showToast(msg: ResourceStr) {
    Prompt.showToast({
      message: msg,
      duration: 2000,
    });
  }
}