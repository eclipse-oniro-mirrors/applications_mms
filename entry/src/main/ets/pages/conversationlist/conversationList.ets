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
import HiLog from "../../utils/HiLog"
import { DeleteDialog } from "../../views/MmsDialogs";
import { MmsListItem } from "../../views/MmsListItem";
import { MoreMenu } from "../../views/MmsMenu";

const TAG = "ConversationList";

@Component
export default struct ConversationList {
    @Link @Watch("changeSelectState") mConListCtrl: ConListController;
    private dialogAlignment: DialogAlignment = DeviceUtil.isTablet() ? DialogAlignment.Center : DialogAlignment.Bottom;
    private dialogOffset: Offset = DeviceUtil.isTablet() ? { dx: 0, dy: 0 } : { dx: 0, dy: -12 };
    private dialogGridCount: number = 4;
    delDialogController: CustomDialogController = null;
    @State mIsMultipleSelectState: boolean = false;
    @Provide menuItems:any = [];

    changeSelectState() {
        this.mIsMultipleSelectState = this.mConListCtrl.isMultipleSelectState;
        this.menuItems = [
            {
                value: $r("app.string.delete"),
                action: () => {
                    this.mConListCtrl.showMultipleSelectView();
                },
                enabled: true
            },
            {
                value: $r("app.string.markAllAsRead"),
                action: () => {
                    this.mConListCtrl.clickToMarkAllAsRead();
                },
                enabled: this.mConListCtrl.unreadTotal == 0 ? false : true
            },
            {
                value: $r("app.string.settings"),
                action: () => {
                    this.mConListCtrl.jumpToSettingsPage();
                },
                enabled: true
            }
        ];
        // @ts-ignore
        this.forceCompleteRerender(true) // recusvise
    }

    /**
     * The function executes after a new instance of the custom component is created and before its build function
     * is executed.
     * You can change the state variable in the aboutToAppear function, and these changes will take effect in
     * subsequent executions of the build function.
     */
    aboutToAppear() {
        this.delDialogController = new CustomDialogController({
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
            offset: this.dialogOffset,
            gridCount: this.dialogGridCount
        });

        this.mConListCtrl.registerDataChangeObserver(this.onContactChange, getContext(this));
    }

    onContactChange = () => {
        this.mConListCtrl.messageList = [];
        this.mConListCtrl.requestItem();
    }

    /**
     * Function executes before custom component destructor consumption.
     * Allow changes to state variables in the aboutToDisappear function, especially changes to the @Link variable,
     * can cause erratic application behavior.
     */
    aboutToDisappear() {
        this.mConListCtrl.unregisterDataChangeObserver(this.onContactChange, getContext(this))
    }

