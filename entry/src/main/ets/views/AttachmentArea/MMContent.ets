/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import RcsDataPreferences from '../../utils/RcsDataPreferences';
import image from '@ohos.multimedia.image';
import commonData from '../../data/commonData';
import ConversationController, { mmsListType } from '../../pages/conversation/conversationController';
import { AudioPlayerService } from '../../service/AudioPlayerService';
import HashMap from '@ohos.util.HashMap';
import ImageUtil from '../../utils/ImageUtil';
import MmsUtil from '../../utils/MmsUtil';
import { Mms, mmsInfo, AddressInfo, RcsSendLoc, LocationType, PageJumpType,
  TransmitPageJumpParam } from '../../utils/TypesUtils';
import HiLog from '../../utils/HiLog';
import fileuri from '@ohos.file.fileuri';
import lazy fs from '@ohos.file.fs';
import I18n from '@ohos.i18n';
import radio from '@ohos.telephony.radio';
import Configuration, { LocaleResponse } from '@system.configuration';
import Intl from '@ohos.intl';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import prompt from '@ohos.promptAction';
import dateUtil, { DateUtil } from '../../utils/DateUtil';
import MMAttachmentAreaController from './MMAttachmentAreaController';
import MMPictureController from './MMPictureController';
import emitter from '@ohos.events.emitter';
import lazy { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import DotUtil from '../../utils/MmsDot/DotUtils';
import { dotNoNeedParmas, mmsTypeParams, seleteParam } from '../../utils/MmsDot/DotCommon';
import dotCommon from '../../utils/MmsDot/DotCommon';
import lazy unifiedDataChannel from '@ohos.data.unifiedDataChannel';
import LocationUtil from '../../utils/LocationUtil';
import { VibrationUtils } from '../../utils/VibrationUtils';
//import { filePreview } from '@kit.PreviewKit';
import FavoriteController from '../../pages/favoritepage/favoriteController'
import { GlobalContextKey } from '../../data/commonData';
import LooseObject from '../../data/LooseObject';
import myCommon from '@ohos.app.ability.common';
import AdvancedSettingsController from '../../pages/settings/advancedSettings/advancedSettingsController';
import { ImagePreviewData, imagePreviewBuilder } from './ImagePreviewBuilder';
import { LengthMetrics, LengthUnit } from '@kit.ArkUI';
import FileUtil, { formatFileSize } from '../../utils/FileUtil';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { MMContentVcard } from './MMContentVcard'
import FileUtils from '../../utils/FileUtil';
import TransmitMsgController from '../../pages/transmitmsg/transmitMsgController';
import { MmsContentMap } from '../MmsMap/MmsContentMap';
import DeviceUtil from '../../utils/DeviceUtil';
import { FontSizeScale } from '../../data/Constant';

const TAG = 'MMContent';
const RCS_IMAGE_MESSAGE_WIDTH = 168;
const PART_CT = '10000';
export const MAX_DURATION = 142;

const RCS_TYPE_NEED_SAVE_TO_FILE_MANAGER = [
  commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO,
  commonData.ENHANCED_INFO_ITEM_TYPE.FILE,
  commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE,
]
const CHECK_IMAGE_EVENT: emitter.InnerEvent = {
  eventId: 2,
  priority: emitter.EventPriority.HIGH
}

@Component
export struct MmsContent {
  @State mConversationCtrl: ConversationController = ConversationController.getInstance();
  @Prop scrollEndIndex: number = -1
  @Prop scrollStartIndex: number = -1
  private listScroller: Scroller = this.mConversationCtrl.scroller;
  conversationRcsDataPreferences: RcsDataPreferences = RcsDataPreferences.getInstance();
  @State mAttachAreaCtrl: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
  @State mPictureCtrl: MMPictureController = MMPictureController.getInstance();
  mmsInfo?: mmsInfo;
  item: Array<Mms> = [];
  @Provide show: boolean = true;
  @Provide index: number = 1;
  private context = getContext(this) as myCommon.UIAbilityContext;
  @Provide mFavoriteCtrl: FavoriteController = FavoriteController.getInstance();
  @Provide multiSelectFlag: Visibility = Visibility.None;
  @Prop contentType: number = -1;
  @Prop isRcs?: boolean = false;
  bubbleTextDirection: string = 'left';
  itemIndex: number = -1;
  @State firstItem: Mms = {
    duration: '',
    type: -1,
    path: '',
    name: ''
  };
  @State ct : string = '';
  @Link conversationCtrl: ConversationController;
  private delConversionController?: CustomDialogController;
  @State imagePath?: PixelMap = undefined;
  private videoWidth: number = 151;
  private videoHeight: number = 202;
  @Link showMMContentPicker: boolean;
  @State showMenu: boolean = false;
  @State isDragging: boolean = false;
  private content: string = ''; // Bubble Display Content
  @ObjectLink mmsItem: mmsListType;
  @Consume storagePixelMap: HashMap<string, PixelMap>;
  @Link isTouch: boolean
  @State screenWidth: number = 0;
  @State isImageOrVideo: boolean = false;
  @State isHidden: boolean = false;//长按弹框弹起的时候隐藏底层视图
  @State slideDataList: Array<Mms> = []; // 幻灯片预览数据源
  @State threadId: number = 0;
  @State isZeroSlide: boolean = false; // 当前幻灯片彩信是否为0kb信息
  @StorageLink('windowWidth') deviceWidth: number = 0;
  private changeConversationSelectedNumberAndCheckAllBool: () => void = () => {};
  private abnormalSceneController?: CustomDialogController;
  private mmsContentBackgroundColor?: Resource | string; // Bubble background color
  private isVcard: boolean = false;
  private isMap: boolean = false;
  @Consume('pageInfos') pageInfos: NavPathStack;
  transmitPageJumpParam: null | TransmitPageJumpParam = null;
  @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();
  /**
   * 当前消息是否是彩信位置消息
   */
  @State isMmsMapMessage: boolean = false;

  async saveImageToPhotoAlbums(sandBoxPath: string) {
    HiLog.i(TAG, 'saveImagePhotoAlbums');
    let context = (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);
    let photoAccessHelper = await import('@ohos.file.photoAccessHelper');
    let phAccessHelper = photoAccessHelper.default.getPhotoAccessHelper(context);
    try {
      //get fileSandbox.fd
      let fileSandbox = await fs.open(sandBoxPath, fs.OpenMode.READ_ONLY);
      let size = fs.statSync(fileSandbox.fd).size;
      let fileSandboxBuffer = new ArrayBuffer(size);
      fs.readSync(fileSandbox.fd, fileSandboxBuffer);
      //write to albums
      let uri = await phAccessHelper.createAsset(photoAccessHelper.default.PhotoType.IMAGE, 'jpg');
      let file = await fs.open(uri, fs.OpenMode.READ_WRITE);
      await fs.write(file.fd, fileSandboxBuffer);
      await fs.close(fileSandbox.fd);
      await fs.close(file.fd);
      prompt.showToast({ message: $r('app.string.Saved_to_album'), duration: 200 });
    } catch (err) {
      let error = err as BusinessError;
      HiLog.i(TAG, `saveImageToPhotoAlbums: ${error}`);
    }
  }

  async saveVideoToAlbums(sandBoxPath: string) {
    HiLog.i(TAG, 'saveVideoAlbums');
    let photoAccessHelper = await import('@ohos.file.photoAccessHelper');
    let context = (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);
    let phAccessHelper = photoAccessHelper.default.getPhotoAccessHelper(context);
    try {
      //get fileSandbox.fd
      let fileSandbox = await fs.open(sandBoxPath, fs.OpenMode.READ_ONLY);
      let size = fs.statSync(fileSandbox.fd).size;
      let fileSandboxBuffer = new ArrayBuffer(size);
      fs.readSync(fileSandbox.fd, fileSandboxBuffer);
      //write to albums
      let uri = await phAccessHelper.createAsset(photoAccessHelper.default.PhotoType.VIDEO, 'mp4');
      let fileAlbums = await fs.open(uri, fs.OpenMode.READ_WRITE);
      try {
        await fs.write(fileAlbums.fd, fileSandboxBuffer);
      } catch (err) {
        HiLog.e(TAG, `fs.write:${err}`);
      }
      await fs.close(fileSandbox);
      await fs.close(fileAlbums);
      prompt.showToast({ message: $r('app.string.Saved_to_album'), duration: 200 });
      HiLog.i(TAG, `uri:${uri}`)

    } catch (err) {
      let error = err as BusinessError
      HiLog.e(TAG, `saveVideoToAlbums: ${error}`);
    }
  }

  checkIfCanTransmit(): boolean {
    let isAudio: boolean = MmsUtil.isAudio(this.firstItem?.type); // Check if it is audio
    let isVideo: boolean = false
    let isVideoCanTransmit: boolean = false
    if (this.mmsItem.isRcs === 1) {
      try {
        isVideo = Boolean(this.mmsItem.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO);
        isVideoCanTransmit = isVideo && this.conversationCtrl.isRcsMsgSourceFileDownloaded;
      } catch (e) {
        HiLog.e(TAG, 'checkIfCanTransmit isVideoCanTransmit error: ' + JSON.stringify(e))
      }
    }
    let hasContent: boolean = (this.mmsInfo && this.mmsInfo?.content) ? true : false; // Check if there is text
    let audioCanTransmit: boolean = !isAudio || (isAudio && hasContent); // Check if the audio can be forwarded
    let checkNotOrigin: boolean = (this.mmsInfo?.contentType !== commonData.MMS_CONTENT_TYPE.ORIGIN) ? true : false;
    let checkIdDownload: boolean = this.firstItem.type !== -1 ? true : false
    return (checkIdDownload && (audioCanTransmit || checkNotOrigin)) || isVideoCanTransmit
  }

  @Builder
  loadMenuBuilderAuto() {
    if (this.checkIfCanTransmit()) {
      this.msgTransmit()
    }
    if (this.isVcard || this.isMap) {
      MenuItem(this.menuItemContent($r('app.string.save')))
        .onClick(() => {
          if (this.isVcard) {
            let saveObject = this.item.find(v => (v.type === commonData.MM_ATTACHMENT_TYPE.VCARD));
            if (!saveObject) {
              HiLog.e(TAG, 'onSaveMenuClick: Failed to obtain the saved data.');
              return;
            }
            if (!saveObject.name.endsWith('.vcf')) {
              saveObject.name = saveObject.name + '.vcf'
            }
            FileUtil.saveFileToFileManager(this.context, saveObject.path, saveObject.name);
            mmsTypeParams.TYPE_STATUS = commonData.int.TYPE_STATE_VCARD;
            DotUtil.getInstance().reportEvent(mmsTypeParams, dotCommon.eventName.LONG_PRESS_SAVE_MMS);
            return
          } else if (this.isMap) {
            let saveObject = this.item.find(v => (v.type === commonData.MM_ATTACHMENT_TYPE.MAP));
            if (!saveObject) {
              HiLog.e(TAG, 'onSaveMenuClick: Failed to obtain the saved data.');
              return;
            }
            this.saveMmsAttachment(saveObject)
          }
        })
        .visibility(this.isMap || this.isVcard ? Visibility.Visible : Visibility.None)
    } else {
      MenuItem() {
        SaveButton({ text: SaveDescription.SAVE, buttonType: ButtonType.Normal })
          .backgroundColor(Color.Transparent)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .borderRadius($r('sys.float.corner_radius_level8'))
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
          .padding({ left: '12vp' })
          .onClick(() => {
            let saveObject: Mms | undefined;
            if (this.item.length > 1) {
              saveObject = this.item[1]
            } else {
              saveObject = this.item[0]
            }

            if (!saveObject) {
              HiLog.e(TAG, 'onSaveMenuClick: Failed to obtain the saved data.');
              return;
            }

            if (saveObject.type === commonData.MM_ATTACHMENT_TYPE.IMAGE ||
              saveObject.type === commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE) {
              this.saveImageToPhotoAlbums(saveObject.path);
              // Save MMS(DOT)
              mmsTypeParams.TYPE_STATUS = 1;
              DotUtil.getInstance().reportEvent(mmsTypeParams, dotCommon.eventName.LONG_PRESS_SAVE_MMS);
            } else if (saveObject.type === commonData.MM_ATTACHMENT_TYPE.VIDEO ||
              saveObject.type === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
              this.saveVideoToAlbums(saveObject.path);
              // Save MMS(DOT)
              mmsTypeParams.TYPE_STATUS = 2;
              DotUtil.getInstance().reportEvent(mmsTypeParams, dotCommon.eventName.LONG_PRESS_SAVE_MMS);
            } else if (saveObject.type === commonData.MM_ATTACHMENT_TYPE.VCARD) {
              FileUtil.saveFileToFileManager(this.context, saveObject.path, saveObject.name);
              // Save MMS(DOT)
              mmsTypeParams.TYPE_STATUS = 3;
              DotUtil.getInstance().reportEvent(mmsTypeParams, dotCommon.eventName.LONG_PRESS_SAVE_MMS);
            }
          })
      }
      .visibility(this.isImageOrVideo ? Visibility.Visible : Visibility.None)
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
    }
    if (this.checkIfCanCopyOrSelectText()) {
      this.copyButton()
      this.chooseTextButton()
    }
  }

  saveMmsAttachment(saveObject: Mms) {
    if (saveObject.type === commonData.MM_ATTACHMENT_TYPE.MAP) {
      FileUtils.saveFileToFileManager(this.context, saveObject.path, saveObject.name)
    }
  }

  @Builder
  chooseTextButton() {
    MenuItem(this.menuItemContent($r('app.string.msg_select_text')))
      .onClick(() => {
        this.conversationCtrl.longPressSelected(this.context, 3);
        this.showMenu = false;
        // 长按功能弹窗打点
        seleteParam.SELECT_STATE = 6;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_LONGPRESS_EVENT);
      })
  }

  @Builder
  copyButton() {
    MenuItem(this.menuItemContent($r('app.string.msg_copy')))
      .onClick(() => {
        this.conversationCtrl.longPressSelected(this.context, 0);
        this.showMenu = false;
        // 长按功能弹窗打点
        seleteParam.SELECT_STATE = 5;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_LONGPRESS_EVENT);
      })
  }

  checkIfCanCopyOrSelectText() {
    if (this.isMmsMapMessage) {
      return true;
    }
    return false
  }

  @Builder
  msgTransmit() {
    MenuItem(this.menuItemContent($r('app.string.msg_transmit')))
      .onClick(() => {
        AppStorage.setOrCreate('isFromMenu', true);
        this.conversationCtrl.longPressSelected(this.context, 1, (type, pageName, params, pageInfos) => {
          this.transmitPageJumpParam = {
            type: type,
            pageName: pageName,
            params: params
          }
        });
      })
  }

  @Builder
  loadMenuBuilderDivider(){
    Divider()
      .color($r('sys.color.ohos_id_color_list_separator'))
      .height($r('app.float.settings_divider_strokeWidth'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({
        left: $r('app.float.conversation_item_press_Shadow_padding_left'),
        right: $r('app.float.conversation_item_press_Shadow_padding_left')
      })
  }

  @Builder
  menuItemContent(content: ResourceStr) {
    Row() {
      Text(content)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .lineHeight('19fp')
        .fontColor($r('sys.color.font_primary'))
        .width('100%');
    }
    .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
    .padding('12vp')
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  MenuBuilder() {
    Menu() {
      MenuItem(this.menuItemContent($r('app.string.select_more')))
        .onClick(() => {
          this.conversationCtrl.longPressSelected(this.context, 4)
          this.changeConversationSelectedNumberAndCheckAllBool();
          this.showMMContentPicker = false;
          seleteParam.SELECT_STATE = 5;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_LONGPRESS_EVENT);
        })
      if (this.mmsItem && this.mmsItem.sendStatus != commonData.int.RCS_RECEIVING_CANCEL &&
        this.mmsItem.sendStatus != commonData.int.RCS_RECEIVING && !this.isZeroSlide) {
        this.loadMenuBuilderAuto()
      }
      this.menuDelete()
    }
    .width('224vp')
    .menuItemDivider({
      strokeWidth: LengthMetrics.px(1),
      color: $r('sys.color.ohos_id_color_list_separator'),
      mode: DividerMode.EMBEDDED_IN_MENU,
      startMargin: { value: 12, unit: LengthUnit.VP },
      endMargin: { value: 12, unit: LengthUnit.VP },
    })
  }

  @Builder
  menuDelete(){
    MenuItem(this.menuItemContent($r('app.string.delete')))
      .onClick(() => {
        this.conversationCtrl.longPressSelected(this.context, 2);
        if (this.mmsInfo?.id) {
          this.conversationCtrl.rcsMsgId = this.mmsInfo?.id;
        }
        setTimeout(() => {
          this.delConversionController?.open();
        }, 10);
      })
  }

  setMenuHeight() {
    if (this.checkIfCanTransmit() && this.isImageOrVideo) {
      return '192vp'
    } else if (!this.checkIfCanTransmit() && !this.isImageOrVideo) {
      return '96vp'
    } else {
      return '144vp'
    }
  }

  setMenuButtonHeight() {
    if (this.checkIfCanTransmit() && this.isImageOrVideo) {
      return '25%'
    } else if (!this.checkIfCanTransmit() && !this.isImageOrVideo) {
      return '50%'
    } else {
      return '33.3%'
    }
  }

  aboutToAppear() {
    if (!this.context) {
      HiLog.w(TAG, 'Initialize getcontext is null!')
      this.context = getContext(this) as myCommon.UIAbilityContext;
      if (!this.context) {
        HiLog.e(TAG, 'retry getcontext failed,context is null!')
      }
    }
    this.threadId = this.conversationCtrl?.threadId;
    let mmsSource: Mms[] = [];
    this.ct = this.mmsItem.ct;
    if (this.isRcs && this.item && (this.item[0]?.type === commonData.ENHANCED_INFO_ITEM_TYPE.VCARD ||
      this.item[1]?.type === commonData.ENHANCED_INFO_ITEM_TYPE.VCARD)) {
      let mmsSource: Mms[] = this.item.filter((item) =>!MmsUtil.isSmil(item.type));
      if (mmsSource.length > 0) {
        this.firstItem = mmsSource[0];
      }
    } else {
      // 处理无smil文件的video和audio类型
      if (this.item && this.item.length === 1) {
        if (MmsUtil.isAudio(this.item[0].type) || MmsUtil.isVideo(this.item[0].type)) {
          this.contentType = commonData.MMS_CONTENT_TYPE.ORIGIN
        }
      }
      mmsSource = this.isRcs ? MmsUtil.deleteRcsSmil(this.item) : MmsUtil.deleteSmil(this.item);
      if (mmsSource.length > 0) {
        this.firstItem = mmsSource[0];
      }
      if(MmsUtil.isSlideType(this.contentType)){
        this.slideDataList = MmsUtil.generateSlidePreviewData(this.item);
      } else if (!this.isRcs) {
        this.isMmsMapMessage = mmsSource.some(v => (v.type === commonData.MM_ATTACHMENT_TYPE.MAP));
      }
    }
    HiLog.i(TAG, 'MMContent this.isMmsMapMessage ' + this.isMmsMapMessage);

    let windowWidth = AppStorage.get('windowWidth') as number;
    this.isImageOrVideo = this.checkIsImageOrVideo();
    this.isVcard = MmsUtil.isVcard(this.firstItem?.type) && this.contentType === commonData.MMS_CONTENT_TYPE.ORIGIN
    this.isMap = this.isMmsMapMessage && this.contentType === commonData.MMS_CONTENT_TYPE.ORIGIN;
    if (windowWidth) {
      this.screenWidth = vp2px(windowWidth) / 2;
    }
  }
// check is image or video
  checkIsImageOrVideo(): boolean {
    let isVideo: boolean = false
    let isVideoCanTransmit: boolean = false
    if (this.mmsItem.isRcs === 1) {
      try {
        isVideo = MmsUtil.isVideo(this.mmsItem.senderNumber ? this.item[0].type : this.item[1].type)
        isVideoCanTransmit = isVideo && this.mmsInfo?.sendStatus === commonData.int.SEND_MESSAGE_SUCCESS;
      } catch (e) {
        HiLog.e(TAG, 'checkIfCanTransmit isVideoCanTransmit error: ' + JSON.stringify(e))
      }
    }
    return (this.firstItem.type !== -1 &&
      ((MmsUtil.isVideo(this.firstItem?.type) || MmsUtil.isImage(this.firstItem?.type)) &&
        this.contentType === commonData.MMS_CONTENT_TYPE.ORIGIN)) || isVideoCanTransmit;
  }

  build() {
      Row() {
        if (this.mmsInfo?.mmsSource && this.mmsInfo?.mmsSource.length <= 2 &&
          this.mmsInfo?.mmsPdu != '' &&
        [commonData.int.MMS_DOWNLOADING, commonData.int.MMS_DOWNLOAD_FAILED, commonData.int.MMS_NOT_DOWNLOAD]
          .includes(Number(this.mmsInfo?.msgState))) {
          MMContentDownLoadMMs({
            mmsInfo: this.mmsInfo,
            item: this.firstItem,
            bubbleTextDirection: this.bubbleTextDirection,
            conversationCtrl: this.conversationCtrl,
            showMenu: this.showMenu
          })
        } else {
          if (this.contentType === commonData.MMS_CONTENT_TYPE.ORIGIN) {
            if (this.isMmsMapMessage) {
              MmsContentMap({
                isCallFrom: 'MMContent',
                mmsItem: this.mmsItem,
                itemIndex: this.itemIndex,
                conversationCtrl: this.conversationCtrl,
                showMenu: this.showMenu,
                isAdvancedSecurity: this.mmsInfo?.isAdvancedSecurity,
                isFromTransmit: false,
                bubbleTextDirection: this.bubbleTextDirection,
                bubbleTextBorderRadius: [2, 16],
                bubbleTextBackgroundColor: this.bubbleTextDirection === 'left' ? $r('sys.color.ohos_id_color_card_bg') :
                $r('app.color.brand'),
                changeConversationSelectedNumberAndCheckAllBool: this.changeConversationSelectedNumberAndCheckAllBool
              })
            } else if (MmsUtil.isAudio(this.firstItem?.type)) {
              MMContentAudio({
                item: this.firstItem, bubbleTextDirection: this.bubbleTextDirection,
                showMenu: this.showMenu
              })
            } else if (MmsUtil.isImage(this.firstItem?.type)) {
              MMContentImage({
                ct: this.ct,
                item: this.firstItem,
                conversationCtrl: this.conversationCtrl,
                isTouch: $isTouch,
                showMenu: this.showMenu,
                isDragging: this.isDragging
              })
            } else if (MmsUtil.isVideo(this.firstItem?.type)) {
              MMContentVideo({
                item: this.firstItem,
                showMenu: this.showMenu
              })
            } else if(MmsUtil.isVcard(this.firstItem?.type)) {
              MMContentVcard({
                item: this.firstItem,
                showMenu: this.showMenu,
                mmsContentBackgroundColor:this.mmsContentBackgroundColor,
                bubbleTextDirection:this.bubbleTextDirection,
                itemIndex: this.itemIndex,
                changeConversationSelectedNumberAndCheckAllBool: () => {
                  this.changeConversationSelectedNumberAndCheckAllBool()
                },
              })
            }
          } else if (MmsUtil.isSlideHasImage(this.contentType)) {
            MMContentSlideImage({
              mmsItem: this.mmsItem,
              showMenu: this.showMenu,
              slideDataList: this.slideDataList,
              threadId: this.threadId,
              mmsIndex: this.itemIndex
            })
          } else if (MmsUtil.isSlideNoImage(this.contentType) ||
            this.mmsItem.msgTitle !== '' ||
          (this.mmsInfo?.mmsSource && this.mmsInfo?.mmsSource?.length > 2)) {
          MMContentSlideNoImage({
            isWhite: false,
            isLeft: false,
            showMenu: this.showMenu,
            mmsItem: this.mmsItem,
            slideDataList: this.slideDataList,
            threadId: this.threadId,
            mmsIndex: this.itemIndex,
          })
        }
      }
    }
    .accessibilityLevel('no')
    .justifyContent((this.bubbleTextDirection === 'right') ? FlexAlign.End : FlexAlign.Start)
    .parallelGesture(
      GestureGroup(GestureMode.Exclusive,
        LongPressGesture({ repeat: false, duration: 500 })
          //Touch and hold the action will be triggered continuously.
          .onAction(() => {
            if (this.slideDataList.find(item => item.ct === PART_CT)) {
              this.isZeroSlide = true;
            }
            if (!this.conversationCtrl.isSelectStatus) {
              this.conversationCtrl.mmsListLongPress(this.itemIndex)
              this.conversationCtrl.judgeTheRcsMsgSourceFileDownloaded(this.mmsItem)
              this.showMenu = true
              VibrationUtils.onceVibration(commonData.VIBRATIONEFFECT.LONG_PRESS_MEDIUM)
            }
            DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.CONTENT_LONGPRESS);
          })
      ))
    .bindContextMenu(this.showMenu, this.MenuBuilder(), {
      preview: MenuPreviewMode.IMAGE,
      previewAnimationOptions: {
        scale: [0.95, 1.1]
      },
      layoutRegionMargin: {
        right: DeviceUtil.isPC() ? 24 : DeviceUtil.isTablet() ? this.padMargin : 16,
        left: DeviceUtil.isPC() ? 24 : DeviceUtil.isTablet() ? this.padMargin : 16
      },
      placement: this.bubbleTextDirection == 'right' ? Placement.BottomRight : Placement.BottomLeft,
      aboutToAppear: () => {
        this.transmitPageJumpParam = null;
      },
      onAppear: (() => {
        HiLog.w(TAG, `select msg id is: ${this.mmsItem.id}`)
        if (!this.conversationCtrl.isSelectStatus) {
          this.conversationCtrl.mmsListLongPress(this.itemIndex);
          this.showMenu = true;
          this.isHidden = true;
        }
      }),
      aboutToDisappear:(()=>{
        if (this.itemIndex === this.scrollStartIndex) {
          this.listScroller.scrollToIndex(this.itemIndex, false, ScrollAlign.START);
        } else if (this.itemIndex === this.scrollEndIndex) {
          this.listScroller.scrollToIndex(this.itemIndex, false, ScrollAlign.END);
        }
        this.showMenu = false
        this.isHidden = false;
      }),
      onDisappear: (() => {
        this.isZeroSlide = false;
        this.conversationCtrl.isRcsMsgSourceFileDownloaded = false;
        if (this.transmitPageJumpParam) {
          TransmitMsgController.handleTransmitPageJump(this.transmitPageJumpParam, this.pageInfos);
          this.transmitPageJumpParam = null;
        }
      })
    })
    .visibility(this.isHidden ? Visibility.Hidden : Visibility.Visible)
    .draggable(MmsUtil.isImage(this.firstItem?.type))
    .onDragStart((event: DragEvent) => {
      HiLog.i(TAG, 'MMContentImage onDragStart.')
      this.showMenu = false;
      this.isDragging = true;
      let dragImageData = new unifiedDataChannel.Image();
      dragImageData.imageUri = fileuri.getUriFromPath(this.firstItem.path);
      let data = new unifiedDataChannel.UnifiedData(dragImageData);
      event.setData(data)
      VibrationUtils.onceVibration(commonData.VIBRATIONEFFECT.DRAG)
    })
    .onDragLeave((event?: DragEvent) => {
      HiLog.i(TAG, 'MMContentImage onDragLeave.');
    })
    .onDragEnd((event?: DragEvent) => {
      HiLog.i(TAG, 'MMContentImage onDragEnd.');
      this.isDragging = false;
    })
  }

}

