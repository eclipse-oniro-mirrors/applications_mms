/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import commonData from '../data/commonData';
import common from '../data/commonData';
import LooseObject from '../data/LooseObject';
import ConversationController from '../pages/conversation/conversationController';
import HiLog from '../utils/HiLog';
import MmsPreferences from '../utils/MmsPreferences';
import MmsUtil from '../utils/MmsUtil';
import ObjectUtil from '../utils/ObjectUtil';
import { TransmitContent, Mms } from '../utils/TypesUtils';
import lazy {
    MMContentAudio,
    MMContentImage,
    MMContentSlideImage,
    MMContentSlideNoImage,
    MMContentVideo,
} from './AttachmentArea/MMContent';
import { MMContentVcard } from './AttachmentArea/MMContentVcard';
import {
    TransmitDialogBottom,
    TransmitDialogTitle,
    TransmitThirdPartDialogBottom,
    TransmitThirdPartDialogTitle
} from './TransmitDialogContent';
import settings from '@ohos.settings';
import Constant from '../data/Constant';
import StringUtil from '../utils/StringUtil';
import { mmsListType } from '../pages/conversation/conversationController';
import FavoriteController from '../pages/favoritepage/favoriteController'
import lazy { SplitScreenManager, SplitInfoModel } from '../utils/SplitScreenManager'
import sim from '@ohos.telephony.sim';
import TransmitMessageUtil from '../utils/TransmitMessageUtils';
import { promptAction } from '@kit.ArkUI';
import DeviceUtil from '../utils/DeviceUtil';
import { MmsContentMap } from './MmsMap/MmsContentMap';

const TAG = 'MmsDialog ';

interface AlertDialogParamWithMmsType {
    value: ResourceStr;
    action: () => void
};
/**
 * Type of the dialog box: No title, 1 message, and 2 buttons
 */
@Component
export struct DeleteDialog {
    controller?: CustomDialogController;
    /**
     * Cancel Event
     */
    cancel: () => void = () => {};
    /**
     * Acknowledge Event
     */
    confirm: () => void = () => {};
    /**
     * Message content
     */
    msg?: string | Resource;
    showDelDialog: string = '';
    mIsMultipleSelectState: boolean = false;
    @State isCheckDialog: boolean = false;
    @Consume show: boolean;
    @Consume index: number;
    @Consume mFavoriteCtrl: FavoriteController;
    @Provide multiSelectFlag: Visibility = Visibility.None;

    build() {
        Column() {
            Text(this.mIsMultipleSelectState ? this.msg : $r('app.string.msg_delete_dialog_tip1'))
                .width('100%')
                .textAlign( TextAlign.Center )
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(22)
                .fontWeight(FontWeight.Medium)
                .fontFamily('HarmonyHeiTi')
        }
        .width('100%')
    }
}






export declare interface AlertDialogParamWithMms {
    message: ResourceStr;
    primaryButton: AlertDialogParamWithMmsType;
    secondaryButton: AlertDialogParamWithMmsType;
}

export interface CheckBoxItem {
    title: string | Resource;
    isOn: boolean;
    onClick: (event?: ClickEvent) => void;
}

const IMAGE_TEXT_TOP_SPACE = 8;
@Component
export struct TransmitMsgDialog {
    @StorageProp('fontSizeScale') fontSizeScale: number = 1;
    private multiSimCardHeight: number | string = '136vp';
    private bottomHeight: number = 136;
    scroller: Scroller = new Scroller()
    controller?: CustomDialogController;
    /**
     * Cancel an event
     */
    cancel: () => void = () => {};
    /**
     * Acknowledgment Events
     */
    confirm: (value: boolean) => void = () => {};
    /**
     * Message content
     */
    msg: LooseObject | null = null;
    @StorageLink('transmitSourceIsChecked') isChecked: boolean = true;
    @StorageLink('defCellularSlotId') @Watch('updateDefCellularSlotId') defCellularSlotId: number = 0;
    @StorageLink('isOnlineRcs') @Watch('updateRcsState') isOnlineRcs: boolean = false;
    @State isCheckedEnabled: boolean = true;
    @State multiSimCard: boolean = MmsPreferences.getInstance().haveMultiSimCardReady();
    @State originContentDetail: string = '';
    @State isTextareaFocusable: boolean = false;
    @State forwardChecked: boolean = true;
    @State mConversationCtrl: ConversationController = ConversationController.getInstance();
    @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding | null = null;
    /* 设备是否开启无障碍屏幕朗读 */
    private accessibilitySwitch: string = Constant.ACCESSIBILITY_SCREEN_READER_SWITCH_CLOSED;
    //分屏通知
    @State @Watch('splitScreenTypeChange') splitInfoModel: SplitInfoModel = SplitScreenManager.getInstance().infoModel;
    @State dialogMaxHeigth: number = 0;
    @StorageLink('isVDEFoldPhoneAndFoldedState') @Watch('onFoldStatusChange')
    isVDEFoldPhoneAndFoldedState: boolean = false;
    @StorageLink('foldStatus') @Watch('getWallpaper') foldStatus: number = 0;
    @State isVDE: boolean = this.isVDEFoldPhoneAndFoldedState && this.foldStatus === 2 ? true : false;
    @State isPC: boolean = DeviceUtil.isPC()

    private onFoldStatusChange(): void {
        if (this.isVDEFoldPhoneAndFoldedState) {
            HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
        } else {
            HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
        }
    }

    getWallpaper() {
        if (this.isVDEFoldPhoneAndFoldedState) {
            HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
            if (this.foldStatus === 2) {
                this.isVDE = true
            } else {
                this.isVDE = false
            }
            HiLog.i(TAG, 'isVDE: ' + this.isVDE);
        } else {
            this.isVDE = false
            HiLog.i(TAG, 'onFoldStatusChange: ' + this.isVDEFoldPhoneAndFoldedState);
        }
    }

