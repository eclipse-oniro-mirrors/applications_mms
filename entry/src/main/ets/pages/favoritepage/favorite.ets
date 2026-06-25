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
import LooseObject from '../../data/LooseObject';
import ConversationListDataSource from '../../model/ConversationListDataSource';
import ImageUtil from '../../utils/ImageUtil';
import MmsUtil, { getIsMmsMapMessageByMmsSource } from '../../utils/MmsUtil';
import PanGestureUtil, { PanGestureAction } from '../../utils/PanGestureUtil';
import image from '@ohos.multimedia.image';
import { AudioPlayerService } from '../../service/AudioPlayerService';
import { Mms, ContactType } from '../../utils/TypesUtils';
import { getPixelMapFromFile } from '../../utils/UserPhotoUtil';
import dateUtil, { DateUtil } from '../../utils/DateUtil';
import FavoriteController from './favoriteController'
import { IPhotoProp } from '../../pages/photoBrowser/photoBrowser';
import ImageBoundsUtil from '../../utils/ImageBoundsUtil'
import fileuri from '@ohos.file.fileuri';
import lazy fs from '@ohos.file.fs';
import FileUtil, { SavedFileInfo } from '../../utils/FileUtil';
import ConversationController, { mmsListType } from '../conversation/conversationController';
import common from '../../data/commonData';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import lazy { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import HiLog from '../../utils/HiLog';
import { messageType } from '../conversationlist/conversationListController';
import commonData from '../../data/commonData';
import DeviceUtil from '../../utils/DeviceUtil';
import lazy { MAX_DURATION } from '../../views/AttachmentArea/MMContent';
import { HashMap, JSON } from '@kit.ArkTS';
import { VibrationUtils } from '../../utils/VibrationUtils';
import { Highlight, HighlightsOptions, HighlightType } from '../../utils/Highlight';
import { curves, LengthMetrics, MeasureText, SymbolGlyphModifier, uiObserver } from '@kit.ArkUI';
import Configuration from '@system.configuration';
import myCommon from '@ohos.app.ability.common';
import lazy { MMContentSlideImage, MMContentSlideNoImage } from '../../views/AttachmentArea/MMContent';
import { ImagePreviewData, imagePreviewBuilder } from '../../views/AttachmentArea/ImagePreviewBuilder';
import { media } from '@kit.MediaKit';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import fileUri from '@ohos.file.fileuri';
import { emitter } from '@kit.BasicServicesKit';
import StringUtil from '../../utils/StringUtil';
import DotUtil from '../../utils/MmsDot/DotUtils';
import dotCommon, { dotNoNeedParmas } from '../../utils/MmsDot/DotCommon';
import TitleBarUtil from '../../utils/TitleBarUtil';
import ResourceUtils from '../../utils/ResourceUtils';
import TransmitSearchMsgPage from '../transmitmsg/transmitSearchMsgPage';
import TransmitMsgPage from '../transmitmsg/transmitMsgPage';
import { MmsContentVcard } from './MmsContentVcard'
import { MMCheckVcardDialog, MMSaveVcardDialog, MMAskIsImportDialog } from '../../views/AttachmentArea/MMMoreDialog'
import { VCardUtil } from '../../utils/VCardUtil';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import bundleManager from '@ohos.bundle.bundleManager';
import promptAction from '@ohos.promptAction';
import DistributedUtil from '../../utils/DistributedUtil';
import LocationUtil from '../../utils/LocationUtil';
import { MmsContentMap } from '../../views/MmsMap/MmsContentMap';
import EmitterConstant from '../../data/EmitterConstant';
import { FontSizeScale } from '../../data/Constant';
import AccessibilityUtil from '../../utils/AccessibilityUtil';
import { TextAccessibilityModifier } from '../../utils/AccessibilityModifier';
import { EmptyPage } from '../../views/EmptyPage';

const TAG = 'Favorite';

@Builder
export function FavoritesLoader(param: LooseObject): void {
  Favorites();
}

@Component
export struct Favorites {
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;
  private item: LooseObject = {}
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Provide show: boolean = true;
  @Provide index: number = 1;
  @Provide @Watch('multiSelectFlagChange') multiSelectFlag: Visibility = Visibility.None;
  @Provide mFavoriteCtrl: FavoriteController = FavoriteController.getInstance();
  @Provide contentHeight: number = 641;
  @State ct: string = '';
  @State isCb: boolean = false
  @State isSelectAll: boolean = false;
  @State isSelectDelete: boolean = false;
  @State screenWidth: number = 0;
  @State currentScreenWidth: string = '';
  private context = getContext(this) as myCommon.UIAbilityContext;
  @StorageProp('isShowContactHeadIcon') isShowHead: boolean = true;
  @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding | null = null;
  @StorageLink('curBp') @Watch('messageBubbleWidthChange') curBp: string = common.STR.DEVICE_MOBILE_PHONE;
  @StorageLink('windowWidth') deviceWidth: number = 0;
  @State mConversationCtrl: ConversationController = ConversationController.getInstance();
  /* 设备是否为pad */
  @State isPad: boolean = false;
  @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();
  favoriteList: ConversationListDataSource = new ConversationListDataSource();
  public mmsListFromFavo: Array<messageType> = [];
  private debounceTimer: number | null = null;
  @State textDirection: string = '';
  private favoriteContentAlignRules: AlignRuleOption = {
    top: { anchor: 'favorite_list_name', align: VerticalAlign.Bottom },
    left: { anchor: 'favorite_list_name', align: HorizontalAlign.Start }
  }
  private listScroller: ListScroller = new ListScroller();
  // List滑动多选
  private listWidth: number = 0
  private listHeight: number = 0
  // 设置一个变量区分是滑动还是点击，防止滑动多选框状态改变时调用点击多选方法
  private isPanGestureUtil: boolean = false
  @State scrollEndIndex: number = -1
  @State scrollStartIndex: number = -1
  // 多选状态下统计选中数量
  @StorageLink('selectLength') @Watch('getSelectNumber') selectNumber: number = 0;
  @State isOpenRCS: boolean = false;
  @State isTouch: boolean = false;
  @StorageLink('isVDEFoldPhoneAndFoldedState') @Watch('onFoldStatusChange')
  isVDEFoldPhoneAndFoldedState: boolean = false;
  @StorageLink('foldStatus') @Watch('getWallpaper') foldStatus: number = 0;
  @State isVDE: boolean = this.isVDEFoldPhoneAndFoldedState && this.foldStatus === 2 ? true : false;
  @State isScrolling: boolean = false;
  private isScrollingStart: boolean = false;
  @State checkBoxStatusHasChanged: boolean = false;
  private onCheckBoxChangedCallBack: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
    this.checkBoxStatusHasChanged = !this.checkBoxStatusHasChanged;
  }
  private ableSlips: boolean = true;
  private listLength: number = 0;
  private initialCurrentYOffset: number = 0;
  private savedFileInfo: SavedFileInfo | null = null
  @State isPC: boolean = DeviceUtil.isPC()
  /* 仅用于PC分布式短信场景，用于获取用户管控权限 */
  public isOsAccountConstraintEnabled: boolean = false;
  @StorageProp('isFavoriteTransmitShow') isFavoriteTransmitShow: boolean = false;
  @StorageProp('isTransmitSearch') isTransmitSearch: boolean = false;
  // 点击长按菜单删除需要删除的信息
  private longPressDeleteItem: LooseObject|null = null;
  private multiSelectFlagChange(): void {
    if (this.isVDE && this.multiSelectFlag == Visibility.Visible && this.isScrolling) {
      animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 2000 }, () => {
        this.isScrolling = false;
      })
    }
  }

  private onFoldStatusChange(): void {
    if (this.isVDEFoldPhoneAndFoldedState) {
      HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
    } else {
      HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
    }
  }

  getWallpaper() {
    if (this.isVDEFoldPhoneAndFoldedState) {
      HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
      if (this.foldStatus === 2) {
        this.isVDE = true;
      } else {
        this.isVDE = false
      }
      HiLog.i(TAG, 'isVDE: ' + this.isVDE);
    } else {
      this.isVDE = false;
      HiLog.i(TAG, 'onFoldStatusChange: ' + this.isVDEFoldPhoneAndFoldedState);
    }
  }

  @Styles
  normalStylesOfCancel(){
    .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
  }

  @Styles
  pressedStylesOfCancel(){
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  transmitAudioDialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: $r('app.string.translate_audio'),
      primaryButton: {
        value: $r('app.string.cancel'),
        buttonStyle: ButtonStyleMode.TEXTUAL,
        action: () => {
        }
      },
      secondaryButton: {
        value: $r('app.string.confirm'),
        buttonStyle: ButtonStyleMode.TEXTUAL,
        action: () => {
          GlobalContext.getContext().setObject('notUpdateData', true)
          this.mFavoriteCtrl.transmitMsg();
        }
      }
    }),
    autoCancel: false,
  });

  /**
   * 删除确认框
   **/
  delConversionController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: this.mFavoriteCtrl.strMsgDeleteDialogTip,
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {}
      },
      secondaryButton: {
        value: $r('app.string.delete'),
        action: () => {
          HiLog.i( TAG, 'start delete')
          if (this.longPressDeleteItem === null) {
            HiLog.i( TAG, 'mut chooce delete mms')
            this.mFavoriteCtrl.cancelFavorites(this.context);
            this.cancelSelectState();
            this.multiSelectFlag = Visibility.None;
          } else {
            HiLog.i( TAG, 'long press delete mms')
            this.mFavoriteCtrl.cancelFavorite(this.context, this.longPressDeleteItem)
            this.longPressDeleteItem = null;
          }
        },
        role: ButtonRole.ERROR
      }
    }),
    autoCancel: false,
  });

  aboutToAppear() {
    HiLog.i(TAG, 'FavoritePage aboutToAppear');
    this.isPad = DeviceUtil.isTablet();
    this.isOpenRCS = SharedPreferencesUtils.getFromPreferences('isUIOpenRcs', '') as boolean;
    this.mFavoriteCtrl.onInit(this.pageInfos);
    this.mFavoriteCtrl.registerDataChangeObserver(this.onContactChange, getContext(this));
    this.mFavoriteCtrl.getFavoriteData(this.context);
    let windowWidth = AppStorage.get('windowWidth') as number;
    uiObserver.on('navDestinationUpdate', (info: NavDestinationInfo) => {
      if (info.state === 0) {
        this.textDirection = Configuration.getLocale().dir;
      }
    });
    if (windowWidth) {
      this.screenWidth = vp2px(windowWidth) / 2;
    }
    this.getPermissionControl();
    emitter.on(EmitterConstant.EVENT_CHECK_BOX_CHANGED, this.onCheckBoxChangedCallBack);
  }

  private async getPermissionControl() {
    this.isOsAccountConstraintEnabled = await DistributedUtil.isOsAccountConstraintEnabled();
  }

  aboutToDisappear() {
    HiLog.i(TAG, 'FavoritePage aboutToDisappear!');
    this.mFavoriteCtrl.unregisterDataChangeObserver(this.onContactChange, getContext(this));
    uiObserver.off('navDestinationUpdate');
    emitter.off(EmitterConstant.EVENT_CHECK_BOX_CHANGED, this.onCheckBoxChangedCallBack);
  }

  onContactChange = () => {
    // 监听到联系人变化，定时任务结束后开始刷新
    HiLog.i(TAG, 'onContactChange: after the timer expires, the actual onContactDataChange will start')
    this.onContactDataChange();
  }

  private onContactDataChange() {
    clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(() => {
      // 定时器结束，开始刷新
      HiLog.i(TAG, 'onContactDataChange: the timer has expired, and onContactDataChange is being triggered');
      this.mFavoriteCtrl.getFavoriteData(this.context);
    }, 200);
  }

  extractFileName(filePath: string): string {
    const lastIndex = filePath.lastIndexOf('/');
    if (lastIndex !== -1) {
      return filePath.slice(lastIndex + 1);
    } else {
      return filePath;
    }
  }

  setRcsReceiveFileSize(totalSize: number) {
    let fileSize: string = '';
    if (totalSize < commonData.int.RCS_FILE_SIZE) {
      fileSize = totalSize.toString() + 'B';
    } else if (totalSize > commonData.int.RCS_FILE_SIZE && totalSize < commonData.int.RCS_FILE_MAX_SIZE) {
      fileSize = (totalSize / commonData.int.RCS_FILE_SIZE).toFixed(2) + 'KB';
    } else {
      fileSize = (totalSize / commonData.int.RCS_FILE_MAX_SIZE).toFixed(2) + 'MB';
    }
    return fileSize;
  }

  destinationShow() {
    if (this.currentScreenWidth === common.STR.EMPTY_STR) {
      this.messageBubbleWidthChange()
    }
    if (this.isVDE) {
      animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 2000 }, () => {
        this.isScrolling = false;
      })
    }
  }

  @Styles
  normalStylesBack(){
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStylesBack(){
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
  }

  messageBubbleWidthChange() {
    HiLog.i(TAG, 'messageBubbleWidthChange Info')
    if (this.curBp === common.STR.DEVICE_MOBILE_PHONE) {
      //When the device is a mobile phone, the maximum bubble width is 80% of the screen.
      this.currentScreenWidth = (this.deviceWidth * 0.8 - 40) + 'vp';
    } else if (this.curBp === common.STR.DEVICE_Folding_SCREEN) {
      //When the device is a folding screen or tablet, the maximum bubble width is 75% of the screen.
      this.currentScreenWidth = (this.deviceWidth / 2 * 0.8) + 'vp';
    } else {
      this.currentScreenWidth = (this.deviceWidth * 0.6 * 0.8) + 'vp';
    }
  }

  getSelectNumber() {
    this.selectNumber = this.mFavoriteCtrl.favoriteList.selectList.length
  }

  @Builder
  navTitle() {
    if (this.show) {
      Text($r('app.string.favorites'))
        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Bold)
        .focusable(true)
        .height('100%')
        .width('100%')
        .padding(this.textDirection === 'rtl' ?
          {
            right: this.isPC ? $r('sys.float.padding_level12') : this.curBp === common.STR.DEVICE_MOBILE_PHONE ? 8 :
              this.isPad ? this.padMargin : $r('sys.float.margin_left')
          } :
          {
            left: this.isPC ? $r('sys.float.padding_level12') : this.curBp === common.STR.DEVICE_MOBILE_PHONE ? 8 :
              this.isPad ? this.padMargin : $r('sys.float.margin_left')
          })
    } else {
      Text(this.selectNumber === 0
        ? $r('app.string.msg_unselected_tip')
        : $r('app.plural.msg_selected_tip_new', this.selectNumber,
        LocationUtil.numFormat(this.selectNumber)))
        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Bold)
        .height('100%')
        .width('100%')
        .padding(this.textDirection === 'rtl' ?
          {
            right: this.curBp === common.STR.DEVICE_MOBILE_PHONE || this.curBp === common.STR.DEVICE_Folding_SCREEN ?
              64 : this.isPad ? this.padMargin + 64 : $r('sys.float.margin_left')
          } :
          {
            left: this.curBp === common.STR.DEVICE_MOBILE_PHONE || this.curBp === common.STR.DEVICE_Folding_SCREEN ? 64 :
              this.isPad ? this.padMargin + 64 : $r('sys.float.margin_left')
          })
    }
  }

  @Builder
  transmitBuilder() {
    if (this.isTransmitSearch) {
      TransmitSearchMsgPage();
    } else {
      TransmitMsgPage()
    }
  }

  @Builder
  buildMmsContentVcard(item: LooseObject, index: number, id: string) {
    MmsContentVcard({
      isSender: item.isSender === 1,
      item: item,
      itemIndex: index,
      listScroller :this.listScroller,
      scrollEndIndex: this.scrollEndIndex,
      scrollStartIndex: this.scrollStartIndex,
      favoriteNameMargin: this.getFavoriteNameMargin(),
      menuMultSelect: ((selectIndex) => {
        this.multiSelectFlag = Visibility.Visible;
        this.mFavoriteCtrl.listCheckBoxChange(selectIndex, true);
      })
    }).padding({ top: 4 })
      .alignRules(this.favoriteContentAlignRules)
      .id(id)
  }

  @Builder
  buildMmsContentMap(item: LooseObject, index: number, id: string) { //彩信位置消息
    MmsContentMap({
      isCallFrom: 'favorite',
      mmsItem: item,
      itemIndex: index,
      isFavorite: true,
      menuMultSelect: ((selectIndex) => {
        this.multiSelectFlag = Visibility.Visible;
        this.mFavoriteCtrl.listCheckBoxChange(selectIndex, true);
      }),
      menuDeleteCallBack: ((deleteItem) => {
        this.LongPressDeleteAction(deleteItem);
      }),
      bubbleTextDirection: item.isSender === 1 ? 'left' : 'right',
      bubbleTextBorderRadius: [2, 16],
      bubbleTextBackgroundColor: item.isSender === 1 ? $r('sys.color.ohos_id_color_card_bg') :
      $r('app.color.brand')
    }).padding({ top: 4 })
      .alignRules(this.favoriteContentAlignRules)
      .id(id)
  }

  getFavoriteNameMargin() {
    return this.isShowHead ? 8 : (this.isPad ? this.padMargin :
      Number(ResourceUtils.getStringSync(this.textDirection === 'rtl' ? $r('sys.float.margin_right') : $r('sys.float.margin_left'))))
  }

  build() {
    NavDestination() {
      RelativeContainer() {
        if (this.mFavoriteCtrl.isFavorite) {
          List({ scroller: this.listScroller }) {
            LazyForEach(this.mFavoriteCtrl.favoriteList, (item: LooseObject, index) => {
              ListItem() {
                RelativeContainer() {
                  if (this.isShowHead) {
                    if (item.senderNumber) {
                      if (item?.isChatbotMessage) {
                        ContactAvatar({
                          rawContactId: '',
                          contactId: '',
                          item: item
                        })
                          .margin(this.textDirection === 'rtl' ?
                            {
                              top: 16,
                              right: this.isPC ? 24 : this.isPad ? this.padMargin : $r('sys.float.margin_right')
                            } :
                            {
                              top: 16,
                              left: this.isPC ? 24 : this.isPad ? this.padMargin : $r('sys.float.margin_left')
                            })
                          .id('favorite_list_avatar')
                          .onClick(() => {
                            this.pageInfos.pushPathByName('RcsDetailsChatbotActivity', {
                              id: item.senderNumber,
                              icon: ''
                            } as LooseObject);
                            DotUtil.getInstance().reportEvent(dotNoNeedParmas,
                              dotCommon.eventName.OPEN_CHATBOT_DETAIL);
                          })
                      } else {
                      ContactAvatar({
                        hasYellowPageIcon: this.mFavoriteCtrl
                          .nameAndPicture(item.senderNumber)?.hasYellowPageIcon,
                        yellowPageId: this.mFavoriteCtrl
                          .nameAndPicture(item.senderNumber)?.yellowPageId,
                        rawContactId: this.mFavoriteCtrl.contactIdMap.get(item.senderNumber) ?? '',
                        contactId: this.mFavoriteCtrl.contactIdMap.get(item.senderNumber) ?? '',
                        item: item,
                      })
                        .onClick(() => {
                          this.mFavoriteCtrl.titleBarAvatar(this.context, item.senderNumber);
                        })
                        .margin(this.textDirection === 'rtl' ?
                          {
                            top: 16,
                            right: this.isPC ? 24 : this.isPad ? this.padMargin : $r('sys.float.margin_right')
                          } :
                          {
                            top: 16,
                            left: this.isPC ? 24 : this.isPad ? this.padMargin : $r('sys.float.margin_left')
                          })
                        .id('favorite_list_avatar')
                      }
                    } else {
                      ContactAvatar({
                        rawContactId: this.mFavoriteCtrl.nameNoPicture('')?.rawContactId,
                        contactId: this.mFavoriteCtrl.nameNoPicture('')?.contactId,
                        item: item
                      })
                        .margin(this.textDirection === 'rtl' ?
                          {
                            top: 16,
                            right: this.isPC ? 24 : this.isPad ? this.padMargin : $r('sys.float.margin_right')
                          } :
                          {
                            top: 16,
                            left: this.isPC ? 24 : this.isPad ? this.padMargin : $r('sys.float.margin_left')
                          })
                        .id('favorite_list_avatar')
                    }
                  }
                  FavoriteName({
                    hasYellowPageIcon: this.mFavoriteCtrl
                      .nameAndPicture(item.senderNumber)?.hasYellowPageIcon,
                    item: item,
                    isPad: this.isPad,
                    isShowHead: this.isShowHead,
                    textDirection: this.textDirection,
                  })
                  if (item.msgType === 0 || item.msgType === 2) {
                    bubbleText({
                      conversationCtrl: $mFavoriteCtrl,
                      content: item.msgContent,
                      item: item,
                      itemIndex: index,
                      bubbleTextBackgroundColor: item.isSender === 0
                        ? $r('app.color.brand') : $r('sys.color.ohos_id_color_card_bg'),
                      isAdvancedSecurity: item.isAdvancedSecurity,
                      isSender: item.isSender,
                      detectResContent: item.detectResContent,
                      textDirection: this.textDirection,
                      listScroller :this.listScroller,
                      scrollEndIndex: this.scrollEndIndex,
                      scrollStartIndex: this.scrollStartIndex,
                      menuMultSelect: ((selectIndex) => {
                        this.multiSelectFlag = Visibility.Visible;
                        this.mFavoriteCtrl.listCheckBoxChange(index, true);
                      }),
                      menuDeleteCallBack: ((deleteItem) => {
                        this.longPressDeleteItem = deleteItem;
                        this.mFavoriteCtrl.clickLongPressDelete();
                        this.delConversionController.open();
                      })
                    }).margin({ top: 4, bottom: 8 })
                      .alignRules(this.favoriteContentAlignRules)
                      .id('favorite_list_content')
                  }
                  else if (item.msgType === 1) {
                    if (MmsUtil.isSlideType(item.contentType)) {
                      FavoriteSlideComponent({
                        itemIndex: index,
                        item: item,
                        listScroller :this.listScroller,
                        scrollEndIndex: this.scrollEndIndex,
                        scrollStartIndex: this.scrollStartIndex,
                        menuMultSelect: ((selectIndex) => {
                          this.multiSelectFlag = Visibility.Visible;
                          this.mFavoriteCtrl.listCheckBoxChange(selectIndex, true);
                        }),
                        menuDeleteCallBack: ((deleteItem) => {
                          this.longPressDeleteItem = deleteItem;
                          this.mFavoriteCtrl.clickLongPressDelete();
                          this.delConversionController.open();
                        })
                      }).alignRules(this.favoriteContentAlignRules)
                        .id('favorite_list_content')
                    } else if (this.mFavoriteCtrl.mmsScreening(item.msgId, 8)) { //彩信位置消息
                      this.buildMmsContentMap(item, index, 'favorite_list_content')
                    } else if (!item.msgContent &&
                    this.mFavoriteCtrl.mmsScreening(item.msgId, 1)) {
                      MmsContentImage({
                        imageProps: this.mFavoriteCtrl.mmsScreening(item.msgId, 1).locationPath ?? '',
                        ct: this.mFavoriteCtrl.mmsScreening(item.msgId, 1).ct ?? '',
                        screenWidth: this.screenWidth,
                        itemIndex: index,
                        item: item,
                        listScroller :this.listScroller,
                        scrollEndIndex: this.scrollEndIndex,
                        scrollStartIndex: this.scrollStartIndex,
                        menuMultSelect: ((selectIndex) => {
                          this.multiSelectFlag = Visibility.Visible;
                          this.mFavoriteCtrl.listCheckBoxChange(selectIndex, true);
                        }),
                        menuDeleteCallBack: ((deleteItem) => {
                          this.longPressDeleteItem = deleteItem;
                          this.mFavoriteCtrl.clickLongPressDelete();
                          this.delConversionController.open();
                        })
                      }).alignRules(this.favoriteContentAlignRules)
                        .id('favorite_list_content')
                    }
                    else if (this.mFavoriteCtrl.mmsScreening(item.msgId, 1) &&
                    item.msgContent) {
                      MmsContentImage({
                        imageProps: this.mFavoriteCtrl.mmsScreening(item.msgId, 1).locationPath ?? '',
                        ct: this.mFavoriteCtrl.mmsScreening(item.msgId, 1).ct ?? '',
                        screenWidth: this.screenWidth,
                        item: item,
                        itemIndex: index,
                        listScroller :this.listScroller,
                        scrollEndIndex: this.scrollEndIndex,
                        scrollStartIndex: this.scrollStartIndex,
                        menuMultSelect: ((selectIndex) => {
                          this.multiSelectFlag = Visibility.Visible;
                          this.mFavoriteCtrl.listCheckBoxChange(selectIndex, true);
                        }),
                        menuDeleteCallBack: ((deleteItem) => {
                          this.longPressDeleteItem = deleteItem;
                          this.mFavoriteCtrl.clickLongPressDelete();
                          this.delConversionController.open();
                        })
                      }).alignRules(this.favoriteContentAlignRules)
                        .id('favorite_list_content_video_1')
                      bubbleText({
                        conversationCtrl: $mFavoriteCtrl,
                        content: item.msgContent,
                        item: item,
                        itemIndex: index,
                        bubbleTextBackgroundColor: item.isSender === 0
                          ? $r('app.color.brand') : $r('sys.color.ohos_id_color_card_bg'),
                        isSender: item.isSender,
                        detectResContent: item.detectResContent,
                        textDirection: this.textDirection,
                        listScroller :this.listScroller,
                        scrollEndIndex: this.scrollEndIndex,
                        scrollStartIndex: this.scrollStartIndex,
                        menuMultSelect: ((selectIndex) => {
                          this.multiSelectFlag = Visibility.Visible;
                          this.mFavoriteCtrl.listCheckBoxChange(selectIndex, true);
                        }),
                        menuDeleteCallBack: ((deleteItem) => {
                          this.longPressDeleteItem = deleteItem;
                          this.mFavoriteCtrl.clickLongPressDelete();
                          this.delConversionController.open();
                        })
                      }).margin({ top: 8, bottom: 8 })
                        .alignRules({
                          top: { anchor: 'favorite_list_content_video_1', align: VerticalAlign.Bottom },
                          left: { anchor: 'favorite_list_content_video_1', align: HorizontalAlign.Start }
                        })
                        .id('favorite_list_content')
                        .accessibilityGroup(true)
                    }
                    else if (this.mFavoriteCtrl.mmsScreening(item.msgId, 3) &&
                      !item.msgContent) {
                      MmsContentAudio({
                        item1: {
                          duration: this.mFavoriteCtrl.mmsScreening(item.msgId, 3).recordingTime ?? '',
                          type: -1,
                          path: this.mFavoriteCtrl.mmsScreening(item.msgId, 3).locationPath ?? '',
                          name: ''
                        },
                        itemIndex: index,
                        isSender: item.isSender,
                        item: item,
                        textDirection: this.textDirection,
                        listScroller :this.listScroller,
                        scrollEndIndex: this.scrollEndIndex,
                        scrollStartIndex: this.scrollStartIndex,
                        menuMultSelect: ((selectIndex) => {
                          this.multiSelectFlag = Visibility.Visible;
                          this.mFavoriteCtrl.listCheckBoxChange(selectIndex, true);
                        }),
                        menuDeleteCallBack: ((deleteItem) => {
                          this.longPressDeleteItem = deleteItem;
                          this.mFavoriteCtrl.clickLongPressDelete();
                          this.delConversionController.open();
                        })
                      }).alignRules(this.favoriteContentAlignRules)
                        .id('favorite_list_content')
                    }
                    else if (this.mFavoriteCtrl.mmsScreening(item.msgId, 3) &&
                    item.msgContent) {
                        MmsContentAudio({
                          item1: {
                            duration: this.mFavoriteCtrl.mmsScreening(item.msgId, 3).recordingTime ?? '',
                            type: -1,
                            path: this.mFavoriteCtrl.mmsScreening(item.msgId, 3).locationPath ?? '',
                            name: ''
                          },
                          itemIndex: index,
                          isSender: item.isSender,
                          item: item,
                          listScroller :this.listScroller,
                          scrollEndIndex: this.scrollEndIndex,
                          scrollStartIndex: this.scrollStartIndex,
                          textDirection: this.textDirection,
                          menuMultSelect: ((selectIndex) => {
                            this.multiSelectFlag = Visibility.Visible;
                            this.mFavoriteCtrl.listCheckBoxChange(selectIndex, true);
                          }),
                          menuDeleteCallBack: ((deleteItem) => {
                            this.longPressDeleteItem = deleteItem;
                            this.mFavoriteCtrl.clickLongPressDelete();
                            this.delConversionController.open();
                          })
                        }).alignRules(this.favoriteContentAlignRules)
                          .id('favorite_list_content_video_3')
                        bubbleText({
                          conversationCtrl: $mFavoriteCtrl,
                          content: item.msgContent,
                          item: item,
                          itemIndex: index,
                          bubbleTextBackgroundColor: item.isSender === 0
                            ? $r('app.color.brand') : $r('sys.color.ohos_id_color_card_bg'),
                          isSender: item.isSender,
                          detectResContent: item.detectResContent,
                          textDirection: this.textDirection,
                          listScroller :this.listScroller,
                          scrollEndIndex: this.scrollEndIndex,
                          scrollStartIndex: this.scrollStartIndex,
                          menuMultSelect: ((selectIndex) => {
                            this.multiSelectFlag = Visibility.Visible;
                            this.mFavoriteCtrl.listCheckBoxChange(selectIndex, true);
                          }),
                          menuDeleteCallBack: ((deleteItem) => {
                            this.longPressDeleteItem = deleteItem;
                            this.mFavoriteCtrl.clickLongPressDelete();
                            this.delConversionController.open();
                          })
                        }).margin({ top: 8, bottom: 8 })
                          .alignRules({
                            top: { anchor: 'favorite_list_content_video_3', align: VerticalAlign.Bottom },
                            left: { anchor: 'favorite_list_content_video_3', align: HorizontalAlign.Start }
                          })
                          .constraintSize({ maxWidth: this.currentScreenWidth })
                          .accessibilityGroup(true)
                        } else if (this.mFavoriteCtrl.mmsScreening(item.msgId, 2) &&
                          !item.msgContent) {
                          MmsContentVideo({
                            mmsSourceItem: {
                              duration: this.mFavoriteCtrl.mmsScreening(item.msgId, 2).recordingTime ?? '',
                              type: -1,
                              path: this.mFavoriteCtrl.mmsScreening(item.msgId, 2).locationPath ?? '',
                              name: ''
                            },
                            screenWidth: this.screenWidth,
                            item: item,
                            itemIndex: index,
                            listScroller :this.listScroller,
                            scrollEndIndex: this.scrollEndIndex,
                            scrollStartIndex: this.scrollStartIndex,
                            menuMultSelect: ((selectIndex) => {
                              this.multiSelectFlag = Visibility.Visible;
                              this.mFavoriteCtrl.listCheckBoxChange(selectIndex, true);
                            }),
                            menuDeleteCallBack: ((deleteItem) => {
                              this.longPressDeleteItem = deleteItem;
                              this.mFavoriteCtrl.clickLongPressDelete();
                              this.delConversionController.open();
                            })
                          }).padding({ top: 4 })
                            .alignRules(this.favoriteContentAlignRules)
                              .id('favorite_list_content')
                        } else if (this.mFavoriteCtrl.mmsScreening(item.msgId, 2) &&
                          item.msgContent) {
                          MmsContentVideo({
                            mmsSourceItem: {
                              duration: this.mFavoriteCtrl.mmsScreening(item.msgId, 2).recordingTime ?? '',
                              type: -1,
                              path: this.mFavoriteCtrl.mmsScreening(item.msgId, 2).locationPath ?? '',
                              name: ''
                            },
                            screenWidth: this.screenWidth,
                            item: item,
                            itemIndex: index,
                            listScroller :this.listScroller,
                            scrollEndIndex: this.scrollEndIndex,
                            scrollStartIndex: this.scrollStartIndex,
                            menuMultSelect: ((selectIndex) => {
                              this.multiSelectFlag = Visibility.Visible;
                              this.mFavoriteCtrl.listCheckBoxChange(selectIndex, true);
                            }),
                            menuDeleteCallBack: ((deleteItem) => {
                              this.longPressDeleteItem = deleteItem;
                              this.mFavoriteCtrl.clickLongPressDelete();
                              this.delConversionController.open();
                            })
                          }).padding({ top: 4 })
                            .alignRules(this.favoriteContentAlignRules)
                              .id('favorite_list_content_video_2')
                          bubbleText({
                            conversationCtrl: $mFavoriteCtrl,
                            content: item.msgContent,
                            item: item,
                            itemIndex: index,
                            bubbleTextBackgroundColor: item.isSender === 0 ? $r('app.color.brand') :
                            $r('sys.color.ohos_id_color_card_bg'),
                            isSender: item.isSender,
                            detectResContent: item.detectResContent,
                            textDirection: this.textDirection,
                            listScroller :this.listScroller,
                            scrollEndIndex: this.scrollEndIndex,
                            scrollStartIndex: this.scrollStartIndex,
                            menuMultSelect: ((selectIndex) => {
                              this.multiSelectFlag = Visibility.Visible;
                              this.mFavoriteCtrl.listCheckBoxChange(selectIndex, true);
                            }),
                            menuDeleteCallBack: ((deleteItem) => {
                              this.longPressDeleteItem = deleteItem;
                              this.mFavoriteCtrl.clickLongPressDelete();
                              this.delConversionController.open();
                            })
                          })
                            .accessibilityGroup(true)
                            .alignRules({
                              top: { anchor: 'favorite_list_content_video_2', align: VerticalAlign.Bottom },
                              left: { anchor: 'favorite_list_content_video_2', align: HorizontalAlign.Start }
                            })
                          .margin({ top: 8, bottom: 8 })
                            .id('favorite_list_content')

                    } else if (this.mFavoriteCtrl.mmsScreening(item.msgId, 4) &&
                      !item.msgContent) {
                        this.buildMmsContentVcard(item, index, 'favorite_list_content')
                    } else if (this.mFavoriteCtrl.mmsScreening(item.msgId, 4) &&
                    item.msgContent) {
                      this.buildMmsContentVcard(item, index, 'favorite_list_content_vcard_2')
                      bubbleText({
                        conversationCtrl: $mFavoriteCtrl,
                        content: item.msgContent,
                        item: item,
                        itemIndex: index,
                        bubbleTextBackgroundColor: item.isSender === 0
                          ? $r('app.color.brand') : $r('sys.color.ohos_id_color_card_bg'),
                        isSender: item.isSender,
                        detectResContent: item.detectResContent,
                        textDirection: this.textDirection,
                        listScroller :this.listScroller,
                        scrollEndIndex: this.scrollEndIndex,
                        scrollStartIndex: this.scrollStartIndex,
                        menuMultSelect: ((selectIndex) => {
                          this.multiSelectFlag = Visibility.Visible;
                          this.mFavoriteCtrl.listCheckBoxChange(selectIndex, true);
                        })
                      })
                        .accessibilityGroup(true)
                        .alignRules({
                          top: { anchor: 'favorite_list_content_vcard_2', align: VerticalAlign.Bottom },
                          left: { anchor: 'favorite_list_content_vcard_2', align: HorizontalAlign.Start }
                        })
                        .margin({ top: 8, bottom: 8 })
                        .id('favorite_list_content')

                    }
                      } else if (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.TEXT) {
                        bubbleText({
                          conversationCtrl: $mFavoriteCtrl,
                          content: item.msgContent,
                          item: item,
                          itemIndex: index,
                          bubbleTextBackgroundColor: item.isSender === 0
                            ? $r('app.color.brand') : $r('sys.color.ohos_id_color_card_bg'),
                          isAdvancedSecurity: item.isAdvancedSecurity,
                          isSender: item.isSender,
                          detectResContent: item.detectResContent,
                          textDirection: this.textDirection,
                          listScroller :this.listScroller,
                          scrollEndIndex: this.scrollEndIndex,
                          scrollStartIndex: this.scrollStartIndex,
                          menuMultSelect: ((selectIndex) => {
                            this.multiSelectFlag = Visibility.Visible;
                            this.mFavoriteCtrl.listCheckBoxChange(selectIndex, true);
                          }),
                          menuDeleteCallBack: ((deleteItem) => {
                            this.longPressDeleteItem = deleteItem;
                            this.mFavoriteCtrl.clickLongPressDelete();
                            this.delConversionController.open();
                          })
                        })
                          .accessibilityGroup(true)
                        .margin({ top: 4, bottom: 8 })
                         .alignRules(this.favoriteContentAlignRules)
                         .id('favorite_list_content')
                        .constraintSize({ maxWidth: this.currentScreenWidth })
                      } else if (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE &&
                        this.mFavoriteCtrl.mmsRcsScreening(item.rcsId, commonData.MSG_ITEM_TYPE.IMAGE)) {
                        MmsContentImage({
                          imageProps: this.mFavoriteCtrl.mmsRcsScreening(item.rcsId,
                            commonData.MSG_ITEM_TYPE.IMAGE).locationPath ?? '',
                          screenWidth: this.screenWidth,
                          itemIndex: index,
                          item: item,
                          listScroller :this.listScroller,
                          scrollEndIndex: this.scrollEndIndex,
                          scrollStartIndex: this.scrollStartIndex,
                          menuMultSelect: ((selectIndex) => {
                            this.multiSelectFlag = Visibility.Visible;
                            this.mFavoriteCtrl.listCheckBoxChange(selectIndex, true);
                          }),
                          menuDeleteCallBack: ((deleteItem) => {
                            this.longPressDeleteItem = deleteItem;
                            this.mFavoriteCtrl.clickLongPressDelete();
                            this.delConversionController.open();
                          })
                        }).alignRules(this.favoriteContentAlignRules)
                            .id('favorite_list_content')
                      }
                  Text(dateUtil.getTime(Number(item.startTime)))
                    .fontSize(10)
                    .width(230)
                    .lineHeight(13)
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    .padding(this.textDirection === 'rtl' ? { right: 12 } : { left: 12 })
                    .margin({ top: 8 })
                    .alignRules({
                      top: { anchor: 'favorite_list_content', align: VerticalAlign.Bottom },
                      left: { anchor: 'favorite_list_name', align: HorizontalAlign.Start }
                    })

                  Toggle({
                    type: ToggleType.Checkbox,
                    isOn: this.checkBoxStatusHasChanged ? this.mFavoriteCtrl.favoriteList.mmsList[index]?.isCbChecked :
                      this.mFavoriteCtrl.favoriteList.mmsList[index]?.isCbChecked
                  })
                    .selectedColor($r('sys.color.font_emphasize'))
                    .width(20)
                    .height(20)
                    .visibility(this.ToggleStatus())
                    .offset({ y: -6 })
                    .onClick(() => {
                      this.mFavoriteCtrl.isClickMore = false
                      this.item = item;
                    })
                    .onChange(((isOn: boolean) => {
                      if (!this.isPanGestureUtil) {
                        this.mFavoriteCtrl.listCheckBoxChange(index, isOn);
                      }

                    }))
                    .responseRegion({ x: -2, y: -14, width: 24, height: 48 })
                    .alignRules({
                      right: { anchor: '__container__', align: HorizontalAlign.End }
                    })
                    .margin(this.textDirection === 'rtl' ?
                      {
                        right: this.isPC ? 24 : this.isPad ? this.padMargin : 16,
                        top: 50,
                        left: this.isPC ? 24 : $r('sys.float.margin_left')
                      } :
                      {
                        right: this.isPC ? 24 : $r('sys.float.margin_right'),
                        left: this.isPC ? 24 : this.isPad ? this.padMargin : 16,
                        top: 50
                      })
                }
                .width('100%')
                .height('auto')
                .renderGroup(true)
              }
            }, (item: LooseObject) => JSON.stringify(item))
            ListItem() {
              Row().width('100%').height('100%').backgroundColor(Color.Transparent)
            }.width('100%').height(this.multiSelectFlag== Visibility.Visible ? 0 : this.fullScreenPadding?.bottom)
          }
          .gesture(PanGesture({ direction: PanDirection.Vertical })
            .onActionStart((event: GestureEvent) => {
              this.isPanGestureUtil = true
              let params: PanGestureAction = {
                type: common.SLIDE_ACTION_TYPE.START,
                event,
                scroller: this.listScroller,
                isMultipleSelectState: !this.show,
                switchNumber: 0,
                mmsList: this.mFavoriteCtrl.favoriteList.mmsList
              }
              PanGestureUtil.panGestureAction(params)
            })
            .onActionUpdate((event: GestureEvent) => {
              let params: PanGestureAction = {
                type: common.SLIDE_ACTION_TYPE.UPDATE,
                event,
                scroller: this.listScroller,
                isMultipleSelectState: !this.show,
                switchNumber: 0,
                mmsList: this.mFavoriteCtrl.favoriteList.mmsList,
                callback: (i: number, startCbChecked: boolean) => {
                  this.mFavoriteCtrl.favoriteList.selectData(i, startCbChecked)
                  this.mFavoriteCtrl.gesTureListCheckBox(this.selectNumber)
                },
                listHeight: this.listHeight,
                scrollEndIndex: this.scrollEndIndex,
                scrollStartIndex: this.scrollStartIndex
              }
              PanGestureUtil.panGestureAction(params)
            })
            .onActionEnd((event: GestureEvent) => {
              this.isPanGestureUtil = false
              let params: PanGestureAction = {
                type: common.SLIDE_ACTION_TYPE.END,
                event,
                scroller: this.listScroller,
                isMultipleSelectState: !this.show,
                switchNumber: 0,
              }
              PanGestureUtil.panGestureAction(params)
            })
          )
          .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
            this.listWidth = newValue.width as number
            this.listHeight = newValue.height as number
          })
          .onGestureRecognizerJudgeBegin((event: BaseGestureEvent, current: GestureRecognizer,
            recognizers: Array<GestureRecognizer>) => {
            return PanGestureUtil.gestureRecognizerJudgeBegin(event, current, !this.show, this.listWidth)
          })
          .width('100%')
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
            if (scrollState === ScrollState.Scroll && this.isVDE && this.ableSlips && this.multiSelectFlag != Visibility.Visible) {
              // >0 向下滑动
              if (scrollOffset > 0) {
                if (!this.isScrolling &&
                  Math.abs(this.initialCurrentYOffset - this.listScroller.currentOffset()?.yOffset) >= 26) {
                  animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 2000 }, () => {
                    HiLog.i(TAG, 'onDidScroll scrollOffset > 0 :' + scrollOffset);
                    this.isScrolling = true;
                  })
                } else if (this.isScrolling) {
                  this.initialCurrentYOffset = this.listScroller.currentOffset()?.yOffset;
                }
              } else if (scrollOffset < 0) {
                if (this.isScrolling &&
                  Math.abs(this.initialCurrentYOffset - this.listScroller.currentOffset()?.yOffset) >= 26) {
                  animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 2000 }, () => {
                    HiLog.i(TAG, 'onDidScroll scrollOffset < 0 :' + scrollOffset);
                    this.isScrolling = false;
                  })
                } else if (!this.isScrolling) {
                  this.initialCurrentYOffset = this.listScroller.currentOffset()?.yOffset;
                } else if (this.listScroller.currentOffset()?.yOffset <= -56) {
                  animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 1000 }, () => {
                    this.isScrolling = false;
                  })
                }
              }
            }
          })
          .onScrollStart(() => {
            this.isScrollingStart = true;
          })
          .onScrollIndex((start, end) => {
            this.scrollStartIndex = start;
            this.scrollEndIndex = end;
          })
          .onScrollStop(() => {
            this.initialCurrentYOffset = this.listScroller.currentOffset()?.yOffset;
          })
          .clipContent(ContentClipMode.SAFE_AREA)
          .onReachStart(() => {
            this.initialCurrentYOffset = this.listScroller.currentOffset()?.yOffset;
          })
          .onReachEnd(() => {
            if (this.isVDE && this.listLength != this.mFavoriteCtrl.favoriteList.mmsList.length) {
              this.listLength = this.mFavoriteCtrl.favoriteList.mmsList.length;
              this.isScrollingStart = false;
            }
            if (this.isVDE && !this.isScrollingStart) {
              if (this.listScroller.currentOffset()?.yOffset <= -50) {
                HiLog.i(TAG, 'onReachEnd ableSlips is false')
                this.ableSlips = false;
                this.isScrolling = false;
              } else {
                this.ableSlips = true;
              }
            }
            if (this.ableSlips && this.isScrolling) {
              HiLog.i(TAG,'favorite onReachEnd');
              // 滑动到底部且隐藏状态，显示
              animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 2000 }, () => {
                this.listScroller.scrollEdge(Edge.End)
                this.isScrolling = false;
              })
            }
          })
          .alignRules(this.multiSelectFlag === Visibility.Visible ? {
            top: { anchor: '__container__', align: VerticalAlign.Top },
            bottom: { anchor: 'bottom_bar_menus', align: VerticalAlign.Top }
          } : {
            top: { anchor: '__container__', align: VerticalAlign.Top },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
          })
          .scrollBar(BarState.Off)
          ScrollBar({
            scroller: this.listScroller,
            direction: ScrollBarDirection.Vertical,
            state: BarState.Auto
          })
            .margin({ bottom: this.multiSelectFlag == Visibility.Visible ?
            this.fullScreenPadding?.bottom as number + 52 : this.fullScreenPadding?.bottom })
            .position({ right: 0 })
        }
        // 没有收藏信息
        else {
          EmptyPage({
            icon: $rawfile('icon/ic_favoriteMessage_m.svg'),
            emptyDescription: $r('app.string.no_star_info'),
            customBackgroundColor: $r('sys.color.ohos_id_color_sub_background'),
            fullPage: true,
            fixedPageHeight: true,
          })
            .padding({bottom: this.fullScreenPadding ? (this.fullScreenPadding.bottom as number) : 0})
        }
        if (this.multiSelectFlag === Visibility.Visible) {
          this.bottomBarMenus()
        }
      }
      .width('100%')
      .height('100%')
      .renderGroup(false)
    }
    .bindSheet(this.isFavoriteTransmitShow && this.isPC, this.transmitBuilder(), {
      height: SheetSize.LARGE,
      blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
      showClose: true,
      preferType: SheetType.CENTER,
      title: { title: ResourceUtils.getStringSync($r('app.string.transmitHeadText'))},
      shouldDismiss: () => {
        AppStorage.setOrCreate('isFavoriteTransmitShow', false);
      },
    })
    .hideTitleBar((this.isVDE && this.isScrolling), true)
    .hideBackButton(this.curBp !== common.STR.DEVICE_MOBILE_PHONE && this.multiSelectFlag !== Visibility.Visible ?
      true : false)
    .bindToScrollable([this.listScroller])
    // .titleBar(TitleBarUtil.getTitleBar({ mainTitle: TitleBarUtil.isShowTitle &&
    //   this.curBp !== common.STR.DEVICE_MOBILE_PHONE ? undefined : $r('app.string.favorites'),
    //   enableComponentSafeArea: true,
    //   stackBuilder: TitleBarUtil.isShowTitle && this.curBp !== common.STR.DEVICE_MOBILE_PHONE ?
    //   this.navTitle.bind(this) : undefined,
    //   backgroundColor: $r('sys.color.ohos_id_color_toolbar_sub_bg'), isMultipleSelectState: !this.show,
    //   selectedNumber: this.selectNumber, callback: () => { this.destinationBackPress() } }))
    .title($r('app.string.favorites'))
    .width('100%')
    .height('100%')
    .padding({ top: this.isPC ? 56 : 0 })
    .backgroundColor($r('sys.color.ohos_id_color_toolbar_sub_bg'))
    .onShown(() => {
      this.destinationShow();
    })
    .onBackPressed(() => {
      return this.destinationBackPress();
    })
  }

  backButtonAccessibilityText(): ResourceStr {
    return !this.show ? getContext(this).resourceManager.getStringSync($r('app.string.disable').id) :
    getContext(this).resourceManager.getStringSync($r('app.string.guide_action_text_previous').id)
  }

  ToggleStatus(){
    return this.multiSelectFlag;
  }

  destinationBackPress(): boolean {

    if (this.multiSelectFlag === Visibility.Visible) {
      this.cancelSelectState();
      return true;
    }
    if (AppStorage.get('curBp') as string !== common.STR.DEVICE_MOBILE_PHONE) {
      DeviceUtil.foldMenuPageBack(this.pageInfos)
    } else {
      this.pageInfos?.pop();
    }
    return true;
  }

  cancelSelectState() {
    this.multiSelectFlag = Visibility.None;
    this.show = true;
    PanGestureUtil.refresh()
    this.mFavoriteCtrl.isClickMore = true;
    this.mFavoriteCtrl.resetSelectData();
    this.mFavoriteCtrl.resetMmsCount();
    this.mFavoriteCtrl.cancelCheckedAll();
    this.mFavoriteCtrl.conversationListDataSource.reload(this.mFavoriteCtrl.messageList, 'cancelSelectState');
  }

  /**
   * 长按删除回调
   * @param deleteItem：长按的item
   */
  LongPressDeleteAction(deleteItem: LooseObject) {
    this.longPressDeleteItem = deleteItem;
    this.mFavoriteCtrl.clickLongPressDelete();
    this.delConversionController.open();
  }

  // 查看 vcard 弹框
  checkVcardDialog: CustomDialogController = new CustomDialogController({
    builder: MMCheckVcardDialog({
      path: this.mFavoriteCtrl.getVcardPath()
    }),
    autoCancel: true,
    cancel: () => {
      this.checkVcardDialog?.close();
    },
    alignment: DialogAlignment.Center,
  })

  importVcard() {
    SharedPreferencesUtils.deletePreferences(this.mFavoriteCtrl.getVcardPath())
    if (!this.savedFileInfo) {
      return
    }
    let vcfFileInfo: SavedFileInfo = this.savedFileInfo;
    const name: string = 'vcard_temp.vcf'
    promptAction.showToast({
      message: $r('app.string.msg_vCard_import_success', name),
      duration: 200
    });
    VCardUtil.getInstance().importVCard(this.context, vcfFileInfo.path, (result: boolean) => {
      HiLog.i(TAG, 'import vcard result: ' + result);
      setTimeout(() => {
        promptAction.showToast({
          message: $r('app.string.vCard_import_success', name),
          duration: 200
        });
      }, 300)
    })
    this.mmConfirmVcardDialog.close();
  }

  // 确认导入 vcard 弹框
  mmConfirmVcardDialog: CustomDialogController = new CustomDialogController({
    builder: MMAskIsImportDialog({
      confirmed: () => {
        this.importVcard()
      },
    }),
    autoCancel: true,
    cancel: () => {
      this.mmConfirmVcardDialog?.close();
    },
    gridCount: 4
  })

  // 保存 vcard 弹框
  mmSaveVcardDialog: CustomDialogController = new CustomDialogController({
    builder: MMSaveVcardDialog({
      path: this.mFavoriteCtrl.getVcardPath(),
      confirmed: async (savedFileInfo: SavedFileInfo) => {
        this.handleSaveVcard(savedFileInfo)
      },
    }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
  })

  async handleSaveVcard(savedFileInfo: SavedFileInfo) {
    this.savedFileInfo = savedFileInfo;
    let atManager = abilityAccessCtrl.createAtManager();
    let info = await bundleManager.getApplicationInfo(commonData.STR.BUNDLE_NAME,
      bundleManager.ApplicationFlag.GET_APPLICATION_INFO_WITH_PERMISSION);
    let hasPermission =
      atManager.verifyAccessTokenSync(info.accessTokenId, 'ohos.permission.WRITE_CONTACTS');
    HiLog.i(TAG, 'check permission: ' + hasPermission);
    if (hasPermission === 0) {
      this.mmConfirmVcardDialog.open();
      this.mmSaveVcardDialog.close();
    } else {
      let permissions: Permissions[] = ['ohos.permission.WRITE_CONTACTS'];
      let permissionResult = await atManager.requestPermissionsFromUser(this.context, permissions);
      HiLog.i(TAG, 'check permission: ' + JSON.stringify(permissionResult.authResults));
      if (permissionResult.authResults[0] == 0) {
        this.mmConfirmVcardDialog.open();
        this.mmSaveVcardDialog.close();
      }
    }
  }

  @Builder
  showVcardMenuItem(data: LooseObject) {
    MenuItem({ content: data.isSender === 0 ? $r('app.string.view_vCard_details')
      : $r('app.string.save_to_contacts') })
      .onClick(() => {
        if (data.isSender === 0) {
          this.checkVcardDialog.open()
        } else {
          this.mmSaveVcardDialog.open()
        }
      })
      .width('100%')
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium })
      .enabled(VCardUtil.isVcard(data))
      .padding(data.textDirection === 'rtl' ? { right: 12 } : { left: 12 })
      .contentFontColor($r('sys.color.ohos_id_color_text_primary'))
    Divider().strokeWidth('app.float.settings_divider_strokeWidth')
      .color($r('sys.color.ohos_id_color_list_separator')).margin({ left: 12, right: 12 })
  }

  @Builder
  MenuBuilder(item: LooseObject = {}) {
    if (this.selectNumber === 1) {
      Column() {
        // Select this text
        MenuItem({ content: $r('app.string.msg_select_text') })
          .onClick(() => {
            this.mFavoriteCtrl.longPressSelected(3);
          })
          .enabled(!(item.isMsm || (item.isMsm && item.content)) ||
          getIsMmsMapMessageByMmsSource(Boolean(item.isRcs), item?.mmsSource))
          .padding({ left: 12 })
          .width('100%')

        Divider()
          .strokeWidth('app.float.settings_divider_strokeWidth')
          .color($r('sys.color.ohos_id_color_list_separator'))
          .margin({ left: 12, right: 12 })

        if (VCardUtil.isVcard(item)) {
          this.showVcardMenuItem(item)
        }
        MenuItem({ content: $r('app.string.share') })
          .onChange(() => {
            this.mFavoriteCtrl.shareMessage();
            this.cancelSelectState();
          })
          .padding({ left: 12 })
          .width('100%')
          .enabled(this.isShare(item))
          .visibility(this.isOsAccountConstraintEnabled ? Visibility.None : Visibility.Visible)
      }
      .width('216vp')
      .align(Alignment.Start)
    }
  }

  /**
   * 多选分享功能是否可用
   * 在选择一条消息的场景下
   * @param item
   * @returns
   */
  isShare(item: LooseObject = {}) {
    return ((item.isRcs === common.MESSAGE_TYPE.RCS && (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.VCARD ||
      item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.FILE ||
      item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE ||
      item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.MAP ||
      item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.CHATBOT_CARD)
    ) || (MmsUtil.isSlideType(item.contentType) && item.rcsType !== commonData.ENHANCED_INFO_ITEM_TYPE.TEXT))
      ? false : true;
  }

  /**
   * 获取多选模式下底部按钮栏的复制按钮是否可用
   */
  private getIsCopyButtonEnabled = () => {
    if (!this.mFavoriteCtrl.getMmsCount() && this.selectNumber > 0 && this.selectNumber <= 30 &&
      this.mFavoriteCtrl.mmsCount <= 0) {
      return true;
    } else { // 单选彩信位置消息时可用
      let item = this.mFavoriteCtrl.mmsListFromFavo?.[this.mFavoriteCtrl.mmsIndex];
      return (item && this.selectNumber === 1 && getIsMmsMapMessageByMmsSource(Boolean(item.isRcs), item.mmsSource));
    }
  }

  @Builder
  bottomBarMenus() {
    Flex() {
      // 删除
      Column() {
        SymbolGlyph($r('sys.symbol.trash'))
          .width('24vp')
          .height('24vp')
          .fontSize('24vp')
          .fontColor([$r('sys.color.ohos_id_color_primary')])
          .responseRegion({
            x: -14,
            y: -6,
            width: 52,
            height: 52
          })
          .margin({ top: 6 })
        Text($r('app.string.delete'))
          .textAlign(TextAlign.Center)// .width('20%')
          .height('12vp')
          .fontSize('10vp')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .margin({ top: 6 })
          .id('bottom_bar_delete_menu')
      }
      .layoutWeight(1)
      .layoutWeight(1)
      .accessibilityLevel('yes')
      .accessibilityGroup(true)
      .accessibilityRole(AccessibilityRoleType.BUTTON)
      .opacity(this.selectNumber === 0 ? 0.4 : 1)
      .enabled(this.selectNumber === 0 ? false : true)
      .onClick(() => {
        if (this.selectNumber != 0) {
          this.mFavoriteCtrl.clickGroupDelete();
          this.longPressDeleteItem = null;
          this.delConversionController.open();
        }
      })
      .height('52vp')

      // 转发
      Column() {
        SymbolGlyph($r('sys.symbol.rectangle_and_arrowshape_turn_up_right'))
          .width('24vp')
          .height('24vp')
          .fontSize('24vp')
          .fontColor([$r('sys.color.ohos_id_color_primary')])
          .responseRegion({
            x: -12,
            y: 0,
            width: 48,
            height: 52
          })
          .margin({ top: 6 })
        Text($r('app.string.msg_transmit'))
          .textAlign(TextAlign.Center)// .width('20%')
          .height('12vp')
          .fontSize('10vp')

          .margin({ top: 6 })
          .id('bottom_bar_transmit_menu')
      }
      .layoutWeight(1)
      .layoutWeight(1)
      .accessibilityLevel('yes')
      .accessibilityGroup(true)
      .accessibilityRole(AccessibilityRoleType.BUTTON)
      .opacity((!this.mFavoriteCtrl.getMmsCount() && this.selectNumber > 0 &&
        this.selectNumber <= 30 &&
        this.mFavoriteCtrl.audioStatus !== common.MMS_AUDIO_STATUS.ONLY_AUDIO &&
        this.mFavoriteCtrl.richMediaCards !== common.MMS_AUDIO_STATUS.ONLY_AUDIO &&
        !this.isOsAccountConstraintEnabled) ? 1 : 0.4)
      .enabled((!this.mFavoriteCtrl.getMmsCount() && this.selectNumber > 0 &&
        this.selectNumber <= 30 &&
        this.mFavoriteCtrl.audioStatus !== common.MMS_AUDIO_STATUS.ONLY_AUDIO &&
        this.mFavoriteCtrl.richMediaCards !== common.MMS_AUDIO_STATUS.ONLY_AUDIO &&
        !this.isOsAccountConstraintEnabled) ? true : false)
      .visibility(this.isSelectDelete ? Visibility.None : Visibility.Visible)
      .onClick(() => {
        if (this.selectNumber !== 0) {
          if (this.mFavoriteCtrl.audioStatus !== common.MMS_AUDIO_STATUS.NO_AUDIO &&
          this.mFavoriteCtrl.isNeedTransmitTip()) {
            this.transmitAudioDialogController.open();
          } else {
            GlobalContext.getContext().setObject('notUpdateData', true)
            this.mFavoriteCtrl.transmitMsg();
          }
        }
      })
      .height('52vp')

      // 复制
      Column() {
        SymbolGlyph($r('sys.symbol.plus_square_on_square'))
          .width('24vp')
          .height('24vp')
          .fontSize('24vp')
          .fontColor([$r('sys.color.ohos_id_color_primary')])
          .responseRegion({
            x: -12,
            y: 0,
            width: 48,
            height: 52
          })
          .margin({ top: 6 })
        Text($r('app.string.msg_copy'))
          .textAlign(TextAlign.Center)// .width('20%')
          .height('12vp')
          .fontSize('10vp')
          .margin({ top: 6 })
          .id('bottom_bar_copy_menu')
      }
      .layoutWeight(1)
      .layoutWeight(1)
      .accessibilityLevel('yes')
      .accessibilityGroup(true)
      .accessibilityRole(AccessibilityRoleType.BUTTON)
      .opacity(this.getIsCopyButtonEnabled() ? 1 : 0.4)
      .enabled(this.getIsCopyButtonEnabled() ? true : false)
      .onClick(() => {
        this.mFavoriteCtrl.longPressSelected(0);
        this.cancelSelectState();
      })
      .height('52vp')

      // 全选
      Column() {
        SymbolGlyph(this.mFavoriteCtrl.isMessageCheckAll ? $r('sys.symbol.checkmark_square_on_square_fill') :
        $r('sys.symbol.checkmark_square_on_square'))
          .width('24vp')
          .height('24vp')
          .fontSize('24vp')
          .fontColor(this.mFavoriteCtrl.isMessageCheckAll ? [$r('app.color.brand')] :
            [$r('sys.color.ohos_id_color_primary')])
          .onClick(() => {
            this.mFavoriteCtrl.clickGroupCheckAll()
          })
          .responseRegion({
            x: -12,
            y: 0,
            width: 48,
            height: 52
          })
          .margin({ top: 6 })
        Text(this.mFavoriteCtrl.isMessageCheckAll ? $r('app.string.msg_deselect_all') : $r('app.string.msg_select_all'))
          .textAlign(TextAlign.Center)// .width('20%')
          .height('12vp')
          .fontSize('10vp')
          .fontColor(this.mFavoriteCtrl.isMessageCheckAll ? $r('sys.color.ohos_id_color_text_primary_activated') :
          $r('sys.color.ohos_id_color_text_primary'))
          .onClick(() => {
            this.mFavoriteCtrl.clickGroupCheckAll()
          })
          .margin({ top: 6 })
          .id('bottom_bar_chooseall_menu')
      }
      .layoutWeight(1)
      .accessibilityLevel('yes')
      .accessibilityGroup(true)
      .accessibilityRole(AccessibilityRoleType.BUTTON)
      .onClick(() => {
        this.mFavoriteCtrl.clickGroupCheckAll()
      })
      .height('52vp')

      // 更多
      Column() {
        SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
          .width('24vp')
          .height('24vp')
          .fontSize('24vp')
          .fontColor([$r('sys.color.ohos_id_color_primary')])
          .responseRegion({
            x: -12,
            y: -4,
            width: 52,
            height: 52
          })
          .margin({ top: 6 })
        Text($r('app.string.more'))
          .textAlign(TextAlign.Center)// .width('20%')
          .height('12vp')
          .fontSize('10vp')
          .responseRegion({
            x: 0,
            y: 0,
            width: '100%',
            height: 52
          })
          .margin({ top: 6 })
          .id('bottom_bar_more_menu')
      }
      .layoutWeight(1)
      .bindMenu(this.MenuBuilder(this.mFavoriteCtrl.mmsListFromFavo[this.mFavoriteCtrl.mmsIndex]),
        { placement: Placement.TopRight, offset: { x: -16, y: 4 } }
      )
      .accessibilityLevel('yes')
      .accessibilityGroup(true)
      .accessibilityRole(AccessibilityRoleType.BUTTON)
      .enabled(this.selectNumber === 0 || this.selectNumber > 1 ? false : true)
      .opacity(
        (this.selectNumber === 0 || this.selectNumber > 1) ? 0.4 : 1
      )
      .visibility(this.isSelectDelete ? Visibility.None : Visibility.Visible)
      .height('52vp')
    }
    .width('100%')
    .height('52vp')
    .translate({ y: this.isVDE && this.isScrolling ? 52 : 0 })
    .alignRules({
      bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
    })
    .margin({
      bottom: this.fullScreenPadding
        ? (this.fullScreenPadding.bottom as number) : 0 as number
    })
    .id('bottom_bar_menus')
  }

}