@Component
export struct MMContentAudio {
  audioPlayerService: AudioPlayerService = AudioPlayerService.getInstance();
  item: Mms = { duration: '', type: -1, path: '', name: '' };
  bubbleTextDirection: string = 'left';
  @State isOnAudio: boolean = false;
  @Prop showMenu: boolean = false;
  @StorageLink('stopAudio') @Watch('stopAudioAction') stopAudio: Mms = { duration: '', type: -1, path: '', name: '' };
  @StorageLink('isBackProcess') @Watch('isBackProcessChange') isBackProcess: boolean = false;
  plusWidth: number = 0;
  private textDirection: string = Configuration.getLocale().dir;

  aboutToAppear() {
    if (this.item.isOnAudio === undefined) {
      this.isOnAudio = false;
    } else {
      this.isOnAudio = this.item.isOnAudio
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

  getWidth() {
    let timeSecond = DateUtil.getDuration(this.item.duration);
    this.plusWidth = (commonData.int.MESSAGE_MAX_WIDTH - commonData.int.MMS_MESSAGE_MIN_WIDTH) / MAX_DURATION * timeSecond
    if ((this.plusWidth + commonData.int.MMS_MESSAGE_MIN_WIDTH) > commonData.int.MESSAGE_MAX_WIDTH) {
      this.plusWidth = commonData.int.MESSAGE_MAX_WIDTH - commonData.int.MMS_MESSAGE_MIN_WIDTH
    }
    return this.plusWidth + commonData.int.MMS_MESSAGE_MIN_WIDTH;
  }

  build() {
    Row() {
      if (this.bubbleTextDirection === 'left') {
        Text(this.item.duration)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Start)
          .margin(this.textDirection === 'rtl' ? { left: this.plusWidth } : { right: this.plusWidth })

        SymbolGlyph($r('sys.symbol.wave_3_left'))
          .rotate({ angle: 180 })
          .draggable(false)
          .margin( { start: LengthMetrics.vp(commonData.int.AUDIO_MESSAGE_MARGIN) })
          .fontSize($r('sys.float.Body_L'))
          .maxFontScale(FontSizeScale.HUGE_2)
          .fontColor([$r('sys.color.ohos_id_color_fourth')])
          .symbolEffect(new HierarchicalSymbolEffect(EffectFillStyle.ITERATIVE), this.isOnAudio)
      } else {
        SymbolGlyph($r('sys.symbol.wave_3_left'))
          .draggable(false)
          .margin( { end: LengthMetrics.vp(commonData.int.AUDIO_MESSAGE_MARGIN) })
          .fontSize($r('sys.float.Body_L'))
          .maxFontScale(FontSizeScale.HUGE_2)
          .fontColor([$r('sys.color.ohos_id_color_primary_contrary')])
          .symbolEffect(new HierarchicalSymbolEffect(EffectFillStyle.ITERATIVE), this.isOnAudio)

        Text(this.item.duration)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.End)
          .margin(this.textDirection === 'rtl' ? { right: this.plusWidth } : { left: this.plusWidth })
      }
    }
    .constraintSize({ maxWidth: commonData.int.AUDIO_MESSAGE_MAX_WIDTH, minWidth: commonData.int.MMS_MESSAGE_MIN_WIDTH})
    .borderRadius(this.textDirection === 'rtl' ?
      {
        topLeft: (this.bubbleTextDirection === 'right') ? 2 : 16,
        topRight: (this.bubbleTextDirection === 'right') ? 16 : 2,
        bottomLeft: 16,
        bottomRight: 16
      } :
      {
        topLeft: (this.bubbleTextDirection === 'right') ? 16 : 2,
        topRight: (this.bubbleTextDirection === 'right') ? 2 : 16,
        bottomLeft: 16,
        bottomRight: 16
      }
    )
    .lightUpEffect(this.showMenu ? 0.8 : 1)
    .backgroundColor(this.bubbleTextDirection === 'left' ? $r('sys.color.ohos_id_color_card_bg') : $r('app.color.brand'))
    .padding({ left: 12, top: 8, right: 12, bottom: 8 })
    .enabled(true)
    .accessibilityLevel('yes')
    .onClick(() => {
      if (!this.isOnAudio && !this.showMenu) {
        this.item.isOnAudio = true;
        this.isOnAudio = true;
      }
      if (!this.showMenu) {
        this.audioPlayerService.playAudio(this.item);
        // Clicking the MMS message content(DOT)
        mmsTypeParams.TYPE_STATUS = 3;
        DotUtil.getInstance().reportEvent(mmsTypeParams, dotCommon.eventName.VIEW_MMS_MSG);
      }
    })
    .accessibilityText(dateUtil.getAudioAccessibilityText(this.item.duration))
  }
}