    updateDefCellularSlotId(): void{
        return;
    }

    updateRcsState(): void{
        return;
    }

    aboutToAppear() {
        this.dialogMaxHeigth = this.setDialogMaxHeigth() - this.getMultTextDiaLogBottomHeight();
        this.originContentDetail = this.msg?.transmitContentDetail;
        this.accessibilitySwitch = settings.getValueSync(getContext(this), 'accessibility_screenreader_enabled',
            Constant.ACCESSIBILITY_SCREEN_READER_SWITCH_CLOSED);
    }

    aboutToDisappear() {
        this.originContentDetail = '';
    }

    build() {
        Column() {

            // Forwarded content
            if (!this.isPC){
                Column() {
                    Scroll() {
                        Column() {
                            TransmitDialogTitle({ msg: this.msg, isChecked: $isChecked })
                            Column() {
                                if (!this.isChecked) {
                                    TextArea({ text: this.msg?.transmitContentDetail })
                                        .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
                                        .padding(0)
                                        .borderRadius(0)
                                        .focusable(this.isTextareaFocusable)
                                        .onClick(() => {
                                            if (!StringUtil.isEmpty(this.accessibilitySwitch)) {
                                                if (this.accessibilitySwitch ===
                                                Constant.ACCESSIBILITY_SCREEN_READER_SWITCH_OPEN) {
                                                    this.isTextareaFocusable = true;
                                                }
                                            }
                                        })
                                        .onTouch(() => {
                                            if (!StringUtil.isEmpty(this.accessibilitySwitch)) {
                                                if (this.accessibilitySwitch !==
                                                Constant.ACCESSIBILITY_SCREEN_READER_SWITCH_OPEN) {
                                                    this.isTextareaFocusable = true;
                                                }
                                            }
                                        })
                                        .onBlur(() => {
                                            this.isTextareaFocusable = false;
                                        })
                                        .onChange((value) => {
                                            if (value === '') {
                                                this.isCheckedEnabled = false;
                                                this.forwardChecked = false;
                                            } else if (value !== this.originContentDetail) {
                                                this.isCheckedEnabled = true;
                                                this.forwardChecked = false;
                                            } else {
                                                this.isCheckedEnabled = true;
                                                this.forwardChecked = true;
                                            }
                                            this.msg!.transmitContentDetail = value;
                                        })
                                } else {
                                    ForEach(this.msg?.transmitContentList, (item: LooseObject, idx?: number) => {
                                        Row() {
                                            if (this.isChecked) {
                                                Column() {
                                                    if (idx === 0) {
                                                        Text(this.msg?.transmitContent)
                                                            .fontSize($r('sys.float.ohos_id_text_size_body2'))
                                                            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                                                            .margin({ bottom: '2vp' })
                                                    }
                                                    Column({ space: '2vp' }) {
                                                        if (item?.info) {
                                                            Text(item?.info)
                                                                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                                                                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                                                                .margin({ bottom: 2 })
                                                        }
                                                        Text(item.content)
                                                            .fontSize($r('sys.float.ohos_id_text_size_body1'))
                                                            .fontColor($r('sys.color.ohos_id_color_text_primary'))
                                                    }
                                                    .justifyContent(FlexAlign.Start)
                                                    .alignItems(HorizontalAlign.Start)
                                                    .margin({ top: (idx !== 0) ? '16vp' : 0 })
                                                }
                                                .alignItems(HorizontalAlign.Start)
                                            }
                                        }
                                    }, (item: LooseObject) => JSON.stringify(item))
                                }
                            }
                            .width('100%')
                            .borderRadius(this.isPC ? '' : $r('sys.float.corner_radius_level8'))
                            .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
                            .alignItems(HorizontalAlign.Start)
                            .constraintSize({ minWidth: 10, maxWidth: '100%' })
                            .padding({
                                right: 12,
                                left: 12,
                                top:  8,
                                bottom: 8
                            })
                        }
                    }
                    .scrollBar(BarState.Off)
                    .border({
                        radius: { topLeft: 2, topRight: 16, bottomLeft: 16, bottomRight: 16 }
                    })
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')
                .padding({ left: 24, right: 24 })
                .constraintSize(this.isVDE ? { maxHeight: '25%' } : { maxHeight: '50%' })
            } else {
                Column() {
                    Scroll() {
                        Column() {
                            TransmitDialogTitle({ msg: this.msg, isChecked: $isChecked })
                            Column() {
                                TextArea({ text: this.msg?.transmitContentDetail })
                                    .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
                                    .padding(0)
                                    .borderRadius(0)
                                    .focusable(this.isTextareaFocusable)
                                    .onClick(() => {
                                        if (!StringUtil.isEmpty(this.accessibilitySwitch)) {
                                            if (this.accessibilitySwitch ===
                                            Constant.ACCESSIBILITY_SCREEN_READER_SWITCH_OPEN) {
                                                this.isTextareaFocusable = true;
                                            }
                                        }
                                    })
                                    .onTouch(() => {
                                        if (!StringUtil.isEmpty(this.accessibilitySwitch)) {
                                            if (this.accessibilitySwitch !==
                                            Constant.ACCESSIBILITY_SCREEN_READER_SWITCH_OPEN) {
                                                this.isTextareaFocusable = true;
                                            }
                                        }
                                    })
                                    .onBlur(() => {
                                        this.isTextareaFocusable = false;
                                    })
                                    .onChange((value) => {
                                        if (value === '') {
                                            this.isCheckedEnabled = false;
                                            this.forwardChecked = false;
                                        } else if (value !== this.originContentDetail) {
                                            this.isCheckedEnabled = true;
                                            this.forwardChecked = false;
                                        } else {
                                            this.isCheckedEnabled = true;
                                            this.forwardChecked = true;
                                        }
                                        this.msg!.transmitContentDetail = value;
                                    })
                                    .visibility(this.isChecked ? Visibility.None : Visibility.Visible)
                                ForEach(this.msg?.transmitContentList, (item: LooseObject, idx?: number) => {
                                    Row() {
                                        Column() {
                                            if (idx === 0) {
                                                Text(this.msg?.transmitContent)
                                                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                                                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                                                    .margin({ bottom: '2vp' })
                                            }
                                            Column({ space: '2vp' }) {
                                                if (item?.info) {
                                                    Text(item?.info)
                                                        .fontSize($r('sys.float.ohos_id_text_size_body2'))
                                                        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                                                        .margin({ bottom: 2 })
                                                }
                                                Text(item.content)
                                                    .fontSize($r('sys.float.ohos_id_text_size_body1'))
                                                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                                            }
                                            .justifyContent(FlexAlign.Start)
                                            .alignItems(HorizontalAlign.Start)
                                            .margin({ top: (idx !== 0) ? '16vp' : 0 })
                                        }
                                        .alignItems(HorizontalAlign.Start)
                                    }.justifyContent(FlexAlign.Start)
                                    .visibility(this.isChecked ? Visibility.Visible : Visibility.None)
                                }, (item: LooseObject) => JSON.stringify(item))
                            }
                            .width('100%')
                            .borderRadius('')
                            .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
                            .alignItems(HorizontalAlign.Start)
                            .justifyContent(FlexAlign.Start)
                            .padding({
                                right: 12,
                                left: 12,
                                top: 8,
                                bottom: 8
                            })
                            .border({
                                radius: { topLeft: 2, topRight: 16, bottomLeft: 16, bottomRight: 16 }
                            })
                        }.alignItems(HorizontalAlign.Start)
                        .justifyContent(FlexAlign.Start)
                        .padding({ left: 24, right: 24 })
                    }
                    .scrollBar(BarState.Off)
                    .width('auto')
                }
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Start)
                .width('100%')
                .constraintSize(this.isVDE ? { maxHeight: '25%' } : { maxHeight: '50%' })
            }


            Row() {
                Checkbox()
                    .enabled(this.isCheckedEnabled && this.forwardChecked ? true : false)
                    .select(this.isChecked)
                    .onChange((value: boolean) => {
                        this.isChecked = value;
                        AppStorage.SetOrCreate('transmitSourceIsChecked', value);
                    })
          .width('20vp')
          .height('20vp')
          .margin('2vp')
                Text($r('app.string.showSource'))
                    .fontColor($r('sys.color.font_primary'))
                    .fontSize($r('sys.float.Subtitle_S'))
                    .fontWeight(FontWeight.Regular)
                    .margin({ left: 12, right: 8 })
                    .opacity(this.isCheckedEnabled && this.forwardChecked? 1 : 0.3)
                    .maxFontScale(2)
            }
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .constraintSize({ minHeight: 48 })
            .width('100%')
            .margin({ top: this.isPC ? '' : 8 })
            .enabled(this.isCheckedEnabled && this.forwardChecked ? true : false)
            .onClick(() => {
                this.isChecked = !this.isChecked;
                AppStorage.SetOrCreate('transmitSourceIsChecked', this.isChecked);
            })
            .visibility(this.splitInfoModel.isSmall ? Visibility.None : Visibility.Visible)
            .padding({ left: 24, right: 24 })

            TransmitDialogBottom({
                isCheckedEnabled: $isCheckedEnabled,
                multiSimCard: this.mConversationCtrl.isAllCardActive,
                cancel: () => {
                  this.msg!.transmitContentDetail = this.originContentDetail;
                  this.controller?.close();
                  this.cancel();
                },
                simCardClick: (value) => {
                    HiLog.i(TAG, 'simCardClick defCellularSlotId: ' + this.defCellularSlotId + 'value: ' + value)
                    let isSlotIdChange = false;
                    if(this.defCellularSlotId + 1 == value && this.isOnlineRcs){
                        this.mConversationCtrl.changeIsRcsMms(true, isSlotIdChange);
                    }else{
                        this.mConversationCtrl.changeIsRcsMms(false, isSlotIdChange);
                    }
                    HiLog.i(TAG, 'simCardClick isRcsMms: ' + this.mConversationCtrl.isRcsMms);
                    if (value === 1) {
                        HiLog.i(TAG, `Transmit simCardClick, set KEY_OF_SELECTED_SLOTID SIM_ONE`);
                        MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SELECTED_SLOTID, common.int.SIM_ONE);
                        AppStorage.setOrCreate('simSlotId',common.int.SIM_ONE);
                    } else {
                        HiLog.i(TAG, `Transmit simCardClick, set KEY_OF_SELECTED_SLOTID SIM_TWO`);
                        MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SELECTED_SLOTID, common.int.SIM_TWO);
                        AppStorage.setOrCreate('simSlotId',common.int.SIM_TWO);
                    }
                    this.controller?.close();
                    this.confirm(this.isChecked);
                },
                confirm: () => {
                  this.controller?.close();
                  this.confirm(this.isChecked);
                }
            })
                .margin({ top: this.isPC ? 16 : 8, bottom: 16 })
        }
        .width('100%')
  }
  setDialogMaxHeigth():number {
      let windowHeight: number = SplitScreenManager.getInstance().fullScreenHeightVP;
      let dialogHeight: number = 0;
    if (windowHeight) {
      dialogHeight = windowHeight -
      this.getTopHeigth() -
      this.getBottomHeigth()
    }
    return dialogHeight * 0.9;
  }
  getTopHeigth() {
    let topHeight: number = this.fullScreenPadding ? (this.fullScreenPadding.top as number) : 0;
    return topHeight;
  }
  getBottomHeigth() {
    let bottomHeight: number = this.fullScreenPadding ? (this.fullScreenPadding.bottom as number) : 0;
    return bottomHeight;
  }

    getMultTextDiaLogBottomHeight() {
        let checkBoxHeight: number = this.fontSizeScale > 1.75 ? this.fontSizeScale * 48 : 48;
        let buttonHeight: number = (this.fontSizeScale > 1 && this.mConversationCtrl.isAllCardActive) ?
        this.bottomHeight : 40;
        let paddingHeight: number = 32;
        let titleHeight: number = 80;
        if (this.splitInfoModel.isSmall) {
            return buttonHeight + paddingHeight + titleHeight;
        } else {
            return checkBoxHeight + buttonHeight + paddingHeight + titleHeight;
        }
  }

    splitScreenTypeChange() {
        this.dialogMaxHeigth = this.setDialogMaxHeigth() - this.getMultTextDiaLogBottomHeight();
    }

}


