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
import DeviceUtil from "../utils/DeviceUtil";

/**
 * Type of the dialog box: No title, 1 message, and 2 buttons
 */
@CustomDialog
export struct DeleteDialog {
    controller: CustomDialogController;
    /**
     * Cancel Event
     */
    cancel: () => void;
    /**
     * Acknowledge Event
     */
    confirm: () => void;
    /**
     * Message content
     */
    msg: string | Resource;
    /**
     * Check whether the deleted information contains locked information.
     */
    hasLockMsg: boolean;
    setSelectLock?: () => void;
    /**
     * Whether to delete lock information synchronously
     */
    isSelectLockMsg?: boolean;
    setSelectLockChange?: (isOn: boolean) => void;

    build() {
        Column() {
            Text(this.msg)
                .width("100%")
                .margin({ bottom: 8 })
                .textAlign(TextAlign.Center)
                .fontSize(16)
                .fontColor($r("sys.color.ohos_id_color_text_primary"))
                .lineHeight(22)
                .fontWeight(FontWeight.Regular)
                .fontFamily("HarmonyHeiTi")
            if (this.hasLockMsg) {
                Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
                    Toggle({ type: ToggleType.Checkbox, isOn: this.isSelectLockMsg })
                        .width("20vp")
                        .height("20vp")
                        .onChange((isOn: boolean) => {
                            this.setSelectLockChange(isOn)
                        })
                    Text($r("app.string.msg_delete_dialog_cb_tip")).height("100%")
                }
                .width("100%")
                .height("32vp")
                .onClick((event?: ClickEvent) => {
                    this.setSelectLock();
                })
            }
            Flex({
                direction: FlexDirection.Row,
                justifyContent: FlexAlign.SpaceEvenly,
                alignItems: ItemAlign.Center
            }) {
                Button() {
                    Text($r("app.string.cancel"))
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .fontColor($r("sys.color.ohos_id_color_floating_button_bg_normal"))
                        .fontWeight(FontWeight.Medium)
                        .fontFamily("HarmonyHeiTi")
                        .lineHeight(22)
                }
                .backgroundColor($r("sys.color.ohos_id_color_background_transparent"))
                .layoutWeight(1)
                .onClick(() => {
                    this.controller.close();
                    this.cancel();
                })

                Divider()
                    .vertical(true)
                    .strokeWidth("1px")
                    .height("20vp")
                    .color($r("sys.color.ohos_id_color_list_separator"))
                Button() {
                    Text($r("app.string.delete"))
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .fontColor($r("sys.color.ohos_id_color_warning"))
                        .fontWeight(FontWeight.Medium)
                        .fontFamily("HarmonyHeiTi")
                        .lineHeight(22)
                }
                .backgroundColor($r("sys.color.ohos_id_color_background_transparent"))
                .layoutWeight(1)
                .onClick(() => {
                    this.controller.close();
                    this.confirm();
                })
            }
            .width("100%")
            .height(40)
        }
        .width("100%")
        .padding({ left: 24, right: 24, top: 24, bottom: 16 })
    }
}

@CustomDialog
export struct DelConversionDialog {
    controller: CustomDialogController;
    /**
     * Cancel Event
     */
    cancel: () => void;
    /**
     * Acknowledge Event
     */
    confirm: () => void;
    /**
     * Message content
     */
    msg: string | Resource;

