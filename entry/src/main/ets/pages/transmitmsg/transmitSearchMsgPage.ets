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

import LooseObject from '../../data/LooseObject';
import HiLog from '../../utils/HiLog';
import { MmsListItem } from '../../views/MmsListItem';
import TransmitSearchMsgController from './transmitSearchMsgController';
import { HighlightType } from '../../utils/Highlight';
import { TransmitMmsDialog, TransmitMsgDialog, TransmitThirdPartMsgDialog } from '../../views/MmsDialogs';
import { messageType } from '../conversationlist/conversationListController';
import commonData from '../../data/commonData';
import { MmsListItemAvatar } from '../../views/MmsListItemAvatar';
import MmsAvatarController from '../../views/MmsAvatar/MmsAvatarController';
import { ContactAvatar } from '../../views/ContactAvatar';
import AvatarColor from '../../model/common/AvatarColor';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import { SubHeader } from '@ohos.arkui.advanced.SubHeader';
import settings from '@ohos.settings';
import StringUtil from '../../utils/StringUtil';
import Constant from '../../data/Constant';
import DeviceUtil from '../../utils/DeviceUtil';
import TransmitMessageUtil from '../../utils/TransmitMessageUtils'
import FavoriteController from '../../pages/favoritepage/favoriteController'
import myCommon from '@ohos.app.ability.common';
import { SymbolGlyphModifier } from '@kit.ArkUI';
import { MySearch, MyText } from './transmitSearchMsg';
import { EmptyPage } from '../../views/EmptyPage';

class MyItem {
  public index: number = -1
  public search: MySearch = new MySearch()
}

const TAG = 'TransmitSearchMsg';

@Builder
export function TransmitSearchMsgLoader(param: LooseObject): void {
  TransmitSearchMsg();
}

@Component
export default struct TransmitSearchMsg {
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;
  @Consume('pageInfos') pageInfos: NavPathStack
  private context = getContext(this) as myCommon.UIAbilityContext;
  @State transmitSearchMsgCtrl: TransmitSearchMsgController = TransmitSearchMsgController.getInstance();
  @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding | null = null;
  @State isExpand: boolean = false;
  scroller: Scroller = new Scroller();
  @State isSearchFocusable: boolean = true;
  /* 设备是否开启无障碍屏幕朗读 */
  private accessibilitySwitch: string = Constant.ACCESSIBILITY_SCREEN_READER_SWITCH_CLOSED;

  transmitMsgDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle:TransmitMessageUtil.getMainTitle(this.transmitSearchMsgCtrl),
      contentBuilder: () => {
        this.transmitDialogControllerBuildContent();
      },
      contentAreaPadding: {left: 0, right: 0, top: 0, bottom: 0}
    }),
    autoCancel: false,
  });

  @Builder
  transmitDialogControllerBuildContent(): void {
    TransmitMsgDialog({
      controller: this.transmitMsgDialogController,
      cancel: () => {
      },
      confirm: (value: boolean) => {
        this.transmitSearchMsgCtrl.transmit(this.context, value)
      },
      msg: this.transmitSearchMsgCtrl.dialogMsg,
    });
  }

  transmitMmsDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle:TransmitMessageUtil.getMainTitle(this.transmitSearchMsgCtrl),
      contentBuilder: () => {
        this.transmitMmsDialogControllerBuildContent();
      },
      contentAreaPadding: {left: 0, right: 0, top: 0, bottom: 0}
    }),
    autoCancel: false,
  });

  @Builder
  transmitMmsDialogControllerBuildContent(): void {
    TransmitMmsDialog({
      controller: this.transmitMmsDialogController,
      cancel: () => {},
      confirm: (value) => {
        this.transmitSearchMsgCtrl.transmit(this.context, value);
      },
      msg: this.transmitSearchMsgCtrl.dialogMsg,
      isRcs: this.transmitSearchMsgCtrl?.isRcs || false
    });
  }

  transmitThirdPartMsgDialog: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.transmitThirdPartMsgDialogBuildContent();
      },
      contentAreaPadding: {left: 0, right: 0, top: 0, bottom: 0}
    }),
    autoCancel: false,
  });

  @Builder
  transmitThirdPartMsgDialogBuildContent(): void {
    TransmitThirdPartMsgDialog({
      controller: this.transmitThirdPartMsgDialog,
      cancel: () => {},
      confirm: (value) => {
        this.transmitSearchMsgCtrl.transmit(this.context, value);
      },
      msg: this.transmitSearchMsgCtrl.dialogMsg
    })
  }

  aboutToAppear(): void {
    this.accessibilitySwitch = settings.getValueSync(getContext(this), 'accessibility_screenreader_enabled',
      Constant.ACCESSIBILITY_SCREEN_READER_SWITCH_CLOSED);
  }

  destinationAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    this.transmitSearchMsgCtrl.init(this.pageInfos);
  }

  destinationBackPress() {
    this.transmitSearchMsgCtrl.refresh();
    this.transmitSearchMsgCtrl.back();
  }

  destinationDisappear() {
    this.transmitSearchMsgCtrl.inputText = '';
  }

  build() {
    NavDestination() {
      Column() {
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center}) {
          this.searchBuilder();
        }
        .width('100%')
        .height(56)

        Stack({ alignContent: Alignment.TopStart }) {
            if (this.transmitSearchMsgCtrl.inputText.length == 0) {
              ContentListView({ searchCtrl: this.transmitSearchMsgCtrl }).zIndex(1)

              Column() {}
              .width('100%')
              .height('100%')
              .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.guide_action_text_previous').id))
              .visibility((this.transmitSearchMsgCtrl.inputText === '') ? Visibility.Visible : Visibility.None)
              .zIndex(1)
              .onClick(()=> {
                if (DeviceUtil.isPC()) {
                  AppStorage.setOrCreate('isTransmitSearch', false);
                } else {
                  this.transmitSearchMsgCtrl.back();
                }
              })
            } else {
              Scroll() {
                Column() {
                  if (!this.transmitSearchMsgCtrl.judgeInputIsNumber() &&
                    this.transmitSearchMsgCtrl.searchCount === 0) {
                    TransmitSearchEmptyPage()
                  } else if (this.transmitSearchMsgCtrl.searchCount === 0) {
                    Column() {
                      SubHeader({
                        secondaryTitle: $r('app.string.msg_send_to')
                      }).margin({ left: -12 })

                      Row() {
                        Text(this.transmitSearchMsgCtrl.inputText)
                          .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
                          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                          .fontWeight(FontWeight.Medium)
                          .maxLines(2)
                      }
                      .padding({ left: 16 })
                      .justifyContent(FlexAlign.Start)
                      .alignItems(VerticalAlign.Center)
                      .width('100%')
                      .height(48)
                      .onClick(() => {
                        if (DeviceUtil.isPC()) {
                          AppStorage.setOrCreate('isTransmitShow', false);
                          AppStorage.setOrCreate('isFavoriteTransmitShow', false);
                        }
                        this.transmitSearchMsgCtrl.clickPhone();
                        if (this.transmitSearchMsgCtrl.mmsStatus === 0) {
                          this.transmitMsgDialogController.open();
                        } else if (this.transmitSearchMsgCtrl.mmsStatus === 3 ||
                          this.transmitSearchMsgCtrl.mmsStatus === 4 ||
                          this.transmitSearchMsgCtrl.mmsStatus === 5) {
                          this.transmitThirdPartMsgDialog.open();
                        } else {
                          this.transmitMmsDialogController.open();
                        }
                      })
                    }
                  } else {
                    this.TransmitSearchContactsPage()
                  }
                }
                .width('100%')
                .height('100%')
                .backgroundColor($r('sys.color.ohos_id_color_background'))
                .visibility((this.transmitSearchMsgCtrl.inputText === '') ? Visibility.None : Visibility.Visible)
              }
              .layoutWeight(1)
              .align(Alignment.Top)
              .scrollable(ScrollDirection.Vertical)
              .edgeEffect(EdgeEffect.Spring)
              .zIndex(2)
            }
          }
      }
      .width('100%')
      .height('100%')
      .padding(this.fullScreenPadding)
    }
    .onAppear(() => {
      this.destinationAppear();
    })
    .onDisAppear(() => {
      this.destinationDisappear();
    })
    .onBackPressed(() => {
      this.destinationBackPress();
      return true;
    })
    .hideTitleBar(true)
  }

  @Builder
  TransmitSearchContactsPage() {
    SubHeader({
      secondaryTitle: $r('app.plural.contacts_found', this.transmitSearchMsgCtrl.searchCount,
        this.transmitSearchMsgCtrl.searchCount),
    }).margin({ left: -12 })

    List({ scroller: this.scroller }) {
      LazyForEach(this.transmitSearchMsgCtrl.transmitSearchListDataSource,
        (item: MyItem, index: number) => {
          ListItem() {
            this.searchItem(item, index)
          }
        }, (item: MyItem) => JSON.stringify(item));

      if (this.transmitSearchMsgCtrl.searchList.length > 3) {
        this.listItemCollapseOpen()
      }
    }
    .padding({ left: 16, right: 16 })
    .width('100%')
    .height(DeviceUtil.isPC()?'calc(100% - 88vp)':'86.5%')
    .scrollBar(BarState.Off)
  }

  @Builder
  searchItem(item: MyItem, index: number) {
    Column() {
      ContentItem({ item: item.search, transmitSearchCtrl: this.transmitSearchMsgCtrl })
        .onClick(() => {
          if (DeviceUtil.isPC()) {
            AppStorage.setOrCreate('isTransmitShow', false);
            AppStorage.setOrCreate('isFavoriteTransmitShow', false);
          }
          this.transmitSearchMsgCtrl.clickContactAction(item.search);
          if (this.transmitSearchMsgCtrl.mmsStatus === commonData.TRANSMIT_MSG_STATUS.NO_MMS) {
            this.transmitMsgDialogController.open();
          } else if (this.transmitSearchMsgCtrl.mmsStatus === commonData.TRANSMIT_MSG_STATUS.THIRD_PART_MMS ||
            this.transmitSearchMsgCtrl.mmsStatus === commonData.TRANSMIT_MSG_STATUS.SHARE_MMS ||
            this.transmitSearchMsgCtrl.dialogMsg.mmsStatus === commonData.TRANSMIT_MSG_STATUS.SHARE_SMS) {
            this.transmitThirdPartMsgDialog.open();
          } else {
            this.transmitMmsDialogController.open();
          }
        })
        .height('100%');
      if (this.transmitSearchMsgCtrl.isDividerShow(this.isExpand, index)) {
        Divider()
          .vertical(false)
          .margin({ left: this.transmitSearchMsgCtrl.isShowHead ? 52 : 0 })
          .width('100%')
          .color('sys.color.ohos_id_color_list_separator');
      }
    }
    .height(this.fontSizeScale > 1 ? this.fontSizeScale * 44 : 64)
  }

  @Builder
  listItemCollapseOpen() {
    ListItem() {
      Row() {
        Text(this.isExpand ? $r('app.string.contacts_retract') : $r('app.string.contacts_open'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .fontWeight(FontWeight.Regular)
          .margin({ right: 4 });
        SymbolGlyph($r('sys.symbol.chevron_down'))
          .height(16)
          .width(16)
          .draggable(false)
          .fontColor([$r('sys.color.icon_fourth')])
          .fontSize('24vp')
          .rotate({
            x: 0,
            y: 0,
            z: 1,
            angle: this.isExpand ? 180 : 0
          });
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .height(48)
      .width('100%')
      .onClick(() => {
        this.isExpand = !this.isExpand;
        this.transmitSearchMsgCtrl.refreshSearchList(this.isExpand);
      });
    }
  }

  @Builder
  backButtonIcon() {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph($r('sys.symbol.chevron_backward')).id('back_image')
        .fontColor([$r('sys.color.ohos_id_color_primary')])
        .draggable(false)
        .fontSize('24vp')
        .width(24).height(24)
    }
    .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.guide_action_text_previous').id))
    .margin({ right: $r('sys.float.ohos_id_elements_margin_horizontal_m') })
    .width(40).height(40)
    .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
    .draggable(false)
    .borderRadius($r('sys.float.corner_radius_level10'))
    .onClick(() => {
      if (DeviceUtil.isPC()) {
        AppStorage.setOrCreate('isTransmitSearch', false);
      } else {
        this.transmitSearchMsgCtrl.back();
      }
    })
  }

  @Builder
  searchBox() {
    Search({ value: this.transmitSearchMsgCtrl.inputText, placeholder: $r('app.string.searchHit') })
      .searchIcon(new SymbolGlyphModifier($r('sys.symbol.magnifyingglass'))
        .fontColor([$r('sys.color.ohos_id_color_secondary')]))
      .cancelButton({ icon: new SymbolGlyphModifier($r('sys.symbol.xmark'))
        .fontColor([$r('sys.color.font_tertiary')]) })
      .layoutWeight(1)
      .placeholderColor($r('sys.color.ohos_id_color_text_secondary'))
      .placeholderFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Regular })
      .textFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Regular })
      .fontColor($r('sys.color.ohos_id_color_text_primary'))
      .backgroundColor($r('sys.color.ohos_id_color_text_field_sub_bg'))
      .enabled(true)
      .flexGrow(1)
      .flexShrink(1)
      .defaultFocus(true)
      .focusable(this.isSearchFocusable)
      .onClick(() => {
        if (!StringUtil.isEmpty(this.accessibilitySwitch)) {
          if (this.accessibilitySwitch ===
          Constant.ACCESSIBILITY_SCREEN_READER_SWITCH_OPEN) {
            this.isSearchFocusable = true;
          }
        }
      })
      .onTouch(() => {
        if (!StringUtil.isEmpty(this.accessibilitySwitch)) {
          if (this.accessibilitySwitch !== Constant.ACCESSIBILITY_SCREEN_READER_SWITCH_OPEN) {
            this.isSearchFocusable = true;
          }
        }
      })
      .onBlur(() => {
        this.isSearchFocusable = false;
      })
      .onChange((value: string) => {
        this.transmitSearchMsgCtrl.inputText = value;
        this.transmitSearchMsgCtrl.search(this.context, value);
        this.isExpand = false;
      })
  }
  @Builder
  searchBuilder() {
    Row() {
      this.backButtonIcon()
      this.searchBox()
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .zIndex(2)
    .width('100%')
    .height(56)
    .padding({ left: DeviceUtil.isPC() ? $r('sys.float.padding_level8') : $r('sys.float.margin_left'),
      right: DeviceUtil.isPC() ? $r('sys.float.padding_level8') : $r('sys.float.margin_right') })
  }
}