class menuItemsObj{
    value?: ResourceStr
    action: () => void = () => {}
    enabled: boolean = false
}
@Component
export struct ResendDialogRcs {
    controller?: CustomDialogController;
    /**
     * Cancel Event
     */
    cancel: () => void = () => {};
    /**
     * Acknowledge Event
     */
    confirm: () => void = () => {};
    /**
     * Message content
     */
    msg?: string | Resource;
    /**
     * Message resend
     */
    // resend: () => void = () => {};

    @Consume menuItemsResendRcs:Array<menuItemsObj>;
    build() {
        Column() {
            List() {
                ForEach(this.menuItemsResendRcs, (item: menuItemsObj, index?: number) => {
                    ListItem() {
                        Button({ type: ButtonType.Normal, stateEffect: item.enabled }) {
                            Text(item.value)
                                .fontSize($r('sys.float.Body_L'))
                                .lineHeight(21)
                                .width('100%')
                                .padding({ left: 12, right: 12 })
                                .fontWeight(FontWeight.Regular)
                                .fontColor(item.enabled ? $r('sys.color.font_primary') :
                                $r('sys.color.font_tertiary'))
                        }
                        .width('100%')
                        .constraintSize({ minHeight: 48 })
                        .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
                        .backgroundColor(Color.Transparent)
                        .onClick(() => {
                            if (item.enabled) {
                                item.action();
                            }
                        })
                    }
                }, (item: menuItemsObj) => JSON.stringify(item))
            }
            .listDirection(Axis.Vertical) // Arrange Direction
            .divider({
                strokeWidth: $r('app.float.settings_divider_strokeWidth'),
                color: $r('sys.color.comp_divider'),
                startMargin: 12,
                endMargin: 12
            }) // Demarcation line between each row
            .edgeEffect(EdgeEffect.Spring) // Slide to Edge Effect
            .chainAnimation(false)
        }
        .width('100%')
        .padding({ left: 12, right: 12 })
    }
}

