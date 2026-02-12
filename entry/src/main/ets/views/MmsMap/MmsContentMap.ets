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
import fileuri from '@ohos.file.fileuri';
import HiLog from '../../utils/HiLog';
import { AddressInfo, Mms } from '../../utils/TypesUtils';
import { EnhancedInfoTemporaryDataSource } from '../../model/EnhancedInfoTemporaryDataSource';
import RcsImageMessageController from '../AttachmentArea/RcsImageMessageController';
import ConversationController from '../../pages/conversation/conversationController';
import LocationUtil from '../../utils/LocationUtil';
import { SystemMode } from '../../utils/SystemMode';
import commonData from '../../data/commonData';
import { getMapInputBoxText, parseAddressInfo } from '../../utils/MmsUtil';
import { Configuration } from '@kit.ArkUI';
import LooseObject from '../../data/LooseObject';
import FavoriteController from '../../pages/favoritepage/favoriteController';
import { VibrationUtils } from '../../utils/VibrationUtils';
import FileUtil from '../../utils/FileUtil';
import myCommon from '@ohos.app.ability.common';
import ConversationDataSource from '../../model/ConversationDataSource';
import { MeasureText } from '@kit.ArkUI';
import common from '../../data/commonData';
import DeviceUtil from '../../utils/DeviceUtil';
import AccessibilityUtil from '../../utils/AccessibilityUtil';

const TAG = 'MmsContentMap';

/**
 * 彩信位置消息组件
 */
@Component
export struct MmsContentMap {
  /**
   * 会话页面中的消息数据
   */
  @Prop mmsItem: LooseObject;
  /**
   * 是否展示长按菜单
   */
  @Prop showMenu: boolean = false;
  public isAdvancedSecurity: boolean = false;
  public conversationCtrl: ConversationController = ConversationController.getInstance();
  /**
   * 是否为转发预览场景
   */
  public isFromTransmit: boolean = false;
  /**
   * 消息方向 left为接收消息，right为发送消息
   */
  public bubbleTextDirection: string = ''; // left: upper left corner right: upper right corner
  /**
   * 文本气泡的圆角
   */
  public bubbleTextBorderRadius: Array<number | Resource> = []; // Fillet size, two parameters in total
  /**
   * 文本气泡的背景色
   */
  public bubbleTextBackgroundColor?: Resource | string; // Bubble background color
  /**
   * 彩信位置消息附件
   */
  private mapImageAttach: Mms = {
    duration: '',
    type: -1,
    path: '',
    name: ''
  };
  /** 位置数据 */
  @State addressInfo: AddressInfo = new AddressInfo(0, 0, '', '');
  /** 是否启用NLU能力 */
  private isEnableNlu: boolean = SystemMode.getInstance().isEnableNlu;
  /**
   * 位置图片的PixelMap
   */
  @State imagePixmap: PixelMap | null = null;
  /**
   * 位置图片的Uri
   */
  @State imageUri: string = '';
  /**
   * 输入框文本
   */
  @State inputBoxText: string = '';
  /**
   * 在消息列表中的索引
   */
  public itemIndex: number = -1;
  /**
   * 是否在收藏页面
   */
  isFavorite: boolean = false;
  menuMultSelect: (index: number) => void = () => {
  };
  menuDeleteCallBack: (deleteItem: LooseObject) => void = () => {
  };
  @Consume multiSelectFlag: Visibility;
  @Consume show: boolean;
  @Consume mFavoriteCtrl: FavoriteController;
  private context = getContext(this) as myCommon.UIAbilityContext;
  /**
   * 是否在幻灯片预览界面展示
   */
  public isDisplayInSlidePreview: boolean = false;
  /**
   * 位置卡片的宽度
   */
  public mmsMapCardWidth: Length = '224vp';
  public changeConversationSelectedNumberAndCheckAllBool: () => void = () => {
  };
  @StorageLink('windowWidth') deviceWidth: number = 0;
  @StorageLink('curBp') curBp: string = common.STR.DEVICE_MOBILE_PHONE;
  @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();
  @StorageLink('mmsNavMode') curNavMode: number = 0;
  @StorageLink('mmsScreenPercentage') mmsScreenPercentage: string = '50%';
  /**
   * 组件的调用方
   */
  @Prop isCallFrom: null | 'MMContent' | 'favorite' | 'SlidePreview' | 'MmsDialogs' = null;

