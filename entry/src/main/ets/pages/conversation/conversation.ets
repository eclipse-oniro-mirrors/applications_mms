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
/**
 * Message/MMS viewing page
 */
import router from "@system.router";
import emitter from '@ohos.events.emitter';
import ConversationController from "./conversationController";
import { Receive } from "../../views/receive/receive";
import LooseObject from "../../data/LooseObject";
import { MoreMenu } from "../../views/MmsMenu";
import { MultiSimCardMenu } from '../../views/MultiSimCardMenu';
import WantUtil from "../../utils/WantUtil";
import { DelConversionDialog } from "../../views/MmsDialogs";
import MmsPreferences from "../../utils/MmsPreferences";
import common from "../../data/commonData";
import simCardService from "../../service/SimCardService"

@Entry
@Component
export struct Conversation {
    @StorageLink('curBp') curBp: string = 'sm'
    @State mConversationCtrl: ConversationController = ConversationController.getInstance();
    @State slotId: number = MmsPreferences.getInstance().getSelectedSlotId();
    @State cardImage: boolean = MmsPreferences.getInstance().haveMultiSimCardReady();
    private gridColumns: GridRowColumnOption = { sm: 4, md: 8, lg: 12 };
    private timeGirdSpan: GridColColumnOption = { sm: 4, md: 8, lg: 12 };
    private messageGirdSpan: GridColColumnOption = { sm: 4, md: 6, lg: 8 };
    private gridColOffset: GridColColumnOption = { sm: 0, md: 2, lg: 4 };
    private gridGutter: string = "24vp";
    private dialogGridCount: number = 4;
    @Provide menuItems: Array<any> = [
        {
            value: $r("app.string.delete"),
            action: () => {
                this.mConversationCtrl.longPressMore(0);
                if(this.mConversationCtrl.mmsList.length == 1) {
                    this.delConversionController.open();
                }
            },
            enabled: true
        },
        {
            value: $r("app.string.msg_pre_call_editor"),
            action: () => {
                this.mConversationCtrl.longPressMore(3);
            },
            enabled: true
        }
    ];