@Component
struct bubbleText {
  @Prop scrollEndIndex: number = -1
  @Prop scrollStartIndex: number = -1
  public listScroller?: ListScroller
  @Link conversationCtrl: ConversationListDataSource;
  private content: string = ''; // Bubble Display Content
  private bubbleTextBackgroundColor?: Resource | string; // Bubble background color
  private itemIndex: number = 0;
  private item: LooseObject = {}
  private context = getContext(this) as myCommon.UIAbilityContext;
  @State showMenu: boolean = false;
  @State isPad: boolean = DeviceUtil.isTablet();
  @Consume index: number;
  @Consume multiSelectFlag: Visibility;
  @Consume contentHeight: number;
  @Consume show: boolean;
  @Consume mFavoriteCtrl: FavoriteController;
  private shouldShowBubble: boolean = true;
  private defaultEmojiSize: number = 16;
  private defaultTextHeight: number = 21;
  private withoutBubbleEmojiSize: number = 24;
  private withoutBubbleTextHeight: number = 36;
  private isAdvancedSecurity: boolean = false;
  private isSender: number = 0;
  private highlights: Array<HighlightsOptions> = [];
  private detectResContent: string = '';
  @Prop textDirection: string = '';
  @StorageLink('curBp') curBp: string = common.STR.DEVICE_MOBILE_PHONE;
  @StorageLink('windowWidth') deviceWidth: number = 0;
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;
  @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();
  @StorageProp('isShowContactHeadIcon') isShowHead: boolean = true;
  @StorageLink('mmsScreenPercentage') mmsScreenPercentage: string = '50%';
  @StorageLink('mmsNavMode') curNavMode: number = 0;
  menuMultSelect: (index: number) => void = () => {
  };
  //点击长按删除回调
  menuDeleteCallBack: (deleteItem: LooseObject) => void = () => {
  };
  @State isPC: boolean = DeviceUtil.isPC()
  /* 仅用于PC分布式短信场景，用于获取用户管控权限 */
  public isOsAccountConstraintEnabled: boolean = false;
  @State accessibilityStr: string = '';
  @StorageLink('isScreenReaderOpen') @Watch('accessibilityStatusChange') isReaderOpen: boolean = false;

