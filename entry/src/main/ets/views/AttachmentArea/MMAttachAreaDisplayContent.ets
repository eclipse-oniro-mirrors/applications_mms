/**
 * Copyright (c) 2023-2024 Huawei Device Co., Ltd.
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

import { AudioPlayerService } from '../../service/AudioPlayerService';
import { Mms } from '../../utils/TypesUtils';
import HiLog from '../../utils/HiLog';
import ImageUtil from '../../utils/ImageUtil';
import { IPhotoProp } from '../../pages/photoBrowser/photoBrowser';
import HashMap from '@ohos.util.HashMap';
import image from '@ohos.multimedia.image';
import ConversationController from '../../pages/conversation/conversationController';
import MMAttachmentAreaController from './MMAttachmentAreaController';
import DotUtil from '../../utils/MmsDot/DotUtils';
import dotCommon, { mmsTypeParams } from '../../utils/MmsDot/DotCommon';
import LocationUtil from '../../utils/LocationUtil';
import dateUtil from '../../utils/DateUtil';
import { ImagePreviewData, imagePreviewBuilder } from './ImagePreviewBuilder';
import fileUri from '@ohos.file.fileuri';
import window from '@ohos.window';

const TAG = 'MMDisplayContent';

@Component
export struct MMAudio {
  audioPlayerService: AudioPlayerService = AudioPlayerService.getInstance();
  item: Mms = { duration: '', path: '', name: '', type: 3 };
  @State isOnAudio: boolean = false;
  @StorageLink('stopAudio') @Watch('stopAudioAction') stopAudio: Mms = { duration: '', type: -1, path: '', name: '' };
  @StorageLink('isBackProcess') @Watch('isBackProcessChange') isBackProcess: boolean = false;
  @State index: number = 1;
  @State displayList: Array<Mms> = [];
  @StorageLink('isDisplayListChange') @Watch('displayListChanged') isAreaDisplayChange: boolean = false;

  displayListChanged() {
    if (this.displayList.length > 0 && this.item && !this.item.isRcs) {
      let resList = this.displayList.map(item => {
        return item.path;
      });
      this.index = resList.indexOf(this.item.path) + 1;
    }
  }
  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    if (this.item.isOnAudio === undefined) {
      this.isOnAudio = false;
    } else {
      this.isOnAudio = this.item.isOnAudio
    }
    if (this.item) {
      let resList = this.displayList.map(item => {
        return item.path;
      });
      this.index = resList.indexOf(this.item.path) + 1;
    }
  }

  stopAudioAction() {
    if (this.stopAudio) {
      if (this.item.name === this.stopAudio.name) {
        this.item.isOnAudio = false;
        this.isOnAudio = false;
      }
    }
  }

  isBackProcessChange() {
    if (this.isBackProcess) {
      this.item.isOnAudio = false;
      this.isOnAudio = false;
    }
  }

  build() {
    Stack({alignContent:Alignment.Top}){
      Row() {
      }
      .width('100%')
      .height('100%')
      .borderRadius(8)
      .backgroundColor($r('app.color.mms_recorder_area_display_bg'))
      .padding({ left: 8 })

      Row() {
        SymbolGlyph($r('sys.symbol.wave_3_left'))
          .width(16)
          .height(16)
          .draggable(false)
          .margin({ right: 8 })
          .fontColor([$r('sys.color.ohos_id_color_fourth')])
          .fontSize($r('app.float.settings_item_primary_title_font_size'))
          .symbolEffect(new HierarchicalSymbolEffect(EffectFillStyle.ITERATIVE), this.isOnAudio)

        Text(this.item.duration)
          .fontSize('16vp')
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Regular)
      }
      .width('100%')
      .height('100%')
      .borderRadius(8)
      .padding({ left: 12 })
      .accessibilityText(getContext(this)
        .resourceManager
        .getStringSync($r('app.string.msg_attachments').id) + this.index +
      dateUtil.getAudioAccessibilityText(this.item.duration))
      .id(this.item?.path)
      .onClick(() => {
        if (!this.isOnAudio) {
          this.item.isOnAudio = true;
          this.isOnAudio = true;
        }
        this.audioPlayerService.playAudio(this.item);
        // Click the attached audio(DOT)
        mmsTypeParams.TYPE_STATUS = 2;
        if (this.item?.isRcs) {
          mmsTypeParams.SMS_STATUS = 2;
        } else {
          mmsTypeParams.SMS_STATUS = 1;
        }
        DotUtil.getInstance().reportEvent(mmsTypeParams, dotCommon.eventName.TOUCH_ATTACHMENTS_EVENT);
      });
    }
    .width(110)
    .height(40)
  }
}

@Component
export struct MMPictureDisplay {
  @State imageWidth: number = 0;
  @State imageHeight: number = 0;
  @Consume('pageInfos') pageInfos: NavPathStack;
  item?: Mms;
  @Link textareaFocusable: boolean;
  @Consume storagePixelMap: HashMap<string, PixelMap> ;
  @State imagePixmap?: PixelMap = undefined;
  @State imagePreData: ImagePreviewData = new ImagePreviewData()
  @StorageLink('isVDEFoldPhoneAndFoldedState') isVDEFoldPhoneAndFoldedState: boolean = false;
  @StorageLink('foldStatus') @Watch('getWallpaper') foldStatus: number = 0;
  @State isVDE: boolean = this.isVDEFoldPhoneAndFoldedState && this.foldStatus === 2 ? true : false;
  @State index: number = 1;
  @State displayList: Array<Mms> = [];
  @StorageLink('isDisplayListChange') @Watch('displayListChanged') isAreaDisplayChange: boolean = false;
  getWallpaper() {
    if (this.isVDEFoldPhoneAndFoldedState) {
      if (this.foldStatus === 2) {
        this.isVDE = true;
      } else {
        this.isVDE = false;
      }
    } else {
      this.isVDE = false;
    }
  }
  displayListChanged() {
    if (this.displayList.length > 0 && this.item && !this.item.isRcs) {
      let resList = this.displayList.map(item => {
        return item.path;
      });
      this.index = resList.indexOf(this.item.path) + 1;
    }
  }

  aboutToAppear() {
    if (this.item && !this.item.isRcs) {
      this.getImagePixmap(this.item.path);
      let resList = this.displayList.map(item => {
        return item.path;
      });
      this.index = resList.indexOf(this.item.path) + 1;
    }
  }

  aboutToDisappear(): void {
    this.imagePixmap?.release();
  }

  getImagePixmap(path: string) {
    let hasStorage: boolean = this.storagePixelMap.hasKey(path);
    if (hasStorage) {
      this.imagePixmap = this.storagePixelMap.get(path) as PixelMap;
    }
    if (!hasStorage || !this.imagePixmap) {
      ImageUtil.convertImageToPixmap(path).then((value: image.PixelMap) => {
        this.imagePixmap = value;
      });
    }
  }

  build() {
    Row() {
      if (this.item?.pixelMap) {
        Image(this.item.pixelMap)
          .height(this.isVDE ? 64 : 80)
          .width(this.isVDE ? 64 : 80)
          .borderRadius(8)
          .draggable(false)
          .geometryTransition(this.imagePreData.getGeometryID(), { follow: true })
          .opacity(this.imagePreData.showImage ? 0 : 1)
      } else if (this.imagePixmap){
        Image(this.imagePixmap)
          .height(this.isVDE ? 64 : 80)
          .width(this.isVDE ? 64 : 80)
          .borderRadius(8)
          .draggable(false)
          .geometryTransition(this.imagePreData.getGeometryID(), { follow: true })
          .opacity(this.imagePreData.showImage ? 0 : 1)
      } else if (this.item?.path && this.item.path !== '') {
        Image(this.item.path)
          .height(this.isVDE ? 64 : 80)
          .width(this.isVDE ? 64 : 80)
          .borderRadius(8)
          .draggable(false)
          .geometryTransition(this.imagePreData.getGeometryID(), { follow: true })
          .opacity(this.imagePreData.showImage ? 0 : 1)
      } else {
        Stack({ alignContent: Alignment.Center }) {
          Row()
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .width(this.isVDE ? 64 : 80)
          .height(this.isVDE ? 64 : 80)
          .borderRadius(16)
          .backgroundColor('#000000')
          .opacity(0.05)
          Image($rawfile('icon/image_failed_24.svg'))
            .width(24)
            .height(24)
            .draggable(false)
            .fillColor($r('sys.color.ohos_id_color_secondary'))
        }
      }
    }
    .geometryTransition(this.imagePreData.getGeometryID(), { follow: true })
    .transition(TransitionEffect.OPACITY)
    .accessibilityText(getContext(this)
      .resourceManager
      .getStringSync($r('app.string.msg_attachments').id) + this.index)
    .accessibilityRole(AccessibilityRoleType.IMAGE)
    .id(this.item?.path)
    .onClick(()=> {
      this.textareaFocusable = false;
      const param: IPhotoProp = { isSandBox: true, uri: this.item?.path || '', width: this.imageWidth,
        height: this.imageHeight };
      if (ConversationController.getInstance().isRcsMms && this.item?.isRcs) {
        let uri = this.item?.path || ''
        this.imagePreData.images = ImagePreviewData.handleImagePath([uri])
        this.imagePreData.imagePreviewShow()
      } else {
        let uri = this.item?.path || ''
        this.imagePreData.images = ImagePreviewData.handleImagePath([uri])
        this.imagePreData.imagePreviewShow()
      }
      // Click the attached image(DOT)
      mmsTypeParams.TYPE_STATUS = 1;
      if (this.item?.isRcs) {
        mmsTypeParams.SMS_STATUS = 2;
      } else {
        mmsTypeParams.SMS_STATUS = 1;
      }
      DotUtil.getInstance().reportEvent(mmsTypeParams, dotCommon.eventName.TOUCH_ATTACHMENTS_EVENT);
    })
    .bindContentCover(this.imagePreData.showImage, imagePreviewBuilder(this.imagePreData), {
      onAppear: () => {
        window.getLastWindow(getContext(this), (err, windowObj) => {
          if (err.code) {
            HiLog.e(TAG, `onAppear getLastWindow error: ${err?.code}, ${err?.message}`);
            return;
          }
          windowObj.setWindowSystemBarEnable([])
        })
      },
      modalTransition: ModalTransition.NONE,
      onDisappear: () => {
        this.imagePreData.imagePreviewHide();
        window.getLastWindow(getContext(this), (err, windowObj) => {
          if (err.code) {
            HiLog.e(TAG, `onDisappear getLastWindow error: ${err?.code}, ${err?.message}`);
            return;
          }
          windowObj.setWindowSystemBarEnable(['status', 'navigation'])
        })
      }
    })
  }
}

@Component
export struct MMVideo {
  item?: Mms;
  @Link textareaFocusable: boolean;
  @State index: number = 1;
  @State displayList: Array<Mms> = [];
  @StorageLink('isDisplayListChange') @Watch('displayListChanged') isDisplayListChange: boolean = false;

  displayListChanged() {
    if (this.displayList.length > 0 && this.item && !this.item.isRcs) {
      let resList = this.displayList.map(item => {
        return item.path;
      });
      this.index = resList.indexOf(this.item.path) + 1;
    }
  }

  aboutToAppear(): void {
    HiLog.i(TAG, 'MMVideo aboutToAppear');
    if (this.item) {
      let resList = this.displayList.map(item => {
        return item.path;
      });
      this.index = resList.indexOf(this.item.path) + 1;
    }
  }
  build() {
    Row() {
      Stack({ alignContent: Alignment.BottomStart }) {
        if (this.item?.isRcs && (this.item?.videoThumbnailUri || this.item.pixelMap)) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(this.item.videoThumbnailUri || this.item.pixelMap)
              .width(80)
              .height(80)
              .draggable(false)
              .borderRadius(8)

            Image($rawfile('icon/video_height28.png'))
              .width(80)
              .height(28)
              .borderRadius({ bottomLeft: 8, bottomRight: 8 })
              .draggable(false)
          }
        } else if (this.item?.pixelMap || this.item?.videoThumbnailUri) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(this.item?.pixelMap || this.item?.videoThumbnailUri)
              .width(80)
              .height(80)
              .draggable(false)
              .borderRadius(8)

            Image($rawfile('icon/video_height28.png'))
              .width(80)
              .height(28)
              .borderRadius({ bottomLeft: 8, bottomRight: 8 })
              .draggable(false)
          }
        } else {
          Stack() {
            Row() {
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .width(80)
            .height(80)
            .borderRadius(16)
            .backgroundColor('#000000')
            .opacity(0.05)
            Image($rawfile('icon/video_failed_24.svg'))
              .width(24)
              .height(24)
              .draggable(false)
              .fillColor($r('sys.color.ohos_id_color_secondary'))
          }
        }

        Image($rawfile('icon/play_video.svg'))
          .width(16)
          .height(16)
          .draggable(false)
          .margin({ bottom: 5, left: 5 })
      }
    } .onClick(() => {
      this.textareaFocusable = false;
      if (this.item !== undefined) {
        ImageUtil.openVideoPreview(this.item);
      }
      // Click the attached video(DOT)
      mmsTypeParams.TYPE_STATUS = 3;
      if (this.item?.isRcs) {
        mmsTypeParams.SMS_STATUS = 2;
      } else {
        mmsTypeParams.SMS_STATUS = 1;
      }
      DotUtil.getInstance().reportEvent(mmsTypeParams, dotCommon.eventName.TOUCH_ATTACHMENTS_EVENT);
    })
    .accessibilityText(getContext(this)
      .resourceManager
      .getStringSync($r('app.string.msg_attachments').id) + this.index)
    .accessibilityRole(AccessibilityRoleType.VIDEO)
    .id(this.item?.path)
  }
}

/**
 * The UI for Location Message show in the attachment area.
 */
