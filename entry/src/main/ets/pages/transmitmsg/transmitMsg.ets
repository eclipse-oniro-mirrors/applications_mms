// @ts-nocheck
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
import TransmitMsgController from "./transmitMsgController";
import DeviceUtil from "../../utils/DeviceUtil";
import router from "@system.router";
import { TransmitMsgDialog } from "../../views/MmsDialogs";
import WantUtil from "../../utils/WantUtil";

@Entry
@Component
export default struct TransmitMsg {
    @State mTransmitMsgCtrl: TransmitMsgController = TransmitMsgController.getInstance();
    @State gridColumns: number = DeviceUtil.isTablet() ? 12 : 4;
    @State gridSizeType: SizeType = DeviceUtil.isTablet() ? SizeType.LG : SizeType.SM;
    @State gridGutter: string = "24vp";
    @State gridMargin: string = "24vp";
    private dialogAlignment: DialogAlignment = DeviceUtil.isTablet() ? DialogAlignment.Center : DialogAlignment.Bottom;
    private dialogOffset: Offset = DeviceUtil.isTablet() ? { dx: 0, dy: 0 } : { dx: 0, dy: -12 };
    delDialogController: CustomDialogController = new CustomDialogController({
        builder: TransmitMsgDialog({
            cancel: () => {

            },
            confirm: () => {
                this.mTransmitMsgCtrl.transmit()
            },
            msg: this.mTransmitMsgCtrl.dialogMsg,
        }),
        autoCancel: false,
        alignment: this.dialogAlignment,
        offset: this.dialogOffset,
        changeValue: (item) => {
            this.mTransmitMsgCtrl.changeValue(item)
        },
        clickChecked: (isOn: boolean) => {
            this.mConListCtrl.clickChecked(isOn)
        }
    });

    aboutToAppear() {
        this.mTransmitMsgCtrl.onInit();
        this.mTransmitMsgCtrl.onShow();
    }

    aboutToDisappear() {
    }

    onPageShow() {
        WantUtil.getWant();
        if(this.mTransmitMsgCtrl.DialogShow){
            this.delDialogController.open();
        }
    }

    onPageHide() {
    }

    onBackPress() {
    }

    build() {
        GridContainer({
            columns: this.gridColumns,
            sizeType: this.gridSizeType,
            gutter: this.gridGutter,
            margin: this.gridMargin
        }) {
            Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
                //Notification information
                Flex() {
                    Row() {
                        Image($rawfile("icon/ic_public_cancel.svg"))
                            .width(24)
                            .height(24)
                            .onClick(() => {
                                // Click Back to return to the unselected SMS state.
                                router.back();
                            })
                        Text($r("app.string.transmitHeadText"))
                            .margin({ left: 16 })
                            .fontSize(20)
                            .fontColor($r("sys.color.ohos_id_color_text_primary"))
                            .fontWeight(FontWeight.Bold)
                    }
                    .alignItems(VerticalAlign.Center)
                    .width("100%")
                    .height(56)
                }

                //Select Contact
                Flex(){
                    Column(){
                        Row() {
                            Text($r("app.string.selectContracts"))
                                .fontSize("16fp")
                                .fontColor($r("sys.color.ohos_id_color_text_primary"))
                            Blank()
                                Image($rawfile("icon/ic_next.svg"))
                                    .width($r("app.float.settings_item_next_image_width"))
                                    .height($r("app.float.settings_item_next_image_height"))
                        }
                        .width("100%")
                        .height("100%")
                        .margin({ left: "4vp" })
                    }
                    .layoutWeight(1)
                    .height("100%")
                }.height("48vp")
                .width("100%")
                .onClick(() => {
                    //Go to Select Contact
                    this.mTransmitMsgCtrl.jumpToSelectContracts()
                })

                //recent
                Flex() {
                    Row() {
                        Text($r("app.string.recently"))
                            .fontSize("16fp")
                            .fontColor($r("sys.color.ohos_id_color_text_primary"))
                    }.height("48vp")
                }
                List() {
                    LazyForEach(this.mTransmitMsgCtrl.transmitMsgDataSource, (item, index) => {
                        ListItem() {
                            Row() {
                                //avatar
                                if(item.conversation.photoFirstName === '') {
                                    Image($rawfile("icon/ic_user_portrait.svg"))
                                        .objectFit(ImageFit.Fill)
                                        .width("40vp")
                                        .height("40vp")
                                        .clip(new Circle({ width: "40vp", height: "40vp" }))
                                        .backgroundColor(item.conversation.portraitColor)
                                } else {
                                    Text(item.conversation.photoFirstName)
                                        .fontSize("30vp")
                                        .fontWeight(FontWeight.Bold)
                                        .fontColor(Color.White)
                                        .height("40vp")
                                        .width("40vp")
                                        .textAlign(TextAlign.Center)
                                        .clip(new Circle({ width: "40vp", height: "40vp" }))
                                        .backgroundColor(item.conversation.portraitColor)
                                }
                                Text(item.conversation.name !== '' ? item.conversation.name : item.conversation.telephone)
                                    .fontSize("16vp")
                                    .fontWeight(FontWeight.Bold)
                                    .margin({ left: 16 })
                            }
                            .width("100%")
                            .height(64)
                        }
                        .onClick( () => {
                            this.mTransmitMsgCtrl.clickSendMessage(item)
                            this.delDialogController.open();
                        })
                    }, item => item.conversation.threadId.toString())
                }
                .divider({
                    strokeWidth: 1,
                    startMargin: 56,
                    endMargin: 0
                })
            }.width("100%")
            .height("100%")
            .useSizeType({
                xs: { span: 4, offset: 0 }, sm: { span: 4, offset: 0 },
                md: { span: 12, offset: 0 }, lg: { span: 12, offset: 0 }
            })
        }
    }
}