    build() {
        Column() {
            Text(this.msg)
                .width("100%")
                .margin({ bottom: 8 })
                .textAlign(TextAlign.Center)
                .fontSize(16)
                .fontColor($r("sys.color.ohos_id_color_text_primary"))
                .lineHeight(22)
                .fontWeight(FontWeight.Regular)
                .fontFamily("HarmonyHeiTi")
            Flex({
                direction: FlexDirection.Row,
                justifyContent: FlexAlign.SpaceEvenly,
                alignItems: ItemAlign.Center
            }) {
                Button() {
                    Text($r("app.string.cancel"))
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .fontColor($r("sys.color.ohos_id_color_floating_button_bg_normal"))
                        .fontWeight(FontWeight.Medium)
                        .fontFamily("HarmonyHeiTi")
                        .lineHeight(22)
                }
                .backgroundColor($r("sys.color.ohos_id_color_background_transparent"))
                .layoutWeight(1)
                .onClick(() => {
                    this.controller.close();
                    this.cancel();
                })

                Divider()
                    .vertical(true)
                    .strokeWidth("1px")
                    .height("20vp")
                    .color($r("sys.color.ohos_id_color_list_separator"))
                Button() {
                    Text($r("app.string.delete"))
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .fontColor($r("sys.color.ohos_id_color_warning"))
                        .fontWeight(FontWeight.Medium)
                        .fontFamily("HarmonyHeiTi")
                        .lineHeight(22)
                }
                .backgroundColor($r("sys.color.ohos_id_color_background_transparent"))
                .layoutWeight(1)
                .onClick(() => {
                    this.controller.close();
                    this.confirm();
                })
            }
            .width("100%")
            .height(40)
        }
        .width("100%")
        .padding({ left: 24, right: 24, top: 24, bottom: 16 })
    }
}

export class MmsSimpleDialog {
    value: AlertDialogParamWithMms;
    private dialogGridCount: number = 4;
    private dialogAlignment: DialogAlignment = DeviceUtil.isTablet() ? DialogAlignment.Center : DialogAlignment.Bottom;
    private dialogOffset: Offset = DeviceUtil.isTablet() ? { dx: 0, dy: 0 } : { dx: 0, dy: -12 };
    constructor(value: AlertDialogParamWithMms) {
        this.value = value;
    }

    show() {
        AlertDialog.show(
            {
                message: this.value.message,
                autoCancel: false,
                alignment: this.dialogAlignment,
                offset: this.dialogOffset,
                gridCount: this.dialogGridCount,
                primaryButton: {
                    value: this.value.primaryButton.value,
                    action: this.value.primaryButton.action,
                    fontColor: $r("sys.color.ohos_id_color_activated")
                },
                secondaryButton: {
                    value: this.value.secondaryButton.value,
                    action: this.value.secondaryButton.action,
                    fontColor: $r("sys.color.ohos_id_color_warning")
                }
            }
        )
    }
}


@CustomDialog
export struct SysSimpleExample {
    controller: CustomDialogController
    cancel: () => void
    confirm: () => void

    value: AlertDialogParamWithMms;
    private dialogAlignment: DialogAlignment = DeviceUtil.isTablet() ? DialogAlignment.Center : DialogAlignment.Bottom;
    private dialogOffset: Offset = DeviceUtil.isTablet() ? { dx: 0, dy: 0 } : { dx: 0, dy: -12 };

    build() {
        Column() {
            Text(this.value.message)
                .fontSize(16)
                .fontWeight(FontWeight.Regular)
                .margin({ top: 24, bottom: 8 })
            Flex({ justifyContent: FlexAlign.SpaceAround ,alignItems: ItemAlign.Center}) {
                Button($r("app.string.cancel"))
                    .onClick(() => {
                        this.controller.close()
                        this.cancel()
                    })
                    .backgroundColor(0xffffff)
                    .fontColor($r("sys.color.ohos_id_color_activated"))
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)
                Text("|").fontSize(16).fontColor(Color.Gray)
                Button($r("app.string.restore"))
                    .onClick(() => {
                        this.controller.close()
                        this.confirm()
                    })
                    .backgroundColor(0xffffff)
                    .fontColor($r("sys.color.ohos_id_color_warning"))
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)
            }.margin({ bottom: 12 ,top:12})
        }.borderRadius(24)
    }
}

declare interface AlertDialogParamWithMms {
    message: ResourceStr;
    primaryButton: {
        value: ResourceStr;
        action: () => void;
    };
    secondaryButton: {
        value: ResourceStr;
        action: () => void;
    };
}

export interface CheckBoxItem {
    title: string | Resource;
    isOn: boolean;
    onClick: (event?: ClickEvent) => void;
}

/**
 * Type of the dialog box: 1 title, 2 options, and 2 buttons
 */