@Component
export struct MMMap {
  item?: Mms;
  @Link textareaFocusable: boolean;
  @StorageLink('isGetStaticMapImage') @Watch('getStaticMapImage') isGetStaticMapImage: boolean = false;
  @Consume storagePixelMap: HashMap<string, PixelMap>;
  @State imagePixmap?: PixelMap = undefined;
  @State path: string = '';
  @State locationImageUri: string = '';

  aboutToAppear(): void {
    this.path = this.item?.path || '';
    if (this.item?.path) {
      try {
        this.locationImageUri = fileUri.getUriFromPath(this.item.path);
      } catch (e) {
        HiLog.e(TAG, `aboutToAppear getUriFromPath: ${e?.code} ${e?.message}`);
      }
    }
  }

  aboutToDisappear(): void {
    this.imagePixmap?.release();
  }

  getStaticMapImage() {
    HiLog.i(TAG, 'getStaticMapImage isGetStaticMapImage:' + this.isGetStaticMapImage);
    if (this.isGetStaticMapImage) {
      this.getImagePixmap(this.path);
    }
  }

  getImagePixmap(path: string) {
    if (!path) {
      HiLog.i(TAG, 'getImagePixmap path is null');
      return;
    }
    let hasStorage: boolean = this.storagePixelMap.hasKey(path);
    if (hasStorage) {
      this.imagePixmap = this.storagePixelMap.get(path) as PixelMap;
    }
    if (!hasStorage || !this.imagePixmap) {
      ImageUtil.convertImageToPixmap(path).then((value: image.PixelMap) => {
        this.imagePixmap = value;
      });
    }
  }