@Component
export struct TransmitMmsDialog {
    @StorageProp('fontSizeScale') fontSizeScale: number = 1;
    private multiSimCardHeight: number | string = '136vp';
    private bottomHeight: number = 136;
    scroller: Scroller = new Scroller()
    controller?: CustomDialogController;
    cancel: () => void = () => {};
    confirm: (value: boolean, isTransmit: boolean) => void = () => {};
    msg: LooseObject | null = null;
    @StorageLink('transmitSourceIsChecked') isChecked: boolean = true;
    @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding | null = null;
    @State isCheckedEnabled: boolean = true;
    @State multiSimCard: boolean = MmsPreferences.getInstance().haveMultiSimCardReady();
    @State isTextareaFocusable: boolean = false;
    @State forwardChecked: boolean = true;
    @State originContentDetail: Record<number, string> = {};
    @State contentDetail: Record<number, string> = {};
    @State isTouch: boolean = false;
    videoHeight: number = 114;
    isFromTransmit: boolean = true;
    @State mConversationCtrl: ConversationController = ConversationController.getInstance();
    @Prop isRcs: boolean = false
    @Consume show: boolean;
    @Consume index: number;
    @Consume mFavoriteCtrl: FavoriteController;
    @Provide multiSelectFlag: Visibility = Visibility.None;

    /*
            监听rcs开关状态 和 当前默认流量卡
         */
    @StorageLink('defCellularSlotId') @Watch('updateDefCellularSlotId') defCellularSlotId: number = 0;
    @StorageLink('isOnlineRcs') @Watch('updateRcsState') isOnlineRcs: boolean = false;

    updateDefCellularSlotId(): void{
        return;
    }

    updateRcsState(): void{
        return;
    }
    aboutToAppear() {
        HiLog.i(TAG, 'aboutToAppear');
        this.contentDetail = this.msg?.transmitContentDetail;
        this.originContentDetail = ObjectUtil.getCopyObject(this.msg?.transmitContentDetail) as Record<number, string>;
    }

    // Check whether there is an SMS message before the index.
    hasMsgBefore(idx: number) {
        HiLog.i(TAG, 'hasMsgBefore');
        let hasMsg: boolean = false;
        for (let index = 0; index < idx; index ++) {
            let msgItem: TransmitContent | Array<TransmitContent> = this.msg?.transmitContentList[index];
            if (msgItem instanceof Array) {
                hasMsg = true;
                break;
            }
        }
        return hasMsg;
    }