  aboutToAppear() {
    if (this.mFavoriteCtrl.searchContent !== '') {
      this.highlights = Highlight.getInstance().getHighlightTexts(this.content, this.mFavoriteCtrl.searchContent);
    }
    this.shouldShowBubble = this.mFavoriteCtrl.showBubbleOrEmoji(this.content)
    this.getPermissionControl()
    this.updateAccessibilityString();
  }

  accessibilityStatusChange() {
    this.updateAccessibilityString();
  }

  private updateAccessibilityString() {
    if (this.isReaderOpen) {
      this.accessibilityStr = AccessibilityUtil.getBubbleTextAccessibilityStrBy(this.detectResContent, this.context);
    } else {
      this.accessibilityStr = '';
    }
  }

  private async getPermissionControl() {
    this.isOsAccountConstraintEnabled = await DistributedUtil.isOsAccountConstraintEnabled()
  }

  @Builder
  longPressMenuBuild() {
    Menu() {
      // 多选
      this.multSelectMenuButton()
      this.multDivider()
      // 复制
      this.copyMenuButton()
      this.multDivider()
      // 转发
      if (!this.isOsAccountConstraintEnabled) {
        this.transmitMenuButton()
        this.multDivider()
      }
      // 选择文本
      this.selectTextMenuButton()
      this.multDivider()
      // 删除
      this.deleteMenuButton()
    }
    .width('224vp')
  }