/**
 * MMS image meassage
 */

PersistentStorage.persistProp('imgArr', '');
PersistentStorage.persistProp('imgPath', '');
@Component
export struct MMContentImage {
  @Consume('pageInfos') pageInfos: NavPathStack;
  audioPlayerService: AudioPlayerService = AudioPlayerService.getInstance();
  @State item: Mms = { duration: '', type: -1, path: '', name: '', ct: '' , isFraud: 0};
  @State ct: string = ''
  @State imagePixmap?: PixelMap = undefined;
  @State imagePath?: string = '';
  @Prop showMenu?: boolean = false;
  @Prop isDragging?: boolean = false;
  @Consume storagePixelMap: HashMap<string, PixelMap>;
  isFromTransmit: boolean = false;
  isFromSlide?: boolean = false;
  imgWidth: number = 0;
  imgHeight: number = 0;
  @Prop conversationCtrl?: ConversationController;
  @Link isTouch: boolean
  screenWidth: number = 0;
  @State imageWidth: number = 0;
  @State imageHeight: number = 0;
  @State isPop?: boolean = false;
  @StorageLink('curBp') curBp: string = commonData.STR.DEVICE_MOBILE_PHONE;
  @StorageLink('imgArr') imgArr: string = '';
  @StorageLink('imgPath') imgPath: string = '';
  @State imagePreData: ImagePreviewData = new ImagePreviewData()
  CHECK_IMAGE_EVENT: emitter.InnerEvent = {
    eventId: 2,
    priority: emitter.EventPriority.HIGH
  }
  @State mConversationCtrl: ConversationController = ConversationController.getInstance();
  @StorageLink('isAtMsgListBottom') isAtMsgListBottom: boolean = false;
  @StorageLink('windowWidth') @Watch('updateScreenWidth') windowWidth: number = 0;
  @StorageProp('currentColorMode')  currentMode: ConfigurationConstant.ColorMode =
    ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;

