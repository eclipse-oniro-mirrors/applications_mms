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
import router from "@system.router";
import ConListController from "./conversationListController";
import DeviceUtil from "../../utils/DeviceUtil";
import { DeleteDialog } from "../../views/MmsDialogs";
import { MmsListItem } from "../../views/MmsListItem";
import { MmsMenu } from "../../views/MmsMenu";

@Entry
@Component
struct ConversationList {
    @StorageLink('ConListController') mConListCtrl: ConListController = ConListController.getInstance();
    @State isSMSReceiving: boolean = false;
    @State smsReceiving: boolean = false;
    @State gridColumns: number = DeviceUtil.isTablet() ? 12 : 4;
    @State gridSizeType: SizeType = DeviceUtil.isTablet() ? SizeType.LG : SizeType.SM;
    @State gridGutter: string = '24vp';
    @State gridMargin: string = '24vp';
    private dialogAlignment: DialogAlignment = DeviceUtil.isTablet() ? DialogAlignment.Center : DialogAlignment.Bottom;
    private dialogOffset: Offset = DeviceUtil.isTablet() ? { dx: 0, dy: 0 } : { dx: 0, dy: -12 };
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
        alignment: this.dialogAlignment,
        offset: this.dialogOffset
    })
    private menuItems: Array<any> = [
        {
            value: $r("app.string.delete"),
            action: () => {
                this.mConListCtrl.showMultipleSelectView();
            },
            enabled: true
        }, {
            value: $r("app.string.markAllAsRead"),
            action: () => {
                this.mConListCtrl.clickToMarkAllAsRead();
            },
            enabled: true
        }, {
            value: $r("app.string.settings"),
            action: () => {
                this.mConListCtrl.jumpToSettingsPage();
            },
            enabled: true
        }
    ];

    /**
     * 当用户点击返回按钮时触发，仅@Entry修饰的自定义组件生效。
     * 返回true表示页面自己处理返回逻辑, 不进行页面路由。
     * 返回false表示使用默认的返回逻辑。
     * 不返回值会作为false处理。
     */
    onBackPress() {
        return this.mConListCtrl.onBackPress();
    }

    build() {
        GridContainer({
            columns: this.gridColumns,
            sizeType: this.gridSizeType,
            gutter: this.gridGutter,
            margin: this.gridMargin
        }) {
            Stack() {
                if (this.mConListCtrl.hasNoMessage && !(this.mConListCtrl.hasAggregate && this.mConListCtrl.showInfoDivWhenSearchFlag
                && this.mConListCtrl.isSearchStatus)) {
                    EmptyView()
                }

                Flex({
                    justifyContent: FlexAlign.SpaceBetween,
                    alignItems: ItemAlign.Center,
                    direction: FlexDirection.Column
                }) {
                    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start} ) {
                        Column() {
                            Row() {
                                if (!this.mConListCtrl.isMultipleSelectState) {

                                    Blank()
                                    Image($rawfile('icon/ic_public_add.svg'))
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
                                        })
                                    Column() {
                                        MmsMenu({
                                            menuItems: this.menuItems,
                                            sizeType: this.gridSizeType
                                        })
                                    }
                                    .margin({ left: $r('app.float.action_bar_space') })
                                } else {
                                    Image($rawfile('icon/ic_public_cancel.svg')).height('24vp').width('24vp')
                                        .onClick(() => {
                                            this.mConListCtrl.onBackPress()
                                        })

                                    Text(this.mConListCtrl.conversationSelectedNumber === 0 ?
                                    $r("app.string.msg_unselected_tip") : $r("app.string.msg_selected_tip", this.mConListCtrl.conversationSelectedNumber))
                                        .fontSize('20fp')
                                        .fontWeight(FontWeight.Bold)
                                        .fontColor(Color.Black)
                                        .margin({ left: 16 })
                                }
                            }
                            .width('100%')
                            .height($r('app.float.action_bar_height'))
                            Column() {
                                if (!this.mConListCtrl.isMultipleSelectState) {
                                    Row() {
                                        Text($r("app.string.messages"))
                                            .fontSize($r('app.float.list_title_font_size_large'))
                                            .fontColor('#182431')
                                            .fontWeight(FontWeight.Bold)
                                            .lineHeight(41)
                                    }
                                }
                                if (this.mConListCtrl.messageList.length != 0) {
                                    //搜索框
                                    // @ts-ignore
                                    Search({
                                        value: this.mConListCtrl.inputValueOfSearch,
                                        placeholder: "搜索信息"
                                    })
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
                            }
                        }.alignItems(HorizontalAlign.Start)

                        List() {
                            if (this.mConListCtrl.hasAggregate && this.mConListCtrl.showInfoDivWhenSearchFlag
                            && this.mConListCtrl.isSearchStatus) {
                                ListItem() {
                                    Column() {
                                        Row() {
                                            if (this.mConListCtrl.unreadTotalOfInfo <= 0) {
                                                Image($rawfile('icon/entrance_icon01.svg'))
                                                    .width('40vp')
                                                    .height('40vp')
                                            } else {
                                                Badge({
                                                    count: this.mConListCtrl.unreadTotalOfInfo,
                                                    maxCount: 99,
                                                    style: {
                                                        color: 0xFFFFFF,
                                                        fontSize: '10',
                                                        badgeSize: '16',
                                                        badgeColor: Color.Red
                                                    }
                                                }) {
                                                    Flex({
                                                        justifyContent: FlexAlign.Center,
                                                        alignItems: ItemAlign.Center
                                                    }) {
                                                        Image($rawfile('icon/entrance_icon01.svg'))
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
                                                    Divider()
                                                        .vertical(false)
                                                        .color($r("app.color.divider_color"))
                                                        .height('1vp')
                                                }
                                            }.layoutWeight(1)
                                            .height('100%')
                                            .padding({ left: '12vp' })
                                        }.height('64vp')
                                        .width('100%')
                                        .onClick(() => {
                                            this.mConListCtrl.clickToInfoMessages()
                                        })
                                    }
                                }
                            }

                            LazyForEach(this.mConListCtrl.conversationListDataSource, (item: any, index: number) => {
                                ListItem() {
                                    MmsListItem({
                                        item: item,
                                        index: index,
                                        isShowHead: this.mConListCtrl.isShowContactHeadIcon,
                                        isMultipleSelectState: this.mConListCtrl.isMultipleSelectState,
                                        onClickHead: (event: ClickEvent) => {
                                            this.mConListCtrl.clickToGroupDetail(item.index);
                                        },
                                        onClickBody: (event: ClickEvent) => {
                                            this.mConListCtrl.clickInfoToConversation(item.index);
                                        },
                                        onItemLongPress: (event: GestureEvent) => {
                                            this.mConListCtrl.conversationLongPress(item.index);
                                        },
                                        onTouchStart: (event: GestureEvent) => {
                                            this.mConListCtrl.touchStart(event, item.index);
                                        },
                                        onTouchUpdate: (event: GestureEvent) => {
                                            this.mConListCtrl.touchMove(event, item.index);
                                        },
                                        onTouchEnd: (event: GestureEvent) => {
                                            this.mConListCtrl.touchEnd(event, item.index);
                                        },
                                        onClickFirstSlipBtn: (event: ClickEvent) => { //已读
                                            this.mConListCtrl.markAllAsReadByIndex(item.index);
                                        },
                                        onClickSecondSlipBtn: (event: ClickEvent) => { //删除
                                            this.mConListCtrl.deleteAction(item.index);
                                            this.delDialogController.open();
                                        }
                                    })
                                }.width('100%')
                                .height('64vp')
                            }, (item: any) => item.threadId.toString())
                        }
                        .edgeEffect(EdgeEffect.Spring)
                        .width('100%')
                        .align(Alignment.Top)
                    }
                    .width("100%")

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
                                                                          : $r("app.string.msg_select_all"))
                                .fontSize(10)
                                .fontColor(this.mConListCtrl.isConversationCheckAll ? $r("app.color.control_activated_color") : $r('app.color.main_font_color'))
                        }.layoutWeight(1).onClick(() => {
                            this.mConListCtrl.clickConversationCheckAll()
                        })
                    }.width('100%')
                    .height(45)
                    .backgroundColor($r("app.color.white"))
                    .visibility(this.mConListCtrl.isMultipleSelectState
                        ? Visibility.Visible : Visibility.None)
                }
                .width('100%')
                .height('100%')
                .useSizeType({
                    xs: { span: 4, offset: 0 }, sm: { span: 4, offset: 0 },
                    md: { span: 12, offset: 0 }, lg: { span: 12, offset: 0 }
                })
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
        }

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
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
            Column() {
                Image($rawfile('icon/ic_massage_m.svg'))
                    .width('160vp')
                    .height('157vp')
                Text($r("app.string.noMessages"))
                    .margin({ top: '9vp' })
                    .fontWeight(FontWeight.Regular)
                    .fontFamily('HarmonyHeiTi')
                    .fontSize($r('app.float.conversation_list_no_message_fs'))
                    .fontColor($r('app.color.main_font_color_40'))
            }
        }
        .height('100%')
        .width('100%')
    }
}