    // Set the modified SM content.
    setMsgContent(msgItem: LooseObject, value: string, index: number) {
        HiLog.i(TAG, 'setMsgContent');
        msgItem.content = value;
        if (Object.values(this.contentDetail).length === 0) {
            this.contentDetail[index] = value;
        } else {
            let content = this.contentDetail[index];
            if (content) {
                content = value;
            }
            this.contentDetail[index] = value;
        }
    }

    isMultipleMms() {
        HiLog.i(TAG, 'isMultipleMms');
        let count: number = 0;
        if (this.msg && this.msg.transmitContentList && this.msg.transmitContentList.length > 0) {
            for (let index = 0; index < this.msg.transmitContentList.length; index ++) {
                const element: TransmitContent | Array<TransmitContent> = this.msg.transmitContentList[index];
                if (!(element instanceof Array)) {
                    if (element.mms && element.mms.length > 0) {
                        count ++;
                    }
                    if (count >= 2) {
                        break;
                    }
                }
            }
        }
        // Check whether the value of MMS data is greater than 1.
        // The fee notification box is displayed when the value is greater than 1.
        if (count > 1) {
            let msg: ResourceStr = '';
            if (this.msg?.contactsParam.contactsNum > 1) {
                msg = $r('app.string.contentSentTo', this.msg?.contactsParam.contactName == '' ?
                this.msg?.contactsParam.telephoneFormatSplit :
                this.msg?.contactsParam.contactNameSplit, this.msg?.contactsParam.contactsNum.toString())
            } else {
                msg = $r('app.string.transmit_expenses_info', this.msg?.contactsParam.contactName == '' ?
                this.msg?.contactsParam.telephoneFormat : this.msg?.contactsParam.contactName)
            }
            this.showExpensesDialog(msg);
        } else {
            this.confirm(this.isChecked, true);
        }
    }

    showExpensesDialog(msg: ResourceStr) {
        HiLog.i(TAG, 'showExpensesDialog');
        AlertDialog.show(
            {
                message: msg,
                autoCancel: false,
                alignment: DialogAlignment.Bottom,
                offset: { dx: 0, dy: -16 },
                gridCount: 4,
                primaryButton: {
                    value: $r('app.string.cancel'),
                    fontColor: $r('sys.color.font_emphasize'),
                    action: () => {
                        HiLog.i(TAG, 'click cancel');
                    }
                },
                textStyle: {
                    wordBreak: WordBreak.BREAK_WORD
                },
                secondaryButton: {
                    value: $r('app.string.transmit_send'),
                    fontColor: $r('sys.color.font_emphasize'),
                    action: () => {
                        HiLog.i(TAG, 'click send');
                        this.confirm(this.isChecked, true);
                    }
                }
            }
        )
    }

    aboutToDisappear() {
    }