  aboutToAppear() {
    this.updateScreenWidth();
  }

  updateScreenWidth() {
    let windowWidth = AppStorage.get('windowWidth') as number;
    if (windowWidth) {
      this.screenWidth = this.curBp === commonData.STR.DEVICE_MOBILE_PHONE ?
        windowWidth : windowWidth / 2;
      this.imageWidth = this.screenWidth / 2;
      this.imageHeight = this.imageWidth;
    }
    this.getImagePixmap(this.item.path);
  }

  calculatedImageDisplaySize(width: number, height: number) {
    /*
     * 定义计算代码图片展示宽度和高度
     * 因为this.imageWidth 是@state属性，值一旦变化就会引起ui刷新重绘，因此采用先定义变量，计算完成之后再赋值。
     * 同理this.imageHeight
     * */
    this.imgWidth = width
    this.imgHeight = height
    let imageWidth = width
    let imageHeight = height
    if (width > height) {
      imageWidth = this.screenWidth / 2 * 4 / 3;
      imageHeight = imageWidth * height / width;
      if (imageHeight > this.screenWidth / 2) {
        imageHeight = this.screenWidth / 2
        imageWidth = imageHeight * width / height;
      }
    } else if (width == height) {
      imageWidth = this.screenWidth / 2;
      imageHeight = this.imageWidth;
    } else {
      imageHeight = this.screenWidth / 2 * 4 / 3;
      imageWidth = imageHeight * width / height;
      if (imageWidth > this.screenWidth / 2) {
        imageWidth = this.screenWidth / 2
        imageHeight = imageWidth * height / width;
      }
    }
    this.imageWidth = imageWidth
    this.imageHeight = imageHeight
  }

