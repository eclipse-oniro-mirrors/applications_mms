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
import LooseObject from "../data/LooseObject";

@Component
export struct MmsListItem {
    @State item: LooseObject = {};
    private isShowHead: boolean = true;
    @Prop isMultipleSelectState: boolean;
    onClickHead: (event?: ClickEvent) => void;
    onClickBody: (event?: ClickEvent) => void;
    onItemLongPress: (event?: GestureEvent) => void;
    onTouchStart: (event?: GestureEvent) => void;
    onTouchUpdate: (event?: GestureEvent) => void;
    onTouchEnd: (event?: GestureEvent) => void;
    onClickFirstSlipBtn: (event?: ClickEvent) => void;
    onClickSecondSlipBtn: (event?: ClickEvent) => void;

    build() {
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.End }) {
            Row() {
                Row() {
                    //avatar
                    if (this.isShowHead) {
                        //Whether to add a red dot to the unread flag
                        Stack() {
                            Column() {
                                Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
                                    //SMS message type. 0: common; 1: notification
                                    if (this.item.conversation.smsType === 0) {
                                        if (this.item.conversation.photoFirstName === '') {
                                            Image($rawfile("icon/ic_user_portrait.svg"))
                                                .objectFit(ImageFit.Fill)
                                                .width("40vp")
                                                .height("40vp")
                                                .clip(new Circle({ width: "40vp", height: "40vp" }))
                                                .backgroundColor(this.item.conversation.portraitColor)
                                        } else {
                                            Text(this.item.conversation.photoFirstName)
                                                .fontSize($r("sys.float.ohos_id_text_size_headline8"))
                                                .fontWeight(FontWeight.Bold)
                                                .fontColor(Color.White)
                                                .height("40vp")
                                                .width("40vp")
                                                .textAlign(TextAlign.Center)
                                                .clip(new Circle({ width: "40vp", height: "40vp" }))
                                                .backgroundColor(this.item.conversation.portraitColor)
                                        }
                                    } else {
                                        Image($rawfile(this.item.conversation.icon))
                                            .objectFit(ImageFit.Fill)
                                            .width("40vp")
                                            .height("40vp")
                                    }
                                    if (this.item.conversation.countOfUnread > 0) {
                                        Text(this.item.conversation.countOfUnread < 100 ?
                                        this.item.conversation.countOfUnread.toString() : "99+")
                                            .fontSize(10)
                                            .align(Alignment.Center)
                                            .padding({ left: 5, right: 5 })
                                            .height(20)
                                            .backgroundColor($r("sys.color.ohos_id_color_badge_red"))
                                            .fontColor($r("sys.color.ohos_id_color_background"))
                                            .zIndex(2)
                                            .position({ x: "60%", y: "-10%" })
                                            .border({
                                                width: 2,
                                                color: $r("sys.color.ohos_id_color_background"),
                                                radius: 50
                                            })
                                    }
                                }
                                .width("40vp")
                                .height("40vp")
                                .onClick(this.onClickHead)
                            }.height("100%").justifyContent(FlexAlign.Center)
                        }
                    }

                    //body
                    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start }) {
                        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center }) {
                            Flex({ direction: FlexDirection.Row,
                                justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                                //Phone number or first name
                                Text(this.item.conversation.name != '' ? this.item.conversation.name :
                                this.item.conversation.telephoneFormat)
                                    .fontSize($r("sys.float.ohos_id_text_size_body1"))
                                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                                    .maxLines(1)
                                    .fontWeight(FontWeight.Medium)
                                Text().width(16)
                                //Date Time
                                Text(this.item.conversation.time)
                                    .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
                                    .fontSize("12fp")
                                    .maxLines(1)
                                    .flexShrink(0)
                            }.width("100%").height(22)

                            //Content Abbreviations for Latest News
                            Row() {
                                //Whether the latest message has not been sent successfully. If yes,
                                if (this.item.conversation.sendingFailed) {
                                    Text($r("app.string.messageSendFailed"))
                                        .fontSize("12fp")
                                        .fontColor($r("sys.color.ohos_id_color_warning"))
                                } else {
                                    //If it's not
                                    Row() {
                                        Text() {
                                            if (this.item.conversation.isDraft) {
                                                Span($r("app.string.draft"))
                                                    .fontSize("14fp")
                                                    .fontColor(Color.Red)
                                            }
                                            //If no, and the number of unread messages is greater than 1.
                                            if (!this.item.conversation.isDraft &&
                                            this.item.conversation.countOfUnread > 1) {
                                                Span($r("app.string.multiUnread", this.item.conversation.countOfUnread))
                                                    .fontSize("14fp")
                                                    .fontColor($r("sys.color.ohos_id_color_help_tip_bg"))
                                            }
                                            //Content Abbreviations for Latest News
                                            Span(this.item.conversation.content.replace(/[\r\n]/g, " "))
                                                .fontSize("14fp")
                                                .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
                                        }
                                        .maxLines(1)
                                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                                    }
                                }
                            }
                            .alignSelf(ItemAlign.Start)
                            .alignItems(VerticalAlign.Top)
                            .width("100%")
                            .height(19)
                            .margin({ top: "2vp" })
                        }.width("100%")
                        .height("100%")
                    }
                    .layoutWeight(1)
                    .height("100%")
                    .padding({ left: "12vp" })

                    //CheckBox
                    if (this.isMultipleSelectState) {
                        Toggle({ type: ToggleType.Checkbox, isOn: this.item.conversation.isCbChecked })
                            .width("20vp")
                            .height("20vp")
                            .selectedColor($r("sys.color.ohos_id_color_activated"))
                            .hitTestBehavior(HitTestMode.None)
                        //              .enabled(false)
                        //              .margin({ right: -14 })
                    }
                }
                .alignItems(VerticalAlign.Top)
                .width("100%")
                .height("100%")
                .offset({
                    x: this.item.conversation.itemLeft
                })
                //Swipe left to delete icon
                if (!this.isMultipleSelectState) {
                    Flex({
                        direction: FlexDirection.Row,
                        justifyContent: FlexAlign.SpaceEvenly,
                        alignItems: ItemAlign.Center
                    }) {
                        if (this.item.conversation.countOfUnread > 0) {
                            Image($rawfile("icon/msg_done.svg"))
                                .width(40)
                                .height(40)
                                .onClick(this.onClickFirstSlipBtn)
                        }
                        Image($rawfile("icon/msg_delete.svg"))
                            .width(40)
                            .height(40)
                            .onClick(this.onClickSecondSlipBtn)
                    }
                    .width(this.item.conversation.countOfUnread > 0 ? 128 : 80)
                    .height("100%")
                    .flexShrink(0)
                    .backgroundColor($r("sys.color.ohos_id_color_background"))
                    .offset({
                        x: this.item.conversation.itemLeft
                    })
                }
            }
            .width("100%")
            .height("100%")
            .gesture(PanGesture({
                direction: this.item.conversation.isDelShow ? PanDirection.Right : PanDirection.Left
            })
                .onActionStart(this.onTouchStart)
                .onActionUpdate(this.onTouchUpdate)
                .onActionEnd(this.onTouchEnd)
            )
        }
        .onClick(this.onClickBody)
        .gesture(LongPressGesture().onAction(this.onItemLongPress))
    }
}