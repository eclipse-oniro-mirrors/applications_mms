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
import DeviceUtil from "../../utils/DeviceUtil";
import InfoMsgController from "./InfoMsgController";
import { DeleteDialog } from "../../views/MmsDialogs";
import { MmsListItem } from "../../views/MmsListItem";
import { MoreMenu } from "../../views/MmsMenu";
import WantUtil from "../../utils/WantUtil";

@Entry
@Component
export default struct InfoMsg {
    @StorageLink("InfoMsgController") @Watch("changeSelectState") mInfoMsgCtrl: InfoMsgController = InfoMsgController.getInstance();
    @State mIsMultipleSelectState : boolean = false;
    @State misShowContactHeadIcon : boolean = true;
    private gridColumns: GridRowColumnOption = { sm: 4, md: 8, lg: 12 };
    private girdSpan: GridColColumnOption = { sm: 4, md: 8, lg: 12 };
    private gridGutter: string = "24vp";
    private gridMargin: string = "24vp";
    private dialogGridCount: number = 4;
    private dialogAlignment: DialogAlignment = DeviceUtil.isTablet() ? DialogAlignment.Center : DialogAlignment.Bottom;
    private dialogOffset: Offset = DeviceUtil.isTablet() ? { dx: 0, dy: 0 } : { dx: 0, dy: -12 };
    delDialogController: CustomDialogController = new CustomDialogController({
        builder: DeleteDialog({
            cancel: () => {
                this.mInfoMsgCtrl.delDialogShow = false;
                this.mInfoMsgCtrl.deleteDialogCancel()
            },
            confirm: () => {
                this.mInfoMsgCtrl.delDialogShow = false;
                this.mInfoMsgCtrl.deleteDialogConfirm()
            },
            msg: this.mInfoMsgCtrl.strMsgDeleteDialogTip,
            hasLockMsg: this.mInfoMsgCtrl.hasLockMsg,
            setSelectLock: () => {
                this.mInfoMsgCtrl.setSelectLock()
            },
            isSelectLockMsg: this.mInfoMsgCtrl.isSelectLockMsg,
            setSelectLockChange: (isOn: boolean) => {
                this.mInfoMsgCtrl.setSelectLockChange(isOn)
            }
        }),
        autoCancel: false,
        alignment: this.dialogAlignment,
        offset: this.dialogOffset,
        gridCount: this.dialogGridCount
    })
    @Provide menuItems: Array<any> = [
        {
            value: $r("app.string.delete"),
            action: () => {
                this.mInfoMsgCtrl.selectInMoreMenu(1);
            },
            enabled: true
        }
//        ,
//        {
//            value: $r("app.string.blocked"),
//            action: () => {
//                this.mInfoMsgCtrl.selectInMoreMenu(2);
//            },
//            enabled: true
//        }
    ];

    changeSelectState() {
        this.mIsMultipleSelectState = this.mInfoMsgCtrl.isMultipleSelectState
        this.misShowContactHeadIcon = this.mInfoMsgCtrl.isShowContactHeadIcon
        // @ts-ignore
        this.forceCompleteRerender(true) // recusvise
    }