  getImagePixmap(path: string) {
    if (fs.accessSync(path)) {
      this.imagePath = fileuri.getUriFromPath(path);
    } else {
      HiLog.e(TAG, 'mms image path not exist')
    }
    let hasStorage: boolean = this.storagePixelMap.hasKey(path);
    HiLog.i(TAG, 'image hasStorage: ' + hasStorage)
    if (hasStorage) {
      this.imagePixmap = this.storagePixelMap.get(path) as PixelMap;
      let imageInfo: image.ImageInfo = this.imagePixmap.getImageInfoSync()
      if (imageInfo == undefined) {
        return;
      }
      this.calculatedImageDisplaySize(imageInfo.size.width, imageInfo.size.height)
      if (!this.imgPath.includes(path)) {
        this.imgArr = this.imgArr + '*' + JSON.stringify(imageInfo)
        this.imgPath = this.imgPath + '*' + path
      }
    }
    if (!hasStorage || !this.imagePixmap) {
      this.cacheWidthAndHeight(path);
      ImageUtil.convertImageToPixmap(path).then((value: image.PixelMap) => {
        this.imagePixmap = value;
        this.storagePixelMap.set(path, this.imagePixmap);
        let imageInfo: image.ImageInfo = this.imagePixmap.getImageInfoSync()
        this.calculatedImageDisplaySize(imageInfo.size.width, imageInfo.size.height)
      });
    }
  }
  // 通过缓存提前计算宽高
  private cacheWidthAndHeight(path: string) {
    let imgArr1 = this.imgArr.split('*');
    let pathArr = this.imgPath.split('*');
    let index: number = pathArr.indexOf(path);
    let imageWidth: number = imgArr1[index] ? JSON.parse(imgArr1[index])?.size.width : this.imageWidth;
    let imageHeight: number = imgArr1[index] ? JSON.parse(imgArr1[index])?.size.height : this.imageHeight;
    this.calculatedImageDisplaySize(imageWidth, imageHeight);
  }

  private faceTempIcon() {
    if(Number(this.currentMode) == ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      return 'icon/mms_star_shield_light.svg'
    } else {
      return ('icon/mms_star_shield_dark.svg')
    }
  }

  build() {
    if (this.imagePixmap || this.imagePath) {
      Stack() {
        Column() {
          Row() {
            Image(this.imagePixmap || this.imagePath)
              .width(this.isPop ? '100%' : this.imageWidth)
              .height(this.isPop ? '100%' : this.imageHeight)
              .border({
                width: '1px',
                radius: this.isFromSlide ? '16vp' : (this.isFromTransmit ? '8vp' : '12vp'),
                color: '#33A1A4B3'
              })
              .syncLoad(true)
              .lightUpEffect(1)
              .draggable(true)
              .objectFit(ImageFit.Contain)
              .enabled(!this.conversationCtrl?.isSelectStatus)
              .geometryTransition(this.imagePreData.getGeometryID(), { follow: true })
              .accessibilityLevel('yes')
              .onClick(() => {
                AppStorage.setOrCreate('stopAudio', {
                  duration: '',
                  type: -1,
                  path: '',
                  name: ''
                } as Mms);
                this.audioPlayerService.stopAudio();
                if (!this.isFromTransmit && !this.conversationCtrl?.isSelectStatus && !this.showMenu) {
                  AppStorage.setOrCreate('isFromMenu', true);
                  this.imagePreData.images = [(this.imagePixmap || this.imagePath) ?? '']
                  this.imagePreData.imagePreviewShow()
                  mmsTypeParams.TYPE_STATUS = 1;
                  DotUtil.getInstance().reportEvent(mmsTypeParams, dotCommon.eventName.VIEW_MMS_MSG);
                }
              })
              .onComplete(msg => {
                if (this.isAtMsgListBottom) {
                  emitter.emit(CHECK_IMAGE_EVENT);
                }
                if (!this.isTouch && !this.isFromTransmit) {
                  emitter.emit(this.CHECK_IMAGE_EVENT)
                  this.mConversationCtrl.scrollToEnd();
                }
              })
              .width(this.isPop ? '100%' : this.imageWidth)
              .height(this.isPop ? '100%' : this.imageHeight)
              .accessibilityLevel('yes')
              .accessibilityDescription(this.isFromSlide ?
              getContext(this).resourceManager.getStringSync($r('app.string.double_click_operation').id) : '')
              .parallelGesture(
                GestureGroup(GestureMode.Exclusive,
                  LongPressGesture({ repeat: false, duration: 500 })
                    .onAction(() => {})
                )
              )
          }
          if (this.item.isFraud == 1) {
            Row({space: 4}) {
              SymbolGlyph($r('sys.symbol.security_shield'))
                .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
                .fontColor([$r('sys.color.icon_primary'), $r('sys.color.icon_emphasize')])
                .fontSize(12)
              Text($r('app.string.ai_face_change_detect_content'))
                .fontSize(10)
                .fontFamily('HarmonyHeiTi')
                .fontWeight(FontWeight.Regular)
                .height(14)
                .lineHeight(12)
                .fontColor($r('sys.color.font_secondary'))
                .accessibilityLevel('yes')
            }.alignItems(VerticalAlign.Top)
            .margin({ left: 12, top: 9 })
          }
        }.alignItems(HorizontalAlign.Start)
        .accessibilityGroup(false)
        .justifyContent(FlexAlign.Start)
        .bindContentCover(this.imagePreData.showImage, imagePreviewBuilder(this.imagePreData), {
          modalTransition: ModalTransition.NONE,
          onDisappear: () => {
            this.imagePreData.imagePreviewHide();
          }
        })
      }.opacity(this.isDragging ? $r('sys.float.ohos_id_alpha_disabled') : 1)
    } else {
      Stack({ alignContent: Alignment.Center }) {
        Row() {
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .width(this.isFromTransmit ? '100%' : this.imageWidth)
        .height(this.isFromTransmit ? 64 : this.imageHeight)
        .borderRadius(this.isFromTransmit ? 8 : 16)
        .backgroundColor('#000000')
        .opacity(0.05)

        SymbolGlyph($r('sys.symbol.picture_damage'))
          .width(34)
          .height(34)
          .draggable(false)
          .fontSize('34vp')
          .fontColor([$r('sys.color.icon_secondary')])
      }.lightUpEffect(this.showMenu ? 0.8 : 1)
    }
  }
}

@Component
export struct MMContentVideo {
  @StorageLink('curBp') curBp: string = commonData.STR.DEVICE_MOBILE_PHONE;
  @StorageLink('imgPath') imgPathStr: string = '';
  @StorageLink('imgArr') imgArrStr: string = '';
  @StorageLink('isAtMsgListBottom') isAtMsgListBottom: boolean = false;
  item: Mms = { duration: '', type: -1, path: '', name: '' };
  @State imagePixmap?: PixelMap = undefined;
  @State imagePath?: string = '';
  @Prop showMenu:boolean = false;
  @Consume storagePixelMap: HashMap<string, PixelMap>;
  @State videoHeight: number = 0;
  @State videoWidth: number = 0;
  defaultVideoHeight: number = 0;
  defaultVideoWidth: number = 0;
  screenWidth: number = 0;
  isFromTransmit: boolean = false;

  aboutToAppear() {
    let windowWidth = AppStorage.get('windowWidth') as number;
    if (windowWidth > 0) {
      this.screenWidth = this.curBp === commonData.STR.DEVICE_MOBILE_PHONE ?
        windowWidth : windowWidth / 2;
    }
    this.getVideoImage();
  }

