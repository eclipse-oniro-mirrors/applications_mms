/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import SlidePreviewController from './SlidePreviewController';
import common from '../../data/commonData';
import { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import HiLog from '../../utils/HiLog';
import commonData from '../../data/commonData';
import DeviceUtil from '../../utils/DeviceUtil';
import { SlideMmsItem } from '../../utils/TypesUtils';
import MmsUtil from '../../utils/MmsUtil';
import { SlideAudio } from './SlideAudio';

import { SymbolGlyphModifier, uiObserver } from '@kit.ArkUI';
import Configuration from '@system.configuration';
//import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
import TitleBarUtil from '../../utils/TitleBarUtil';
import { BottomBar, BottomBarOption } from './CustomBottomBar';
import myCommon from '@ohos.app.ability.common';
import { MMContentVideo, MMContentImage } from '../../views/AttachmentArea/MMContent';
import LocationUtil from '../../utils/LocationUtil';
import { MmsContentMap } from '../../views/MmsMap/MmsContentMap';
import FavoriteController from '../favoritepage/favoriteController';
import { EmptyPage } from '../../views/EmptyPage';


const TAG = 'SlidePreview';

@Builder
export function SlidePreviewLoader(param: LooseObject): void {
  SlidePreview();
}

@Entry
@Component
export struct SlidePreview {
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;
  private item: LooseObject = {}
  @Consume('pageInfos') pageInfos: NavPathStack;
  @Provide index: number = 1;
  @Provide contentHeight: number = 641;
  @State ct: string = '';
  @State isSelectAll: boolean = false;
  @State isSelectDelete: boolean = false;
  @State screenWidth: number = 0;
  @State currentScreenWidth: string = '';
  private context = getContext(this) as myCommon.UIAbilityContext;
  @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding | null = null;
  @StorageLink('curBp') curBp: string = commonData.STR.DEVICE_MOBILE_PHONE;
  @StorageLink('windowWidth') deviceWidth: number = 0;
  /* 设备是否为pad */
  @State isPad: boolean = false;
  @State textDirection: string = '';
  // 需要从controller同步的变量
  @State @Watch('slideCtrlStatusChanged') mSlidePreviewCtrl: SlidePreviewController = new SlidePreviewController();
  // 是否是可选择状态
  @State @Watch('selectStatusChanged') isSelectStatus: boolean = this.mSlidePreviewCtrl.isSelectStatus;
  // 选择数量变化
  @State selectSaveCount: number = this.mSlidePreviewCtrl.selectSaveCount;
  // 是否全选状态
  @State @Watch('isCheckAllChanged') isCheckAllBool: boolean = this.mSlidePreviewCtrl.isAttachCheckAll;
  @State isShowSaveAllBtn: boolean = this.mSlidePreviewCtrl.isShowSaveAllBtn;
  @State msgTitle: string = this.mSlidePreviewCtrl.msgTitle;
  initToolBarList: Array<BottomBarOption> = [];
  @State toolBarList: Array<BottomBarOption> = this.initToolBarList;
  // 展示的第一个附件类型是audio时会自动播放
  slideFirstItem: SlideMmsItem = {
    duration: '',
    type: 0,
    path: '',
    name: ''
  };
  timeId: number = -1;
  @State isAutoPlayAudio: boolean = false;
  private scroller: Scroller = new Scroller();
  @State transitionType: NavigationSystemTransitionType = NavigationSystemTransitionType.TITLE;
  @State isTouch: boolean = false;
  @State isPageHide: boolean = false;
  @Provide multiSelectFlag: Visibility = Visibility.None;
  @Provide show: boolean = true;
  @Provide mFavoriteCtrl: FavoriteController = FavoriteController.getInstance();

  @Styles
  normalStylesOfCancel(){
    .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
  }

  @Styles
  pressedStylesOfCancel(){
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  normalStylesBack(){
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStylesBack(){
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
  }

  @Styles
  normalStylesMenu(){
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStylesMenu(){
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  actionButtonPressStyles(){
    .stateStyles({
      normal: this.normalStylesMenu,
      pressed: this.pressedStylesMenu
    })
  }

  delSlideController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: $r('app.string.msg_delete_dialog_con_tip1'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
        }
      },
      secondaryButton: {
        value: $r('app.string.delete'),
        action: () => {
          this.mSlidePreviewCtrl.deleteDialogConfirm(this.context);
        },
        role: ButtonRole.ERROR
      }
    }),
    autoCancel: false,
  });

  aboutToAppear() {
    HiLog.i(TAG, 'SlidePreviewPage aboutToAppear');
    this.isPad = DeviceUtil.isTablet();
    this.mSlidePreviewCtrl.onInit(this.pageInfos);
    this.mSlidePreviewCtrl.getSlidePreviewData();
    let windowWidth = AppStorage.get('windowWidth') as number;
    uiObserver.on('navDestinationUpdate', (info: NavDestinationInfo) => {
      if (info.state === 0) {
        this.textDirection = Configuration.getLocale().dir;
      }
    });
    if (windowWidth) {
      this.screenWidth = vp2px(windowWidth) / 2;
    }

    this.initToolBarList = [{
      barStyle: {
        iconName: $r('sys.symbol.rectangle_and_arrowshape_turn_up_right'),
        textName: $r('app.string.msg_transmit'),
        isDisabled: !this.mSlidePreviewCtrl.attachIsNotEmpty
      },
      clickAction: () => {
        this.mSlidePreviewCtrl.transmitMsg(this.context);
      },
    }, {
      barStyle: {
        iconName: $r('sys.symbol.trash'),
        textName: $r('app.string.delete')
      },
      clickAction: () => {
        this.delSlideController.open()
      },
    }, {
      barStyle: {
        iconName: $r('sys.symbol.checkmark_square_on_square'),
        textName: $r('app.string.msg_select_all'),
        isHidden: true
      },
      clickAction: () => {
        this.mSlidePreviewCtrl.clickCheckAllBtn();
      }
    }];
    this.toolBarList = this.initToolBarList;
    this.slideFirstItem = this.mSlidePreviewCtrl.getFirstItem();
    if (this.slideFirstItem.type === common.MM_ATTACHMENT_TYPE.AUDIO) {
      this.isAutoPlayAudio = true;
    }

  }

  aboutToDisappear() {
    clearTimeout(this.timeId)
    HiLog.i(TAG, 'SlidePreviewPage aboutToDisappear!');
    uiObserver.off('navDestinationUpdate');
  }

  slideCtrlStatusChanged() {
    this.isSelectStatus = this.mSlidePreviewCtrl.isSelectStatus;
    this.isCheckAllBool = this.mSlidePreviewCtrl.isAttachCheckAll;
    this.selectSaveCount = this.mSlidePreviewCtrl.selectSaveCount;
    this.isShowSaveAllBtn = this.mSlidePreviewCtrl.isShowSaveAllBtn;
    this.msgTitle = this.mSlidePreviewCtrl.msgTitle;
  }

  selectStatusChanged() {
    if (this.toolBarList?.length) {
      let checkAllOption: BottomBarOption = this.toolBarList[this.toolBarList.length - 1];
      checkAllOption.barStyle.isHidden = !this.isSelectStatus;
      this.toolBarList.splice(-1, 1, checkAllOption)
    }
  }

  //监听是否全选变化，修改toolbar全选选项状态
  isCheckAllChanged() {
    let checkAllOption: BottomBarOption = this.toolBarList[this.toolBarList.length - 1];
    if (this.isCheckAllBool) {
      checkAllOption.barStyle = {
        iconName: $r('sys.symbol.checkmark_square_on_square_fill'),
        iconFontColor: [$r('app.color.brand')],
        textName: $r('app.string.msg_deselect_all'),
        textFontColor: $r('sys.color.font_emphasize'),
        isHidden: !this.isSelectStatus
      }
    } else {
      checkAllOption.barStyle = {
        iconName: $r('sys.symbol.checkmark_square_on_square'),
        iconFontColor: [$r('sys.color.ohos_id_color_primary')],
        textName: $r('app.string.msg_select_all'),
        textFontColor: $r('sys.color.font_primary'),
        isHidden: !this.isSelectStatus
      }
    }
    this.toolBarList.splice(-1, 1, checkAllOption)
  }

  destinationShow() {
    this.isPageHide = false;
  }

  @Builder
  navTitle() {
    if (this.isSelectStatus) {
      Row() {
        Text(this.mSlidePreviewCtrl.selectSaveCount == 0
          ? $r('app.string.msg_unselected_tip')
          : $r('app.plural.msg_selected_tip_new', this.mSlidePreviewCtrl.selectSaveCount,
          LocationUtil.numFormat(this.mSlidePreviewCtrl.selectSaveCount)))
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Bold)
          .height('100%')
          .padding(this.textDirection === 'rtl' ?
            {
              right: this.curBp === common.STR.DEVICE_MOBILE_PHONE ? 8 : this.isPad ? 24 : $r('sys.float.margin_left')
            } :
            { left: this.curBp === common.STR.DEVICE_MOBILE_PHONE ? 8 : this.isPad ? 24 : $r('sys.float.margin_left') })
      }
    } else {
      Row() {
        Text($r('app.string.mms'))
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Bold)
          .focusable(true)
          .height('100%')
          .padding(this.textDirection === 'rtl' ?
            {
              right: this.curBp === common.STR.DEVICE_MOBILE_PHONE ? 8 : this.isPad ? 24 : $r('sys.float.margin_left')
            } :
            { left: this.curBp === common.STR.DEVICE_MOBILE_PHONE ? 8 : this.isPad ? 24 : $r('sys.float.margin_left') })
      }
    }
  }

  @Builder
  buildAttachShowArea(item: SlideMmsItem, index: number) {
    if (item.type === commonData.MM_ATTACHMENT_TYPE.IMAGE) {
      MMContentImage({
        item: item,
        isFromTransmit: false,
        isTouch: $isTouch,
        isPop: false,
        isFromSlide: true
      })
    } else if (item.type === commonData.MM_ATTACHMENT_TYPE.VIDEO) {
      MMContentVideo({
        item: item,
        videoWidth: 151,
        videoHeight: 202,
        isFromTransmit: false
      })
        .width(151)
    } else if (item.type === commonData.MM_ATTACHMENT_TYPE.AUDIO) {
      SlideAudio({
        audioItem: item,
        audioId: item.name,
        isAutoPlay: this.isAutoPlayAudio && index === 0,
        isPageHide: this.isPageHide
      })
    } else if (item.type === commonData.MM_ATTACHMENT_TYPE.MAP) { // 彩信位置附件
      MmsContentMap({
        isCallFrom: 'SlidePreview',
        mmsItem: {
          mmsSource: [item],
          content: item.content
        },
        isFromTransmit: false,
        bubbleTextDirection: 'left',
        bubbleTextBorderRadius: [2, 16],
        bubbleTextBackgroundColor: $r('sys.color.ohos_id_color_card_bg'),
        isDisplayInSlidePreview: true
      })
    }

  }

  @Builder
  buildToggleOrSave(item: SlideMmsItem, index: number) {
    if (this.isSelectStatus) {
      Toggle({
        type: ToggleType.Checkbox,
        isOn: item.isCbChecked
      })
        .width(20)
        .height(20)
        .onChange(((isOn: boolean) => {
          this.mSlidePreviewCtrl.listCheckBoxChange(index, isOn);
        }))
        .responseRegion({
          x: -2,
          y: -14,
          width: 24,
          height: 48
        })
        .alignRules({
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
    } else {
      SaveButton({ icon: SaveIconStyle.FULL_FILLED, buttonType: ButtonType.Normal })
        .width(24)
        .height(24)
        .backgroundColor(Color.Transparent)
        .iconColor($r('sys.color.ohos_id_color_primary'))
        .iconSize(24)
        .onClick(() => {
          if (item.type === commonData.MM_ATTACHMENT_TYPE.IMAGE) {
            this.mSlidePreviewCtrl.saveImageToPhotoAlbums(item.path);
          } else if (item.type === commonData.MM_ATTACHMENT_TYPE.VIDEO) {
            this.mSlidePreviewCtrl.saveVideoToAlbums(item.path);
          } else {
            this.mSlidePreviewCtrl.saveAudioToFileManager(item.path, item.name);
          }
        })
    }

  }

  @Builder
  buildSlideItem(item: SlideMmsItem, index: number) {
    Row() {
      Column() {
        // attach area
        if (MmsUtil.isSlideAttach(item.type)) {
          Stack({ alignContent: Alignment.End }) {
            Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
              this.buildAttachShowArea(item, index);
            }.width('100%')

            Flex({ justifyContent: FlexAlign.End, alignItems: ItemAlign.Center }) {
              Column() {
                this.buildToggleOrSave(item, index)
              }.padding({ right: $r('app.float.blocked_records_padding') })
              .margin({ top: MmsUtil.isAudio(item.type) ? '-19vp' : 0 })
            }
            .width('40vp')
          }.margin({
            bottom: $r('app.float.space_24')
          })
        }

        if (item.content && !this.isSelectStatus) {
          if (item.type === commonData.MM_ATTACHMENT_TYPE.MAP) { // 彩信位置附件
            if (item.inputBoxTextOfMmsMap) {
              this.renderText(item.inputBoxTextOfMmsMap);
            }
          } else {
            this.renderText(item.content);
          }
        }

        if (this.mSlidePreviewCtrl.totalCount > 1) {
          Stack() {
            Divider()
              .width('100%')
              .color($r('sys.color.comp_divider'))

            Text() {
              Span(String(index + 1));
              Span('/' + this.mSlidePreviewCtrl.totalCount)
            }
            .fontSize($r('app.float.settings_item_secondary_title_font_size'))
            .fontColor($r('sys.color.font_secondary'))
            .fontFamily('HarmonyHeiTi')
            .padding({
              left: $r('app.float.blocked_records_list_padding'),
              right: $r('app.float.blocked_records_list_padding')
            })
            .backgroundColor($r('sys.color.background_secondary'))
          }
        }
      }
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding({
      top: $r('app.float.space_16')
    })
  }

  @Builder
  renderText(value: string | undefined) { //渲染附件携带的文本
    Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Text(value)
        .enableDataDetector(true)
        .margin({
          left: $r('app.float.space_16'),
          right: $r('app.float.space_16'),
          bottom: $r('app.float.blocked_records_divider_padding')
        })
        .padding({
          bottom: 0
        })
        .copyOption(CopyOptions.LocalDevice);
    }.width('100%')
  }

  @Builder
  buildSaveAllBottomBar() {
    Column() {
      Column() {
        SaveButton({ icon: SaveIconStyle.FULL_FILLED, buttonType: ButtonType.Normal })
          .width($r('app.float.icon_side_length_medium'))
          .height($r('app.float.icon_side_length_medium'))
          .backgroundColor(Color.Transparent)
          .iconColor($r('sys.color.ohos_id_color_primary'))
          .iconSize($r('app.float.icon_side_length_medium'))
          .onClick(() => {
            this.mSlidePreviewCtrl.clickSaveAllBtn();
          })
        Text($r('app.string.saveAll'))
          .fontSize('10vp')
          .margin({ top: $r('app.float.settings_item_padding_top') })
          .fontColor($r('sys.color.ohos_id_color_toolbar_text'))
          .fontWeight(FontWeight.Medium)
      }
      .onClick(() => {
        this.mSlidePreviewCtrl.clickSaveAllBtn();
      })
      .accessibilityGroup(true)
      .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.saveAll').id))
      .height('100%')
      .width('100%')
      .actionButtonPressStyles()
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
    }
    .width('20%')
    .height('100%')
    .padding({ left: 4, right: 4 })
    .opacity(this.isSelectStatus && !this.selectSaveCount ? 0.4 : 1)
    .enabled(!this.isSelectStatus || !!this.selectSaveCount)
    .visibility(Visibility.Visible)
  }

  @Builder
  bottomBarMenus() {
    Row() {
      if (this.isShowSaveAllBtn && this.mSlidePreviewCtrl.attachIsNotEmpty) {
        this.buildSaveAllBottomBar()
      }
      ForEach(this.toolBarList, (barOption: BottomBarOption) => {
        BottomBar(barOption)
      })
    }
    .justifyContent(FlexAlign.SpaceAround)
    .width('100%')
    .height(52)
    .alignRules({
      left: { anchor: '__container__', align: HorizontalAlign.Start },
      bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
    })
    .id('bottom_bar_menus')
  }

  onBackIconClick = () => { // 页面返回按钮或全部保存模式下退出按钮的点击事件
    HiLog.i(TAG, `onClickBackIcon: isSelectStatus: ${this.mSlidePreviewCtrl.isSelectStatus}`);
    this.transitionType = NavigationSystemTransitionType.DEFAULT;
    if (this.destinationBackPress() === false) {
      //返回值为true时，表示重写返回键逻辑，返回值为false时，表示回退到上一个页面。
      this.pageInfos?.pop();
    }
  }

  build() {
    //HdsNavDestination() {
    NavDestination() {
      RelativeContainer() {
        if (this.mSlidePreviewCtrl.attachIsNotEmpty) {
          List() {
            if (this.msgTitle && !this.isSelectStatus) {
              ListItem() {
                Text($r('app.string.subject', this.msgTitle))
                  .margin({
                    top: $r('app.float.space_16'),
                    left: $r('app.float.space_16'),
                    right: $r('app.float.space_16')
                  })
              }
            }
            LazyForEach(this.mSlidePreviewCtrl.slideDataSource, (item: SlideMmsItem, index) => {
              ListItem() {
                this.buildSlideItem(item, index)
              }
            }, (item: SlideMmsItem) => JSON.stringify(item))
          }
          .width('100%')
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            bottom: { anchor: 'bottom_bar_menus', align: VerticalAlign.Top }
          })
          .onScrollStop(() => {
            this.isAutoPlayAudio = false;
          })
        }  else {
          EmptyPage({
            icon: $rawfile('icon/no_Message.svg'),
            emptyDescription: $r('app.string.mms_empty_content'),
            fullPage: true,
            fixedPageHeight: false,
            customBackgroundColor: Color.Transparent,
          })
            .height('calc(100% - 52vp)')
        }
        this.bottomBarMenus()
      }
      .width('100%')
      .height('100%')
      .padding({ bottom: this.fullScreenPadding ? (this.fullScreenPadding.bottom as number) : 0 })
      .renderGroup(false)
    }
    .hideTitleBar(false)
    .bindToScrollable([this.scroller])
    .title($r('app.string.mms'))
    // .titleBar(TitleBarUtil.getTitleBar({mainTitle: $r('app.string.mms'), isMultipleSelectState: this.isSelectStatus,
    //   enableComponentSafeArea: true, selectedNumber: this.mSlidePreviewCtrl.selectSaveCount,
    //   callback: this.onBackIconClick }))
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_toolbar_sub_bg'))
    .onShown(() => {
      this.transitionType = NavigationSystemTransitionType.DEFAULT;
      this.destinationShow();
    })
    .onHidden(() => {
      this.destinationPageHide();
    })
    .onBackPressed(() => {
      this.transitionType = NavigationSystemTransitionType.DEFAULT;
      return this.destinationBackPress();
    })
    .systemTransition(this.transitionType)
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP])
  }

  destinationBackPress(): boolean {
    return this.mSlidePreviewCtrl.onBackPress();
  }

  destinationPageHide() {
    this.isPageHide = true;
  }
}