  @Builder
  multDivider() {
    Divider()
      .color($r('sys.color.comp_divider'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({
        left: $r('app.float.conversation_item_press_Shadow_padding_left'),
        right: $r('app.float.conversation_item_press_Shadow_padding_left')
      })
  }

  @Builder
  multSelectMenuButton() {
    MenuItem({ content: $r('app.string.select_more') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.show = false;
        this.showMenu = false;
        this.mFavoriteCtrl.isSelectStatus = true;
        this.mFavoriteCtrl.mmsIndex = this.index;
        this.item.isCbChecked = true;
        this.multiSelectFlag = Visibility.Visible
        this.menuMultSelect(this.itemIndex);
        PanGestureUtil.addFirstSelect(this.itemIndex, this.item.isCbChecked, true)
      })
  }

  @Builder
  copyMenuButton() {
    MenuItem({ content: $r('app.string.msg_copy') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.mFavoriteCtrl.mmsIndex = this.itemIndex
        this.mFavoriteCtrl.longPressSelected(0);
        this.showMenu = false;
      })
  }

  @Builder
  transmitMenuButton() {
    MenuItem({ content: $r('app.string.msg_transmit') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.mFavoriteCtrl.mmsIndex = this.itemIndex
        setTimeout(() =>{
          this.mFavoriteCtrl.longPressSelected(1)
        }, 300);
        this.showMenu = false
      })
  }

  @Builder
  selectTextMenuButton() {
    MenuItem({ content: $r('app.string.msg_select_text') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.mFavoriteCtrl.mmsIndex = this.itemIndex
        setTimeout(() =>{
          this.mFavoriteCtrl.longPressSelected(3);
        }, 300)
      })
  }

  @Builder
  deleteMenuButton() {
    MenuItem({ content: $r('app.string.delete') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        setTimeout(() =>{
          this.menuDeleteCallBack(this.item);
        }, 300);
        this.showMenu = false;
      })
  }

  @Styles
  normalStyles(){
    .backgroundColor(this.shouldShowBubble ? this.bubbleTextBackgroundColor : Color.Transparent)
  }

  @Styles
  pressedStyles(){
    .backgroundColor(this.shouldShowBubble ? this.bubbleTextBackgroundColor : Color.Transparent)
  }

  private getEnableDataDetectorFlag(): boolean {
    let flag = (this.multiSelectFlag == Visibility.Visible ? false : true)
    HiLog.iw(TAG, 'getEnableDataDetectorFlag:' + flag);
    return flag;
  }

  build() {
    Row() {
      if (this.mFavoriteCtrl.searchContent === '' ||
        (this.mFavoriteCtrl.searchContent !== '' && this.content.indexOf(this.mFavoriteCtrl.searchContent) == -1) ||
      GlobalContext.getContext().getObject('isFontNormal')) {
        Text(this.detectResContent === '' ? this.content :
          (this.isAdvancedSecurity ? this.content : this.detectResContent)) {
          Span(this.content)
        }
          .wordBreak(WordBreak.BREAK_ALL)
          .fontSize(this.shouldShowBubble ? this.defaultEmojiSize : this.withoutBubbleEmojiSize)
          .lineHeight(this.shouldShowBubble ? this.defaultTextHeight : this.withoutBubbleTextHeight)
          .maxFontScale(this.shouldShowBubble ? 5 : 2)
          .fontColor(this.item.isSender === 0 ? $r('sys.color.font_on_primary') : $r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Regular)
          .fontFeature('\"ss08\" 1')
          .enableDataDetector(this.getEnableDataDetectorFlag())
          .dataDetectorConfig( {types: [],
            color: this.item.isSender === 0 ? $r('sys.color.font_on_primary') : ''})
          .copyOption(this.multiSelectFlag == Visibility.Visible || this.showMenu
            ? CopyOptions.None : CopyOptions.LocalDevice)
          .attributeModifier(new TextAccessibilityModifier(this.accessibilityStr))
      } else {
        Text() {
          ForEach(this.highlights, (contentData: LooseObject) => {
            Span(contentData.text)
              .fontWeight(contentData.type === HighlightType.normal ? FontWeight.Regular : FontWeight.Bold)
          })
        }
        .fontSize(this.shouldShowBubble ? this.defaultEmojiSize : this.withoutBubbleEmojiSize)
        .lineHeight(this.shouldShowBubble ? this.defaultTextHeight : this.withoutBubbleTextHeight)
        .maxFontScale(this.shouldShowBubble ? 5 : 2)
        .fontColor(this.item.isSender === 0 ? $r('sys.color.font_on_primary') : $r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Regular)
        .fontFeature('\"ss08\" 1')
        .enableDataDetector(this.getEnableDataDetectorFlag())
        .dataDetectorConfig( {types: [],
          color: this.item.isSender === 0 ? $r('sys.color.font_on_primary') : ''})
      }
    }
    .borderRadius(this.textDirection === 'rtl' ?
      { topLeft: 16, topRight: 2, bottomLeft: 16, bottomRight: 16 } :
      { topLeft: 2, topRight: 16, bottomLeft: 16, bottomRight: 16 })
    .padding({
      left: 12,
      right: 12,
      top: this.isPC ? 10 : 8,
      bottom: this.isPC ? 9 : 8
    })
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles
    })
    .accessibilityLevel('no')
    .constraintSize({ maxWidth: this.messageBubbleWidthChange(this.content) })
    .parallelGesture(
      GestureGroup(GestureMode.Exclusive,
        // 长按让showMenu为true，覆盖text自带的复制，让bindContextMenu生效
        LongPressGesture({ repeat: false, duration: 500 })
          .onAction(() => {
            if (this.multiSelectFlag == Visibility.None) {
              this.showMenu = true
            }
          })
        ,
        TapGesture({ count: 1 })
          .onAction(() => {
            if (this.mFavoriteCtrl.isSelectStatus) {
              this.mFavoriteCtrl.multiSelectMmsMsg(this.itemIndex);
              this.mFavoriteCtrl.listCheckBoxChange(this.itemIndex,
                !this.mFavoriteCtrl.mmsListFromFavo[this.itemIndex]?.isCbChecked);
            }
          })
      )
    )
    .bindContextMenu(this.showMenu, this.longPressMenuBuild, this.isPC ? {
      onAppear: () => {
        VibrationUtils.onceVibration(commonData.VIBRATIONEFFECT.LONG_PRESS_MEDIUM)
      },
      onDisappear: () => {
        if (this.itemIndex === this.scrollStartIndex) {
          this.listScroller?.scrollToIndex(this.itemIndex, false, ScrollAlign.START);
        } else if (this.itemIndex === this.scrollEndIndex) {
          this.listScroller?.scrollToIndex(this.itemIndex, false, ScrollAlign.END);
        }
        this.showMenu = false;
      }
    } : {
      placement: Placement.BottomLeft,
      preview: MenuPreviewMode.IMAGE,
      previewAnimationOptions: {
        scale: [0.95, 1.1]
      },
      onAppear: () => {
        VibrationUtils.onceVibration(commonData.VIBRATIONEFFECT.LONG_PRESS_MEDIUM)
      },
      onDisappear: () => {
        if (this.itemIndex === this.scrollStartIndex) {
          this.listScroller?.scrollToIndex(this.itemIndex, false, ScrollAlign.START);
        } else if (this.itemIndex === this.scrollEndIndex) {
          this.listScroller?.scrollToIndex(this.itemIndex, false, ScrollAlign.END);
        }
        this.showMenu = false;
      }
    })
  }