    /** Message details dialog box */
    dialogController: CustomDialogController = new CustomDialogController({
        builder: DetailsDialog({
            item: this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex],
            receiver: this.mConversationCtrl.strContactsName == ''
                ? this.mConversationCtrl.strContactsNumber :
                this.mConversationCtrl.strContactsName
        }),
        autoCancel: true,
        alignment: DialogAlignment.Bottom,
        offset: { dx: 0, dy: $r("app.float.dialog_bottom_margin") },
        gridCount: this.dialogGridCount
    })
    delConversionController: CustomDialogController = new CustomDialogController({
        builder: DelConversionDialog({
            cancel: () => {
                this.mConversationCtrl.deleteDialogCancel()
            },
            confirm: () => {
                this.mConversationCtrl.deleteDialogConfirm()
            },
            msg: this.mConversationCtrl.strMsgDeleteDialogTip,
        }),
        autoCancel: false,
        alignment: DialogAlignment.Bottom,
        offset: { dx: 0, dy: $r("app.float.dialog_bottom_margin") },
        gridCount: this.dialogGridCount
    });

    aboutToAppear() {
        this.mConversationCtrl.onInit();
        this.mConversationCtrl.onShow();
        emitter.on(simCardService.SIM_STATE_CHANGE_EVENT, () => {
            this.cardImage = MmsPreferences.getInstance().haveMultiSimCardReady();
        });
        emitter.on(simCardService.SLOTID_CHANGE_EVENT, () => {
            this.slotId = MmsPreferences.getInstance().getSelectedSlotId();
            console.log("receive SLOTID_CHANGE_EVENT, this.slotId: " + this.slotId);
        });
    }

    aboutToDisappear() {
        emitter.off(common.int.EVENT_SIM_STATE_CHANGE);
        emitter.off(common.int.EVENT_SLOTID_CHANGE);
    }

    onPageShow() {
        WantUtil.getWant();
    }

    onPageHide() {
        this.mConversationCtrl.onHide()
    }

    onBackPress() {
        return this.mConversationCtrl.onBackPress();
    }

    build() {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween }) {
            Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
                // <!--Top titleBar-->
                // New page
                if (this.mConversationCtrl.isNewMsg) {
                    Row() {
                        Image($rawfile("icon/ic_message_back.svg"))
                            .width("24vp")
                            .height("24vp")
                            .onClick(() => {
                                // Click Return to restore the status of unselected SMs.
                                if (!this.mConversationCtrl.onBackPress()) {
                                    router.back();
                                }
                            })
                        Row().width($r("app.float.space_16"))
                        Text($r("app.string.new_message"))
                            .fontSize(20)
                            .lineHeight(28)
                            .fontColor($r("sys.color.ohos_id_color_text_primary"))
                            .fontWeight(FontWeight.Bold)
                    }
                    .width("100%")
                    .height(56)
                    .flexShrink(0)
                    .padding({ left: "24vp", right: "24vp" })
                    .zIndex(2)
                }
                // Page for viewing SMS details
                else {
                    Row() {
                        // Select Status
                        if (this.mConversationCtrl.isSelectStatus) {
                            Row() {
                                Image($rawfile("icon/ic_public_cancel.svg"))
                                    .width(24)
                                    .height(24)
                                    .onClick(() => {
                                        // Click Return to restore the status of unselected SMs.
                                        this.mConversationCtrl.titleBarCancel()
                                    })
                                Text(this.mConversationCtrl.selectDeleteMsgCount == 0
                                    ? $r("app.string.msg_unselected_tip")
                                    : $r("app.string.msg_selected_tip", this.mConversationCtrl.selectDeleteMsgCount))
                                    .margin({ left: 16 })
                                    .fontSize(20)
                                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                                    .fontWeight(FontWeight.Bold)
                            }
                            .alignItems(VerticalAlign.Center)
                            .width("100%")
                        }
                        // Non-Selected Status
                        else {
                            Row() {
                                Flex({
                                    alignItems: ItemAlign.Center,
                                }) {
                                    Row() {
                                        Image($rawfile("icon/ic_message_back.svg"))
                                            .width(24)
                                            .height(24)
                                            .margin({ right: 16 })
                                            .onClick(() => {
                                                if (!this.mConversationCtrl.onBackPress()) {
                                                    router.back();
                                                }
                                            })

                                        if(this.mConversationCtrl.strContactsName === '' ||
                                        this.mConversationCtrl.photoFirstName === "-1") {
                                            Image($rawfile("icon/ic_user_portrait.svg"))
                                                .objectFit(ImageFit.Fill)
                                                .width(40)
                                                .height(40)
                                                .clip(new Circle({ width: 40, height: 40 }))
                                                .backgroundColor(this.mConversationCtrl.portraitColor)
                                                .onClick(() => {
                                                    this.mConversationCtrl.titleBarAvatar();
                                                })
                                        } else {
                                            Text(this.mConversationCtrl.photoFirstName)
                                                .fontSize($r("sys.float.ohos_id_text_size_headline8"))
                                                .fontWeight(FontWeight.Medium)
                                                .fontColor(Color.White)
                                                .height("40vp")
                                                .width("40vp")
                                                .textAlign(TextAlign.Center)
                                                .clip(new Circle({ width: "40vp", height: "40vp" }))
                                                .backgroundColor(this.mConversationCtrl.portraitColor)
                                                .onClick(() => {
                                                    this.mConversationCtrl.titleBarAvatar();
                                                })
                                        }
                                    }
                                    .flexBasis(80)
                                    Column() {
                                        Flex({
                                            direction: FlexDirection.Column,
                                            justifyContent: FlexAlign.Center,
                                            alignItems: ItemAlign.Start
                                        }) {
                                            if (this.mConversationCtrl.contactsNum > 1) {
                                                Text(this.mConversationCtrl.strContactsName)
                                                    .maxLines(1)
                                                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                                                    .fontSize(20)
                                                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                                                    .fontWeight(FontWeight.Medium)
                                                Text($r("app.string.members", this.mConversationCtrl.contactsNum))
                                                    .maxLines(1)
                                                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                                                    .fontSize(20)
                                                    .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
                                                    .fontWeight(FontWeight.Medium)
                                            } else if (this.mConversationCtrl.strContactsName == '' ||
                                                      this.mConversationCtrl.strContactsName == null) {
                                                Text(this.mConversationCtrl.strContactsNumberFormat)
                                                    .maxLines(1)
                                                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                                                    .fontSize(20)
                                                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                                                    .fontWeight(FontWeight.Medium)
                                            } else {
                                                Text(this.mConversationCtrl.strContactsName.replace(/\s*/g,""))
                                                    .maxLines(1)
                                                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                                                    .fontSize(20)
                                                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                                                    .fontWeight(FontWeight.Medium)
                                                    .lineHeight(28)
                                                if (this.mConversationCtrl.strContactsName.replace(/\s*/g,"") !==
                                                this.mConversationCtrl.strContactsNumberFormat) {
                                                    Text(this.mConversationCtrl.strContactsNumberFormat)
                                                        .maxLines(1)
                                                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                                                        .fontSize(20)
                                                        .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
                                                        .lineHeight(19)
                                                        .fontWeight(FontWeight.Medium)
                                                }
                                            }
                                        }
                                    }
                                    .flexGrow(1)
                                    .flexShrink(1)
                                    .alignItems(HorizontalAlign.Start)
                                    .padding({ left: 12, right: 16 })
                                    .margin({left: this.mConversationCtrl.strContactsNumberFormat.length > 17 ? 25 : 0})

                                    Row() {
                                        Image($rawfile("icon/ic_message_phone.svg"))
                                            .width(24)
                                            .height(24)
                                            .onClick(() => {
                                                this.mConversationCtrl.clickCall();
                                            })
                                        Blank().width($r("app.float.space_16"))
                                        Column() {
                                            MoreMenu()
                                        }
                                    }
                                    .flexShrink(0)
                                }.height("100%")
                            }
                            .width("100%")
                        }
                    }
                    .height(56)
                    .constraintSize({ minHeight: 56 })
                    .padding({ left: 24, right: 24 })
                    .zIndex(2)
                }
                // <!--Middle Content Area-->
                Row() {
                    // New Message Content
                    if (this.mConversationCtrl.isNewMsg) {
                        Row() {
                            Receive({ mConversationController: $mConversationCtrl })
                        }.margin({ top: $r("app.float.new_message_margin_top") })
                    }
                    // SMS message content
                    // <!--Information List-->
                    if (!this.mConversationCtrl.isNewMsg) {
                        List({ space: 10, initialIndex: this.mConversationCtrl.mmsList.length - 1, scroller: this.mConversationCtrl.scroller }) {
                            ForEach(this.mConversationCtrl.mmsList, (item, index) => {
                                ListItem() {
                                    Row() {
                                        GridRow({ columns: this.gridColumns, gutter: this.gridGutter }) {
                                            // <!--Information Sending Item-->
                                            if (!item.isReceive && !item.isDraft) {
                                                GridCol({ span: this.timeGirdSpan}) {
                                                    Flex({
                                                        direction: FlexDirection.Column,
                                                        justifyContent: FlexAlign.Center,
                                                        alignItems: ItemAlign.Center
                                                    }) {
                                                        // SMS/MMS
                                                        if (index == 0) {
                                                            Text($r("app.string.msg_note_mms"))
                                                                .fontSize(12)
                                                                .lineHeight(16)
                                                                .fontColor($r("sys.color.ohos_id_color_text_secondary"))
                                                                .margin({ bottom: 2 })
                                                        }
                                                        // Time
                                                        if (item.dateShow) {
                                                            Text() {
                                                                Span(item.date)
                                                                    .fontSize(12)
                                                                    .fontColor($r("sys.color.ohos_id_color_text_secondary"))
                                                                Span(item.week)
                                                                    .fontSize(12)
                                                                    .fontColor($r("sys.color.ohos_id_color_text_secondary"))
                                                            }.lineHeight(16).margin({ bottom: 8 })
                                                        }
                                                    }.width("100%")
                                                }
                                                GridCol({ span: this.messageGirdSpan, offset: this.gridColOffset }) {
                                                    Flex({
                                                        direction: FlexDirection.Column,
                                                        justifyContent: FlexAlign.Center,
                                                        alignItems: ItemAlign.Center
                                                    }) {
                                                        Flex({
                                                            justifyContent: FlexAlign.Center,
                                                            alignItems: ItemAlign.Start
                                                        }) {
                                                            Column() {
                                                                Flex({
                                                                    justifyContent: FlexAlign.End,
                                                                    alignItems: ItemAlign.End
                                                                }) {
                                                                    // <!--Text-->
                                                                    Flex({
                                                                        justifyContent: FlexAlign.End,
                                                                        alignItems: ItemAlign.End
                                                                    }) {
                                                                        // <!--Sending failed icon-->
                                                                        if (!item.isMsm &&
                                                                        ((this.mConversationCtrl.contactsNum == 1 &&
                                                                        item.sendStatus == 2) ||
                                                                        (this.mConversationCtrl.contactsNum > 1 &&
                                                                        item.failuresNumber > 0 &&
                                                                        item.completeNumber ==
                                                                        this.mConversationCtrl.contactsNum))) {
                                                                            Row() {
                                                                                Image($rawfile("icon/ic_send_fail.svg"))
                                                                                    .width(20)
                                                                                    .height(20)
                                                                                    .objectFit(ImageFit.Fill)
                                                                            }
                                                                            .margin({ right: 8 })
                                                                            .padding({ top: 9 })
                                                                        }
                                                                        // Message Bubble
                                                                        bubbleText({
                                                                            conversationCtrl: $mConversationCtrl,
                                                                            bubbleTextBorderRadius: [4, 24],
                                                                            bubbleTextDirection: "right",
                                                                            content: item.content,
                                                                            bubbleTextBackgroundColor: $r("app.color.sender_bubble"),
                                                                            isShowMsgLongMenu: item.isShowMsgLongMenu,
                                                                            itemIndex: index,
                                                                            delConversionController: this.delConversionController
                                                                        })
                                                                            .constraintSize({maxWidth: 284})
                                                                    }
                                                                }
                                                                // <!--Sending time and sending status-->
                                                                Flex({
                                                                    alignItems: ItemAlign.Center,
                                                                    justifyContent: FlexAlign.End
                                                                }) {
                                                                    if (this.mConversationCtrl.contactsNum == 1 &&
                                                                    item.sendStatus != 1) {
                                                                        Text(item.time)
                                                                            .textAlign(TextAlign.Start)
                                                                            .fontSize(10)
                                                                            .lineHeight(13)
                                                                            .fontColor($r("sys.color.ohos_id_color_text_secondary"))
                                                                            .margin({ top: 8, right: 5 })
                                                                    }
                                                                    // Card 1 or Card 2
                                                                    if (this.cardImage) {
                                                                        Image(item.subId == 0 ?
                                                                        $rawfile("icon/icon_mms_sim_1.svg") :
                                                                        $rawfile("icon/icon_mms_sim_2.svg"))
                                                                            .width(10)
                                                                            .height(10)
                                                                            .margin({ top: 8, right: 5 })
                                                                    }
                                                                    // Locked
                                                                    if (item.isLock) {
                                                                        Image($rawfile("icon/msg_lock.svg"))
                                                                            .width(10)
                                                                            .height(10)
                                                                            .margin({ top: 8, right: 5 })
                                                                    }
                                                                    Text($r("app.string.messageSendFailed"))
                                                                        .textAlign(TextAlign.Start)
                                                                        .fontSize(10)
                                                                        .lineHeight(13)
                                                                        .margin({ top: 8 })
                                                                        .fontColor($r("sys.color.ohos_id_color_warning"))
                                                                        .visibility(item.sendStatus == 2 ?
                                                                        Visibility.Visible : Visibility.None)
                                                                    Text($r("app.string.messageSending"))
                                                                        .textAlign(TextAlign.Start)
                                                                        .fontSize(10)
                                                                        .fontColor($r("sys.color.ohos_id_color_text_secondary"))
                                                                        .lineHeight(13)
                                                                        .margin({ top: 8 })
                                                                        .visibility(item.sendStatus == 1 ?
                                                                        Visibility.Visible : Visibility.None)
                                                                    Text($r("app.string.messageDeliver"))
                                                                        .textAlign(TextAlign.Start)
                                                                        .fontSize(10)
                                                                        .fontColor($r("sys.color.ohos_id_color_text_secondary"))
                                                                        .lineHeight(13)
                                                                        .margin({ top: 8 })
                                                                        .visibility(item.sendStatus == 0 ?
                                                                        Visibility.Visible : Visibility.None)
                                                                }.width("100%").margin({ right: 12 })
                                                            }
                                                            .width("100%")
                                                            .alignItems(HorizontalAlign.End)
                                                            // Sender's avatar, which is available only for group messages.
                                                            Flex({ direction: FlexDirection.Column,
                                                                justifyContent: FlexAlign.Start,
                                                                alignItems: ItemAlign.Center }) {
                                                                Image($rawfile("icon/user_avatar_full_fill.svg"))
                                                                    .width(30)
                                                                    .height(30)
                                                            }
                                                            .width(50)
                                                            .height(30)
                                                            .visibility(this.mConversationCtrl.contactsNum > 1 ?
                                                            Visibility.Visible : Visibility.None)
                                                        }
                                                    }
                                                    .width("100%")
                                                }
                                            }
                                            // <!--Information receiving item-->
                                            else if (item.isReceive) {
                                                GridCol({ span: this.timeGirdSpan}) {
                                                    // <!--Information receiving item-->
                                                    Flex({
                                                        direction: FlexDirection.Column,
                                                        justifyContent: FlexAlign.Center,
                                                        alignItems: ItemAlign.Center
                                                    }) {
                                                        // SMS/MMS
                                                        if (index == 0) {
                                                            Text($r("app.string.msg_note_mms"))
                                                                .fontSize(12)
                                                                .lineHeight(16)
                                                                .fontColor($r("sys.color.ohos_id_color_text_secondary"))
                                                                .margin({ bottom: 2 })
                                                        }
                                                        // Time
                                                        if (item.dateShow) {
                                                            Text() {
                                                                Span(item.date)
                                                                    .fontSize(12)
                                                                    .fontColor($r("sys.color.ohos_id_color_text_secondary"))
                                                                Span(item.week)
                                                                    .fontSize(12)
                                                                    .fontColor($r("sys.color.ohos_id_color_text_secondary"))
                                                            }.lineHeight(16).margin({ bottom: 8 })
                                                        }
                                                    }.width("100%")
                                                }
                                                GridCol({ span: this.messageGirdSpan }) {
                                                    Flex({
                                                        direction: FlexDirection.Column,
                                                        justifyContent: FlexAlign.Center,
                                                        alignItems: ItemAlign.Center
                                                    }) {
                                                        Flex({
                                                            justifyContent: FlexAlign.Center,
                                                            alignItems: ItemAlign.Start
                                                        }) {
                                                            Column() {
                                                                Flex({
                                                                    alignItems: ItemAlign.Start,
                                                                    justifyContent: FlexAlign.Start
                                                                }) {
                                                                    // Message Bubble
                                                                    bubbleText({
                                                                        conversationCtrl: $mConversationCtrl,
                                                                        bubbleTextBorderRadius: [4, 24],
                                                                        bubbleTextDirection: "left",
                                                                        content: item.content,
                                                                        bubbleTextBackgroundColor: $r("sys.color.ohos_id_color_card_bg"),
                                                                        isShowMsgLongMenu: item.isShowMsgLongMenu,
                                                                        itemIndex: index,
                                                                        delConversionController: this.delConversionController
                                                                    })
                                                                        .constraintSize({maxWidth: 284})
                                                                }
                                                                // <!--Sending time and sending status-->
                                                                Flex({
                                                                    alignItems: ItemAlign.Center,
                                                                    justifyContent: FlexAlign.Start
                                                                }) {
                                                                    Text(item.time)
                                                                        .textAlign(TextAlign.Start)
                                                                        .fontSize(10)
                                                                        .lineHeight(13)
                                                                        .fontColor($r("sys.color.ohos_id_color_text_secondary"))
                                                                        .margin({ top: 8, right: 5 })
                                                                    // Card 1 or Card 2
                                                                    if (this.cardImage) {
                                                                        Image(item.subId == 0 ?
                                                                        $rawfile("icon/icon_mms_sim_1.svg") :
                                                                        $rawfile("icon/icon_mms_sim_2.svg"))
                                                                            .width(10)
                                                                            .height(10)
                                                                            .margin({ top: 8, left: 5 })
                                                                    }
                                                                    // Locked
                                                                    if (item.isLock) {
                                                                        Image($rawfile("icon/msg_lock.svg"))
                                                                            .width(10)
                                                                            .height(10)
                                                                            .margin({ top: 8, left: 5 })
                                                                    }
                                                                }.width("70%").margin({ left: 12 })
                                                            }
                                                            .width("100%")
                                                            .alignItems(HorizontalAlign.Start)
                                                        }
                                                    }.width("100%")
                                                }
                                            }
                                        }.layoutWeight(1)
                                        if (this.mConversationCtrl.isSelectStatus) {
                                            Row() {
                                                Toggle({
                                                    type: ToggleType.Checkbox,
                                                    isOn: item.isCbChecked
                                                })
                                                    .selectedColor($r("sys.color.ohos_id_color_activated"))
                                                    .width(24)
                                                    .height(24)
                                                    .onChange(((isOn: boolean) => {
                                                        this.mConversationCtrl.listCheckBoxChange(index, isOn)
                                                    }))
                                            }
                                            .margin({ left: 4 })
                                            .width(48)
                                            .height(48)
                                        }
                                    }
                                    .padding(this.curBp === 'sm' ? { left: 16, right: 16 } : { left: 24, right: 24})
                                    .width('100%')
                                    .alignItems(VerticalAlign.Center)
                                }.onClick(() => {
                                    if (this.mConversationCtrl.isSelectStatus) {
                                        this.mConversationCtrl.listCheckBoxChange(index,!item.isCbChecked)
                                    }
                                })
                                .padding(index == this.mConversationCtrl.mmsList.length - 1 ? { bottom: 20 } : null)
                            }, item => JSON.stringify(item))
                        }
                        .listDirection(Axis.Vertical) // Arrange Direction
                        .edgeEffect(EdgeEffect.Spring) // Sliding to the edge has no effect
                        .width("100%")
                        .margin({ top: 16 })
                    }
                }
                .width("100%")
                .flexBasis("auto")
                .flexShrink(1)
            }
            .width("100%")
            // Input box at the bottom
            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
                // More options at the bottom
                if (this.mConversationCtrl.isSelectStatus && !this.mConversationCtrl.hasDetailDelete) {
                    /** The Info button is checked at the bottom. */
                    Flex({
                        direction: FlexDirection.Row,
                        alignItems: ItemAlign.Center,
                        justifyContent: FlexAlign.SpaceBetween
                    }) {
                        /** Delete */
                        Column() {
                            Image($rawfile("icon/ic_public_delete.svg"))
                                .width(24)
                                .height(24)
                            Text($r("app.string.delete"))
                                .fontSize(10)
                                .margin({ top: 3})
                                .lineHeight(14)
                                .fontWeight(FontWeight.Medium)
                                .fontColor($r("sys.color.ohos_id_color_text_primary"))
                        }.width("25%").opacity(this.mConversationCtrl.selectDeleteMsgCount == 0 ? 0.4 : 1)
                        .onClick(() => {
                            if (this.mConversationCtrl.selectDeleteMsgCount != 0) {
                                this.mConversationCtrl.clickGroupDelete();
                                this.delConversionController.open();
                            }
                        })
                        /** Forwarding */
                        //                        Column() {
                        //                            Image($rawfile("icon/ic_transfer.svg"))
                        //                                .width(24)
                        //                                .height(24)
                        //                            Text($r("app.string.msg_transmit")) {
                        //
                        //                            }.fontSize(10).margin({ top: 3 })
                        //                            .fontColor($r("sys.color.ohos_id_color_text_primary"))
                        //                            .fontWeight(FontWeight.Medium)
                        //                            .lineHeight(14)
                        //                        }.width("25%").opacity(this.mConversationCtrl.selectDeleteMsgCount == 0 ? 0.4 : 1)
                        //                        .onClick(() => {
                        //
                        //                        })
                        /** Favorites */
                        //                        Column() {
                        //                            Image($rawfile("icon/ic_msg_favorite_m.svg"))
                        //                                .width(24)
                        //                                .height(24)
                        //                            Text($r("app.string.msg_star")) {
                        //
                        //                            }.fontSize(10).margin({ top: 3 })
                        //                            .fontColor($r("sys.color.ohos_id_color_text_primary"))
                        //                            .fontWeight(FontWeight.Medium)
                        //                            .lineHeight(14)
                        //                        }.width("25%").opacity(this.mConversationCtrl.selectDeleteMsgCount == 0 ? 0.4 : 1)
                        //                        .onClick(() => {
                        //
                        //                        })
                        /** Select All */
                        Column() {
                            Image(this.mConversationCtrl.isMessageCheckAll ? $rawfile("icon/ic_select_all_filled.svg")
                                                                           : $rawfile("icon/ic_select_all.svg"))
                                .width(24)
                                .height(24)
                            Text(this.mConversationCtrl.isMessageCheckAll ? $r("app.string.msg_deselect_all")
                                                                          : $r("app.string.msg_select_all")) {
                            }
                            .fontSize(10)
                            .margin({ top: 3 })
                            .lineHeight(14)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(this.mConversationCtrl.isMessageCheckAll ?
                            $r("sys.color.ohos_id_color_subtab_text_on") : $r("sys.color.ohos_id_color_text_primary"))
                        }.width("25%")
                        .onClick(() => {
                            this.mConversationCtrl.clickGroupCheckAll()
                        })
                        /** more */
                        Column() {
                            Image($rawfile("icon/ic_message_more1.svg"))
                                .width(24)
                                .height(24)
                            Text($r("app.string.more")) {
                            }.fontSize(10).margin({ top: 3 })
                            .lineHeight(14)
                            .fontWeight(FontWeight.Medium)
                            .fontColor($r("sys.color.ohos_id_color_text_primary"))
                        }
                        .width("25%")
                        .enabled(this.mConversationCtrl.selectDeleteMsgCount == 1 ? true : false)
                        // @ts-ignore
                        .bindMenu(this.MenuBuilder)
                    }
                    .width("100%")
                    .height(56)
                }
                // <!--Bottom Send Bar-->
                if (!this.mConversationCtrl.isSelectStatus) {
                    Flex({ alignItems: ItemAlign.End, justifyContent: FlexAlign.Center }) {
                        // <!--Left More and Full Screen Display-->
                        Row() {
                            Image($rawfile("icon/msg_add.svg"))
                                .onClick(() => {

                                })
                                .width(24)
                                .height(24)
                                .visibility(Visibility.Visible)
                                .opacity(0.3)
                            Blank().width(16)
                            Row() {
                                if (this.cardImage) {
                                    MultiSimCardMenu({
                                        slotId: this.slotId
                                    })
                                }
                                Row() {
                                    TextArea({
                                        placeholder: $r("app.string.msg_note_mms"),
                                        text: this.mConversationCtrl.textValue
                                    })
                                        .placeholderColor($r("sys.color.ohos_id_color_text_hint"))
                                        .caretColor($r("sys.color.ohos_id_color_focused_outline"))
                                        .backgroundColor($r("sys.color.ohos_id_color_background_transparent"))
                                        .onChange(value => {
                                            this.mConversationCtrl.changeValue(value);
                                        })
                                        .padding({left: 0, right: this.cardImage ? 42 : 0})
                                        .borderRadius(0)
                                        .fontSize(16)
                                }.constraintSize({ minHeight: 40 })
                            }
                            .backgroundColor($r("sys.color.ohos_id_color_text_field_sub_bg"))
                            .padding({ left: 8, right: 8})
                            .borderRadius(20)
                            .width('100%')
                            .layoutWeight(1)
                            Image($rawfile("icon/ic_message_emoji.svg"))
                                .width(24)
                                .height(24)
                                .margin({left:16})
                                .visibility(Visibility.Visible)
                                .opacity(0.3)
                            // <!--send-->
                            Image(this.mConversationCtrl.canSendMessage ? $rawfile("icon/ic_message_send_filled.svg")
                                                                        : $rawfile("icon/ic_message_send.svg"))
                                .onClick(() => {
                                    //  Click Send.
                                    this.mConversationCtrl.send();
                                })
                                .width(24)
                                .height(24)
                                .margin({left:16})
                        }.width("100%")
                    }
                    .constraintSize({ minHeight: 56 })
                    .width("100%").padding({ bottom: 8, top: 8 })
                }
            }
            .width("100%")
            .padding({
                left: this.mConversationCtrl.isSelectStatus && !this.mConversationCtrl.hasDetailDelete ? 0 :
                $r("app.float.space_24"),
                right: this.mConversationCtrl.isSelectStatus && !this.mConversationCtrl.hasDetailDelete ? 0 :
                $r("app.float.bottom_send_bar_padding_right")
            })
            .clip(new Rect({
                width: "100%",
                height: "100%",
                radius: this.mConversationCtrl.isSelectStatus ? [] : [[20, 20], [20, 20], [0, 0], [0, 0]]
            }))
            .backgroundColor(this.mConversationCtrl.isSelectStatus && !this.mConversationCtrl.hasDetailDelete ?
                null : $r("sys.color.ohos_id_color_toolbar_bg"))
        }
        .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
        .width("100%")
        .height("100%")
    }

    @Builder MenuBuilder() {
        Column() {
            Row() {
                Text($r("app.string.query_details"))
                    .lineHeight(22)
                    .fontSize(16)
                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                    .margin({ left: 16, top: 13, bottom: 13 })
            }
            .width("100%")
            .height(48)
            .onClick(()=>{
                this.dialogController.open()
                this.mConversationCtrl.isSelectStatus = !this.mConversationCtrl.isSelectStatus
                this.mConversationCtrl.isMessageCheckAll = false
                this.mConversationCtrl.cancleCheckedAll()
            })

            if (this.mConversationCtrl.hasReport) {
                Divider()
                    .margin({ left: 16, right: 16 })
                    .strokeWidth(0.5)
                    .color($r("sys.color.ohos_id_color_list_separator"))

                Row() {
                    Text($r("app.string.query_report"))
                        .lineHeight(22)
                        .fontSize(16)
                        .fontColor($r("sys.color.ohos_id_color_text_primary"))
                        .margin({ left: 16, top: 13, bottom: 13 })
                }.height(48)
                .onClick(() => {
                    this.mConversationCtrl.moreSelected(6)
                })
            }
        }.borderRadius(24)
        .width(145)
        .alignItems(HorizontalAlign.Start)
    }
}