    build() {
        Stack(){
            Flex({
                direction: FlexDirection.Column,
                justifyContent: FlexAlign.Start,
                alignItems: ItemAlign.Start
            }) {
                Column() {
                    // Menu Bar
                    Row() {
                        if (!this.mConListCtrl.isMultipleSelectState) {
                            Blank()
                            Image($rawfile("icon/ic_public_add.svg"))
                                .width($r("app.float.icon_side_length_medium"))
                                .height($r("app.float.icon_side_length_medium"))
                                .onClick(() => {
                                    // The page for creating an SMS message is displayed.
                                    router.push(
                                        {
                                            uri: "pages/conversation/conversation",
                                            params: {
                                                isNewMsg: true
                                            }
                                        })
                                })
                            Column() {
                                MoreMenu()
                            }
                            .margin({ left: $r("app.float.action_bar_space") })
                        } else {
                            Image($rawfile("icon/ic_public_cancel.svg")).height("24vp").width("24vp")
                                .onClick(() => {
                                    this.mConListCtrl.onBackPress()
                                })
                            Text(this.mConListCtrl.conversationSelectedNumber === 0 ?
                            $r("app.string.msg_unselected_tip") :
                            $r("app.string.msg_selected_tip", this.mConListCtrl.conversationSelectedNumber))
                                .fontSize("20fp")
                                .fontWeight(FontWeight.Bold)
                                .margin({ left: 16 })
                        }
                    }
                    .width("100%")
                    .height($r("app.float.action_bar_height"))

                    // Title bar
                    Column() {
                        if (!this.mConListCtrl.isMultipleSelectState) {
                            Row() {
                                Text($r("app.string.messages"))
                                    .fontSize($r("app.float.list_title_font_size_large"))
                                    .fontColor($r("sys.color.ohos_id_color_foreground"))
                                    .fontWeight(FontWeight.Bold)
                                    .lineHeight(41)
                            }.margin({ top: 8 })

                            // Unread Message
                            Text($r("app.string.unread_messages", String(this.mConListCtrl.unreadTotal)))
                                .fontSize($r("sys.float.ohos_id_text_size_over_line"))
                                .fontColor($r("sys.color.ohos_id_color_text_secondary"))
                                .fontWeight(FontWeight.Regular)
                                .margin({ top: 2 })
                                .visibility(this.mConListCtrl.unreadTotal == 0 ? Visibility.None : Visibility.Visible)
                        }
                    }
                    .height(this.mConListCtrl.unreadTotal == 0 ? 56 : $r("app.float.message_bar_height"))
                    .visibility(this.mConListCtrl.isMultipleSelectState
                        ? Visibility.None : Visibility.Visible)
                }
                .alignItems(HorizontalAlign.Start)
                .flexShrink(0)

                if (!(this.mConListCtrl.hasNoOrdinaryMsg && !(this.mConListCtrl.hasAggregate && this.mConListCtrl.hasInfoMsg
                && this.mConListCtrl.isSearchStatus))) {
                    Column() {
                        //Search box
                        // @ts-ignore
                        Row() {
                            if (this.mConListCtrl.messageList.length != 0) {
                                Image($rawfile("icon/ic_message_search.svg"))
                                    .width(17)
                                    .height(18)
                                    .fillColor($r("sys.color.ohos_id_color_activated"))
                                    .margin({ left: 11.5 })

                                Text("搜索联系人")
                                    .fontSize("16fp")
                                    .fontColor($r("sys.color.ohos_id_color_text_secondary"))
                                    .margin({ left: 7.5 })
                            }
                        }
                        .visibility(Visibility.None)
                        .height(40)
                        .width("100%")
                        .margin({ top: 8, bottom: 8 })
                        .borderWidth(1.5)
                        .borderRadius(20)
                        .borderColor("#33182431")

                        List() {
                            if (this.mConListCtrl.hasAggregate && this.mConListCtrl.hasInfoMsg
                            && this.mConListCtrl.isSearchStatus) {
                                ListItem() {
                                    Column() {
                                        Row() {
                                            Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center }) {
                                                if (this.mConListCtrl.unreadTotalOfInfo > 0) {
                                                    Text(this.mConListCtrl.unreadTotalOfInfo < 100 ?
                                                    this.mConListCtrl.unreadTotalOfInfo.toString() : "99+")
                                                        .fontSize(10)
                                                        .align(Alignment.Center)
                                                        .padding({ left: 5, right: 5 })
                                                        .height(20)
                                                        .backgroundColor($r("sys.color.ohos_id_color_badge_red"))
                                                        .fontColor($r("sys.color.ohos_id_color_background"))
                                                        .zIndex(2)
                                                        .position({ x: "60%", y: "8%" })
                                                        .border({
                                                            width: 2,
                                                            color: $r("sys.color.ohos_id_color_background"),
                                                            radius: 50
                                                        })
                                                }
                                                Image($rawfile("icon/entrance_icon01.svg"))
                                                    .width("40vp")
                                                    .height("40vp")
                                            }.width("40vp").height("64vp")

                                            Column() {
                                                Row() {
                                                    Text($r("app.string.infoMessages"))
                                                        .fontSize('16fp')
                                                        .fontColor($r("sys.color.ohos_id_color_text_primary"))
                                                        .fontWeight(FontWeight.Medium)
                                                    Blank()
                                                    if (this.mConListCtrl.unreadTotalOfInfo > 0) {
                                                        Text(this.mConListCtrl.unreadTotalOfInfo + "")
                                                            .height("64vp")
                                                            .margin({
                                                                right: $r("app.float.settings_item_status_title_margin_right")
                                                            })
                                                            .fontSize($r("app.float.settings_item_secondary_title_font_size"))
                                                            .fontWeight(FontWeight.Regular)
                                                            .fontColor($r("sys.color.ohos_id_color_text_secondary"))
                                                        Image($rawfile("icon/ic_next.svg"))
                                                            .width($r("app.float.settings_item_next_image_width"))
                                                            .height($r("app.float.settings_item_next_image_height"))
                                                    }
                                                }
                                                .width("100%")
                                                .height("100%")
                                                .margin({ left: "4vp" })
                                            }.layoutWeight(1)
                                            .height("100%")
                                            .padding({ left: "12vp" })
                                        }.height("64vp")
                                        .width("100%")
                                        .onClick(() => {
                                            this.mConListCtrl.clickToInfoMessages(this.mConListCtrl.hasAggregate,
                                            this.mConListCtrl.hasInfoMsg,this.mConListCtrl.isSearchStatus)
                                        })
                                    }
                                }.opacity(this.mConListCtrl.isMultipleSelectState ? 0.4 : 1)
                            }

                            LazyForEach(this.mConListCtrl.conversationListDataSource, (item: any, index: number) => {
                                ListItem() {
                                    MmsListItem({
                                        item: item,
                                        isShowHead: this.mConListCtrl.isShowContactHeadIcon,
                                        isMultipleSelectState: this.mIsMultipleSelectState,
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
                                            // @ts-ignore
                                            this.forceCompleteRerender(true) // recusvise
                                        },
                                        onTouchEnd: (event: GestureEvent) => {
                                            this.mConListCtrl.touchEnd(event, item.index);
                                            // @ts-ignore
                                            this.forceCompleteRerender(true) // recusvise
                                        },
                                        onClickFirstSlipBtn: (event: ClickEvent) => { //Read
                                            this.mConListCtrl.markAllAsReadByIndex(item.index);
                                        },
                                        onClickSecondSlipBtn: (event: ClickEvent) => { //Delete
                                            this.mConListCtrl.deleteAction(item.index);
                                            this.delDialogController.open();
                                        }
                                    })
                                }.width("100%")
                                .height("64vp")
                            }, (item: any) => JSON.stringify(item))
                        }
                        .edgeEffect(EdgeEffect.Spring)
                        .width("100%")
                        .align(Alignment.Top)
                        .divider({
                            strokeWidth: 1,
                            startMargin: this.mConListCtrl.isShowContactHeadIcon ? 52 : 12,
                            endMargin: 0
                        })
                        .flexShrink(1)

                        Blank()

                        /*Select All Delete button at the bottom*/
                        if (this.mConListCtrl.isMultipleSelectState) {
                            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                                Column() {
                                    Image($rawfile("icon/ic_public_delete.svg")).height(24).width(24)
                                    Text($r("app.string.delete")).fontSize(10).margin({ top: 3 }).lineHeight(13)
                                }
                                .width("50%")
                                .onClick(() => {
                                    this.mConListCtrl.clickConversationDelete();
                                    this.delDialogController.open();
                                })
                                .enabled(!(this.mConListCtrl.conversationSelectedNumber === 0))
                                .opacity(this.mConListCtrl.conversationSelectedNumber == 0 ? 0.5 : 1)
                                .alignItems(HorizontalAlign.Center)

                                Column() {
                                    Image(this.mConListCtrl.isConversationCheckAll ?
                                    $rawfile("icon/ic_select_all_filled.svg") : $rawfile("icon/ic_select_all.svg"))
                                        .height(24).width(24)
                                    Text(this.mConListCtrl.isConversationCheckAll ? $r("app.string.msg_deselect_all")
                                                                                  : $r("app.string.msg_select_all"))
                                        .fontSize(10)
                                        .margin({ top: 3 })
                                        .lineHeight(13)
                                        .fontColor(this.mConListCtrl.isConversationCheckAll ?
                                        $r("sys.color.ohos_id_color_bottom_tab_text_on") :
                                        $r("sys.color.ohos_id_color_bottom_tab_text_off"))
                                }
                                .width("50%")
                                .onClick(() => {
                                    this.mConListCtrl.clickConversationCheckAll()
                                })
                                .alignItems(HorizontalAlign.Center)
                            }
                            .width("100%")
                            .height(56)
                            .padding({
                                left: $r("app.float.menu_layout_padding_left"),
                                right: $r("app.float.menu_layout_padding_right")
                            })
                            .flexBasis(56)
                            .flexShrink(0)
                            .backgroundColor($r("sys.color.ohos_id_color_background"))
                        }
                    }
                    .width("100%")
                    .height("100%")
                }
            }
            .width("100%")
            .height("100%")
            if (this.mConListCtrl.hasNoOrdinaryMsg && !(this.mConListCtrl.hasAggregate && this.mConListCtrl.hasInfoMsg
            && this.mConListCtrl.isSearchStatus)) {
                EmptyView().hitTestBehavior(HitTestMode.Transparent)
            }
        }
        .width("100%")
        .height("100%")
    }
}

@Component
struct EmptyView {

    build() {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
            Column() {
                Image($rawfile("icon/ic_massage_m.svg"))
                    .width($r("app.float.empty_image_width"))
                    .height($r("app.float.empty_image_height"))
                Text($r("app.string.noMessages"))
                    .margin({ top: $r("app.float.empty_text_top_margin") })
                    .fontWeight(FontWeight.Regular)
                    .fontFamily("HarmonyHeiTi")
                    .fontSize($r("app.float.conversation_list_no_message_fs"))
                    .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
            }
            //             .margin({ top: '40%' })
            .offset({ y: -60 })
        }
        .height("100%")
        .width("100%")
    }
}