  calculatedVideoImageDisplaySize(videoOriginWidth: number, videoOriginHeight: number) {
    if (videoOriginWidth > videoOriginHeight) {
      this.videoWidth = this.screenWidth / 2 / 3 * 4;
      let videoHeightTemp = videoOriginHeight * this.videoWidth / videoOriginWidth;
      let maxVideoHeight = this.screenWidth / 2;
      if (videoHeightTemp >= maxVideoHeight) {
        this.videoHeight = maxVideoHeight;
      } else {
        this.videoHeight = videoHeightTemp;
      }
    } else if (videoOriginWidth == videoOriginHeight) {
      if (videoOriginWidth >= this.screenWidth / 2) {
        this.videoWidth = this.screenWidth / 2;
        this.videoHeight = this.videoWidth;
      } else {
        this.videoWidth = videoOriginWidth;
        this.videoHeight = videoOriginHeight;
      }
    } else {
      this.videoHeight = this.screenWidth / 2 / 3 * 4;
      let videoWidthTemp = videoOriginWidth * this.videoHeight / videoOriginHeight;
      let maxVideoWidth = this.screenWidth / 2;
      if (videoWidthTemp > maxVideoWidth) {
        this.videoWidth = maxVideoWidth;
      } else {
        this.videoWidth = videoWidthTemp;
      }
    }
  }

  getVideoImage() {
    if (this.item.path !== '') {
      let fileName = 'IMG_' + this.item.name.replace('mp4', 'jpeg');
      let index = this.item.path.lastIndexOf('/');
      let filePath = this.item.path.substring(0, index);
      let videoImgPath = filePath + '/' + fileName;
      if (fs.accessSync(videoImgPath)) {
        this.imagePath = fileuri.getUriFromPath(videoImgPath);
      }
      let hasStorage: boolean = this.storagePixelMap.hasKey(this.item.path);
      HiLog.i(TAG, 'video hasStorage: ' + hasStorage);
      if (hasStorage) {
        this.imagePixmap = this.storagePixelMap.get(this.item.path) as PixelMap;
        if (this.imgPathStr.includes(videoImgPath)) {
          this.cacheWidthAndHeight(videoImgPath);
        } else {
          let imageInfo: image.ImageInfo = this.imagePixmap.getImageInfoSync();
          if (!imageInfo) {
            return;
          }
          this.calculatedVideoImageDisplaySize(imageInfo.size.width, imageInfo.size.height);
          this.imgArrStr = this.imgArrStr + '*' + JSON.stringify(imageInfo);
          this.imgPathStr = this.imgPathStr + '*' + videoImgPath;
        }
      }
      if (!hasStorage || !this.imagePixmap) {
        if (this.imgPathStr.includes(videoImgPath)) {
          this.cacheWidthAndHeight(videoImgPath);
        }
        ImageUtil.getFetchFrameByTime(this.item.path, (pixMap: PixelMap) => {
          if (!pixMap) {
            return;
          }
          HiLog.i(TAG, 'getFetchFrameByTime response');
          this.imagePixmap = pixMap;
          this.storagePixelMap.set(this.item.path, this.imagePixmap);
          let imageInfo: image.ImageInfo = this.imagePixmap.getImageInfoSync();
          if (!this.imgPathStr.includes(videoImgPath)) {
            this.calculatedVideoImageDisplaySize(imageInfo.size.width, imageInfo.size.height);
          }
        });
      }
    }
  }

  // 通过缓存提前计算宽高
  private cacheWidthAndHeight(path: string) {
    let imgArr = this.imgArrStr.split('*');
    let pathArr = this.imgPathStr.split('*');
    let index: number = pathArr.indexOf(path);
    let videoOriginWidth: number = imgArr[index] ? JSON.parse(imgArr[index])?.size.width : this.videoWidth;
    let videoOriginHeight: number = imgArr[index] ? JSON.parse(imgArr[index])?.size.height : this.videoHeight;
    this.calculatedVideoImageDisplaySize(videoOriginWidth, videoOriginHeight);
  }

  build() {
    if (this.imagePath) {
      Stack({ alignContent: Alignment.Center }) {
        Image(this.imagePath)
        .width(this.videoWidth > 0 ? this.videoWidth : this.defaultVideoWidth)
        .height(this.videoHeight > 0 ? this.videoHeight : this.defaultVideoHeight)
        .draggable(false)
        .backgroundColor(this.imagePath ? Color.Transparent : Color.Black)
        .borderRadius(this.isFromTransmit ? 8 : 16)
        .objectFit(ImageFit.Fill)
        .onComplete(msg => {
          if (this.isAtMsgListBottom) {
            emitter.emit(CHECK_IMAGE_EVENT);
          }
        })

        SymbolGlyph($r('sys.symbol.play_circle'))
        .width(34)
        .height(34)
        .draggable(false)
        .fontSize('34vp')
        .fontColor([$r('sys.color.ohos_id_color_background')])
      }
      .lightUpEffect(this.showMenu ? 0.8 : 1)
      .borderRadius(this.isFromTransmit ? 8 : 16)
      .accessibilityLevel('yes')
      .onClick(() => {
        if (!this.showMenu && !this.isFromTransmit) {
          ImageUtil.openVideoPreview(this.item);
          mmsTypeParams.TYPE_STATUS = 2;
          DotUtil.getInstance().reportEvent(mmsTypeParams, dotCommon.eventName.VIEW_MMS_MSG);
        }
      })
      .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.accessibility_video').id))
    } else if (!this.imagePath && this.imagePixmap) {
      Stack({ alignContent: Alignment.Center }) {
        Image(this.imagePixmap)
        .width(this.videoWidth > 0 ? this.videoWidth : this.defaultVideoWidth)
        .height(this.videoHeight > 0 ? this.videoHeight : this.defaultVideoHeight)
        .draggable(false)
        .backgroundColor(this.imagePixmap ? Color.Transparent : Color.Black)
        .borderRadius(this.isFromTransmit ? 8 : 16)
        .objectFit(ImageFit.Fill)
        .onComplete(msg => {
          if (this.isAtMsgListBottom) {
            emitter.emit(CHECK_IMAGE_EVENT);
          }
        })

        SymbolGlyph($r('sys.symbol.play_circle'))
        .width(34)
        .height(34)
        .draggable(false)
        .fontSize('34vp')
        .fontColor([$r('sys.color.ohos_id_color_background')])
      }
      .lightUpEffect(this.showMenu ? 0.8 : 1)
      .borderRadius(this.isFromTransmit ? 8 : 16)
      .accessibilityLevel('yes')
      .onClick(() => {
        if (!this.showMenu && !this.isFromTransmit) {
          ImageUtil.openVideoPreview(this.item);
        }
      })
      .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.accessibility_video').id))
    } else {
      Stack({ alignContent: Alignment.Center }) {
        Row() {
        }
        .width(this.videoWidth > 0 ? this.videoWidth : this.defaultVideoWidth)
        .height(this.videoHeight > 0 ? this.videoHeight : this.defaultVideoHeight)
        .borderRadius(this.isFromTransmit ? 8 : 16)
        .backgroundColor($r('sys.color.black'))
        .opacity(0.05)

        SymbolGlyph($r('sys.symbol.resolution_video'))
        .width(34)
        .height(34)
        .draggable(false)
        .fontSize('34vp')
        .fontColor([$r('sys.color.icon_secondary')])
      }
      .lightUpEffect(this.showMenu ? 0.8 : 1)
      .borderRadius(this.isFromTransmit ? 8 : 16)
      .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.accessibility_video').id))
    }
  }

  private openPreview() {
    let uiContext = getContext(this);
    let index = this.item.path.lastIndexOf('/');
    let filePath = this.item.path.substring(0, index);
    let videoPath = filePath + '/' + this.item.name;
    if (fs.accessSync(videoPath)) {
      videoPath = fileuri.getUriFromPath(videoPath);
    }
    // let fileInfo: filePreview.PreviewInfo = {
    //   title: this.item.name,
    //   uri: videoPath,
    //   mimeType: 'video/mp4'
    // };
    GlobalContext.getContext().setObject(GlobalContextKey.IS_JUMP_TO_PREVIEW, true);
    // filePreview.openPreview(uiContext, fileInfo).then(() => {
    //   HiLog.i(TAG, 'previewMmsVideo success');
    // }).catch((err: BusinessError) => {
    //   HiLog.i(TAG, 'previewMmsVideo openPreview failed, err = ' + JSON.stringify(err));
    // });
  }
}

@Component
export struct MMContentSlideImage {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Prop mmsItem?: mmsListType;
  @Prop favoriteItem?: LooseObject;
  @Prop showMenu: boolean = false;
  @Prop slideDataList?: Array<Mms> = [];
  @Prop threadId?: number = 0;
  @Prop mmsIndex?: number = 0;
  @Prop slideFirstItemTransmit?: Mms;
  @Prop msgTitleTransmit?: string = '';
  @State imagePath?: string = '';
  @State imageWidth: number = 0;
  @State imageHeight: number = 0;
  @State isPop?: boolean = false;
  @StorageLink('curBp') curBp: string = commonData.STR.DEVICE_MOBILE_PHONE;
  @State screenWidth: number = 0;
  @State slideFirstItem: Mms = {
    duration: '',
    type: -1,
    path: '',
    name: ''
  }
  isFromTransmit: boolean = false;
  msgTitle: string | Resource = '';
  firstItemText: string | Resource = '';
  conversationCtrl: ConversationController = ConversationController.getInstance();