  @Builder
  SetPixelMap() {
    if (this.item?.pixelMap || this.imagePixmap || this.locationImageUri) {
      Stack({ alignContent: Alignment.BottomStart }) {
        // Location Message's image.
        Image(this.item?.pixelMap || this.imagePixmap || this.locationImageUri)
          .width(80)
          .height(80)
          .borderRadius(8)
          .id('image_map')

        Image($rawfile('icon/icon_mask_layer.svg'))
          .width(80)
          .height(40)
          .borderRadius({ bottomLeft: 8, bottomRight: 8 })
          .draggable(false)
      }
    } else {
      Stack() {
        Stack()
          .width(80)
          .height(80)
          .borderRadius(8)
          .backgroundColor($r('sys.color.comp_background_secondary'))

        SymbolGlyph($r('sys.symbol.local_fill'))
          .fontColor([$r('sys.color.ohos_id_color_warning')])
          .width('12vp')
          .height('12vp')
          .draggable(false)
          .fontSize('12vp')
      }
    }
  }

  build() {
    Column() {
      Row() {

          Stack({ alignContent: Alignment.BottomStart }) {
          this.SetPixelMap()
          // Text for address info
          Text(this.item?.address?.address)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width(80)
            .maxLines(1)
            .fontSize($r('sys.float.ohos_id_text_size_caption'))
            .fontColor(Color.White)
            .padding({ left: 4, right: 4, bottom: 4 })
            .id('text_location')
        }
        }
        .onClick(() => {
        this.textareaFocusable = false;
        // Click to navigate the address.
        if (this.item?.address) {
          LocationUtil.queryLocation(this.item?.address)
        }
      })
      if (this.item?.pageCount) {
        Text(`${this.item?.pageNum ?? 1}/${this.item.pageCount}`)
          .fontSize($r('sys.float.ohos_id_text_size_caption1'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
      }
    }.alignItems(HorizontalAlign.End)
  }
}