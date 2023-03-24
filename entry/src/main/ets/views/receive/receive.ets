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
import ReceiveController from "./receiveController"
import ConversationController from "../../pages/conversation/conversationController"

@Component
export struct Receive {
    @State mReceiveController: ReceiveController = ReceiveController.getInstance();
    @Link mConversationController: ConversationController;

    aboutToAppear() {
        this.mReceiveController.onInit((receiverData) => {
            this.mConversationController.setReceiveContactValue(receiverData)
        })
    }

    build() {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
            Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
                Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
                    Text($r("app.string.putAddresser"))
                        .maxLines(1)
                        .lineHeight($r("app.float.addressee_line_height"))
                        .fontSize($r("app.float.addressee_font_size"))
                        .fontColor($r("sys.color.ohos_id_color_text_secondary"))
                        .fontWeight(FontWeight.Regular)
                        .fontFamily("HarmonyHeiTi")
                        .flexShrink(0)
                    Flex({ wrap: FlexWrap.NoWrap, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
                        // If a contact is selected
                        if (this.mReceiveController.isInputStatus) {
                            if (this.mReceiveController.selectContacts.length > 0) {
                                ForEach(this.mReceiveController.selectContacts, (item, index) => {
                                    Row() {
                                        if (item.contactName == "" || item.contactName == null) {
                                            Text(item.telephoneFormat)
                                                .textAlign(TextAlign.Center)
                                                .maxLines(1)
                                                .textOverflow({ overflow: TextOverflow.Ellipsis })
                                                .fontSize(12)
                                                .flexShrink(1)
                                        }
                                        if (item.contactName != "" && item.contactName != null) {
                                            Text(item.contactName)
                                                .textAlign(TextAlign.Center)
                                                .maxLines(1)
                                                .textOverflow({ overflow: TextOverflow.Ellipsis })
                                                .fontSize(12)
                                                .flexShrink(1)
                                        }
                                        if (item.select) {
                                            Image($rawfile("icon/ic_public_cancel.svg"))
                                                .width(16)
                                                .height(16)
                                                .flexShrink(1)
                                        }
                                    }
                                    .padding({ left: 8, right: 8 })
                                    .margin(8)
                                    .backgroundColor($r("sys.color.ohos_id_color_component_normal"))
                                    .borderRadius(24)
                                    .height(28)
                                    .alignItems(VerticalAlign.Center)
                                    .constraintSize({ maxWidth: item.select ? 244 : 228 ,minWidth: 68})
                                    .onClick(() => {
                                        this.mReceiveController.nameClick(index, (receiverData) => {
                                            this.mConversationController.setReceiveContactValue(receiverData);
                                        })
                                    })
                                }, item => JSON.stringify(item))
                            }
                            Flex() {
                                TextArea({ text: this.mReceiveController.myText })
                                    .caretColor($r("sys.color.ohos_id_color_focused_outline"))
                                    .placeholderColor($r("sys.color.ohos_id_color_text_hint"))
                                    .backgroundColor($r("sys.color.ohos_id_color_background_transparent"))
                                    .focusable(true)
                                    .flexShrink(1)
                                    .onChange((value) => {
                                        this.mReceiveController.searchChange(value, (receiverData) => {
                                            this.mConversationController.setReceiveContactValue(receiverData);
                                        });
                                    })
                                    .onBlur(() => {
                                        this.mReceiveController.checkReceive((receiverData) => {
                                            this.mConversationController.setReceiveContactValue(receiverData);
                                        });
                                    })
                                    .onFocus(() => {
                                        this.mReceiveController.myContactFocus();
                                    })
                            }
                            .flexShrink(1)
                            .constraintSize({ maxHeight: 120 })
                        }
                        else {
                            Text(this.mReceiveController.strSelectContact)
                                .fontColor($r("sys.color.ohos_id_color_text_primary_activated"))
                                .textAlign(TextAlign.Center)
                                .fontSize(16)
                                .lineHeight(22)
                                .maxLines(1)
                                .textAlign(TextAlign.Start)
                                .textOverflow({ overflow: TextOverflow.Ellipsis })
                                .width("100%")
                                .padding({ top: 12, bottom: 12 })
                                .onClick(() => {
                                    this.mReceiveController.myContactClick();
                                })
                        }
                    }
                    .flexShrink(1)
                }
                .flexBasis("auto")
                .flexShrink(1)

                // Contact icon on the right
                Image($rawfile("icon/ic_about.svg"))
                    .width(24)
                    .height(24)
                    .onClick(() => {
                        // The page for selecting a contact is displayed.
                        this.mReceiveController.clickToContracts((receiverData) => {
                            this.mConversationController.setReceiveContactValue(receiverData);
                        })
                    })

            }
            .constraintSize({ minHeight: 56, maxHeight:200 })
            .backgroundColor($r("sys.color.ohos_id_color_background"))
            .borderRadius($r("app.float.settings_items_radius"))
            .padding({ left: 12, right: 12 })

            Column() {
                // Indicates whether to display the recent contact list.
                if (this.mReceiveController.isShowSearch && this.mReceiveController.contacts.length > 0) {
                    //                    Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
                    //                        Text("最近联系人")
                    //                            .fontSize(16)
                    //                            .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
                    //                            .fontWeight(FontWeight.Regular)
                    //                    }
                    //                    .height(48)
                    // List area
                    List({ space: 0, initialIndex: 0 }) {
                        ForEach(this.mReceiveController.contacts, (item, index) => {
                            ListItem() {
                                Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
                                    Image($rawfile("icon/ic_user_portrait.svg"))
                                        .objectFit(ImageFit.Fill)
                                        .width("40vp")
                                        .height("40vp")
                                        .clip(new Circle({ width: "40vp", height: "40vp" }))
                                        .backgroundColor($r("app.color.ic_user_head_color"))
                                        .onClick(() => {
                                            this.mReceiveController.titleBarAvatar(index)
                                        })

                                    Flex({
                                        direction: FlexDirection.Column,
                                        justifyContent: FlexAlign.Center,
                                        alignItems: ItemAlign.Start
                                    }) {
                                        if (item.contactName != '' || item.contactName != null) {
                                            Text(item.contactName)
                                                .fontSize(16)
                                                .fontColor($r("sys.color.ohos_id_color_text_primary"))
                                                .maxLines(1)
                                                .fontWeight(FontWeight.Medium)
                                                .textOverflow({ overflow: TextOverflow.Ellipsis })
                                        }
                                        Text(item.telephoneFormat)
                                            .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
                                            .fontSize(14)
                                            .maxLines(1)
                                            .margin({ top: 4 })
                                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                                    }
                                    .layoutWeight(1)
                                    .margin({ left: 12 })
                                    .onClick(() => {
                                        this.mReceiveController.addContact(index, (receiverData) => {
                                            this.mConversationController.setReceiveContactValue(receiverData);
                                        })
                                    })
                                }
                                .width('100%')
                                .height(64)
                            }
                        }, item => JSON.stringify(item))
                    }
                    .listDirection(Axis.Vertical) // Arrange Direction
                    .edgeEffect(EdgeEffect.Spring) // Sliding to the edge has no effect
                    .divider({
                        strokeWidth: 1,
                        color: $r("sys.color.ohos_id_color_list_separator"),
                        startMargin: 52,
                        endMargin: 0
                    }) // Demarcation line between each row
                }
            }.padding({ left: 12, right: 12, bottom: 56 })
        }
        .width("100%")
        .padding({ left: 12, right: 12 })
    }
}