@CustomDialog
export struct CheckBoxDialog {
    controller: CustomDialogController;
    /**
     * Cancel Event
     */
    cancel: () => void;
    /**
     * Acknowledge Event
     */
    confirm: () => void;
    /**
     * Title
     */
    title: string | Resource;

    /**
     * Option Collection
     */
    @State itemList: Array<CheckBoxItem> = [];

    build() {
        Column() {
            // dialog title
            Text(this.title)
                .width("100%")
                .margin({ bottom: 8 })
                .fontSize(16)
                .fontColor($r("sys.color.ohos_id_color_text_primary"))
                .lineHeight(22)
                .fontWeight(FontWeight.Regular)
                .fontFamily("HarmonyHeiTi")
            // item Checklist
            ForEach(this.itemList, (item, index) => {
                Flex({
                    direction: FlexDirection.Row,
                    justifyContent: FlexAlign.SpaceBetween,
                    alignItems: ItemAlign.Center
                }) {
                    Text(item.title)
                    Toggle({ type: ToggleType.Checkbox, isOn: item.isOn })
                        .width("20vp")
                        .height("20vp")
                        .enabled(false)
                }
                .width("100%")
                .height("32vp")
                .onClick(item.onClick)
            }, (item, index) => index.toString())
            // OK and Cancel Buttons
            Flex({
                direction: FlexDirection.Row,
                justifyContent: FlexAlign.SpaceEvenly,
                alignItems: ItemAlign.Center
            }) {
                Button() {
                    Text($r("app.string.cancel"))
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .fontColor($r("sys.color.ohos_id_color_floating_button_bg_normal"))
                        .fontWeight(FontWeight.Medium)
                        .fontFamily("HarmonyHeiTi")
                        .lineHeight(22)
                        .onClick(() => {
                            this.controller.close();
                            this.cancel();
                        })
                }.backgroundColor($r("sys.color.ohos_id_color_background_transparent")).layoutWeight(1)

                Divider()
                    .vertical(true)
                    .strokeWidth("1px")
                    .height("20vp")
                    .color($r("sys.color.ohos_id_color_list_separator"))
                Button() {
                    Text($r("app.string.ok"))
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .fontColor($r("sys.color.ohos_id_color_floating_button_bg_normal"))
                        .fontWeight(FontWeight.Medium)
                        .fontFamily("HarmonyHeiTi")
                        .lineHeight(22)
                        .onClick(() => {
                            this.controller.close();
                            this.confirm();
                        })
                }.backgroundColor($r("sys.color.ohos_id_color_background_transparent")).layoutWeight(1)
            }
            .width("100%")
            .height(40)
        }
        .width("100%")
        .padding({ left: 24, right: 24, top: 24, bottom: 16 })
    }
}

@CustomDialog
export struct TransmitMsgDialog {
    scroller: Scroller = new Scroller()
    controller: CustomDialogController;
    /**
     * Cancel an event
     */
    cancel: () => void;
    /**
     * Acknowledgment Events
     */
    confirm: () => void;
    /**
     * Message content
     */
    msg: object | Resource | any;

    isChecked: boolean = true;

    changeValue?: () => void;

    clickChecked?: () => void;