@CustomDialog
struct DetailsDialog {
    controller: CustomDialogController
    item: LooseObject
    receiver: string

    build() {
        Column() {
            Text($r("app.string.msgDetails"))
                .fontSize(20)
                .lineHeight(28)
                .fontColor($r("sys.color.ohos_id_color_text_primary"))
                .fontWeight(FontWeight.Bold)
                .fontFamily("HarmonyHeiTi")
                .margin({ top: 14, bottom: 14 })
            Text() {
                Span($r("app.string.type")).fontSize(16)
                Span($r("app.string.sms")).fontSize(16)
            }
            .fontSize(16)
            .fontColor($r("sys.color.ohos_id_color_text_primary"))
            .margin({ bottom: 4 })
            .fontFamily("HarmonyHeiTi")

            Text() {
                Span(this.item.isReceive ? $r("app.string.sender") : $r("app.string.putAddresser")).fontSize(16)
                Span(this.receiver).fontSize(16)
            }
            .fontSize(16)
            .fontColor($r("sys.color.ohos_id_color_text_primary"))
            .margin({ bottom: 4 })
            .fontFamily("HarmonyHeiTi")

            Text() {
                Span($r("app.string.sendTime")).fontSize(16)
                Span(this.item.fullDate ).fontSize(16)
                Span(this.item.timeOfSms ).fontSize(16)
            }
            .fontSize(16)
            .fontColor($r("sys.color.ohos_id_color_text_primary"))
            .margin({ bottom: 8 })
            .fontFamily("HarmonyHeiTi")

            Flex({ justifyContent: FlexAlign.Center }) {
                Button() {
                    Text($r("app.string.msg_know"))
                        .fontFamily("HarmonyHeiTi")
                        .fontWeight(FontWeight.Medium)
                        .fontSize(16)
                        .fontColor($r("sys.color.ohos_id_color_floating_button_bg_normal"))
                }
                .width(200)
                .backgroundColor(Color.Transparent)
                .margin({top: 5})
                .onClick(() => {
                    this.controller.close()
                })
            }.height(40)
        }
        .borderRadius(24)
        .padding({ left: 24, right: 24, bottom: 16 })
        .alignItems(HorizontalAlign.Start)
    }
}

