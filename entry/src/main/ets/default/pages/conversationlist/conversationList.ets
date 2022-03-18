/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import prompt from '@system.prompt';
import router from '@system.router';
import ConListController from './conversationListController'
import common from '../../data/commonData'
import {DeleteDialog} from '../../views/MmsDialogs';
import {MmsListItem} from '../../views/MmsListItem';
import {SearchResultPage} from './SearchResultPage';
import LooseObject from '../../data/LooseObject';

@Entry
@Component
struct ConversationList {
  @StorageLink('ConListController') mConListCtrl: ConListController = ConListController.getInstance();
  delDialogController: CustomDialogController = new CustomDialogController({
    builder: DeleteDialog({
      cancel: () => {
        this.mConListCtrl.deleteDialogCancel()
      },
      confirm: () => {
        this.mConListCtrl.deleteDialogConfirm()
      },
      msg: this.mConListCtrl.strMsgDeleteDialogTip,
      hasLockMsg: this.mConListCtrl.hasLockMsg,
      setSelectLock: () => {
        this.mConListCtrl.setSelectLock()
      },
      isSelectLockMsg: this.mConListCtrl.isSelectLockMsg,
      setSelectLockChange: (isOn: boolean) => {
        this.mConListCtrl.setSelectLockChange(isOn)
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: '-20vp' }
  })
  @State isSMSReceiving: boolean = false
  @State smsReceiving: boolean = false

  build() {
    Column() {
      Row() {
        Image($rawfile('icon/ic_cancel_black.svg')).height('24vp').width('24vp')
          .onClick(() => {
            this.mConListCtrl.onBackPress()
          })
          .visibility(this.mConListCtrl.isMultipleSelectState
            ? Visibility.Visible : Visibility.None)
        Blank()
        Image($rawfile('icon/add_2.svg'))
          .width($r('app.float.icon_side_length_medium'))
          .height($r('app.float.icon_side_length_medium'))
          .onClick(() => {
            // 跳转新建短信界面
            router.push(
              {
                uri: 'pages/conversation/conversation',
                params: {
                  isNewMsg: true
                }
              })
          }).visibility(this.mConListCtrl.isMultipleSelectState
          ? Visibility.Hidden : Visibility.Visible)

        Image($rawfile('icon/ic_public_more.svg'))
          .width($r('app.float.icon_side_length_medium'))
          .height($r('app.float.icon_side_length_medium'))
          .onClick(() => {
          })
          .visibility(this.mConListCtrl.isMultipleSelectState
            ? Visibility.Hidden : Visibility.Visible)
          .margin({ right: $r('app.float.action_bar_space'), left: $r('app.float.action_bar_space') })
          .bindMenu([
            { //this.mConListCtrl.messageList.length == 0
              // @ts-ignore
              value: $r("app.string.delete"),
              action: () => {
                this.mConListCtrl.isMultipleSelectState = true
                this.mConListCtrl.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN)
              }
            },
            {
              // @ts-ignore
              value: $r("app.string.favorites"),
              action: () => {
                this.mConListCtrl.jumpToFavoritesPage();
              }
            },
            {
              // @ts-ignore
              value: $r("app.string.blocked"),
              action: () => {
              }
            },
            {
              // @ts-ignore
              value: $r("app.string.markAllAsRead"),
              action: () => {
                this.mConListCtrl.clickToMarkAllAsRead()
              }
            },
            {
              // @ts-ignore
              value: $r("app.string.settings"),
              action: () => {
                this.mConListCtrl.jumpToSettingsPage()
              }
            },
          ])
      }
      .width('100%')
      .height($r('app.float.action_bar_height'))
      .padding({ left: $r('app.float.settings_item_padding_left') })

      Row() {
        Text($r("app.string.messages"))
          .fontSize($r('app.float.list_title_font_size_large'))
          .fontColor('#182431')
          .fontWeight(FontWeight.Bold)
          .visibility(this.mConListCtrl.isMultipleSelectState
            ? Visibility.None : Visibility.Visible)


        Text(this.mConListCtrl.conversationSelectedNumber === 0 ?
        $r("app.string.msg_unselected_tip") : $r("app.string.msg_selected_tip", this.mConListCtrl.conversationSelectedNumber))
          .fontSize('30fp')
          .fontColor(Color.Black)
          .visibility(this.mConListCtrl.isMultipleSelectState
            ? Visibility.Visible : Visibility.None)
      }
      .width('100%')
      .height('56vp')
      .padding({ left: '24vp' })


      if (this.mConListCtrl.messageList.length != 0) {
        //搜索框
        // @ts-ignore
        Search({ value: this.mConListCtrl.inputValueOfSearch, placeholder: $r("app.string.search2") })
          .visibility(Visibility.None)
          .height('40vp')
          .border({ radius: '20vp' })
            //          .focusable(this.mInfoMsgCtrl.isSearchFocusable)
          .enabled(!this.mConListCtrl.isMultipleSelectState)
          .margin({ left: '24vp', right: '24vp', top: '8vp', bottom: '8vp' })
          .backgroundColor($r("app.color.search_input_background"))
        //          .onChange((value: string) => {
        ////            this.mConListCtrl.clickToSearch(value);
        //          })
        //          .onTouch((event: TouchEvent) => {
        //            if (event.type === TouchType.Down) {
        ////              this.mConListCtrl.searchTouchStart(true, event)
        //            }
        //          })
      }
      Column() {
        List() {
          if (this.mConListCtrl.hasAggregate && this.mConListCtrl.showInfoDivWhenSearchFlag
          && this.mConListCtrl.isSearchStatus) {
            ListItem() {
              Column() {
                Row() {
                  if (this.mConListCtrl.unreadTotalOfInfo <= 0) {
                    Image($rawfile('icon/entrance_icon01.svg'))
                      .clip(Circle)
                      .width('40vp')
                      .height('40vp')
                  } else {
                    Badge({
                      count: this.mConListCtrl.unreadTotalOfInfo,
                      maxCount: 99,
                      style: { color: 0xFFFFFF, fontSize: '10', badgeSize: '16', badgeColor: Color.Red }
                    }) {
                      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
                        Image($rawfile('icon/entrance_icon01.svg'))
                          .clip(Circle)
                          .width('40vp')
                          .height('40vp')
                      }.width('100%')
                      .height('100%')
                    }.width('40vp').height('40vp')
                  }

                  Column() {
                    Row() {
                      Text($r("app.string.infoMessages"))
                        .fontSize('16fp')
                        .fontColor(Color.Black)
                      Blank()
                      if (this.mConListCtrl.unreadTotalOfInfo > 0) {
                        Text(this.mConListCtrl.unreadTotalOfInfo + '')
                          .fontSize('12fp')
                          .fontColor(Color.Black)
                          .height('64vp')
                          .width('64vp')
                      }
                    }.width('100%')
                    .height('100%')
                    .margin({ left: '4vp' })

                    if (this.mConListCtrl.messageList.length > 0) {
                      Divider().vertical(false).color(Color.Black).height('1vp')
                    }
                  }.layoutWeight(1)
                  .height('100%')
                  .padding({ left: '12vp' })
                }.height('64vp')
                .width('100%')
                .padding({ left: '24vp', right: '24vp' })
                .onClick(() => {
                  this.mConListCtrl.clickToInfoMessages()
                })
              }
            }
          }


          ForEach(this.mConListCtrl.messageList, (item: any, index: number) => {
            ListItem() {
              MmsListItem({
                item: item,
                index: index,
                isShowHead: this.mConListCtrl.isShowContactHeadIcon,
                isMultipleSelectState: this.mConListCtrl.isMultipleSelectState,
                onClickHead: (event: ClickEvent) => {
                  this.mConListCtrl.clickToGroupDetail(index);
                },
                onClickBody: (event: ClickEvent) => {
                  this.mConListCtrl.clickInfoToConversation(index);
                },
                onItemLongPress: (event: GestureEvent) => {
                  this.mConListCtrl.conversationLongPress(index);
                },
                onTouchStart: (event: GestureEvent) => {
                  this.mConListCtrl.touchStart(event, index);
                },
                onTouchUpdate: (event: GestureEvent) => {
                  this.mConListCtrl.touchMove(event, index);
                },
                onTouchEnd: (event: GestureEvent) => {
                  this.mConListCtrl.touchEnd(event, index);
                },
                onClickFirstSlipBtn: (event: ClickEvent) => { //已读
                  this.mConListCtrl.markAllAsReadByIndex(index);
                },
                onClickSecondSlipBtn: (event: ClickEvent) => { //删除
                  this.mConListCtrl.deleteAction(index);
                  this.delDialogController.open();
                }
              })
            }.width('100%')
            .height('64vp')
          }, (item: any) => item.threadId.toString())
        }
        .visibility(Visibility.Visible)
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
        .align(Alignment.Top)
      }.layoutWeight(1)

      /*底部全选删除按钮*/
      Row() {
        Column() {
          Image($rawfile('icon/ic_delete_m.svg')).height(20).width(20)
          Text($r("app.string.delete")).fontSize(10).fontColor(Color.Black)
        }.layoutWeight(1).onClick(() => {
          this.mConListCtrl.clickConversationDelete()
          this.delDialogController.open()
        }).enabled(!(this.mConListCtrl.conversationSelectedNumber === 0))
        .opacity(this.mConListCtrl.conversationSelectedNumber == 0 ? 0.5 : 1)

        Column() {
          Image(this.mConListCtrl.isConversationCheckAll ?
          $rawfile('icon/ic_select_all_filled.svg') : $rawfile('icon/ic_select_all.svg'))
            .height(20).width(20)
          Text(this.mConListCtrl.isConversationCheckAll ? $r("app.string.msg_deselect_all")
                                                        : $r("app.string.msg_select_all")).fontSize(10)
            .fontColor(this.mConListCtrl.isConversationCheckAll ? Color.Blue : Color.Black)
        }.layoutWeight(1).onClick(() => {
          this.mConListCtrl.clickConversationCheckAll()
        })
      }.width('100%')
      .height(45)
      .backgroundColor($r("app.color.white"))
      .visibility(this.mConListCtrl.isMultipleSelectState
        ? Visibility.Visible : Visibility.None)

      if (this.mConListCtrl.messageList.length == 0 && !(this.mConListCtrl.hasAggregate && this.mConListCtrl.showInfoDivWhenSearchFlag
      && this.mConListCtrl.isSearchStatus)) {
        EmptyView()
      }

    }
    .width('100%')
    .height('100%')
    .onKeyEvent((event: KeyEvent) => {
      if (event.keyCode === 4 && event.keyText === 'Back') { //返回按钮
        if (this.mConListCtrl.deleteDialogShow) {
          this.delDialogController.close()
          this.mConListCtrl.deleteDialogShow = false
          event.stopPropagation()
          return
        }

        if (this.mConListCtrl.isMultipleSelectState) {
          // @ts-ignore
          for (let element of this.mConListCtrl.messageList) {
            element.isCbChecked = false;
          }
          this.mConListCtrl.isMultipleSelectState = false;
          event.stopPropagation()
        }
        if (!this.mConListCtrl.isSearchStatus) {
          this.mConListCtrl.backSearch();
          event.stopPropagation()
        }
      }
    })
  }

  aboutToAppear() {
  }

  aboutToDisappear() {
  }

  onPageShow() {
    this.mConListCtrl.onShow();
  }

  onPageHide() {
    this.mConListCtrl.unSubscribe();

  }
}

@Component
struct EmptyView {
  build() {
    Column() {
      Image($rawfile('icon/ic_massage_m.svg'))
        .width('160vp')
        .height('157vp')
      Text($r("app.string.noMessages"))
        .margin({ top: '9vp' })
    }.height('100%')
    .padding({ top: $r('app.float.empty_view_top_padding') })
  }
}