@Component
export struct ContentItem {
  item: MySearch = new MySearch();
  @Link transmitSearchCtrl: TransmitSearchMsgController;
  private mmsAvatarController: MmsAvatarController = MmsAvatarController.getInstance();

  build() {
    Row() {
      if (this.transmitSearchCtrl.isShowHead) {
        ContactAvatar({
          rawContactId: this.item.rawContactId,
          contactId: this.item.contactId,
          firstPhotoName: this.item.firstName,
          portraitColor: this.item.portraitColor
        })
          .height(40)
          .width(40)
          .onClick(() => {
            this.transmitSearchCtrl.clickAvatar(this.item);
          })
      }
      Column() {
        Row() {
          Text() {
            ForEach(this.item.nameHighlights, (name: MyText) => {
              Span(name.text)
                .fontColor(name.type === HighlightType.normal ? $r('sys.color.ohos_id_color_text_primary')
                  : $r('sys.color.ohos_id_color_text_primary_activated'))
                .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
                .fontWeight(FontWeight.Medium)
            })
          }
          .textAlign(TextAlign.Start)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .margin( { bottom: 2 })

        Row() {
          Text() {
            ForEach(this.item.infoHighlights, (info: MyText) => {
              Span(info.text)
                .fontColor(info.type === HighlightType.normal ? $r('sys.color.font_secondary')
                  : $r('sys.color.ohos_id_color_text_primary_activated'))
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
            })
          }
          .textAlign(TextAlign.Start)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .height('100%')
      .margin( { left: this.transmitSearchCtrl.isShowHead ? 16 : 0 })
      .layoutWeight(1)
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .height('100%')
    .width('100%')
  }
}

@Component
export struct ContentListView {
  @Link searchCtrl: TransmitSearchMsgController;
  @StorageLink('hasInfoMsg') hasInfoMsg: boolean = false;
  @StorageLink('unreadTotalOfInfo') unreadTotalOfInfo: number = 0;
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;
  /* 设备是否为pad */
  @State isPad: boolean = false
  // 设备是否为PC
  @State isPC: boolean = DeviceUtil.isPC();
  @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();
  @State isMultiSelectStatus: boolean = false;
  @State isInSetReadThreadIndex: number = -1;

  aboutToAppear(): void {
    this.isPad = DeviceUtil.isTablet();
  }

  build() {
    Column() {
      List() {
        if (this.hasInfoMsg) {
          ListItem() {
            Row() {
              if (this.searchCtrl.isShowHead) {
                SymbolGlyph($r('sys.symbol.bell_fill'))
                  .alignRules({
                    center: { anchor: '__container__', align: VerticalAlign.Center },
                    left: { anchor: '__container__', align: HorizontalAlign.Start }
                  })
                  .renderGroup(true)
                  .fontSize('24vp')
                  .fontColor([$r('sys.color.ohos_id_color_primary_contrary')])
                  .id('ic_bell_fill')
                  .width('40vp')
                  .height('40vp')
                  .margin({ right: 16 })
                  .draggable(false)
                  .borderRadius(20)
                  .backgroundColor($r('app.color.mms_avatar_bg'))
                  .padding(8)
              }
              Text($r('app.string.infoMessages'))
                .fontSize('16fp')
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                .fontWeight(FontWeight.Medium)
              Blank()
              if (this.unreadTotalOfInfo > 0) {
                Text(this.unreadTotalOfInfo + '')
                  .height('64vp')
                  .margin({
                    right: $r('app.float.settings_item_status_title_margin_right')
                  })
                  .fontSize($r('app.float.settings_item_secondary_title_font_size'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .width($r('app.float.settings_item_next_image_width'))
                  .height($r('app.float.settings_item_next_image_height'))
                  .fontColor([$r('sys.color.ohos_id_color_fourth')])
                  .draggable(false)
              }
            }
            .width('100%')
            .height('100%')
          }
          .padding({
            left: this.isPC ? 24 : this.isPad ? this.padMargin : 16,
            right: this.isPC ? 24 : this.isPad ? this.padMargin : 16
          })
          .width('100%')
          .height(56)
        }

        LazyForEach(this.searchCtrl.conversationListDataSource, (item: messageType) => {
          ListItem() {
            Row() {
              MmsListItem({
                item: item,
                isMultipleSelectState: this.isMultiSelectStatus,
                isInSetReadThreadIndex: this.isInSetReadThreadIndex,
                loadFromDB: false,
                isPad: this.isPad,
              })
            }
          }
          .width('100%')
          .height(this.fontSizeScale >= 1.45 ? (this.fontSizeScale * 60) + 'vp' : (this.fontSizeScale * 80) + 'vp')
        }, (item: messageType) => JSON.stringify(item))
      }
      .divider({
        strokeWidth: $r('app.float.settings_divider_strokeWidth'),
        startMargin: this.searchCtrl.isShowHead ? (52 + this.padMargin) :
          (this.isPC ? 24 : this.isPad ? this.padMargin : 16),
        endMargin: this.isPC ? 24 : this.isPad ? this.padMargin : 16,
        color: $r('sys.color.ohos_id_color_list_separator')
      })
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .width('100%')
    .backgroundColor($r('sys.color.ohos_id_color_background'))
  }
}

@Component
export struct TransmitSearchEmptyPage {
  build() {
    Column() {
      EmptyPage({
        icon: $rawfile('icon/ic_massage_m.svg'),
        emptyDescription: $r('app.string.there_is_no_match'),
        fullPage: true,
        fixedPageHeight: true,
        customBackgroundColor: Color.Transparent,
      })
        .id('empty_page')
        .onClick(()=>{
          this.getUIContext().getFocusController().clearFocus();
        })
        .offset({ y: 0 })
        .animation({
          duration: 200
        })
    }
    .height('calc(100% - 56vp)')
    .width('100%')
  }
}