// Custom Chat Bubble
@Component
struct bubbleText {
    @Link conversationCtrl: ConversationController;
    private delConversionController: any;
    private bubbleTextBorderRadius: Array<number>; // Fillet size, two parameters in total
    private bubbleTextDirection: string; // left: upper left corner right: upper right corner
    private content: string; // Bubble Display Content
    private bubbleTextBackgroundColor: Resource | string; // Bubble background color
    private isShowMsgLongMenu: boolean;
    private itemIndex: number;
    @State showMenu: boolean = false

    aboutToAppear() {
        this.showMenu = this.isShowMsgLongMenu
    }

    @Builder MenuBuilder() {
        Row() {
            Button($r("app.string.msg_transmit"))
                .fontSize(14)
                .fontColor($r("sys.color.ohos_id_color_text_primary"))
                .backgroundColor($r("sys.color.ohos_id_color_dialog_bg"))
                .onClick(() => {
                    this.conversationCtrl.longPressSelected(1)
                    this.showMenu = false
                })
            Button($r("app.string.delete"))
                .fontSize(14)
                .fontColor($r("sys.color.ohos_id_color_text_primary"))
                .backgroundColor($r("sys.color.ohos_id_color_dialog_bg"))
                .onClick(() => {
                    this.conversationCtrl.longPressSelected(2)
                    this.showMenu = false
                    this.delConversionController.open();
                })
            Button($r("app.string.more"))
                .fontSize(14)
                .fontColor($r("sys.color.ohos_id_color_text_primary"))
                .backgroundColor($r("sys.color.ohos_id_color_dialog_bg"))
                .onClick(() => {
                    this.conversationCtrl.longPressSelected(4)
                    this.showMenu = false
                })
        }
        .height(40)
        .borderRadius(20)
        .backgroundColor($r("sys.color.ohos_id_color_dialog_bg"))
    }