    /**
     * The function executes after a new instance of the custom component is created and before its build function
     * is executed.
     * Allows state variables to be changed in the aboutToAppear function, and these changes will take effect in
     * subsequent executions of the build function.
     */
    aboutToAppear() {
        this.mInfoMsgCtrl.onInit()
    }
    /**
     * Function executes before custom component destructor consumption.
     * Allow changes to state variables in the aboutToDisappear function, especially changes to the @Link variable,
     * can cause erratic application behavior.
     */
    aboutToDisappear() {
    }
    /**
     * Triggers once when this page is displayed. In scenarios such as routing and application access to the
     * foreground and background, only customized components modified by @Entry take effect.
     */
    onPageShow() {
        this.mInfoMsgCtrl.onShow();
        WantUtil.getWant();
    }
    /**
     * Triggers once when this page disappears. In scenarios such as routing and application access to the foreground
     * and background, only customized components modified by @Entry take effect.
     */
    onPageHide() {
        this.mInfoMsgCtrl.onHide()
    }
    /**
     * Triggered when a user clicks the back button. Only the customized component modified by @Entry takes effect.
     * If true is returned, the page processes the return logic and does not route the page
     * 返If false is returned, the default return logic is used.
     * If no value is returned, the value is treated as false.
     */
    onBackPress() {
        // Key returned by the system. The value true indicates interception.
        if (this.mInfoMsgCtrl.delDialogShow) {
            this.delDialogController.close();
            this.mInfoMsgCtrl.delDialogShow = false;
            return true;
        }
        if (this.mInfoMsgCtrl.isMultipleSelectState) {
            for (let element of this.mInfoMsgCtrl.messageList) {
                element.isCbChecked = false;
            }
            this.mInfoMsgCtrl.isMultipleSelectState = false;
            this.mInfoMsgCtrl.showToolBar = true;
            return true;
        }
        return false;
    }