  aboutToAppear() {
    HiLog.i(TAG, 'MMContentSlideImage aboutToAppear');
    let windowWidth = AppStorage.get('windowWidth') as number;
    if (windowWidth) {
      this.screenWidth = this.curBp === commonData.STR.DEVICE_MOBILE_PHONE ?
        windowWidth : windowWidth / 2;
      this.imageWidth = this.screenWidth / 2;
      this.imageHeight = this.imageWidth;
    }

    if (this.favoriteItem) {
      this.mmsItem = this.favoriteItem as mmsListType;
    }
    this.msgTitle = this.mmsItem?.msgTitle ? $r('app.string.subject', this.mmsItem?.msgTitle) : '';
    if (this.slideDataList?.length) {
      this.slideFirstItem = this.slideDataList[0];
    }
    if(this.isFromTransmit){
      this.slideFirstItem = this.slideFirstItemTransmit as Mms;
      this.msgTitle = this.msgTitleTransmit ? $r('app.string.subject', this.msgTitleTransmit) : '';
    }
    if(this.slideFirstItem?.path){
      const firstItemPath = this.slideFirstItem.path;
      if (this.slideFirstItem.type === commonData.MM_ATTACHMENT_TYPE.IMAGE ||
        this.slideFirstItem.type === commonData.MM_ATTACHMENT_TYPE.MAP) {
        if (fs.accessSync(firstItemPath)) {
          this.imagePath = fileuri.getUriFromPath(firstItemPath);
        }
      } else {
        let fileName = 'IMG_' + this.slideFirstItem.name.replace('mp4', 'jpeg');
        let index = firstItemPath.lastIndexOf('/');
        let filePath = firstItemPath.substring(0, index);
        let videoPath = filePath + '/' + fileName;
        if (fs.accessSync(videoPath)) {
          this.imagePath = fileuri.getUriFromPath(videoPath);
        }
      }
    }
    this.firstItemText = this.slideFirstItem.content || '';
  }

  jumpToSlideImagesPreviewPage() {
    HiLog.i(TAG, 'jumpToSlideImagesPreviewPage entry');
    let param: LooseObject = {
      slideDataList: this.slideDataList,
      mmsItem: this.mmsItem,
      threadId: this.threadId,
      mmsIndex: this.mmsIndex,
      favoriteItem: this.favoriteItem
    }
    if (typeof this.mmsIndex === 'number' && !this.favoriteItem) {
      this.conversationCtrl.slideMmsIndex = this.mmsIndex;
      this.conversationCtrl.setSlideInfoOffset();
    }
    this.pageInfos.pushPathByName('SlidePreview', param)
    HiLog.i(TAG, 'jumpToSlideImagesPreviewPage end');
  }

  @Builder
  buildSlideShowImage() {
    if (this.slideFirstItem.type === commonData.MM_ATTACHMENT_TYPE.IMAGE ||
      this.slideFirstItem.type === commonData.MM_ATTACHMENT_TYPE.MAP) {
      Stack() {
        Image(this.imagePath)
          .width(224)
          .height(112)
          .draggable(false)
          .borderRadius({
            topLeft: this.isFromTransmit ? 8 : 16,
            topRight: this.isFromTransmit ? 8 : 16,
          })
        Image($rawfile('icon/ppt_top.svg'))
          .width(32)
          .height(32)
          .draggable(false)
      }
    } else {
      Stack({ alignContent: Alignment.Center }) {
        Image(this.imagePath)
          .width(224)
          .height(112)
          .draggable(false)
          .backgroundColor(this.imagePath ? Color.Transparent : Color.Black)
          .borderRadius({
            topLeft: this.isFromTransmit ? 8 : 16,
            topRight: this.isFromTransmit ? 8 : 16,
          })
          .objectFit(ImageFit.Fill)

        SymbolGlyph($r('sys.symbol.play_circle'))
          .fontSize(32)
          .draggable(false)
          .fontColor([$r('sys.color.ohos_id_color_background')])
      }.lightUpEffect(this.showMenu ? 0.8 : 1)
    }
  }