    build() {
        Row() {
            Text(this.content)
                .fontSize(16)
                .lineHeight(21)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .fontColor($r("sys.color.ohos_id_color_text_primary"))
        }
        .backgroundColor(this.bubbleTextBackgroundColor)
        .borderRadius(this.bubbleTextDirection == "right" ?
            { topLeft: this.bubbleTextBorderRadius[1], topRight: this.bubbleTextBorderRadius[0],
                bottomLeft: this.bubbleTextBorderRadius[1], bottomRight: this.bubbleTextBorderRadius[1] }:
            { topLeft: this.bubbleTextBorderRadius[0], topRight: this.bubbleTextBorderRadius[1],
                bottomLeft: this.bubbleTextBorderRadius[1], bottomRight: this.bubbleTextBorderRadius[1] })
        .flexBasis("auto")
        .gesture(
        LongPressGesture({ repeat: false, duration: 500 })
            //Touch and hold the action will be triggered continuously.
            .onAction(() => {
                if (!this.conversationCtrl.isSelectStatus) {
                    this.conversationCtrl.mmsListLongPress(this.itemIndex)
                    this.showMenu = true
                }
            })
        )
        .bindPopup(this.showMenu, {
            builder: this.MenuBuilder,
            placement: this.bubbleTextDirection == "left" ? Placement.TopRight : Placement.TopLeft,
            maskColor: $r("sys.color.ohos_id_color_mask_thin"),
            popupColor: $r("sys.color.ohos_id_color_background_transparent"),
            enableArrow: false,
            onStateChange: (e) => {
                if (!e.isVisible) {
                    this.showMenu = false
                }
            }
        })
    }
}