  private calCurPageRatio(): number {
    if (this.curNavMode === common.int.NAVIGATION_MODE_STACK) {
      return 1;
    }

    try {
      if (!this.mmsScreenPercentage || !this.mmsScreenPercentage.endsWith('%')) {
        return 0.5;
      }
      let percentage = Number(this.mmsScreenPercentage.replace('%', ''));
      if (isNaN(percentage) || percentage < 0 || percentage > 100) {
        return 0.5;
      }
      return 1 - percentage / 100;
    } catch (error) {
      HiLog.e(TAG, 'Failed to calculate page ratio, error: ' + JSON.stringify(error));
      return 0.5;
    }
  }

  private messageBubbleWidthChange(content: string): string {
    HiLog.i(TAG, 'messageBubbleWidthChange by content');
    if (this.curBp === common.STR.DEVICE_MOBILE_PHONE) {
      return this.setWidth(1, content);
    } else if (this.curBp === common.STR.DEVICE_Folding_SCREEN) {
      return this.setWidth(this.calCurPageRatio(), content);
    } else {
      if (this.padMargin === DeviceUtil.padPortraitMargin) {
        return this.setWidth(0.5, content);
      }
      return this.setWidth(0.6, content);
    }
  }

  private setWidth(screenPercent: number, content: string): string {
    let currentScreenWidthForNumber: number = this.deviceWidth * screenPercent * 0.8;
    if (this.isShowHead) {
      if (this.isPad) {
        currentScreenWidthForNumber = this.deviceWidth * screenPercent * 0.8 - 40 - this.padMargin;
      } else {
        currentScreenWidthForNumber = this.deviceWidth * screenPercent * 0.8  - 56;
      }
    } else {
      currentScreenWidthForNumber = this.deviceWidth * screenPercent * 0.8 - 20;
    }
    if (this.multiSelectFlag == Visibility.Visible) {
      currentScreenWidthForNumber = currentScreenWidthForNumber - 20 - 8;
    }
    const fullTextWidthPx: number = MeasureText.measureText({
      textContent: content,
      fontSize: this.shouldShowBubble ? this.defaultEmojiSize * this.fontSizeScale :
        this.withoutBubbleEmojiSize * this.fontSizeScale
    });
    const fullTextWidthVp: number = px2vp(fullTextWidthPx);
    if (fullTextWidthVp <= currentScreenWidthForNumber - 24) {
      return 'auto'
    } else {
      return currentScreenWidthForNumber + 'vp'
    }
  }
}

