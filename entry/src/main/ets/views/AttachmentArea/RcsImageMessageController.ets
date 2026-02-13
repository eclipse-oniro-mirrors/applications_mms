/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import { Conversation } from '../../pages/conversation/conversation';
import commonData from '../../data/commonData';
import ConversationController, { mmsListType } from '../../pages/conversation/conversationController';
import ImageUtil from '../../utils/ImageUtil';
import { Mms } from '../../utils/TypesUtils';
import HiLog from '../../utils/HiLog';
import lazy fs from '@ohos.file.fs';
import { BusinessError } from '@ohos.base';
import prompt from '@ohos.promptAction';
import MMAttachmentAreaController from './MMAttachmentAreaController';
import emitter from '@ohos.events.emitter';
import ReceiveService from '../../StaticSubscriber/ReceiveService';
import MmsUtil from '../../utils/MmsUtil';
import MMPictureController from './MMPictureController';
import { common } from '@kit.AbilityKit';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import { formatFileSize } from '../../utils/FileUtil';
import { image } from '@kit.ImageKit';

const TAG = 'RcsImageMessageController';

export default class RcsImageMessageController {
  private static sInstance: RcsImageMessageController;
  public static readonly CHECK_IMAGE_EVENT: emitter.InnerEvent = {
    eventId: 2,
    priority: emitter.EventPriority.HIGH
  }
  private conversationCtrl: ConversationController = ConversationController.getInstance();
  private mPictureCtrl: MMPictureController = MMPictureController.getInstance();
  private mAttachAreaCtrl: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();

  constructor() {
  }

  public static getInstance() {
    if (RcsImageMessageController.sInstance == null) {
      RcsImageMessageController.sInstance = new RcsImageMessageController();
    }
    return RcsImageMessageController.sInstance;
  }

  public async convertAndSetImagePixelMap(path: string, mapKeyToPixelMap: Map<string, PixelMap>) {
    let value: image.PixelMap | null = null;
    try {
      value = await ImageUtil.convertImageToPixmap(path);
    } catch (e) {
      HiLog.e(TAG, 'convertAndSetImagePixelMap: convertImageToPixmap error: ' + JSON.stringify(e));
      value = null;
    }
    if (value) {
      mapKeyToPixelMap.set(path, value);
    }
  }

  public downloadImage(id: string | number, path: string) {
    HiLog.i(TAG, 'downloadImage');
    const mmsStaticSub: ReceiveService = new ReceiveService();
    mmsStaticSub.handleRcsReceiveFileOnclick(String(id || ''), path, 'image/jpeg')
  }

  public onRcsNormalImageClick(showMenu: boolean, mmsItem: mmsListType, rcsInfoStatus: number,
    wifiNoticeController: CustomDialogController, isWifiConnected: string, item: Mms,
    abnormalSceneController: CustomDialogController | undefined) {
    HiLog.i(TAG, 'onRcsImageClick');
    if (showMenu) {
      return;
    }
    if (mmsItem.sendStatus === commonData.int.RCS_FIRST_RECEIVING) {
      HiLog.i(TAG, 'onRcsImageClick  Message status RCS_FIRST_RECEIVING');
      let isOnlineRcs = AppStorage.get('isOnlineRcs') as boolean;
      HiLog.i(TAG, 'onRcsNormalImageClick netConnectType: ' + isOnlineRcs);
      if (!isOnlineRcs) {
        abnormalSceneController?.open();
        return;
      }
      if (rcsInfoStatus != Conversation.RCS_INFO_STATUS && isWifiConnected != '1') {
        wifiNoticeController.open();
      } else {
        this.downloadImage(mmsItem.id, item.path);
      }
    } else if (![commonData.int.SEND_MESSAGE_SENDING, commonData.int.RCS_RECEIVING].includes(mmsItem.sendStatus)) {
      MMAttachmentAreaController.getInstance().previewRcsMessageWithPathOrUri(item.path, item.name, false);
    }
  }

  public checkIfCanTransmit(item: Mms, mmsItem: mmsListType): boolean {
    const isAudio: boolean = MmsUtil.isAudio(item?.type); // Check if it is audio
    const hasContent: boolean = (mmsItem && mmsItem?.content) ? true : false; // Check if there is text
    const audioCanTransmit: boolean = !isAudio || (isAudio && hasContent); // Check if the audio can be forwarded
    const checkNotOrigin: boolean = (mmsItem?.contentType !== commonData.MMS_CONTENT_TYPE.ORIGIN) ? true : false;
    const checkIdDownload: boolean = item.type !== -1 ? true : false
    return checkIdDownload && (audioCanTransmit || checkNotOrigin);
  }

  public async saveImageToPhotoAlbums(sandBoxPath: string) {
    HiLog.i(TAG, 'saveImagePhotoAlbums');
    const context = getContext(this) || (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);
    let photoAccessHelper = await import('@ohos.file.photoAccessHelper');
    let phAccessHelper = photoAccessHelper.default.getPhotoAccessHelper(context);
    try {
      //get fileSandbox.fd
      let fileSandbox = await fs.open(sandBoxPath, fs.OpenMode.READ_ONLY);
      let size = fs.statSync(fileSandbox.fd).size;
      let fileSandboxBuffer = new ArrayBuffer(size);
      fs.readSync(fileSandbox.fd, fileSandboxBuffer);
      //write to albums
      let uri = await phAccessHelper.createAsset(photoAccessHelper.default.PhotoType.IMAGE,
        sandBoxPath.endsWith('gif') ? 'gif' : 'jpg');
      let file = await fs.open(uri, fs.OpenMode.READ_WRITE);
      await fs.write(file.fd, fileSandboxBuffer);
      await fs.close(fileSandbox.fd);
      await fs.close(file.fd);
      prompt.showToast({
        message: $r('app.string.Saved_to_album'), duration: 200
      });
    } catch (err) {
      let error = err as BusinessError;
      HiLog.i(TAG, `saveImageToPhotoAlbums: ${error}`);
    }
  }

  public onImageProgressCancelButtonClick(context: Context, showMenu: boolean, mmsItem: mmsListType, item: Mms) {
    if (showMenu) {
      return;
    }
    if (mmsItem.sendStatus === commonData.int.SEND_MESSAGE_SENDING) {
      this.conversationCtrl?.cancelRcsFile(context, String(mmsItem.id || ''));
    } else if (mmsItem.sendStatus === commonData.int.RCS_RECEIVING) {
      this.conversationCtrl?.cancelReceiveFileOnclick(String(mmsItem.id || ''), item.path);
      AppStorage.setOrCreate('cancelItemDirection_' + mmsItem.id, mmsItem.isReceive);
    }
  }

  public onRcsImageComplete(isTouch: boolean, isFromTransmit: boolean) {
    if (!isTouch && !isFromTransmit) {
      emitter.emit(RcsImageMessageController.CHECK_IMAGE_EVENT);
      this.conversationCtrl?.scrollToEnd();
    }
  }

  public getOverlayNodeTextContent = (mmsItem: mmsListType, imageOriginSizeAfterFormat: string) => {
    const totalSizeWithUnit: string = (mmsItem.totalSize && mmsItem.totalSize > 0) ?
    formatFileSize(mmsItem.totalSize, 2) : imageOriginSizeAfterFormat;
    if (mmsItem.sendStatus === 1 || mmsItem.sendStatus === commonData.int.RCS_RECEIVING) {
      return `${formatFileSize(mmsItem.clurSize || 0, 2)} / ${totalSizeWithUnit}`;
    } else {
      return `${totalSizeWithUnit}`
    }
  }
}