    build() {
        GridRow({ columns: this.gridColumns, gutter: this.gridGutter }) {
            GridCol({ span: this.girdSpan }) {
                //Notification Information
                Column() {
                    if (this.mIsMultipleSelectState) {
                        //Multi-Select Status Title
                        Flex({ direction: FlexDirection.Column }) {
                            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                                Image($rawfile("icon/ic_public_cancel.svg"))
                                    .width("24vp")
                                    .height("24vp")
                                    .onClick(() => {
                                        this.onBackPress()
                                    })
                                Text(this.mInfoMsgCtrl.conversationSelectedNumber == 0 ?
                                $r("app.string.msg_unselected_tip") :
                                $r("app.string.msg_selected_tip", this.mInfoMsgCtrl.conversationSelectedNumber))
                                    .padding({ left: "16vp" })
                                    .fontSize("20fp")
                                    .fontWeight(FontWeight.Bold)
                            }
                            .height("56vp")
                        }
                        .width("100%")
                        .height("56vp")
                    } else if (!this.mInfoMsgCtrl.searchStatus) {
                        //Header Row
                        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                                Image($rawfile("icon/ic_message_back.svg"))
                                    .width("24vp")
                                    .height("24vp")
                                    .onClick(() => {
                                        this.mInfoMsgCtrl.back()
                                    })
                                Text($r("app.string.infoMessages"))
                                    .padding({ left: "16vp" })
                                    .fontSize("20fp")
                                    .fontWeight(FontWeight.Bold)
                            }
                            .height("56vp")
                        }
                        .width("100%")
                        .height("56vp")
                    }

                    Row() {
                        //Back button
                        if (this.mInfoMsgCtrl.isShowSearchBack) {
                            Image($rawfile("icon/ic_message_back.svg"))
                                .width(24)
                                .height(24)
                                .onClick((event: ClickEvent) => {
                                    this.mInfoMsgCtrl.clickSearchBack();
                                })
                        }
                        //Search box
                        // @ts-ignore
                        Search({ value: this.mInfoMsgCtrl.inputValueOfSearch, placeholder: "搜索通知信息" })
                            .layoutWeight(1)
                            .height("40vp")
                            .border({ radius: "20vp" })
                            .enabled(!this.mIsMultipleSelectState)
                            .backgroundColor($r("sys.color.ohos_id_color_text_field_bg"))
                            .onChange((value: string) => {
                                this.mInfoMsgCtrl.clickToSearch(value);
                            })
                            .onSubmit((value: string) => {
                                this.mInfoMsgCtrl.clickToSearch(value);
                            })
                    }
                    .visibility(Visibility.None)
                    .width("100%")
                    .height("56vp")
                    .padding({ left: 24, right: 24 })
                    .alignItems(VerticalAlign.Center)

                    //SMS message display list
                    Stack({ alignContent: Alignment.Top }) {
                        Column() {
                            List({ initialIndex: 0 }) {
                                if (this.mInfoMsgCtrl.isSearchStatus) {
                                    LazyForEach(this.mInfoMsgCtrl.conversationListDataSource, (item, index) => {
                                        //A real list of information
                                        ListItem() {
                                            MmsListItem({
                                                item: item,
                                                isShowHead: this.misShowContactHeadIcon,
                                                isMultipleSelectState: this.mIsMultipleSelectState,
                                                onClickHead: (event: ClickEvent) => {
                                                    this.mInfoMsgCtrl.clickToGroupDetail(item.index);
                                                },
                                                onClickBody: (event: ClickEvent) => {
                                                    this.mInfoMsgCtrl.clickInfoToConversation(item.index);
                                                },
                                                onItemLongPress: (event: GestureEvent) => {
                                                    this.mInfoMsgCtrl.conversationLongPress(item.index)
                                                },
                                                onTouchStart: (event: GestureEvent) => {
                                                    this.mInfoMsgCtrl.touchStart(event, item.index);
                                                },
                                                onTouchUpdate: (event: GestureEvent) => {
                                                    this.mInfoMsgCtrl.touchMove(event, item.index);
                                                },
                                                onTouchEnd: (event: GestureEvent) => {
                                                    this.mInfoMsgCtrl.touchEnd(event, item.index);
                                                    // @ts-ignore
                                                    this.forceCompleteRerender(true) // recusvise
                                                },
                                                onClickFirstSlipBtn: (event: ClickEvent) => {
                                                    this.mInfoMsgCtrl.markAllAsReadByIndex(item.index);
                                                },
                                                onClickSecondSlipBtn: (event: ClickEvent) => {
                                                    this.mInfoMsgCtrl.deleteAction(item.index);
                                                    this.delDialogController.open();
                                                    this.mInfoMsgCtrl.delDialogShow = true;
                                                }
                                            })
                                        }
                                        .width("100%")
                                        .height("64vp")
                                        .alignSelf(ItemAlign.Start)
                                    }, item => JSON.stringify(item))
                                }
                            }
                            .align(Alignment.Top)
                            .cachedCount(this.mInfoMsgCtrl.limit)
                            .edgeEffect(EdgeEffect.Spring)
                            .width("100%")
                            .divider({
                                strokeWidth: 1,
                                startMargin: this.mInfoMsgCtrl.isShowContactHeadIcon ? 52 : 12,
                                endMargin: 0
                            })
                        }.width("100%")
                        //Search Above
                        //SMS Search Session Item
                        //Left avatar
                        //Information on the right
                        //Name and date above
                        //Details of the information below
                        //intermediate spacing line
                        //Number of barcodes in the search information list
                        //Search Information List
                        //Left avatar
                        //Information on the right
                        //Name and date above
                        //Details of the information below
                        //If there is no session information, that is, {{total}} is 0, a blank image is displayed.
                        //Show Search Status
                        if (this.mInfoMsgCtrl.isSearchCoverage) {
                            //Display of layers for search
                            Flex()
                                .width("100%")
                                .height("100%")
                                .opacity(0.2)
                                .backgroundColor(Color.Gray)
                                .onTouch((event: TouchEvent) => {
                                    if (event.type === TouchType.Down) {
                                        this.mInfoMsgCtrl.searchCoverageClick()
                                    }
                                })
                        }
                    }
                    .flexShrink(1)

                    Blank()

                    //Single session press and hold option
                    if (this.mInfoMsgCtrl.isMultipleSelectState) {
                        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                            //Delete
                            Flex({
                                direction: FlexDirection.Column,
                                justifyContent: FlexAlign.Center,
                                alignItems: ItemAlign.Center
                            }) {
                                Image($rawfile(this.mInfoMsgCtrl.svgDelete))
                                    .width("24vp")
                                    .height("24vp")
                                    .margin({ top: "3vp" })
                                Text($r("app.string.delete"))
                                    .fontSize("10fp")
                                    .fontWeight(FontWeight.Medium)
                                    .fontFamily("HarmonyHeiTi")
                                    .margin({ top: 3 })
                            }
                            .width("50%")
                            .opacity(this.mInfoMsgCtrl.checkSelectedNumberIsEmpty() ? 0.4 : 1)
                            .onClick(() => {
                                if (!this.mInfoMsgCtrl.checkSelectedNumberIsEmpty()) {
                                    this.mInfoMsgCtrl.clickConversationDelete()
                                    this.delDialogController.open()
                                    this.mInfoMsgCtrl.delDialogShow = true;
                                }
                            })
                            //Select All
                            Flex({
                                direction: FlexDirection.Column,
                                justifyContent: FlexAlign.Center,
                                alignItems: ItemAlign.Center
                            }) {
                                Image($rawfile(this.mInfoMsgCtrl.isConversationCheckAll ?
                                    "icon/ic_select_all_filled.svg" :
                                    "icon/ic_select_all.svg"))
                                    .width("24vp")
                                    .height("24vp")
                                    .margin({ top: "3vp" })
                                Text(this.mInfoMsgCtrl.strCheckBoxSelectTip)
                                    .fontSize("10fp")
                                    .fontColor(this.mInfoMsgCtrl.isConversationCheckAll ?
                                    $r("sys.color.ohos_id_color_bottom_tab_text_on") :
                                    $r("sys.color.ohos_id_color_bottom_tab_text_off"))
                                    .fontWeight(FontWeight.Medium)
                                    .fontFamily("HarmonyHeiTi")
                                    .margin({ top: 3 })
                            }
                            .width("50%")
                            .onClick(() => {
                                this.mInfoMsgCtrl.clickConversationCheckAll()
                            })
                        }
                        .width("100%")
                        .height(56)
                        .padding({ left: $r("app.float.menu_layout_padding_left"),
                            right: $r("app.float.menu_layout_padding_right") })
                        .flexBasis(56)
                        .flexShrink(0)
                    }