@Component
struct MmsContentImage {
  @Prop scrollEndIndex: number = -1
  @Prop scrollStartIndex: number = -1
  public listScroller?: ListScroller
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State imageProps: string = ''
  @State imagePixmap?: PixelMap = undefined;
  private itemIndex: number = 0;
  @Consume multiSelectFlag: Visibility;
  @State ct: string = '';
  @Consume contentHeight: number;
  @Consume show: boolean;
  isFromTransmit: boolean = false;
  imgWidth: number = 0;
  imgHeight: number = 0;
  private context = getContext(this) as myCommon.UIAbilityContext;
  audioPlayerService: AudioPlayerService = AudioPlayerService.getInstance();
  @State imageWidth: number = 0;
  @State imageHeight: number = 0;
  @State imgFavoriteWidth: number = 0;
  @State imgFavoriteHeight: number = 0;
  @Link screenWidth: number;
  @Consume mFavoriteCtrl: FavoriteController;
  @State showMenu: boolean = false;
  @StorageLink('curBp') curBp: string = commonData.STR.DEVICE_MOBILE_PHONE;
  private item: LooseObject = {}
  private isSender: number = 0;
  @Consume storagePixelMap: HashMap<string, PixelMap>;
  @State imagePreData: ImagePreviewData = new ImagePreviewData()
  @StorageLink('windowWidth') @Watch('updateScreenWidth') windowWidth: number = 0;
  menuMultSelect: (index: number) => void = () => {
  };
  //点击长按删除回调
  menuDeleteCallBack: (deleteItem: LooseObject) => void = () => {
  };
  aboutToAppear() {
    this.updateScreenWidth();
  }

  updateScreenWidth() {
    this.getImagePixmap(this.imageProps);
    let windowWidth = AppStorage.get('windowWidth') as number;
    if (windowWidth) {
      this.screenWidth = this.curBp === commonData.STR.DEVICE_MOBILE_PHONE ?
        windowWidth : windowWidth / 2;
      this.imageWidth = this.screenWidth / 2;
      this.imageHeight = this.imageWidth;
    }
  }

  getImagePixmap(path: string) {
    let hasStorage: boolean = this.storagePixelMap.hasKey(path);
    HiLog.i(TAG, 'favorite hasStorage:' + hasStorage)
    if (hasStorage) {
      this.imagePixmap = this.storagePixelMap.get(path) as PixelMap;
    } else {
      HiLog.i(TAG, 'create favorite PixelMap' )
      ImageUtil.convertImageToPixmap(path).then((value: image.PixelMap) => {
        this.imagePixmap = value;
        this.storagePixelMap.set(path, this.imagePixmap);
      });
    }
  }

  @Builder
  longPressMenuBuild() {
    Menu() {
      // 多选
      this.multSelectMenuButton()
      this.multDivider()
      // 保存
      this.saveMenuButton()
      this.multDivider()
      // 转发
      this.transmitMenuButton()
      this.multDivider()
      // 删除
      this.deleteMenuButton()
    }
    .width('224vp')
  }

  @Builder
  multDivider() {
    Divider()
      .color($r('sys.color.comp_divider'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({
        left: $r('app.float.conversation_item_press_Shadow_padding_left'),
        right: $r('app.float.conversation_item_press_Shadow_padding_left')
      })
  }

  @Builder
  multSelectMenuButton() {
    MenuItem({ content: $r('app.string.select_more') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.show = false;
        this.showMenu = false;
        this.mFavoriteCtrl.isSelectStatus = true;
        this.mFavoriteCtrl.mmsIndex = this.itemIndex;
        this.item.isCbChecked = true;
        this.multiSelectFlag = Visibility.Visible;
        this.menuMultSelect(this.itemIndex);
      })
  }

  @Builder
  saveMenuButton() {
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
        .onClick(async () => {
          let mmsSource: Mms[] = this.item.mmsSource;
          let saveObject: Mms
          if (mmsSource.length > 1) {
            saveObject = mmsSource[1]
          } else {
            saveObject = mmsSource[0]
          }
          if (saveObject.type === commonData.MM_ATTACHMENT_TYPE.IMAGE) {
            this.mFavoriteCtrl.saveImageToPhotoAlbums(saveObject.path)
            this.showMenu = false;
          } else if (saveObject.type === commonData.MM_ATTACHMENT_TYPE.VIDEO) {
            this.mFavoriteCtrl.saveVideoToAlbums(saveObject.path)
            this.showMenu = false;
          }
        })
    }
    .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
  }

  @Builder
  transmitMenuButton() {
    MenuItem({ content: $r('app.string.msg_transmit') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.mFavoriteCtrl.mmsIndex = this.itemIndex
        setTimeout(() =>{
          this.mFavoriteCtrl.longPressSelected(1)
        }, 300);
        this.showMenu = false
      })
  }

  @Builder
  deleteMenuButton() {
    MenuItem({ content: $r('app.string.delete') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        setTimeout(() =>{
          this.menuDeleteCallBack(this.item);
        }, 300);
        this.showMenu = false;
      })
  }

  build() {
    Image(this.imagePixmap)
      .width(this.imageWidth)
      .height(this.imageHeight)
      .border({
        width: '1px',
        radius: '12vp',
        color: '#33A1A4B3'
      })
      .margin({ top: 4})
      .lightUpEffect(1)
      .draggable(false)
      .objectFit(ImageFit.Cover)
      .geometryTransition(this.imagePreData.getGeometryID(), { follow: false })
      .transition(TransitionEffect.OPACITY)
      .parallelGesture(
        GestureGroup(GestureMode.Exclusive,
          // 长按让showMenu为true，覆盖text自带的复制，让bindContextMenu生效
          LongPressGesture({ repeat: false, duration: 500 })
            .onAction(() => {
              if (this.multiSelectFlag == Visibility.None) {
                this.showMenu = true
              }
            })
          ,
          TapGesture({ count: 1 })
            .onAction(() => {
              if (this.mFavoriteCtrl.isSelectStatus) {
                this.mFavoriteCtrl.multiSelectMmsMsg(this.itemIndex);
                this.mFavoriteCtrl.listCheckBoxChange(this.itemIndex,
                  !this.mFavoriteCtrl.mmsListFromFavo[this.itemIndex]?.isCbChecked);
                return;
              }
              AppStorage.setOrCreate('stopAudio', { duration: '', type: -1, path: '', name: '' } as Mms);
              this.audioPlayerService.stopAudio();
              if (!this.isFromTransmit) {
                this.imagePreData.images = ImagePreviewData.handleImagePath([this.imageProps])
                this.imagePreData.imagePreviewShow()
              }
            })
        )
      )
        .bindContentCover(this.imagePreData.showImage, imagePreviewBuilder(this.imagePreData), {
        modalTransition: ModalTransition.NONE,
        onDisappear: () => {
          this.showMenu = false;
          this.imagePreData.imagePreviewHide();
        }
      })
      .onComplete(msg => {
        if (msg) {
          this.imgWidth = msg.width
          this.imgHeight = msg.height
        }
      })
      .priorityGesture(
        GestureGroup(GestureMode.Exclusive,
          TapGesture({ count: 2 })
            .onAction(() => {
            })
        )
      )
      .bindContextMenu(this.showMenu, this.longPressMenuBuild, {
        placement: Placement.BottomLeft,
        preview: MenuPreviewMode.IMAGE,
        previewAnimationOptions: {
          scale: [0.95, 1.1]
        },
        onAppear: () => {
          VibrationUtils.onceVibration(commonData.VIBRATIONEFFECT.LONG_PRESS_MEDIUM)
        },
        onDisappear: () => {
          if (this.itemIndex === this.scrollStartIndex) {
            this.listScroller?.scrollToIndex(this.itemIndex, false, ScrollAlign.START);
          } else if (this.itemIndex === this.scrollEndIndex) {
            this.listScroller?.scrollToIndex(this.itemIndex, false, ScrollAlign.END);
          }
          this.showMenu = false;
        }
      })
  }
}

@Component
struct MmsContentAudio {
  @Prop scrollEndIndex: number = -1
  @Prop scrollStartIndex: number = -1
  public listScroller?: ListScroller
  @Prop isSender: number = 0
  audioPlayerService: AudioPlayerService = AudioPlayerService.getInstance();
  item1: Mms = { duration: '', type: -1, path: '', name: '' };
  private context = getContext(this) as myCommon.UIAbilityContext;
  @State isOnAudio: boolean = false;
  @StorageLink('stopAudio') @Watch('stopAudioAction') stopAudio: Mms = { duration: '', type: -1, path: '', name: '' };
  @StorageLink('isBackProcess') @Watch('isBackProcessChange') isBackProcess: boolean = false;
  @Consume mFavoriteCtrl: FavoriteController;
  @State showMenu: boolean = false;
  private itemIndex: number = 0;
  @Consume multiSelectFlag: Visibility;
  @Consume show: boolean;
  private item: LooseObject = {}
  plusWidth: number = 0;
  @Prop textDirection: string = '';
  public isRcs: boolean = false;
  menuMultSelect: (index: number) => void = () => {
  };
  //点击长按删除回调
  menuDeleteCallBack: (deleteItem: LooseObject) => void = () => {
  };
  aboutToAppear() {
    if (this.item1.isOnAudio === undefined) {
      this.isOnAudio = false;
    } else {
      this.isOnAudio = this.item1.isOnAudio
    }
  }

  stopAudioAction() {
    if (this.stopAudio) {
      if (this.item1.name === this.stopAudio.name) {
        this.item1.isOnAudio = false;
        this.isOnAudio = false;
      }
    }
  }

  isBackProcessChange() {
    if (this.isBackProcess) {
      this.item1.isOnAudio = false;
      this.isOnAudio = false;
    }
  }

  @Builder
  longPressMenuBuild() {
    Menu() {
      // 多选
      this.multSelectMenuButton()

      this.multDivider()
      // 删除
      this.deleteMenuButton()
    }
    .width('224vp')
  }