    build() {
        Column() {
          Column() {
            // Title
            TransmitDialogTitle({ msg: this.msg, isChecked: $isChecked })

            // Forwarded content
            Column() {
                Scroll() {
                    Column() {
                        ForEach(this.msg?.transmitContentList, (item: TransmitContent | Array<TransmitContent>, idx: number) => {
                            if (item instanceof Array) {
                                Column() {
                                    if (!this.isChecked) {
                                        TextArea({ text: this.contentDetail[idx] })
                                            .backgroundColor($r('sys.color.ohos_id_color_background'))
                                            .padding(0)
                                            .borderRadius(0)
                                            .focusable(this.isTextareaFocusable)
                                            .onTouch(() => {
                                                this.isTextareaFocusable = true;
                                            })
                                            .onBlur(() => {
                                                this.isTextareaFocusable = false;
                                            })
                                            .onChange((value) => {
                                                if (value === '') {
                                                    this.isCheckedEnabled = false;
                                                    this.forwardChecked = false;
                                                } else if (value !== this.originContentDetail[idx]) {
                                                    this.isCheckedEnabled = true;
                                                    this.forwardChecked = false;
                                                } else {
                                                    this.isCheckedEnabled = true;
                                                    this.forwardChecked = true;
                                                }
                                                this.setMsgContent(item, value, idx);
                                            })
                                    } else {
                                        ForEach(item, (subItem: TransmitContent, index) => {
                                            Column() {
                                                if (index === 0 && !this.hasMsgBefore(idx)) {
                                                    Text(this.msg?.transmitContent)
                                                        .fontSize($r('sys.float.Body_M'))
                                                        .fontColor($r('sys.color.font_secondary'))
                                                        .margin({ bottom: 2 })
                                                }
                                                Column() {
                                                    if (subItem?.info) {
                                                        Text(subItem?.info)
                                                            .fontSize($r('sys.float.Body_M'))
                                                            .fontColor($r('sys.color.font_secondary'))
                                                    }
                                                    Text(subItem.content)
                                                        .fontSize($r('sys.float.Body_L'))
                                                        .fontColor($r('sys.color.font_primary'))
                                                        .margin({ top: (subItem?.info && subItem?.info.length !== 0) ? 2 : 0 })
                                                }
                                                .justifyContent(FlexAlign.Start)
                                                .alignItems(HorizontalAlign.Start)
                                                .margin({ top: (index !== 0) ? '24vp' : 0 })
                                            }
                                            .alignItems(HorizontalAlign.Start)
                                        })
                                    }
                                }
                                .alignItems(HorizontalAlign.Start)
                                .constraintSize({ minWidth: 10, maxWidth: '100%' })
                                .padding({ right: 12, left: 12, top: 8, bottom: 8 })
                                .backgroundColor($r('sys.color.background_primary'))
                                .border({
                                    radius: { topLeft: 2, topRight: 16, bottomLeft: 16, bottomRight: 16 }
                                })
                                .margin({ bottom: (idx === this.msg?.transmitContentList.length - 1) ? 0 : 8 })
                            } else {
                                Column() {
                                    if (item?.mms && item?.mms.length > 0 &&
                                        item?.contentType === commonData.MMS_CONTENT_TYPE.ORIGIN) {
                                        if (MmsUtil.isImage(item?.mms[0].type)) {
                                            MMContentImage({
                                                item: item?.mms[0],
                                                isFromTransmit: this.isFromTransmit,
                                                isTouch: $isTouch,
                                                isPop:true
                                            })
                                                .width('84vp')
                                              .height('64vp')
                                        } else if (MmsUtil.isVideo(item?.mms[0].type)) {
                                            MMContentVideo({
                                                item: item?.mms[0],
                                                isFromTransmit: this.isFromTransmit
                                            })
                                        } else if (MmsUtil.isAudio(item?.mms[0].type)) {
                                            MMContentAudio({
                                                item: item?.mms[0],bubbleTextDirection: 'right',
                                            })
                                                .width(84)
                                        } else if (MmsUtil.isVcard(item?.mms[0].type)) {
                                            MMContentVcard({
                                                item: item?.mms[0],
                                                bubbleTextDirection: 'left',
                                                mmsContentBackgroundColor:$r('sys.color.background_primary'),
                                                isFromTransmit: this.isFromTransmit
                                            })
                                        } else if (item?.mms && !item.isRcs && item.mms.length === 2 &&
                                        [item.mms[0]?.type, item.mms[1]?.type].includes(
                                          commonData.MM_ATTACHMENT_TYPE.MAP)) { //彩信位置消息
                                            MmsContentMap({
                                                isCallFrom: 'MmsDialogs',
                                                mmsItem: item,
                                                bubbleTextDirection: 'left',
                                                bubbleTextBackgroundColor: $r('sys.color.background_primary'),
                                                isFromTransmit: this.isFromTransmit,
                                                bubbleTextBorderRadius: [2, 16],
                                                mmsMapCardWidth: '100%'
                                            })
                                        }
                                        if (item?.mms.length == 2 && MmsUtil.isText(item?.mms[1].type) &&
                                            !MmsUtil.isMap(item?.mms[0].type)) { //彩信位置消息不展示Text
                                            Column() {
                                                Text(item.content)
                                                    .fontSize($r('sys.float.Body_M'))
                                                    .fontColor($r('sys.color.font_secondary'))
                                                    .margin({ bottom: 2 })
                                            }
                                            .alignItems(HorizontalAlign.Start)
                                            .constraintSize({ minWidth: 10, maxWidth: '100%' })
                                            .padding({ right: 12, left: 12, top: 8, bottom: 8 })
                                            .backgroundColor($r('sys.color.background_primary'))
                                            .border({
                                                radius: { topLeft: 2, topRight: 16, bottomLeft: 16, bottomRight: 16 }
                                            })
                                            .margin({
                                                bottom: (idx ===
                                                    this.msg?.transmitContentList.length - 1) ? 0 :
                                                    IMAGE_TEXT_TOP_SPACE,
                                                top: IMAGE_TEXT_TOP_SPACE
                                            })
                                        }
                                    } else if (item?.mms && item?.mms.length > 0 &&
                                        item?.contentType === commonData.MMS_CONTENT_TYPE.SLIDE_CONTAINS_IMAGE) {
                                        MMContentSlideImage({
                                            isFromTransmit: this.isFromTransmit,
                                            slideFirstItemTransmit: item.slideFirstItemTransmit,
                                            msgTitleTransmit: item.msgTitleTransmit
                                        })
                                    } else if (item?.mms && item?.mms.length > 0 &&
                                        item?.contentType === commonData.MMS_CONTENT_TYPE.SLIDE_NO_IMAGE ||
                                        item.msgTitleTransmit) {
                                        MMContentSlideNoImage({
                                            item: item?.mms?.[0],
                                            isWhite: true,
                                            isLeft: true,
                                            isFromTransmit: this.isFromTransmit,
                                            slideFirstItemTransmit: item.slideFirstItemTransmit,
                                            msgTitleTransmit: item.msgTitleTransmit
                                        })
                                    }
                                    if (item?.mms && item?.mms.length === 0 && item?.content !== '') {
                                        Text(item?.content)
                                            .fontColor($r('sys.color.font_primary'))
                                            .fontSize($r('sys.float.Subtitle_S'))
                                            .fontWeight(FontWeight.Regular)
                                            .margin({ top: 8, left: 8 })
                                    }
                                }
                                .justifyContent(FlexAlign.Start)
                                .alignItems(HorizontalAlign.Start)
                                .width('100%')
                                .margin({
                                    bottom: (idx === this.msg?.transmitContentList.length - 1) ? 0 : 8
                                })
                            }
                        })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .border({
                      radius: { topLeft: 2, topRight: 16, bottomLeft: 16, bottomRight: 16 }
                    })
                }
                .scrollBar(BarState.Off)
            }
            .constraintSize({ maxHeight: this.setDialogMaxHeigth() - this.getMultTextDiaLogBottomHeight()})
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            if (TransmitMessageUtil.transmitCanAddSource(this.msg)) {
                Row() {
                    Checkbox()
                        .select(this.isChecked)
                        .onChange((value: boolean) => {
                            this.isChecked = value;
                            AppStorage.setOrCreate('transmitSourceIsChecked', value);
                        })
            .width('20vp')
            .height('20vp')
            .margin('2vp')
                    Text($r('app.string.showSource'))
                        .fontColor($r('sys.color.font_primary'))
                        .fontSize($r('sys.float.Subtitle_S'))
                        .fontWeight(FontWeight.Regular)
                        .margin({ left: 12, right: 8 })
                        .maxFontScale(2)
                }
                .justifyContent(FlexAlign.Start)
                .alignItems(VerticalAlign.Center)
                .constraintSize({ minHeight: 48 })
                .width('100%')
                .margin( { top: 8 })
                .onClick(() => {
                    this.isChecked = !this.isChecked;
                    AppStorage.setOrCreate('transmitSourceIsChecked', this.isChecked);
                })
            }
          }.margin({ right: 24, left: 24 })
            TransmitDialogBottom({
                isCheckedEnabled: $isCheckedEnabled,
                multiSimCard: this.mConversationCtrl.isAllCardActive,
                cancel: () => {
                    this.controller?.close();
                    this.cancel();
                },
                simCardClick: (value) => {
                    /*
                    * 判断当前卡支不支持rcs，如果不支持，直接提示，否则正常转发
                     */
                    HiLog.i(TAG, 'simCardClick defCellularSlotId: ' + this.defCellularSlotId + 'value: ' + value)
                    if (this.getIsOnlyRcsType(value)) {
                        if (this.defCellularSlotId + 1 == value && this.isOnlineRcs) {
                            if (value === 1) {
                                HiLog.i(TAG, `OnlineRcs simCardClick, set KEY_OF_SELECTED_SLOTID SIM_ONE`);
                                MmsPreferences.getInstance()
                                    .setValueToMap(common.STR.KEY_OF_SELECTED_SLOTID, common.int.SIM_ONE);
                            } else {
                                HiLog.i(TAG, `OnlineRcs simCardClick, set KEY_OF_SELECTED_SLOTID SIM_TWO`);
                                MmsPreferences.getInstance()
                                    .setValueToMap(common.STR.KEY_OF_SELECTED_SLOTID, common.int.SIM_TWO);
                            }
                            if (this.isRcs) {
                                this.confirm(this.isChecked, true);
                            } else {
                                this.isMultipleMms();
                            }
                            this.controller?.close();
                        } else {
                            let msg: Resource = $r('app.string.audio_play_error');
                            this.showToast({
                                message: msg,
                                duration: 3000
                            });
                            this.controller?.close();
                            this.confirm(this.isChecked, false);
                        }
                    } else {
                        if (value === 1) {
                            HiLog.i(TAG, `NoOnlyRcsType simCardClick, set KEY_OF_SELECTED_SLOTID SIM_ONE`);
                            MmsPreferences.getInstance()
                                .setValueToMap(common.STR.KEY_OF_SELECTED_SLOTID, common.int.SIM_ONE);
                        } else {
                            HiLog.i(TAG, `NoOnlyRcsType simCardClick, set KEY_OF_SELECTED_SLOTID SIM_TWO`);
                            MmsPreferences.getInstance()
                                .setValueToMap(common.STR.KEY_OF_SELECTED_SLOTID, common.int.SIM_TWO);
                        }
                        this.controller?.close();
                        if (this.isRcs) {
                            this.confirm(this.isChecked, true);
                        } else {
                            this.isMultipleMms();
                        }
                    }
                },
                confirm: () => {
                    this.controller?.close();
                    if (this.isRcs) {
                        this.confirm(this.isChecked, true);
                    } else {
                        this.isMultipleMms();
                    }
                }
            })
                .margin({ top: 8, bottom: 16 })
        }
        .width('100%')
        .constraintSize({ maxHeight: this.setDialogMaxHeigth()})
    }

    getIsOnlyRcsType(value: number): boolean {
        HiLog.i(TAG, `getIsOnlyRcsType + select simCard number: ` + value);
        let isTrasmit: boolean = false;
        if (this.msg === null || this.msg.transmitContentList === null) {
            return false;
        }
        let mmsList: LooseObject[] = [];
        for (let i = 0; i < this.msg.transmitContentList.length; i++) {
            let transmitContent: LooseObject = this.msg.transmitContentList[i];
            if (transmitContent instanceof Array) {
                mmsList.push(transmitContent)
            } else if (transmitContent?.isRcs && transmitContent.mms &&
                (transmitContent.mms[0]?.type === commonData.ENHANCED_INFO_ITEM_TYPE.FILE ||
                    transmitContent.mms[1]?.type === commonData.ENHANCED_INFO_ITEM_TYPE.FILE ||
                    transmitContent.mms[0]?.type === commonData.ENHANCED_INFO_ITEM_TYPE.MAP ||
                    transmitContent.mms[1]?.type === commonData.ENHANCED_INFO_ITEM_TYPE.MAP ||
                    transmitContent.mms[0]?.type === commonData.ENHANCED_INFO_ITEM_TYPE.VCARD ||
                    transmitContent.mms[1]?.type === commonData.ENHANCED_INFO_ITEM_TYPE.VCARD
                )) {
                if (this.defCellularSlotId + 1 == value && this.isOnlineRcs) {
                    mmsList.push(transmitContent)
                } else {
                    HiLog.i(TAG, `transmit Content has rcs type message : ` + transmitContent.mms[0]?.type);
                }
            } else {
                mmsList.push(transmitContent)
            }

        }
        if (mmsList.length === 0) {
            isTrasmit = true;
        } else {
            isTrasmit = false;
        }
        return isTrasmit;
    }
    /*
    * toast 提示
     */
    showToast(options: promptAction.ShowToastOptions) {
        try {
            promptAction.showToast(options);
        } catch (err) {
            HiLog.e(TAG, `showToast error: ${err}`);
        }
    }

    setDialogMaxHeigth():number {
        let windowHeight = AppStorage.get('windowHeight') as number;
        let dialogHeight : number = 0;
        if (windowHeight) {
          dialogHeight = windowHeight -
          this.getTopHeigth() -
          this.getBottomHeigth()
        }
        return dialogHeight * 0.9;
      }
      getTopHeigth() {
        let topHeight: number = this.fullScreenPadding ? (this.fullScreenPadding.top as number) : 0;
        return topHeight;
      }
      getBottomHeigth() {
        let bottomHeight: number = this.fullScreenPadding ? (this.fullScreenPadding.bottom as number) : 0;
        return bottomHeight;
      }
    
        getMultTextDiaLogBottomHeight() {
            let checkBoxHeight: number = this.fontSizeScale > 1.75 ? this.fontSizeScale * 48 : 48;
            let buttonHeight: number = (this.fontSizeScale > 1 && this.mConversationCtrl.isAllCardActive) ?
            this.bottomHeight : 40;
            let paddingHeight:number = 32;
            let titleHeight:number = 80;
            return checkBoxHeight + buttonHeight + paddingHeight + titleHeight;
      }
}


@Component
export struct TransmitThirdPartMsgDialog {
    scroller: Scroller = new Scroller()
    controller?: CustomDialogController;
    /**
     * Cancel an event
     */
    cancel: () => void = () => {};
    /**
     * Acknowledgment Events
     */
    confirm: (value: boolean) => void = () => {};
    /**
     * Message content
     */
    msg: LooseObject | null = null;
    @StorageLink('transmitSourceIsChecked') isChecked: boolean = true;
    @State isCheckedEnabled: boolean = true;
    @State multiSimCard: boolean = MmsPreferences.getInstance().haveMultiSimCardReady();
    @State mConversationCtrl: ConversationController = ConversationController.getInstance();
    @State originContentDetail: string = '';
    @State isTextareaFocusable: boolean = false;
    @State forwardChecked: boolean = true;