    build() {
        Column() {
            Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
                Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }){
                    // Title
                    Column() {
                        if(this.msg.contactsParam.contactsNum > 1) {
                            Text() {
                                Span($r("app.string.contentSentTo"))
                                    .fontSize(20)
                                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                                    .fontWeight(FontWeight.Bold)
                                Span(this.msg.contactsParam.contactName == "" ?
                                this.msg.contactsParam.telephoneFormatSplit :
                                this.msg.contactsParam.contactNameSplit)
                                    .fontSize(20)
                                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                                    .fontWeight(FontWeight.Bold)
                                Span($r('app.string.including'))
                                    .fontSize(20)
                                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                                    .fontWeight(FontWeight.Bold)
                                Span(this.msg.contactsParam.contactsNum)
                                    .fontSize(20)
                                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                                    .fontWeight(FontWeight.Bold)
                                Span($r('app.string.people'))
                                    .fontSize(20)
                                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                                    .fontWeight(FontWeight.Bold)
                            }
                        } else {
                            Text() {
                                Span($r("app.string.contentSentTo"))
                                    .fontSize(20)
                                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                                    .fontWeight(FontWeight.Bold)
                                Span(this.msg.contactsParam.contactName == '' ?
                                this.msg.contactsParam.telephoneFormat :
                                this.msg.contactsParam.contactName)
                                    .fontSize(20)
                                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                                    .fontWeight(FontWeight.Bold)
                            }
                        }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .width("100%")

                    // Forwarded content
                    Column(){
                        List() {
                            ForEach(this.msg.transmitContentList, item => {
                                ListItem() {
                                    if( item.msgShowType == 0 || item.msgShowType == 4){
                                        Flex() {
                                            if( item.msgUriPath != '' && (item.msgType==1 || item.msgType == 2)) {
                                                Image($rawfile(item.msgUriPath))
                                                    .width('100%')
                                                    .height(150)
                                            } else if( item.msgUriPath != '' && item.msgType == 5) {
                                                Image($rawfile("icon/msg_contacts.svg"))
                                                    .height(48)
                                                    .width(48)
                                                    .margin({left: 10, right: 10})
                                                Flex() {
                                                    Text(item.msgUriPath)
                                                        .align(Alignment.Center)
                                                    if(item.audioTime != '') {
                                                        Text(item.audioTime)
                                                            .align(Alignment.Center)
                                                    }
                                                }
                                                .padding(5)
                                                .margin({right: 40})
                                            } else if(item.content != '') {
                                                if(this.isChecked || (!this.isChecked && item.isMsm)) {
                                                    Column() {
                                                        Column() {
                                                            Text(this.msg.transmitContent)
                                                            Text(item.contentInfo)
                                                        }
                                                        Column() {
                                                            Text(item.content)
                                                                .fontSize(16)
                                                                .margin({ top: 5})
                                                        }
                                                    }
                                                    .padding({ top: 20 })
                                                    .width('100%')
                                                    .alignItems(HorizontalAlign.Start)

                                                } else if(!this.isChecked && !item.isMsm) {
                                                    TextArea({
                                                        text: item.content
                                                    })
                                                        .onChange((item) => {
                                                            this.changeValue()
                                                        })
                                                }
                                            }
                                        }
                                    } else if(item.msgShowType == 1 || item.msgShowType == 2) {
                                        Flex() {
                                            Image($rawfile("icon/ppt.svg"))
                                                .width('100%')
                                                .height(150)
                                            if(item.content != '') {
                                                Text(item.content)
                                            }
                                        }
                                        .padding(20)
                                        .backgroundColor('#20A9A9A9')
                                        .borderRadius(15)
                                    } else {
                                        Flex() {
                                            if(item.content != '') {
                                                Text(item.content)
                                                    .margin({ top: 10, left: 30, bottom: 10})
                                            }
                                        }
                                    }

                                }
                            }, item => item.msgType.toString())
                        }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .width("100%")
                }
            }

            Flex({ justifyContent: FlexAlign.SpaceAround }) {
                Button() {
                    Text($r("app.string.cancel"))
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .fontColor($r("sys.color.ohos_id_color_floating_button_bg_normal"))
                        .fontWeight(FontWeight.Medium)
                        .fontFamily("HarmonyHeiTi")
                        .lineHeight(22)
                }
                .backgroundColor($r("sys.color.ohos_id_color_background_transparent"))
                .layoutWeight(1)
                .onClick(() => {
                    this.controller.close();
                    this.cancel();
                })

                Divider().vertical(true).strokeWidth("1px").height("20vp").color($r("sys.color.ohos_id_color_list_separator"))
                Button() {
                    Text($r("app.string.msg_transmit"))
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .fontColor($r("sys.color.ohos_id_color_warning"))
                        .fontWeight(FontWeight.Medium)
                        .fontFamily("HarmonyHeiTi")
                        .lineHeight(22)
                }
                .backgroundColor($r("sys.color.ohos_id_color_background_transparent"))
                .layoutWeight(1)
                .onClick(() => {
                    this.controller.close();
                    this.confirm();
                })
            }
        }
        .width("100%")
        .height(200)
        .padding({ left: 24, right: 24, top: 24, bottom:40 })
    }
}