  build() {
    Column() {
      this.buildSlideShowImage()
      Row() {
        Flex({direction: FlexDirection.Column, alignItems: ItemAlign.Start}){
          if(this.msgTitle){
            Text(this.msgTitle)
              .fontSize($r('app.float.settings_item_primary_title_font_size'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Regular)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          if(this.firstItemText){
            Text(this.firstItemText)
              .fontSize($r('app.float.settings_item_primary_title_font_size'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Regular)
              .maxLines(1)
          }
          if(!this.msgTitle && !this.firstItemText){
            Text($r('app.string.msg_slide'))
              .fontSize($r('app.float.settings_item_primary_title_font_size'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Regular)
          }
        }
      }
      .width(224)
      .borderRadius({
        bottomLeft: 16,
        bottomRight: 16
      })
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    }
    .id('slide_with_image')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .width(224)
    .borderRadius(16)
    .lightUpEffect(this.showMenu ? 0.8 : 1)
    .accessibilityLevel('yes')
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        LongPressGesture()
          .onAction(() => {
            HiLog.i(TAG, 'MMContentSlideImage LongPressGesture')
          }),
        TapGesture({ count: 1 }).onAction((event?: GestureEvent) => {
          HiLog.i(TAG, 'MMContentSlideImage onClick')
          if (!this.isFromTransmit) {
            this.jumpToSlideImagesPreviewPage()
          }
        })
      )
    )
  }
}

@Component
export struct MMContentSlideNoImage {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Prop mmsItem?: mmsListType;
  @Prop favoriteItem?: LooseObject;
  @Prop showMenu?: boolean = false;
  @Prop slideDataList?: Array<Mms> = [];
  @Prop threadId?: number = 0;
  @Prop mmsIndex?: number = 0;
  @Prop slideFirstItemTransmit?: Mms;
  @Prop msgTitleTransmit?: string = '';
  @StorageLink('windowWidth') deviceWidth: number = 0;
  @StorageLink('curBp') curBp: string = commonData.STR.DEVICE_MOBILE_PHONE;
  item: Mms = { duration: '', type: -1, path: '', name: '' };
  isWhite: boolean = false;
  isLeft: boolean = false;
  isFromTransmit: boolean = false;
  msgTitle: string | Resource = '';
  firstItemText: string = '';
  conversationCtrl: ConversationController = ConversationController.getInstance();

  aboutToAppear() {
    HiLog.i(TAG, 'MMContentSlideNoImage aboutToAppear');
    if (this.favoriteItem) {
      this.mmsItem = this.favoriteItem as mmsListType;
    }
    this.msgTitle = this.mmsItem?.msgTitle ? $r('app.string.subject', this.mmsItem?.msgTitle) : '';
    this.firstItemText = this.slideDataList?.length ? this.slideDataList[0].content || '' : '';
    if(this.isFromTransmit){
      const slideFirstItem = this.slideFirstItemTransmit as Mms;
      this.firstItemText = slideFirstItem ? slideFirstItem.content || '' : '';
      this.msgTitle = this.msgTitleTransmit ? $r('app.string.subject', this.msgTitleTransmit) : '';
    }
  }


  jumpToSlideImagesPreviewPage(){
    HiLog.i(TAG, 'jumpToSlideImagesPreviewPage entry');
    let param: LooseObject = {
      slideDataList: this.slideDataList,
      mmsItem: this.mmsItem,
      threadId: this.threadId,
      mmsIndex: this.mmsIndex,
      favoriteItem: this.favoriteItem
    }
    if (typeof this.mmsIndex === 'number' && !this.favoriteItem) {
      this.conversationCtrl.slideMmsIndex = this.mmsIndex;
      this.conversationCtrl.setSlideInfoOffset();
    }
    this.pageInfos.pushPathByName('SlidePreview', param)
    HiLog.i(TAG, 'jumpToSlideImagesPreviewPage end');
  }

  private getMaxWidth(): number {
    let screenPercent = 1;
    if (this.curBp === commonData.STR.DEVICE_MOBILE_PHONE) {
      screenPercent = 1;
    } else if (this.curBp === commonData.STR.DEVICE_Folding_SCREEN) {
      screenPercent = 0.5;
    } else {
      screenPercent = 0.6;
    }
    return this.deviceWidth * screenPercent * 0.8;
  }

  build() {
    Row() {
      Image($rawfile('icon/mms_ppt.svg'))
        .objectFit(ImageFit.Contain)
        .width($r('app.float.icon_side_length_medium'))
        .height($r('app.float.icon_side_length_medium'))
        .draggable(false)
        .margin({ end: LengthMetrics.vp(16) })
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
        if (this.msgTitle) {
          Text(this.msgTitle)
            .fontSize($r('app.float.settings_item_primary_title_font_size'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Regular)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        if (this.firstItemText) {
          Text(this.firstItemText)
            .fontSize($r('app.float.settings_item_primary_title_font_size'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Regular)
            .maxLines(this.msgTitle ? 1 : 2)
        }
        if (!this.msgTitle && !this.firstItemText) {
          Text($r('app.string.msg_slide'))
            .fontSize($r('app.float.settings_item_primary_title_font_size'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Regular)
        }
      }
      .constraintSize({ maxWidth: this.getMaxWidth() - 66 + 'vp' })
    }
    .id('slide_no_image')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .constraintSize({ maxWidth: this.getMaxWidth() + 'vp' })
    // .alignItems(VerticalAlign.Center)
    .borderRadius({
      topRight: 16,
      bottomLeft: 16,
      bottomRight: 16
    })
    .padding({
      left: $r('app.float.infoMsg_list_padding_left'),
      right: $r('app.float.infoMsg_list_padding_right'),
      top: $r('app.float.settings_items_margin_top'),
      bottom: $r('app.float.settings_items_margin_bottom')
    })
    .accessibilityLevel('yes')
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        LongPressGesture()
          .onAction(() => {
            HiLog.i(TAG, 'MMContentSlideNoImage LongPressGesture')
          }),
        TapGesture({ count: 1 }).onAction((event?: GestureEvent) => {
          HiLog.i(TAG, 'MMContentSlideNoImage onClick')
          if (!this.isFromTransmit) {
            this.jumpToSlideImagesPreviewPage()
          }
        })
      )
    )
  }
}

@Component
export struct MMContentDownLoadMMs {
  @Prop showMenu:boolean=false;
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;
  @StorageLink('AdvancedSettingsController') mAdvancedSettingsCtrl:
    AdvancedSettingsController = AdvancedSettingsController.getInstance();
  localeInfo: LocaleResponse = Configuration.getLocale();
  autoDownloadFlag: boolean = false;
  expiresTime: string = '';
  mmsInfo: mmsInfo = new mmsInfo();
  item: Mms = {
    duration: '',
    type: -1,
    path: '',
    name: '',
    size: ''
  };
  bubbleTextDirection: string = 'left';
  isExpires: boolean = false;
  @Link conversationCtrl: ConversationController;
  securityModeController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.advancedSecurityDialogBuildContent();
      },
      buttons: [{
        value: $r('app.string.setting_konw'),
        buttonStyle: ButtonStyleMode.TEXTUAL,
        action: () => {}
      }]
    }),
  })

  @Builder
  advancedSecurityDialogBuildContent(): void {
    Row() {
      SymbolGlyph($r('sys.symbol.security_shield'))
        .fontSize(32)
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
        .fontColor([$r('sys.color.icon_primary'), $r('sys.color.icon_emphasize')])
    }
    .width('100%')
    .margin({ bottom: 16 })
    .justifyContent(FlexAlign.Center)

    Row() {
      Text($r('app.string.in_advanced_mode'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontFamily('HarmonyHeiTi')
        .lineHeight(24)
        .fontColor($r('sys.color.font_primary'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .maxFontScale(2)
    }
    .width('100%')
    .margin({ bottom: 16 })
    .justifyContent(FlexAlign.Center)
    Scroll() {
      Column() {
        Row() {
          Text(this.mAdvancedSettingsCtrl.isAdvancedSecurity ? $r('app.string.setting_advanced_mode') : $r('app.string.leave_setting_advanced_mode'))
            .fontSize(16)
            .fontWeight(FontWeight.Regular)
            .fontFamily('HarmonyHeiTi')
            .lineHeight(20)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }.width("100%")
    }
    .scrollBar(BarState.Off)
    .layoutWeight(this.fontSizeScale > 3 ? 1 : 0)
  }

  aboutToAppear() {
    this.isExpires = Date.now() > Number(this.mmsInfo.expiresTime);
    this.conversationCtrl.getAirPlaneMode();
  }

  @Builder loadBuildColumn() {
    if ([commonData.int.MMS_DOWNLOAD_FAILED, commonData.int.MMS_NOT_DOWNLOAD].includes(this.mmsInfo.msgState) &&
         (!this.autoDownloadFlag ||
           (this.autoDownloadFlag && this.mmsInfo.msgState == commonData.int.MMS_DOWNLOAD_FAILED)) &&
         !this.isExpires) {
      Divider().height(0.5).width(Configuration.getLocale().language == 'zh' ? 201 : 221)
        .color($r('sys.color.comp_divider'))
    }
    if ([commonData.int.MMS_DOWNLOAD_FAILED, commonData.int.MMS_NOT_DOWNLOAD].includes(this.mmsInfo.msgState) &&
         (!this.autoDownloadFlag ||
           (this.autoDownloadFlag && this.mmsInfo.msgState == commonData.int.MMS_DOWNLOAD_FAILED)) &&
         !this.isExpires) {
      Row() {
        Button($r('app.string.download'), { type: ButtonType.Normal, stateEffect: false })
          .fontSize($r('sys.float.Body_L')).fontColor($r('sys.color.font_emphasize'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
          .constraintSize({ minHeight: 40, minWidth: 120 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .enabled(true)
      .onClick(() => {
        if (this.conversationCtrl.isAirPlaneMode) {
          this.conversationCtrl.showToast($r('app.string.air_plane_mode_receive_message'));
        } else if (this.mmsInfo.isAdvancedSecurity) {
          this.securityModeController.open();
        } else {
          this.conversationCtrl.downloadMms(this.mmsInfo, getContext(this));
        }
      })
    } else if (this.mmsInfo.msgState == commonData.int.MMS_DOWNLOADING && !this.isExpires) {
      Row() {
        Text($r('app.string.downloading'))
          .fontSize($r('sys.float.Body_L')).fontColor($r('sys.color.ohos_id_color_text_primary')).fontWeight(FontWeight.Regular)
      }
      .constraintSize({ minHeight: 21 })
      .width('100%')
      .margin({bottom: 8})
      .alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Start)
      .enabled(false)
    } else if (this.isExpires) {
      Row() {
        Text($r('app.string.expired'))
          .fontSize($r('sys.float.Body_L')).fontColor($r('sys.color.ohos_id_color_text_primary')).fontWeight(FontWeight.Regular)
      }
      .constraintSize({ minHeight: 21 })
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .enabled(false)
    }
  }

  build() {
    Column() {
      Text($r('app.string.messageSize', (Number(this.item.size) / 1024).toFixed(0)))
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
        .lineHeight(16)
        .fontFamily('HarmonyHeiTi')
      Text($r('app.string.expiresTime', new Intl.DateTimeFormat(`${Configuration.getLocale()
        .language}-${Configuration.getLocale()
        .countryOrRegion}`, {
        hour12: !I18n.System.is24HourClock(),
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
      } as Intl.DateTimeOptions).format(new Date(Number(this.mmsInfo.expiresTime)))))
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
        .lineHeight(16)
        .fontFamily('HarmonyHeiTi')
        .margin({ bottom: 8 })
      this.loadBuildColumn();
    }
    .width(Configuration.getLocale().language == 'zh' ? 225 : 245)
    .constraintSize({ minHeight: [6, 7].includes(this.mmsInfo.msgState) ? 88.5 : 69.5 })
    .borderRadius({
      topLeft: (this.bubbleTextDirection === 'right') ? 16 : 2,
      topRight: (this.bubbleTextDirection === 'right') ? 2 : 16,
      bottomLeft: 16,
      bottomRight: 16
    })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .padding({ top: 8, left: 12, right: 12 })
    .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
    .lightUpEffect(this.showMenu ? 0.8 : 1)
  }
}

@Builder
function loadMenuBuilderDivider() {
  Divider()
    .color($r('sys.color.ohos_id_color_list_separator'))
    .height($r('app.float.settings_divider_strokeWidth'))
    .lineCap(LineCapStyle.Square)
    .width(0)
    .alignSelf(ItemAlign.Stretch)
    .padding({
      left: $r('app.float.conversation_item_press_Shadow_padding_left'),
      right: $r('app.float.conversation_item_press_Shadow_padding_left')
    })
}

interface RcsSaveButtonVisibilityOption {
  hasLongPressVideoDownload: boolean
  isRcs: number
  rcsType: number
}