  @Builder
  multDivider() {
    Divider()
      .color($r('sys.color.comp_divider'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({
        left: $r('app.float.conversation_item_press_Shadow_padding_left'),
        right: $r('app.float.conversation_item_press_Shadow_padding_left')
      })
  }

  @Builder
  multSelectMenuButton() {
    MenuItem({ content: $r('app.string.select_more') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.show = false;
        this.showMenu = false;
        this.mFavoriteCtrl.isSelectStatus = true;
        this.mFavoriteCtrl.mmsIndex = this.itemIndex;
        this.item.isCbChecked = true;
        this.multiSelectFlag = Visibility.Visible;
        this.menuMultSelect(this.itemIndex);
      })
  }

  @Builder
  deleteMenuButton() {
    MenuItem({ content: $r('app.string.delete') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        setTimeout(() =>{
          this.menuDeleteCallBack(this.item);
        }, 300);
        this.showMenu = false;
      })
  }

  getWidth() {
    let timeSecond = DateUtil.getDuration(this.item1.duration);
    this.plusWidth = (commonData.int.MESSAGE_MAX_WIDTH - commonData.int.MMS_MESSAGE_MIN_WIDTH) /
      MAX_DURATION * timeSecond
    return this.plusWidth + commonData.int.MMS_MESSAGE_MIN_WIDTH;
  }

  build() {
    Row() {
      if (this.isSender === 0) {
        SymbolGlyph($r('sys.symbol.wave_3_left'))
          .draggable(false)
          .margin({ end: LengthMetrics.vp(commonData.int.AUDIO_MESSAGE_MARGIN) })
          .fontColor([$r('sys.color.ohos_id_color_primary_contrary')])
          .fontSize($r('sys.float.Body_L'))
          .maxFontScale(FontSizeScale.HUGE_2)
          .symbolEffect(new HierarchicalSymbolEffect(EffectFillStyle.ITERATIVE), this.isOnAudio)
        Text(this.item1.duration)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.End)
          .margin({ left: this.plusWidth })
      } else {
        Text(this.item1.duration)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Start)
          .margin({ right: this.plusWidth })
        SymbolGlyph($r('sys.symbol.wave_3_left'))
          .rotate({ angle: 180 })
          .draggable(false)
          .margin({ end: LengthMetrics.vp(commonData.int.AUDIO_MESSAGE_MARGIN) })
          .fontSize($r('sys.float.Body_L'))
          .maxFontScale(FontSizeScale.HUGE_2)
          .fontColor([$r('sys.color.ohos_id_color_fourth')])
          .symbolEffect(new HierarchicalSymbolEffect(EffectFillStyle.ITERATIVE), this.isOnAudio)
      }
    }
    .constraintSize({ maxWidth: commonData.int.AUDIO_MESSAGE_MAX_WIDTH, minWidth: commonData.int.MMS_MESSAGE_MIN_WIDTH })
    .margin({ top: 4 })
    .backgroundColor(this.isSender === 0 ? $r('app.color.brand') : $r('sys.color.ohos_id_color_card_bg'))
    .borderRadius(this.textDirection === 'rtl' ?
      { topLeft: 16, topRight: 2, bottomLeft: 16, bottomRight: 16 } :
      { topLeft: 2, topRight: 16, bottomLeft: 16, bottomRight: 16 })
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .parallelGesture(
      GestureGroup(GestureMode.Exclusive,
        // 长按让showMenu为true
        LongPressGesture({ repeat: false, duration: 500 })
          .onAction(() => {
            if (this.multiSelectFlag == Visibility.None) {
              this.showMenu = true
            }
          })
        ,
        TapGesture({ count: 1 })
          .onAction(() => {
            if (this.mFavoriteCtrl.isSelectStatus) {
              this.mFavoriteCtrl.multiSelectMmsMsg(this.itemIndex);
              this.mFavoriteCtrl.listCheckBoxChange(this.itemIndex,
                !this.mFavoriteCtrl.mmsListFromFavo[this.itemIndex]?.isCbChecked);
              return;
            }
            if (!this.isOnAudio) {
              this.item1.isOnAudio = true;
              this.isOnAudio = true;
            }
            this.audioPlayerService.playAudio(this.item1);
          })
      )
    )
    .accessibilityText(dateUtil.getAudioAccessibilityText(this.item1.duration))
    .bindContextMenu(this.showMenu, this.longPressMenuBuild, {
      placement: Placement.BottomLeft,
      preview: MenuPreviewMode.IMAGE,
      previewAnimationOptions: {
        scale: [0.95, 1.1]
      },
      onAppear: () => {
        VibrationUtils.onceVibration(commonData.VIBRATIONEFFECT.LONG_PRESS_MEDIUM)
      },
      onDisappear: () => {
        if (this.itemIndex === this.scrollStartIndex) {
          this.listScroller?.scrollToIndex(this.itemIndex, false, ScrollAlign.START);
        } else if (this.itemIndex === this.scrollEndIndex) {
          this.listScroller?.scrollToIndex(this.itemIndex, false, ScrollAlign.END);
        }
        this.showMenu = false;
      }
    })
  }
}

@Component
export struct MmsContentVideo {
  @Prop scrollEndIndex: number = -1
  @Prop scrollStartIndex: number = -1
  public listScroller?: ListScroller
  mmsSourceItem: Mms = { duration: '', type: -1, path: '', name: '' };
  @State imagePixmap?: PixelMap = undefined;
  videoWidth: number = 0;
  videoHeight: number = 0;
  isFromTransmit: boolean = false;
  private context = getContext(this) as myCommon.UIAbilityContext;
  @State msgId: number | string = 0;
  @State imageWidth: number = 0;
  @State imageHeight: number = 0;
  @State imgFavoriteWidth: number = 0;
  @State imgFavoriteHeight: number = 0;
  @Link screenWidth: number;
  @State imagePath: string = '';
  @Consume mFavoriteCtrl: FavoriteController;
  @State showMenu: boolean = false;
  @Consume multiSelectFlag: Visibility;
  @Consume show: boolean;
  private item: LooseObject = {}
  private itemIndex: number = 0;
  @Prop isSender: number = 0
  @State saveButtonOptions: SaveButtonOptions = {
    text: SaveDescription.SAVE,
    buttonType: ButtonType.Normal
  }
  @StorageLink('curBp') curBp: string = commonData.STR.DEVICE_MOBILE_PHONE;
  isRcs = false
  menuMultSelect: (index: number) => void = () => {
  };
  //点击长按删除回调
  menuDeleteCallBack: (deleteItem: LooseObject) => void = () => {
  };
  aboutToAppear() {
    this.videoWidth = AppStorage.get<number | undefined>('videoWidth') || 0
    this.videoHeight = AppStorage.get<number | undefined>('videoHeight') || 0
    this.imagePixmap = AppStorage.get<PixelMap | undefined>('imagePixmap')
    this.getVideoPixmap(this.mmsSourceItem.path);
  }

  async getVideoPixmap(path: string) {
    let videoName = FileUtil.getFileName(path);
    this.mmsSourceItem.name = videoName
    // 彩信获取缩略图的命名规范
    let fileSuffix = '';
    if (path.endsWith('3gp')) {
      fileSuffix = videoName.replace('3gp', 'jpeg')
    } else {
      fileSuffix = videoName.replace('mp4', 'jpeg')
    }
    let imageName: string = this.isRcs ? videoName : 'IMG_' + fileSuffix;
    this.imagePath = FileUtil.getSandboxPath(this.context) + '/' + imageName;
    ImageBoundsUtil.getImageBounds(this.imagePath).then(res => {
      this.imageWidth = res[0]
      this.imageHeight = res[1]
      this.imgFavoriteWidth = ImageBoundsUtil.getWidth(this.imageWidth, this.imageHeight, this.screenWidth)
      this.imgFavoriteHeight = ImageBoundsUtil.getHeight(this.imageWidth, this.imageHeight, this.screenWidth)
    })
    if (fs.accessSync(this.imagePath)) {
      this.imagePath = fileuri.getUriFromPath(this.imagePath);
    } else if (this.item.partType == commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
      // 当彩信获取不到首屏缩略图，重新获取视频在指定时间点的缩略图
      this.imagePath = '';
      let windowWidth = AppStorage.get('windowWidth') as number;
      if (windowWidth > 0) {
        this.screenWidth = this.curBp === commonData.STR.DEVICE_MOBILE_PHONE ?
          windowWidth : windowWidth / 2;
      }
      ImageUtil.getFetchFrameByTime(path, (pixMap: PixelMap) => {
        if (pixMap === null) {
          return;
        }
        HiLog.i(TAG, 'getFetchFrameByTime response');
        this.imagePixmap = pixMap;
        // 以同步方法获取图像像素信息
        let imageInfo: image.ImageInfo = this.imagePixmap.getImageInfoSync();
        // 设置宽高
        this.calculatedVideoImageDisplaySize(imageInfo.size.width, imageInfo.size.height);
      });
    }
    if (this.isRcs) {
      await this.getThumbnailFunc(path, imageName)
    }
  }

  async getThumbnailFunc(uri: string, imageName: string) {
    HiLog.i(TAG, 'getThumbnailFunc Start!');
    let windowWidth = AppStorage.get('windowWidth') as number;
    if (windowWidth > 0) {
      this.screenWidth = this.curBp === commonData.STR.DEVICE_MOBILE_PHONE ?
        windowWidth : windowWidth / 2;
    }
    const videoImgPath = FileUtil.getSandboxPath(this.context) + '/' + imageName;
    let dstPath = '';
    if (uri.endsWith('3gp')) {
      dstPath = videoImgPath.replace('.3gp', 'Pixmap.jpeg')
    } else {
      dstPath = videoImgPath.replace('.mp4', 'Pixmap.jpeg')
    }
    if (fs.accessSync(videoImgPath)) {
      if (!fs.accessSync(dstPath)) {
        fs.copyFileSync(videoImgPath, dstPath)
      }
      this.imagePath = fileuri.getUriFromPath(dstPath);
      try {
        const imageSource: image.ImageSource = image.createImageSource(dstPath);
        this.imagePixmap = await imageSource.createPixelMap();
        imageSource.release();
        let imageInfo: image.ImageInfo = this.imagePixmap.getImageInfoSync();
        this.calculatedVideoImageDisplaySize(imageInfo.size.width, imageInfo.size.height);
      } catch (e) {
        HiLog.e(TAG, 'video hasStorage imageSource error ' + JSON.stringify(e));
      }
    }
    const avImageGenerator: media.AVImageGenerator = await media.createAVImageGenerator()
    avImageGenerator.fdSrc = await fs.open(uri)
    this.imagePixmap = await avImageGenerator.fetchFrameByTime(0, media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC,
      { width: -1, height: -1 })
    AppStorage.setOrCreate('imagePixmap', this.imagePixmap)
    let imageInfo: image.ImageInfo = this.imagePixmap.getImageInfoSync();
    if (!imageInfo) {
      return;
    }
    this.calculatedVideoImageDisplaySize(imageInfo.size.width, imageInfo.size.height);
    fs.close(avImageGenerator.fdSrc.fd)
    avImageGenerator.release();
  }

  aboutToDisappear(): void {
    this.imagePixmap?.release();
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
    AppStorage.setOrCreate('videoWidth', this.videoWidth)
    AppStorage.setOrCreate('videoHeight', this.videoHeight)
  }

  @Builder
  MenuBuilder() {
    Row() {
      MenuItem({ content: $r('app.string.delete') })
        .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
        .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
        .contentFontColor($r('sys.color.font_primary'))
        .onClick(() => {
          this.mFavoriteCtrl.cancelFavorite(this.context, this.item);
          this.showMenu = false;
        })
    }
    .height(40)
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
  }

  @Builder
  longPressMenuBuild() {
    Menu() {
      // 多选
      this.multSelectMenuButton()
      this.multDivider()
      // 保存
      this.saveMenuButton()
      this.multDivider()
      // 转发
      this.transmitMenuButton()
      this.multDivider()
      // 删除
      this.deleteMenuButton()
    }
    .width('224vp')
  }