                    //All read and more
                    if (!this.mInfoMsgCtrl.isMultipleSelectState && this.mInfoMsgCtrl.showToolBar) {
                        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                            //All read
                            Flex({
                                direction: FlexDirection.Column,
                                justifyContent: FlexAlign.Center,
                                alignItems: ItemAlign.Center
                            }) {
                                Image($rawfile("icon/ic_allread.svg"))
                                    .width("24vp")
                                    .height("24vp")
                                    .margin({ top: "3vp" })
                                Text($r("app.string.markAllAsRead"))
                                    .fontSize($r("sys.float.ohos_id_text_size_caption"))
                                    .fontWeight(FontWeight.Medium)
                                    .fontColor($r("sys.color.ohos_id_color_toolbar_text"))
                            }
                            .width("50%")
                            .opacity(this.mInfoMsgCtrl.unreadTotalOfInfo == 0 ? 0.4 : 1)
                            .onClick(() => {
                                this.mInfoMsgCtrl.clickToMarkAllAsReadForInfo()
                            })
                            //more
                            Flex({
                                direction: FlexDirection.Column,
                                justifyContent: FlexAlign.Center,
                                alignItems: ItemAlign.Center
                            }) {
                                MoreMenu({
                                    menuText: $r("app.string.more")
                                })
                            }
                            .width("50%")
                        }
                        .width("100%")
                        .height(56)
                        .padding({ left: $r("app.float.menu_layout_padding_left"),
                            right: $r("app.float.menu_layout_padding_right") })
                        .flexBasis(56)
                        .flexShrink(0)
                    }
                    //Setting the background of the navigation bar
                    //Delete pop-up dialog box
                }
                .width("100%")
                .height("100%")
            }
        }
        .margin({ left: this.gridMargin })
    }
}