  async aboutToAppear() {
    HiLog.i(TAG, `aboutToAppear isCallFrom: ${this.isCallFrom}`);
    let mmsSource: Mms[] = [];
    if (this.isFromTransmit) {
      mmsSource = this.mmsItem.mms;
    } else {
      mmsSource = this.mmsItem.mmsSource
    }
    const mapImageAttach = mmsSource?.find(v => (v.type === commonData.MM_ATTACHMENT_TYPE.MAP));
    if (mapImageAttach) {
      this.mapImageAttach = mapImageAttach;
      this.addressInfo = parseAddressInfo(mapImageAttach?.text) || new AddressInfo(0, 0, '', '');
    }

    if (this.isDisplayInSlidePreview) { //在幻灯片预览位置附件的场景，位置附件内容不渲染输入框文本，而在幻灯片预览界面渲染
      this.inputBoxText = '';
    } else {
      this.inputBoxText = getMapInputBoxText(mapImageAttach?.content);
    }

    try {
      this.initMmsImage();
    } catch (e) {
      this.imagePixmap = null;
      this.imageUri = '';
      HiLog.e(TAG, `aboutToAppear initMmsImage error: ${e?.code} ${e?.message}`);
    }
  }

  /**
   * 初始化位置图片
   */
  private async initMmsImage() {
    const path = this.mapImageAttach.path;
    if (!this.mapImageAttach?.path) {
      return;
    }

    try {
      this.imageUri = fileuri.getUriFromPath(path);
    } catch (e) {
      this.imageUri = '';
      HiLog.e(TAG, `initMmsImage fileuri.getUriFromPath failed, error: ${e?.code} ${e?.message}`)
    }

    if (!this.imageUri) {
      this.imagePixmap = null;
      HiLog.e(TAG, 'initMmsImage: imageUri empty');
      return;
    }

    //优化图片加载性能
    const mapKeyToPixelMap: Map<string, PixelMap> = EnhancedInfoTemporaryDataSource.getInstance().mapKeyToPixelMap;
    const pixmap = mapKeyToPixelMap.get(this.imageUri);
    if (pixmap) {
      this.imagePixmap = pixmap;
    } else {
      this.imagePixmap = null;
      RcsImageMessageController.getInstance().convertAndSetImagePixelMap(this.imageUri, mapKeyToPixelMap);
    }
  }