  @Builder
  multDivider() {
    Divider()
      .color($r('sys.color.comp_divider'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({
        left: $r('app.float.conversation_item_press_Shadow_padding_left'),
        right: $r('app.float.conversation_item_press_Shadow_padding_left')
      })
  }

  @Builder
  multSelectMenuButton() {
    MenuItem({ content: $r('app.string.select_more') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .onClick(() => {
        this.show = false;
        this.showMenu = false;
        this.mFavoriteCtrl.isSelectStatus = true;
        this.mFavoriteCtrl.mmsIndex = this.itemIndex;
        this.item.isCbChecked = true;
        this.multiSelectFlag = Visibility.Visible
        this.menuMultSelect(this.itemIndex);
      })
  }

  @Builder
  saveMenuButton() {
    MenuItem() {
      SaveButton({ text: SaveDescription.SAVE, buttonType: ButtonType.Normal })
        .backgroundColor(Color.Transparent)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .borderRadius($r('sys.float.corner_radius_level8'))
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
        .padding({left:'12vp'})
        .onClick(async () => {
          let mmsSource: Mms[] = this.item.mmsSource;
          let saveObject: Mms
          if (mmsSource.length > 1) {
            saveObject = mmsSource[1]
          } else {
            saveObject = mmsSource[0]
          }
          if (saveObject.type === commonData.MM_ATTACHMENT_TYPE.IMAGE) {
            this.mFavoriteCtrl.saveImageToPhotoAlbums(saveObject.path)
            this.showMenu = false;
          } else if (saveObject.type === commonData.MM_ATTACHMENT_TYPE.VIDEO) {
            this.mFavoriteCtrl.saveVideoToAlbums(saveObject.path)
            this.showMenu = false;
          }
        })
    }
    .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
  }

  @Builder
  transmitMenuButton() {
    MenuItem({ content: $r('app.string.msg_transmit') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .onClick(() => {
        this.mFavoriteCtrl.mmsIndex = this.itemIndex
        setTimeout(() =>{
          this.mFavoriteCtrl.longPressSelected(1)
        }, 300);
        this.showMenu = false
      })
  }

  @Builder
  deleteMenuButton() {
    MenuItem({ content: $r('app.string.delete') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .onClick(() => {
        setTimeout(() =>{
          this.menuDeleteCallBack(this.item);
        }, 300);
        this.showMenu = false;
      })
  }

  build() {
    if (this.imagePath && !this.isRcs) {
    Stack({ alignContent: Alignment.Center }) {
      Image(this.imagePath)
        .width(this.imgFavoriteWidth)
        .height(this.imgFavoriteHeight)
        .draggable(false)
        .backgroundColor(this.imagePixmap ? Color.Transparent : Color.Black)
        .borderRadius(this.isFromTransmit ? 8 : 16)
        .objectFit(ImageFit.Fill)

      SymbolGlyph($r('sys.symbol.play_circle'))
        .width(34)
        .height(34)
        .draggable(false)
        .fontSize('34vp')
        .fontColor([$r('sys.color.ohos_id_color_background')])
    }
    .parallelGesture(
      GestureGroup(GestureMode.Exclusive,
        // 长按让showMenu为true，覆盖text自带的复制，让bindContextMenu生效
        LongPressGesture({ repeat: false, duration: 500 })
          .onAction(() => {
            if (this.multiSelectFlag == Visibility.None) {
              this.showMenu = true
            }
          })
        ,
        TapGesture({ count: 1 })
          .onAction(() => {
            ImageUtil.openVideoPreview(this.mmsSourceItem);
          })
      )
    )
    .bindContextMenu(this.showMenu, this.longPressMenuBuild, {
      placement: Placement.BottomLeft,
      preview: MenuPreviewMode.IMAGE,
      previewAnimationOptions: {
        scale: [0.95, 1.1]
      },
      onAppear: () => {
        VibrationUtils.onceVibration(commonData.VIBRATIONEFFECT.LONG_PRESS_MEDIUM)
      },
      onDisappear: () => {
        this.showMenu = false;
      }
    })
    .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.accessibility_video').id))
    } else if (this.imagePixmap) {
      Stack({ alignContent: Alignment.Center }) {
        Image(this.imagePixmap)
          .draggable(false)
          .backgroundColor(this.imagePixmap ? Color.Transparent : Color.Black)
          .borderRadius(this.isFromTransmit ? 8 : 16)
          .objectFit(ImageFit.Fill)
          .width(this.videoWidth)
          .height(this.videoHeight)

        SymbolGlyph($r('sys.symbol.play_circle'))
          .width(34)
          .height(54)
          .draggable(false)
          .fontColor([$r('sys.color.ohos_id_color_background')])
          .fontSize(34)
      }
      .parallelGesture(
        GestureGroup(GestureMode.Exclusive,
          // 长按让showMenu为true
          LongPressGesture({ repeat: false, duration: 500 })
            .onAction(() => {
              if (this.multiSelectFlag == Visibility.None) {
                this.showMenu = true
              }
            })
          ,
          TapGesture({ count: 1 })
            .onAction(() => {
              ImageUtil.openVideoPreview(this.mmsSourceItem);
            })
        )
      )
      .bindContextMenu(this.showMenu, this.longPressMenuBuild, {
        placement: Placement.BottomLeft,
        preview: MenuPreviewMode.IMAGE,
        previewAnimationOptions: {
          scale: [0.95, 1.1]
        },
        onAppear: () => {
          VibrationUtils.onceVibration(commonData.VIBRATIONEFFECT.LONG_PRESS_MEDIUM)
        },
        onDisappear: () => {
          if (this.itemIndex === this.scrollStartIndex) {
            this.listScroller?.scrollToIndex(this.itemIndex, false, ScrollAlign.START);
          } else if (this.itemIndex === this.scrollEndIndex) {
            this.listScroller?.scrollToIndex(this.itemIndex, false, ScrollAlign.END);
          }
          this.showMenu = false;
        }
      })
      .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.accessibility_video').id))
    }
  }
}

@Component
export struct ContactAvatar {
  @Prop rawContactId: string = '{}';
  @Prop contactId: string = '{}';
  @Prop item: LooseObject = {};
  @Prop imgSize: number = 40;
  @Prop loadFromDB: boolean = false;
  @State photoPixelMap: PixelMap | null = null;
  @Consume mFavoriteCtrl: FavoriteController;
  @Prop hasYellowPageIcon: string = '';
  @Prop yellowPageId: string = '';
  @State isChatbots: boolean = false;
  @State chatbotsIconPath: string = '';
  // 服务号logo
  @State pubLogoUrl: string = '';

  async aboutToAppear() {
    if (this.contactId) {
      getPixelMapFromFile(this.contactId, this.loadFromDB, (pixelMap: PixelMap | null) => {
        this.photoPixelMap = pixelMap;
      })
    }
  }

  //chatbot头像
  @Builder
  chatbotImage() {
    Image(this.chatbotsIconPath ? (this.chatbotsIconPath.startsWith('https') ?
    this.chatbotsIconPath : fileUri.getUriFromPath(this.chatbotsIconPath)) :
    $rawfile('icon/ic_bell_default_dark.svg'))
      .objectFit(ImageFit.Auto)
      .width('32vp')
      .height('32vp')
      .draggable(false)
      .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.contact_avatar_button').id))
      .clip(new Circle({ width: '32vp', height: '32vp' }))
      .syncLoad(true)
      .backgroundColor($r('app.color.mms_avatar_bg'))
      .fillColor($r('sys.color.ohos_id_color_primary_contrary'))
  }

  build() {
    if (this.photoPixelMap) {
      Image(this.photoPixelMap)
        .objectFit(ImageFit.Fill)
        .width(32)
        .height(32)
        .flexShrink(0)
        .borderRadius(16)
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.contact_avatar_button').id))
    } else if (this.isChatbots) {
      this.chatbotImage()
    } else if (this.hasYellowPageIcon) {
      Image('data:image/png;base64,' + this.hasYellowPageIcon)
        .draggable(false)
        .objectFit(ImageFit.Fill)
        .width(32)
        .height(32)
        .flexShrink(0)
        .clip(new Circle({ width: 32, height: 32 }))
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.contact_avatar_button').id))
        .border({
          width: '1vp',
          style: BorderStyle.Solid,
          radius: '20vp',
          color: $r('sys.color.ohos_id_color_click_effect')
        })
    } else if (this.item.senderNumber) {
      if (this.mFavoriteCtrl.nameAndPicture(this.item.senderNumber)) {
        Text(this.mFavoriteCtrl.nameAndPicture(this.item.senderNumber).photoFirstNames[0].firstName)
          .fontSize('12vp')
          .fontColor($r('sys.color.ohos_id_color_text_primary_contrary'))
          .fontWeight(900)
          .width(32)
          .height(32)
          .flexShrink(0)
          .textAlign(TextAlign.Center)
          .borderRadius(16)
          .backgroundColor($r('app.color.mms_avatar_bg'))
          .foregroundColor($r('sys.color.ohos_id_color_primary_contrary'))
          .draggable(false)
      } else if (this.mFavoriteCtrl.nameNoPicture(this.item.senderNumber)) {
        SymbolGlyph($r('sys.symbol.person_crop_circle_fill_1'))
          .width(32)
          .height(32)
          .fontSize('32vp')
          .fontColor([$r('app.color.mms_avatar_bg'), $r('sys.color.white')])
          .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
          .flexShrink(0)
          .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.contact_avatar_button').id))
          .foregroundColor($r('sys.color.ohos_id_color_primary_contrary'))
          .draggable(false)
      } else {
        SymbolGlyph($r('sys.symbol.person_crop_circle_fill_1'))
          .width(32)
          .height(32)
          .fontSize('32vp')
          .fontColor([$r('app.color.mms_avatar_bg'), $r('sys.color.white')])
          .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
          .flexShrink(0)
          .foregroundColor($r('sys.color.ohos_id_color_primary_contrary'))
          .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.avatar_button').id))
          .draggable(false)
      }
    } else {
      Image($rawfile('icon/ic_user_portrait.svg'))
        .objectFit(ImageFit.Fill)
        .width(32)
        .height(32)
        .clip(new Circle({ width: 32, height: 32 }))
        .backgroundColor($r('app.color.mms_avatar_bg'))
        .foregroundColor($r('sys.color.ohos_id_color_primary_contrary'))
        .draggable(false)
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.contact_avatar_button').id))
        .syncLoad(true)
    }
  }
}

@Component
export struct FavoriteSlideComponent {
  @Prop scrollEndIndex: number = -1
  @Prop scrollStartIndex: number = -1
  public listScroller?: ListScroller
  private itemIndex: number = 0;
  @Consume multiSelectFlag: Visibility;
  @State ct?: string = '';
  @Consume contentHeight: number;
  @Consume show: boolean;
  @Consume mFavoriteCtrl: FavoriteController;
  @State showMenu: boolean = false;
  private context = getContext(this) as myCommon.UIAbilityContext;
  private item: LooseObject = {}
  @State slideDataList: Array<Mms> = [];
  menuMultSelect: (index: number) => void = () => {
  };
  //点击长按删除回调
  menuDeleteCallBack: (deleteItem: LooseObject) => void = () => {
  };
  aboutToAppear() {
    this.slideDataList = MmsUtil.generateSlidePreviewData(this.item.mmsSource);
  }

  @Builder
  multDivider() {
    Divider()
      .color($r('sys.color.comp_divider'))
      .lineCap(LineCapStyle.Square)
      .width(0)
      .alignSelf(ItemAlign.Stretch)
      .padding({
        left: $r('app.float.conversation_item_press_Shadow_padding_left'),
        right: $r('app.float.conversation_item_press_Shadow_padding_left')
      })
  }

  @Builder
  multSelectMenuButton() {
    MenuItem({ content: $r('app.string.select_more') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.show = false;
        this.showMenu = false;
        this.mFavoriteCtrl.mmsIndex = this.itemIndex;
        this.mFavoriteCtrl.isSelectStatus = true;
        this.item.isCbChecked = true;
        this.multiSelectFlag = Visibility.Visible;
        this.menuMultSelect(this.itemIndex);
      })
  }

  @Builder
  transmitMenuButton() {
    MenuItem({ content: $r('app.string.msg_transmit') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.mFavoriteCtrl.mmsIndex = this.itemIndex
        setTimeout(() =>{
          this.mFavoriteCtrl.longPressSelected(1)
        }, 300);
        this.showMenu = false
      })
  }

  @Builder
  deleteMenuButton() {
    MenuItem({ content: $r('app.string.delete') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        setTimeout(() =>{
          this.menuDeleteCallBack(this.item);
        }, 300);
        this.showMenu = false;
      })
  }

  @Builder
  longPressMenuBuild() {
    Menu() {
      // 多选
      this.multSelectMenuButton()
      this.multDivider()
      // 转发
      this.transmitMenuButton()
      this.multDivider()
      // 删除
      this.deleteMenuButton()
    }
    .width('224vp')
  }

  build() {
    Column() {
      Row() {
        if (MmsUtil.isSlideHasImage(this.item.contentType)) {
          MMContentSlideImage({
            showMenu: this.showMenu,
            slideDataList: this.slideDataList,
            favoriteItem: this.item,
            mmsIndex: this.itemIndex
          })
        } else {
          MMContentSlideNoImage({
            showMenu: this.showMenu,
            slideDataList: this.slideDataList,
            favoriteItem: this.item,
            mmsIndex: this.itemIndex,
          })
        }
      }
      .margin({ top: 4, bottom: 8 })
      .parallelGesture(
        GestureGroup(GestureMode.Exclusive,
          LongPressGesture({ repeat: false, duration: 500 })//Touch and hold the action will be triggered continuously.
            .onAction(() => {
              if (this.multiSelectFlag == Visibility.None) {
                this.showMenu = true
              }
            }),
          TapGesture({ count: 2 })
            .onAction(() => {
            })
        ))
      .bindContextMenu(this.showMenu, this.longPressMenuBuild, {
        placement: Placement.BottomLeft,
        preview: MenuPreviewMode.IMAGE,
        previewAnimationOptions: {
          scale: [0.95, 1.1]
        },
        onAppear: () => {
          VibrationUtils.onceVibration(commonData.VIBRATIONEFFECT.LONG_PRESS_MEDIUM)
        },
        onDisappear: () => {
          if (this.itemIndex === this.scrollStartIndex) {
            this.listScroller?.scrollToIndex(this.itemIndex, false, ScrollAlign.START);
          } else if (this.itemIndex === this.scrollEndIndex) {
            this.listScroller?.scrollToIndex(this.itemIndex, false, ScrollAlign.END);
          }
          this.showMenu = false;
          this.multiSelectFlag = Visibility.None
        }
      })
    }

  }
}

@Component
export struct FavoriteName {
  @Consume mFavoriteCtrl: FavoriteController;
  @Prop item: LooseObject = {};
  @Prop hasYellowPageIcon: string = '';
  // 服务号名称
  @State pubName: string = '';
  @Provide isShowHead: boolean = true;
  @Provide textDirection: string = '';
  @Provide isPad: boolean = true;
  @Provide padMargin: number = 0;
  @State chatbotNameStr: string = '';
  private context = getContext(this) as myCommon.UIAbilityContext;
  aboutToAppear() {
  }

  getSipName(): string {
    if (StringUtil.isEmpty(this.chatbotNameStr)) {
      return ''
    }
    return this.chatbotNameStr;
  }

  build() {
    if (this.item.senderNumber) {
      if (this.getSipName() !== '') {
        Text(this.getSipName())
          .fontSize(10)
          .width(230)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .lineHeight(13)
          .fontFeature('\"ss08\" 1')
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .alignRules(this.isShowHead ? {
            left: { anchor: 'favorite_list_avatar', align: HorizontalAlign.End }
          } : {})
          .margin(this.textDirection === 'rtl' ? {
            top: 16,
            right: this.isShowHead ? 8 : (this.isPad ? this.padMargin : $r('sys.float.margin_right'))
          }
            : {
              top: 16,
              left: this.isShowHead ? 8 : (this.isPad ? this.padMargin : $r('sys.float.margin_left'))
            })
          .id('favorite_list_name')
      } else if (this.mFavoriteCtrl.nameAndPicture(this.item.senderNumber)) {
        Text(this.mFavoriteCtrl.nameAndPicture(this.item.senderNumber).name)
          .fontSize(10)
          .width(230)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .lineHeight(13)
          .fontFeature('\"ss08\" 1')
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .alignRules(this.isShowHead ? {
            left: { anchor: 'favorite_list_avatar', align: HorizontalAlign.End }
          } : {})
          .margin(this.textDirection === 'rtl' ? {
            top: 16,
            right: this.isShowHead ? 8 : (this.isPad ? this.padMargin : $r('sys.float.margin_right'))
          }
            : {
              top: 16,
              left: this.isShowHead ? 8 : (this.isPad ? this.padMargin : $r('sys.float.margin_left'))
            })
          .id('favorite_list_name')
      } else {
        Text(this.pubName ? this.pubName : this.item.senderNumber)
          .fontSize(10)
          .width(230)
          .fontFeature('\"ss08\" 1')
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .lineHeight(13)
          .alignRules(this.isShowHead ? {
            left: { anchor: 'favorite_list_avatar', align: HorizontalAlign.End }
          } : {})
          .margin(this.textDirection === 'rtl' ? {
            top: 16,
            right: this.isShowHead ? 8 : (this.isPad ? this.padMargin : $r('sys.float.margin_right'))
          }
            : {
              top: 16,
              left: this.isShowHead ? 8 : (this.isPad ? this.padMargin : $r('sys.float.margin_left'))
            })
          .id('favorite_list_name')
      }
    } else {
      Text($r('app.string.me'))
        .fontSize(10)
        .width(230)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .lineHeight(13)
        .alignRules(this.isShowHead ? {
          left: { anchor: 'favorite_list_avatar', align: HorizontalAlign.End }
        } : {})
        .margin(this.textDirection === 'rtl' ? {
          top: 16,
          right: this.isShowHead ? 8 : (this.isPad ? this.padMargin : $r('sys.float.margin_right'))
        }
          : {
            top: 16,
            left: this.isShowHead ? 8 : (this.isPad ? this.padMargin : $r('sys.float.margin_left'))
          })
        .id('favorite_list_name')
    }
  }
}

@Builder
export function RcsFileSaveMenuInFavorite(onSaveMenuClick: () => void) {
  MenuItem({ content: $r('app.string.save') })
    .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
    .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
    .contentFontColor($r('sys.color.font_primary'))
    .onClick(onSaveMenuClick)
}
