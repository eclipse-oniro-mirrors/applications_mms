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
 * 弹框种类：无标题，1个消息，2个按钮
 */
@CustomDialog
export struct DeleteDialog {
    controller: CustomDialogController;
    /**
     * 取消事件
     */
    cancel: () => void;
    /**
     * 确认事件
     */
    confirm: () => void;
    /**
     * 消息内容
     */
    msg: string | Resource;
    /**
     * 删除的信息中，是否包含锁定的信息
     */
    hasLockMsg: boolean;
    setSelectLock?: () => void;
    /**
     * 是否同步删除锁定信息勾选项
     */
    isSelectLockMsg?: boolean;
    setSelectLockChange?: (isOn: boolean) => void;

    build() {
        Column() {
            Text(this.msg)
                .width('100%')
                .margin({ bottom: 8 })
                .textAlign(TextAlign.Center)
                .fontSize(16)
                .fontColor('#182431')
                .lineHeight(22)
                .fontWeight(FontWeight.Regular)
                .fontFamily('HarmonyHeiTi')
            if (this.hasLockMsg) {
                Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
                    Toggle({ type: ToggleType.Checkbox, isOn: this.isSelectLockMsg })
                        .width('20vp')
                        .height('20vp')
                        .onChange((isOn: boolean) => {
                            this.setSelectLockChange(isOn)
                        })
                    Text($r("app.string.msg_delete_dialog_cb_tip")).height('100%')
                }
                .width('100%')
                .height('32vp')
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
                        .fontColor('#007DFF')
                        .fontWeight(FontWeight.Medium)
                        .fontFamily('HarmonyHeiTi')
                        .lineHeight(22)
                }
                .backgroundColor($r("app.color.back_Transparent"))
                .layoutWeight(1)
                .onClick(() => {
                    this.controller.close();
                    this.cancel();
                })

                Divider().vertical(true).strokeWidth('2px').height('20vp').color(Color.Gray)
                Button() {
                    Text($r("app.string.delete"))
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .fontColor('#FA2A2D')
                        .fontWeight(FontWeight.Medium)
                        .fontFamily('HarmonyHeiTi')
                        .lineHeight(22)
                }
                .backgroundColor($r("app.color.back_Transparent"))
                .layoutWeight(1)
                .onClick(() => {
                    this.controller.close();
                    this.confirm();
                })
            }
            .width('100%')
            .height(40)
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 24, bottom: 16 })
    }
}

export class MmsSimpleDialog {
    value: AlertDialogParamWithMms;
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
                primaryButton: {
                    value: this.value.primaryButton.value,
                    action: this.value.primaryButton.action
                },
                secondaryButton: {
                    value: this.value.secondaryButton.value,
                    action: this.value.secondaryButton.action,
                    fontColor: $r("sys.color.ohos_id_color_handup")
                }
            }
        )
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
 * 弹框种类：1标题，2个勾选项，2按钮
 */
@CustomDialog
export struct CheckBoxDialog {
    controller: CustomDialogController;
    /**
     * 取消事件
     */
    cancel: () => void;
    /**
     * 确认事件
     */
    confirm: () => void;
    /**
     * 标题
     */
    title: string | Resource;

    /**
     * 选项集合
     */
    @State itemList: Array<CheckBoxItem> = [];

    build() {
        Column() {
            // dialog标题
            Text(this.title)
                .width('100%')
                .margin({ bottom: 8 })
                .fontSize(16)
                .fontColor('#182431')
                .lineHeight(22)
                .fontWeight(FontWeight.Regular)
                .fontFamily('HarmonyHeiTi')
            // item勾选列表
            ForEach(this.itemList, (item, index) => {
                Flex({
                    direction: FlexDirection.Row,
                    justifyContent: FlexAlign.SpaceBetween,
                    alignItems: ItemAlign.Center
                }) {
                    Text(item.title)
                    Toggle({ type: ToggleType.Checkbox, isOn: item.isOn })
                        .width('20vp')
                        .height('20vp')
                        .enabled(false)
                }
                .width('100%')
                .height('32vp')
                .onClick(item.onClick)
            }, (item, index) => index.toString())
            // 确定和取消按钮
            Flex({
                direction: FlexDirection.Row,
                justifyContent: FlexAlign.SpaceEvenly,
                alignItems: ItemAlign.Center
            }) {
                Button() {
                    Text($r("app.string.cancel"))
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .fontColor('#007DFF')
                        .fontWeight(FontWeight.Medium)
                        .fontFamily('HarmonyHeiTi')
                        .lineHeight(22)
                        .onClick(() => {
                            this.controller.close();
                            this.cancel();
                        })
                }.backgroundColor($r("app.color.back_Transparent")).layoutWeight(1)

                Divider().vertical(true).strokeWidth('2px').height('20vp').color(Color.Gray)
                Button() {
                    Text($r("app.string.ok"))
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .fontColor('#007DFF')
                        .fontWeight(FontWeight.Medium)
                        .fontFamily('HarmonyHeiTi')
                        .lineHeight(22)
                        .onClick(() => {
                            this.controller.close();
                            this.confirm();
                        })
                }.backgroundColor($r("app.color.back_Transparent")).layoutWeight(1)
            }
            .width('100%')
            .height(40)
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 24, bottom: 16 })
    }
}