  /**
   * 获取卡片的圆角
   */
  private getBorderRadius(): Length | BorderRadiuses | LocalizedBorderRadiuses {
    // 原生逻辑，短信原文的圆角设置
    return Configuration.getLocale().dir === 'rtl' ? ((this.bubbleTextDirection === 'right' && !this.isFavorite) ?
      {
        topLeft: (this.showMenu || this.isFromTransmit) ? this.bubbleTextBorderRadius[1]
          : this.bubbleTextBorderRadius[0],
        topRight: this.bubbleTextBorderRadius[1],
        bottomLeft: this.bubbleTextBorderRadius[1],
        bottomRight: this.bubbleTextBorderRadius[1]
      } :
      {
        topLeft: this.bubbleTextBorderRadius[1],
        topRight: (this.showMenu || this.isFromTransmit) ? this.bubbleTextBorderRadius[1] :
        this.bubbleTextBorderRadius[0],
        bottomLeft: this.bubbleTextBorderRadius[1],
        bottomRight: this.bubbleTextBorderRadius[1]
      }) :
      ((this.bubbleTextDirection == 'right' && !this.isFavorite) ?
        {
          topLeft: this.bubbleTextBorderRadius[1],
          topRight: (this.showMenu || this.isFromTransmit) ? this.bubbleTextBorderRadius[1] :
          this.bubbleTextBorderRadius[0],
          bottomLeft: this.bubbleTextBorderRadius[1],
          bottomRight: this.bubbleTextBorderRadius[1]
        } :
        {
          topLeft: (this.showMenu || this.isFromTransmit) ? this.bubbleTextBorderRadius[1] :
          this.bubbleTextBorderRadius[0],
          topRight: this.bubbleTextBorderRadius[1],
          bottomLeft: this.bubbleTextBorderRadius[1],
          bottomRight: this.bubbleTextBorderRadius[1]
        });
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
        this.mmsItem.isCbChecked = true;
        this.mFavoriteCtrl.mmsIndex = this.itemIndex;
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
        HiLog.i(TAG, 'onTransmitClick');
        this.mFavoriteCtrl.mmsIndex = this.itemIndex;
        setTimeout(() => {
          this.mFavoriteCtrl.longPressSelected(1);
        }, 300);
        this.showMenu = false;
      })
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
  deleteMenuButton() {
    MenuItem({ content: $r('app.string.delete') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        setTimeout(() => {
          this.menuDeleteCallBack(this.mmsItem);
        }, 300);
        this.showMenu = false;
      })
  }

  @Builder
  saveMenuButton() {
    MenuItem({ content: $r('app.string.save') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        HiLog.i(TAG, 'onSaveClick');
        let mmsSource: Mms[] = [];
        if (this.isFromTransmit) {
          mmsSource = this.mmsItem.mms;
        } else {
          mmsSource = this.mmsItem.mmsSource
        }
        const saveObject = mmsSource?.find(v => (v.type === commonData.MM_ATTACHMENT_TYPE.MAP));
        if (!saveObject) {
          HiLog.e(TAG, 'onSaveMenuClick: Failed to obtain the saved data.');
          return;
        }
        FileUtil.saveFileToFileManager(this.context, saveObject.path, saveObject.name);
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
  chooseTextMenuButton() {
    MenuItem({ content: $r('app.string.msg_select_text') })
      .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
      .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
      .contentFontColor($r('sys.color.font_primary'))
      .onClick(() => {
        this.mFavoriteCtrl.mmsIndex = this.itemIndex
        setTimeout(() => {
          this.mFavoriteCtrl.longPressSelected(3);
        }, 300);
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
      // 保存
      this.saveMenuButton()
      this.multDivider()
      // 复制
      this.copyMenuButton()
      this.multDivider()
      // 选择文本
      this.chooseTextMenuButton()
      this.multDivider()
      // 删除
      this.deleteMenuButton()
    }
    .width('224vp')
  }

  /**
   * 位置卡片的点击事件
   */
  private onMmsMapCardClick = () => {
    HiLog.i(TAG, 'onMmsMapCardClick');
    //此处为适配多选模式点击消息后可选中或取消选中多选选择框的功能
    if (this.isFavorite) {
      if (this.mFavoriteCtrl.isSelectStatus) {
        this.mFavoriteCtrl.multiSelectMmsMsg(this.itemIndex);
        this.mFavoriteCtrl.listCheckBoxChange(this.itemIndex,
          !this.mFavoriteCtrl.mmsListFromFavo[this.itemIndex]?.isCbChecked);
        return;
      }
    } else if (this.isCallFrom === 'MMContent') {
      if (this.conversationCtrl?.isSelectStatus) {
        this.conversationCtrl.multiSelectMmsMsg(this.itemIndex)
        this.conversationCtrl.listCheckBoxChange(this.itemIndex,
          !ConversationDataSource.getInstance().mmsList[this.itemIndex].isCbChecked)
        this.changeConversationSelectedNumberAndCheckAllBool();
        return;
      }
    }

    if (this.showMenu || this.isFromTransmit) { //显示长按菜单或转发预览场景下不响应点击事件
      HiLog.w(TAG, `onMmsMapCardClick: return, showMenu: ${this.showMenu}, isFromTransmit: ${this.isFromTransmit}`);
      return;
    }
    if (this.addressInfo) { //拉起地图Kit的位置详情展示器Picker
      LocationUtil.queryLocation(new AddressInfo(this.addressInfo.latitude, this.addressInfo.longitude,
        this.addressInfo.name, this.addressInfo.address));
    }
  }

  build() {
    if (this.isFavorite) {
      Column() {
        MmsMapCard({
          imagePixmap: this.imagePixmap,
          imagePath: this.imageUri,
          title: this.addressInfo.name,
          description: this.addressInfo.address,
          onMmsMapCardClick: this.onMmsMapCardClick,
          cardWidth: this.mmsMapCardWidth
        })

        if (this.inputBoxText) {
          this.renderInputBoxText();
        }
      }
      .alignItems(HorizontalAlign.Start)
      .lightUpEffect(this.showMenu ? 0.8 : 1)
      .accessibilityStyles()
      .onClick(this.onMmsMapCardClick)
      .parallelGesture(
        GestureGroup(GestureMode.Exclusive,
          // 长按让showMenu为true
          LongPressGesture({ repeat: false, duration: 500 })
            .onAction(() => {
              if (this.multiSelectFlag == Visibility.None) {
                this.showMenu = true
              }
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
          HiLog.w(TAG, `select msg id is: ${this.mmsItem.id}`)
          VibrationUtils.onceVibration(commonData.VIBRATIONEFFECT.LONG_PRESS_MEDIUM)
        },
        onDisappear: () => {
          this.showMenu = false;
        }
      })
    } else {
      Column() {
        MmsMapCard({
          imagePixmap: this.imagePixmap,
          imagePath: this.imageUri,
          title: this.addressInfo.name,
          description: this.addressInfo.address,
          onMmsMapCardClick: this.onMmsMapCardClick,
          cardWidth: this.mmsMapCardWidth
        })

        if (this.inputBoxText) {
          this.renderInputBoxText();
        }
      }
      .alignItems(this.bubbleTextDirection === 'left' ? HorizontalAlign.Start : HorizontalAlign.End)
      .lightUpEffect(this.showMenu ? 0.8 : 1)
      .accessibilityStyles()
      .onClick(this.onMmsMapCardClick)
      .accessibilityDescription(AccessibilityUtil.getOnClickAndLongPressEventsDes(getContext(this)))
    }
  }

  @Styles accessibilityStyles() {
    .accessibilityLevel('yes')
    .accessibilityGroup(true, { accessibilityPreferred: true })
  }

  private calCurPageRatio(): number {
    if (this.curNavMode === common.int.NAVIGATION_MODE_STACK) {
      return 1;
    }
    try {
      return 1 - Number(this.mmsScreenPercentage.replace('%', '')) / 100;
    } catch {
      HiLog.e(TAG, 'Failed to convert the string percentage to a number.');
    }
    return 0.5;
  }

  private messageWidthChange(content: string): string {
    HiLog.i(TAG, 'messageWidthChange by content');
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
    HiLog.i(TAG, 'setWidth');
    let currentScreenWidthForNumber = 0
    if (this.conversationCtrl.isSelectStatus && this.conversationCtrl.contactsNum > 1) {
      currentScreenWidthForNumber = this.deviceWidth * screenPercent * 0.8 - 24 - 8 - 32 - 8;
    } else if (this.conversationCtrl.isSelectStatus && this.conversationCtrl.contactsNum <= 1) {
      currentScreenWidthForNumber = this.deviceWidth * screenPercent * 0.8 - 24 - 8;
    } else {
      if (this.conversationCtrl.contactsNum > 1) {
        currentScreenWidthForNumber = this.deviceWidth * screenPercent * 0.8 - 32 - 8;
      } else {
        currentScreenWidthForNumber = this.deviceWidth * screenPercent * 0.8;
      }
    }
    const fullTextWidthPx: number = MeasureText.measureText({
      textContent: content,
    });
    const fullTextWidthVp: number = px2vp(fullTextWidthPx);
    if (fullTextWidthVp <= currentScreenWidthForNumber - 24) {
      return 'auto'
    } else {
      return currentScreenWidthForNumber + 'vp'
    }
  }

  private getDataDetectorFlag(): boolean {
    let flag = (this.isEnableNlu && !this.isAdvancedSecurity &&
      this.multiSelectFlag !== Visibility.Visible && this.isCallFrom !== 'MmsDialogs')
    HiLog.iw(TAG, 'enableDataDetectorFlag:' + flag);
    return flag;
  }

  @Builder
  renderInputBoxText() {
    Row() {
      Text(this.inputBoxText) {
        Span(this.inputBoxText);
      }
      .clip(true)
      .fontSize($r('sys.float.Body_L'))
      .lineHeight(19)
      .maxFontScale(5)
      .fontColor(this.bubbleTextDirection === 'right' ? $r('sys.color.font_on_primary') :
      $r('sys.color.ohos_id_color_text_primary'))
      .fontWeight(FontWeight.Regular)
      .enableDataDetector(this.getDataDetectorFlag())
      .dataDetectorConfig({
        types: [],
        color: this.bubbleTextDirection === 'right' ? $r('sys.color.font_on_primary') : ''
      })
      .draggable(false)
      .fontFeature('\"ss08\" 1')
      .onTouchIntercept((event: TouchEvent) => {
        if (this.conversationCtrl?.isSelectStatus) {
          return HitTestMode.None;
        } else {
          return HitTestMode.Default;
        }
      });
    }
    .id('mms_content_map_input_text')
    .width(this.messageWidthChange(this.inputBoxText))
    .padding({
      left: 12,
      right: 12,
      top: 8,
      bottom: 8
    })
    .margin({
      top: 8
    })
    .borderRadius(this.getBorderRadius())
    .draggable(false)
    .backgroundColor(this.bubbleTextBackgroundColor)
    .onClick(() => {
      //此处为适配多选模式点击消息后可选中或取消选中多选选择框的功能
      if (this.isFavorite) {
        if (this.mFavoriteCtrl.isSelectStatus) {
          this.mFavoriteCtrl.multiSelectMmsMsg(this.itemIndex);
          this.mFavoriteCtrl.listCheckBoxChange(this.itemIndex,
            !this.mFavoriteCtrl.mmsListFromFavo[this.itemIndex]?.isCbChecked);
        }
      } else if (this.isCallFrom === 'MMContent') {
        if (this.conversationCtrl?.isSelectStatus) {
          this.conversationCtrl.multiSelectMmsMsg(this.itemIndex)
          this.conversationCtrl.listCheckBoxChange(this.itemIndex,
            !ConversationDataSource.getInstance().mmsList[this.itemIndex].isCbChecked)
          this.changeConversationSelectedNumberAndCheckAllBool();
        }
      }
    })
  }
}

@Component
struct MmsMapCard {
  /** 位置地点标题 */
  @Prop title: string = '';
  /** 位置的详细描述 */
  @Prop description: string = '';
  /**
   * 位置图片的PixelMap
   */
  @Prop imagePixmap: PixelMap | null;
  /**
   * 位置图片的Uri
   */
  @Prop imagePath: string;
  /**
   * 位置卡片的宽度
   */
  @Prop cardWidth: Length = '224vp';
  /**
   * 位置卡片的点击事件
   */
  public onMmsMapCardClick = () => {
  }

  build() {
    Column() {
      if (this.imagePixmap || this.imagePath) {
        Image(this.imagePixmap || this.imagePath)
          .objectFit(ImageFit.Cover)
          .width('100%')
          .aspectRatio(16 / 9)
          .syncLoad(true)
          .draggable(false)
      } else {
        Column() {
          SymbolGlyph($r('sys.symbol.local_fill'))
            .fontColor([$r('sys.color.ohos_id_color_warning')])
            .width('24vp')
            .height('24vp')
            .draggable(false)
            .fontSize('24vp')
        }
        .width('100%')
        .aspectRatio(16 / 9)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('sys.color.comp_background_secondary'))
      }
      Column() {
        Text(this.title)
          .margin({ bottom: 4 })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontSize($r('sys.float.Body_L'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
          .width('100%');
        Text(this.description)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontSize($r('sys.float.Body_M'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .width('100%');
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding(12);
    }
    .width(this.cardWidth)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(20)
    .clip(true)
    .onClick(this.onMmsMapCardClick)
    .id('mms_content_map_card')
  }
}