    aboutToAppear() {
        this.originContentDetail = this.msg?.transmitContentDetail;
        let isCardOneActive: boolean = sim.isSimActiveSync(common.int.SIM_ONE);
        let isCardTwoActive: boolean = sim.isSimActiveSync(common.int.SIM_TWO);
        if (!isCardOneActive || !isCardTwoActive) {
            this.multiSimCard = false
        }
    }

    aboutToDisappear() {
        this.originContentDetail = '';
    }

    build() {
        Column() {
            Column() {
                // Title
                TransmitThirdPartDialogTitle({ msg: this.msg, isChecked: $isChecked })
            }.margin({top: 24, left: 24, right: 24, bottom: 8})

            Column() {

                TransmitThirdPartDialogBottom({
                    isCheckedEnabled: $isCheckedEnabled,
                    multiSimCard: this.multiSimCard,
                    cancel: () => {
                        this.msg!.transmitContentDetail = this.originContentDetail;
                        this.controller?.close();
                        this.cancel();
                    },
                    simCardClick: (value) => {
                        if (value === 1) {
                            HiLog.i(TAG, `TransmitThirdPart simCardClick, set KEY_OF_SELECTED_SLOTID SIM_ONE`);
                            MmsPreferences.getInstance()
                                .setValueToMap(common.STR.KEY_OF_SELECTED_SLOTID, common.int.SIM_ONE);
                        } else {
                            HiLog.i(TAG, `TransmitThirdPart simCardClick, set KEY_OF_SELECTED_SLOTID SIM_TWO`);
                            MmsPreferences.getInstance()
                                .setValueToMap(common.STR.KEY_OF_SELECTED_SLOTID, common.int.SIM_TWO);
                        }
                        this.controller?.close();
                        this.confirm(this.isChecked);
                    },
                    confirm: () => {
                        this.controller?.close();
                        this.confirm(this.isChecked);
                    }
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
        }
    }
}

@CustomDialog
export struct AudioPrompts {
    controller?: CustomDialogController
    @Link isResumeSend: boolean;
    @Consume('conversation_rcs_recordDuration') recordDuration: number;
    @StorageProp('fontSizeScale') fontSizeScale: number = 1;

    build() {
        Column() {
            if (this.isResumeSend) {
                SymbolGlyph($r('sys.symbol.mic_badge_xmark'))
                    .fontColor([$r('sys.color.white')])
                    .width(60).height(60).fontSize('60vp')
                    .draggable(false)
            } else {
              Row() {
                Text((common.int.RCS_RECORD_MAX_DURATION - this.recordDuration).toString())
                  .fontSize('50vp')
                  .width(60).height(60)
                  .fontColor($r('sys.color.font_on_primary'))
                  .fontWeight(FontWeight.Regular).fontFamily('HarmonyHeiTi')
                  .textAlign(TextAlign.Center)
              }
              .visibility((this.recordDuration >= common.int.RCS_RECORD_START_COUNTDOWN) ? Visibility.Visible :
              Visibility.None)
              Row() {
                  SymbolGlyph($r('sys.symbol.mic'))
                  .width(32).height(32).fontSize('32vp')
                  .draggable(false)
              }
              .width(60).height(60)
              .borderRadius(50)
              .backgroundColor($r('sys.color.ohos_id_color_floating_button_icon'))
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Center)
              .visibility((this.recordDuration >= common.int.RCS_RECORD_START_COUNTDOWN) ? Visibility.None :
              Visibility.Visible)
            }
            Row() {
                Text(this.isResumeSend ? $r('app.string.slide_down_text') : $r('app.string.slide_up_text'))
                    .fontSize(Math.min(this.fontSizeScale, 2) * 14 + 'vp')
                    .fontColor($r('sys.color.font_on_primary'))
                    .fontWeight(FontWeight.Regular).fontFamily('HarmonyHeiTi')
                    .margin({ top: 16 })
            }
        }
        .padding(16)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('sys.color.ohos_id_color_secondary'))
        .borderRadius($r('sys.float.corner_radius_level12'))
    }
}