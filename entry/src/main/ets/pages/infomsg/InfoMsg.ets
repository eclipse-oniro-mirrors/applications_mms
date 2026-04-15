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
/*
 * 1 Aggregate and display some marketing information
 *
 * */
import DeviceUtil from '../../utils/DeviceUtil';
import InfoMsgController from './InfoMsgController';
import { DeleteDialog } from '../../views/MmsDialogs';
import { MmsListItem } from '../../views/MmsListItem';
import { MoreMenu } from '../../views/MmsMenu';
import WantUtil from '../../utils/WantUtil';
import HiLog from '../../utils/HiLog';
import MmsPreferences from '../../utils/MmsPreferences';
import common from '../../data/commonData';
import ConListController, { messageType } from '../conversationlist/conversationListController';
import dotCommon, { longPressDeParams, stateParam } from '../../utils/MmsDot/DotCommon';
import FavoriteController from '../../pages/favoritepage/favoriteController'
import DotUtil from '../../utils/MmsDot/DotUtils';
import LooseObject from '../../data/LooseObject';
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import CommonData from '../../data/commonData';
//import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
//import TitleBarUtil from '../../utils/TitleBarUtil';
import { curves, LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';
import lazy { SplitScreenManager, SplitInfoModel } from '../../utils/SplitScreenManager'
import StringUtil from '../../utils/StringUtil';
import PanGestureUtil, { PanGestureAction } from '../../utils/PanGestureUtil';
import myCommon from '@ohos.app.ability.common';
import AccessibilityUtil from '../../utils/AccessibilityUtil';
import Configuration from '@system.configuration';
import ConversationListService from '../../service/ConversationListService';
import { displaySync } from '@kit.ArkGraphics2D';
import { util } from '@kit.ArkTS';
import Constant from '../../data/Constant';
import LocationUtil from '../../utils/LocationUtil';

class menuItemsParameters {
    value?: Resource;
    action: () => void = () => {
    };
    enabled: boolean = false;
    public visible: boolean = true;
}
const NUMBER_FIFTY_EIGHT: number = 56;
const NUMBER_TWENTY_EIGHT: number = 28;
const NUMBER_TEN: number = 10;
const TAG = 'InfoMsg'

@Builder
export function InfoMsgLoader(param: LooseObject): void {
    InfoMsg();
}

@Entry
@Component
export default struct InfoMsg {
    @StorageProp('fontSizeScale') fontSizeScale: number = 1;
    @Consume('pageInfos') pageInfos: NavPathStack;
    @Consume @Watch('updateAllReadStatus') unreadTotalOfInfo: number;
    private context = getContext(this) as myCommon.UIAbilityContext;
    @LocalStorageProp('fullScreenPadding') fullScreenPadding:Padding|null=null;
    @StorageLink('InfoMsgController') @Watch('changeSelectState') mInfoMsgCtrl: InfoMsgController = InfoMsgController.getInstance();
    @State @Watch('onMultipleSelectState') mIsMultipleSelectState: boolean = false;
    @StorageLink('mmsNavMode') curNavMode: number = 0;
    @State isInSetReadThreadIndex: number = -1;
    @State misShowContactHeadIcon : boolean = true;
    // 为了防止刚进入通知信息mInfoMsgCtrl属性改变导致标题栏状态刷新，需要使用一个自定义变量去重新控制多选数量
    @State conversationSelectedNumber : number = 0;
    @State isDeleting : boolean = false;
    private dialogGridCount: number = 4;
    private dialogAlignment: DialogAlignment = DeviceUtil.isTablet() ? DialogAlignment.Center : DialogAlignment.Bottom;
    private dialogOffset: Offset = DeviceUtil.isTablet() ? { dx: 0, dy: 0 } : { dx: 0, dy: $r('app.float.dialog_bottom_margin')};
    @State mListScrolling: boolean = false;
    private defaultScroll: Scroller = new Scroller()
    private touchScroll: Scroller = new Scroller()
    @State touchIndex: number = -1;
    @State conListCtrl: ConListController = this.mInfoMsgCtrl.conListCtrl;
    @State isSwipeAction: boolean = false;
    private listScroller: ListScroller = new ListScroller();
    private deleteTimerTrue: number = -1;
    private deleteTimerFalse: number = -1;

    // List滑动多选
    private listWidth: number = 0
    private listHeight: number = 0
    @State scrollEndIndex: number = -1
    @State scrollStartIndex: number = -1

    private marginLeft: number = getContext(this).resourceManager.getNumber($r('sys.float.margin_left'));
    private marginRight: number = getContext(this).resourceManager.getNumber($r('sys.float.margin_right'));

    @State scrollOffsetY: number = 0;
    @State hideSearchScrollOffsetY: number = SplitScreenManager.getInstance().infoModel.isSmall ? 0 : 56;
    @State bol4HideSearch: boolean = false;
    private animationDuration: number = 200;
    @Provide show: boolean = true;
    @Provide index: number = 1;
    @Provide mFavoriteCtrl: FavoriteController = FavoriteController.getInstance();
    @StorageLink('curBp') curBp: string = CommonData.STR.DEVICE_MOBILE_PHONE;
    @StorageLink('listShowMenu') listShowMenu: boolean = false;
    //分屏通知
    @State splitInfoModel: SplitInfoModel = SplitScreenManager.getInstance().infoModel;
    @State searchOffsetY: number = 0;
    prevSearchOffsetY: number = 0;
    scrollReachEnd: boolean = false;
    @StorageLink('isShowContactHeadIcon') isShowHeadIcon: boolean = InfoMsgController.getInstance().isShowContactHeadIcon;

    @StorageLink('isVDEFoldPhoneAndFoldedState') @Watch('onFoldStatusChange') isVDEFoldPhoneAndFoldedState
        : boolean = false;
    @StorageLink('foldStatus') @Watch('getWallpaper') foldStatus
        : number = 0;
    @State isVDE: boolean = this.isVDEFoldPhoneAndFoldedState && this.foldStatus === 2 ? true : false
    @State isScrollingStart: boolean = false;
    @State isScrollingEnd: boolean = false;
    @State isOverView: boolean = false;
    @State stages:number = 0;
    private initialCurrentYOffset: number = 0;
    private isPC: Boolean = DeviceUtil.isPC();
    @State isShowPinButton: boolean = false;
    @State isShowUnPinButton: boolean = false;
    myDisplaySync:displaySync.DisplaySync = displaySync.create();

    updateStage() {
        if (this.stages == 0) {
            this.myDisplaySync.start();
            this.myDisplaySync.on("frame", (frameInfo: displaySync.IntervalInfo)=> {
                this.updateStage();
            });
        }
        this.stages += 1;
        if (this.stages == 2) {
            this.myDisplaySync.stop()
        }
    }

    private onFoldStatusChange(): void {
        if (this.isVDEFoldPhoneAndFoldedState) {
            HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
        } else {
            HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
        }
    }

    updateAllReadStatus() {
        if (this.curBp !== common.STR.DEVICE_MOBILE_PHONE && this.unreadTotalOfInfo === 0) {
            this.mInfoMsgCtrl.clickToMarkAllAsReadForInfo(this.context);
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
            HiLog.i(TAG, 'isVDE :' + this.isVDE);
        } else {
            this.isVDE = false
            HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
        }
    }


    /* 侧滑时，删除按钮头部角度 */
    @State itemEndHeadAngle: number = 0;
    /* 侧滑时，删除按钮底部角度 */
    @State itemEndBodyAngle: number = 0;
    /* 侧滑时，删除长滑系数 */
    @State itemEndSwipeScale: number = 1;
    /* 侧滑时，是否可以开始动画 */
    private itemEndDustbinAnimationEnabled: boolean = true;
    /* 当前是否需要隐藏已读设置按钮 */
    @State isHideReadButton: boolean = false;
    /* 设备是否为pad */
    @State isPad: boolean = false;
    /* 当前需要删除的消息 */
    @State currentDeleteIndex: number = -1;
    /* 当前长滑的消息 */
    @State currentScrollIndex: number = -1;
    //会话列表是否隐藏 搜索出结果前绘画列表和搜索结果之前有段渲染延迟。
    @StorageLink('isNoneSessionList') isNoneSessionList: boolean = false;
    @State currentHasReadIndex: number = -1;
    @State currentPinOptIndex: number = -1;
    @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();
    @Styles normalStyles(){
        .backgroundColor(Color.Transparent)
        .padding({
            left: this.marginLeft - 8,
            right: this.marginRight - 8
        })
    }
    @Styles pressedStyles(){
        .backgroundColor(this.isSwipeAction ? Color.Transparent : $r('sys.color.interactive_click'))
    }
    @Styles pressedStylesMenu(){
        .backgroundColor($r('sys.color.interactive_click'))
        .borderRadius($r('sys.float.corner_radius_level4'))
    }

    delDialogController: CustomDialogController = new CustomDialogController({
        builder: CustomContentDialog({
            contentBuilder: () => {
                this.deleteDialogBuildContent();
            },
            buttons: [
                {
                    value: $r('app.string.cancel'),
                    buttonStyle: ButtonStyleMode.TEXTUAL,
                    action: () => {
                        if (!this.mIsMultipleSelectState) {
                            MmsPreferences.getInstance().setShowDelDialog(common.bool.TRUE)
                        }
                        this.mInfoMsgCtrl.delDialogShow = false;
                        this.currentDeleteIndex = -1;
                        // 通知删除会话弹窗-取消打点
                        stateParam.DIALOG_STATE = 1;
                        stateParam.PAGE_STATE = 2;
                        DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.DELETE_SESSION_EVENT);
                        try {
                            this.listScroller.closeAllSwipeActions();
                        } catch (err) {
                            HiLog.w(TAG, `listScroller.closeAllSwipeActions error: ${err}`)
                        }
                    }
                },
                {
                    value: $r('app.string.delete'),
                    buttonStyle: ButtonStyleMode.TEXTUAL,
                    action: () => {
                        this.currentHasReadIndex = -1;
                        this.mIsMultipleSelectState = false;
                        if (this.currentDeleteIndex !== -1) {
                            let accessContent = 'infoMsg' + this.currentDeleteIndex;
                            AccessibilityUtil.requestFocusForAccessibility(accessContent);
                            this.mInfoMsgCtrl.deleteAction(this.currentDeleteIndex);
                            this.currentDeleteIndex = -1;
                        }
                        this.mInfoMsgCtrl.delDialogShow = false;
                        this.mInfoMsgCtrl.deleteDialogConfirm(this.context);
                        // 通知删除会话弹窗-确认打点
                        stateParam.DIALOG_STATE = 2;
                        stateParam.PAGE_STATE = 2;
                        DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.DELETE_SESSION_EVENT);
                        this.deleteTimerTrue = setTimeout(() => {
                            this.isDeleting = true;
                             this.deleteTimerFalse = setTimeout(() => {
                                this.isDeleting = false;
                            }, 20);
                        }, 200);
                    },
                    role: ButtonRole.ERROR
                },
            ]
        }),
        autoCancel: false,
    })
    @Builder
    deleteDialogBuildContent(): void {
        DeleteDialog({
            msg: this.mInfoMsgCtrl.strMsgDeleteDialogTip,
            mIsMultipleSelectState: this.mIsMultipleSelectState
        })
    }
    @Provide menuItems: Array<menuItemsParameters> = [
        {
            value: $r('app.string.delete'),
            action: () => {
                this.mInfoMsgCtrl.selectInMoreMenu(1);
            },
            enabled: true,
            visible: true
        }
    ];

    aboutToAppear() {
        HiLog.i(TAG, 'aboutToAppear');
        this.isPad = DeviceUtil.isTablet();
        this.updateStage()
    }

    aboutToDisappear(): void {
        HiLog.i(TAG, 'aboutToDisappear');
        this.mInfoMsgCtrl.clearSelectedState();
        clearTimeout(this.deleteTimerTrue);
        clearTimeout(this.deleteTimerFalse);
    }

    onMultipleSelectState() {
        if (this.mIsMultipleSelectState) {
            HiLog.i(TAG, 'onMultipleSelectState')
            this.conListCtrl.closeItemEnd();
        }
    }

    changeSelectState() {
        this.mIsMultipleSelectState = this.mInfoMsgCtrl.isMultipleSelectState
        // 进入通知信息页面，变量改变会调用这里，但是由于多选数量不会改变，所以标题栏不会重新刷新
        this.conversationSelectedNumber = this.mInfoMsgCtrl.conversationSelectedNumber
        if (this.isVDE && this.mIsMultipleSelectState && this.mListScrolling) {
            this.mListScrolling = false;
        }
        this.misShowContactHeadIcon = this.mInfoMsgCtrl.isShowContactHeadIcon
        this.unreadTotalOfInfo = this.mInfoMsgCtrl.unreadTotalOfInfo
    }

    exitMultipleSelectState() {
            longPressDeParams.PAGE_STATE = 2;
            DotUtil.getInstance().reportEvent(longPressDeParams, dotCommon.eventName.LONGPRESS_SELECT_CANCEL_DELETE);
            HiLog.i(TAG, 'exitMultipleSelectState')
            for (let element of this.mInfoMsgCtrl.messageList) {
                element.isCbChecked = false;
            }
            this.mInfoMsgCtrl.isMultipleSelectState = false;
            this.mInfoMsgCtrl.showToolBar = true;
            this.mInfoMsgCtrl.clearSelectedState();
    }

    /**
     * The function executes after a new instance of the custom component is created and before its build function
     * is executed.
     * Allows state variables to be changed in the aboutToAppear function, and these changes will take effect in
     * subsequent executions of the build function.
     */
    destinationAppear() {
        HiLog.i(TAG, 'destinationAppear')
        this.mInfoMsgCtrl.onInit(this.pageInfos, this.context)
        AppStorage.set('isSelectInfoMsg', true)
    }

    /**
     * Function executes before custom component destructor consumption.
     * Allow changes to state variables in the aboutToDisappear function, especially changes to the @Link variable,
     * can cause erratic application behavior.
     */
    destinationDisappear() {
        HiLog.i(TAG, 'destinationDisappear')
        if (this.mInfoMsgCtrl.isMultipleSelectState) {
            this.exitMultipleSelectState();
        }
        AppStorage.set('isSelectInfoMsg', false)
    }

    /**
     * Triggers once when this page is displayed. In scenarios such as routing and application access to the
     * foreground and background, only customized components modified by @Entry take effect.
     */
    destinationShow() {
        HiLog.i(TAG, 'destinationShow')
        this.mInfoMsgCtrl.onShow(this.context);
        WantUtil.getWant(this.context, this.pageInfos);
        AppStorage.set('isSelectInfoMsg', true)
        if (this.isVDE) {
            animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 2000 }, () => {
                this.mListScrolling = false;
            })
        }
    }

    /**
     * Triggers once when this page disappears. In scenarios such as routing and application access to the foreground
     * and background, only customized components modified by @Entry take effect.
     */
    destinationPageHide() {
        HiLog.i(TAG, 'destinationPageHide')
        this.mInfoMsgCtrl.onHide()
        AppStorage.set('isSelectInfoMsg', false)
    }

    /**
     * Triggered when a user clicks the back button. Only the customized component modified by @Entry takes effect.
     * If true is returned, the page processes the return logic and does not route the page
     * 返If false is returned, the default return logic is used.
     * If no value is returned, the value is treated as false.
     */
    destinationBackPress() {
        HiLog.i(TAG, 'destinationBackPress start!')
        // Key returned by the system. The value true indicates interception.
        if (this.mInfoMsgCtrl.delDialogShow) {
            HiLog.i(TAG, 'destinationBackPress delDialogShow = true')
            this.delDialogController.close();
            this.mInfoMsgCtrl.delDialogShow = false;
            return true;
        }
        if (this.mInfoMsgCtrl.isMultipleSelectState) {
            this.exitMultipleSelectState();
            return true;
        }
        if (this.curBp !== common.STR.DEVICE_MOBILE_PHONE) {
            return false;
        }
        this.pageInfos.clear();
        return false;
    }

    listItemClick(item: messageType, index?: number) {
        HiLog.iw(TAG, `listItemClick`);
        if (item.countOfUnread > 0) {
            this.mInfoMsgCtrl.conListCtrl.statisticalData(this.context);
        }
        // 解决小概率点击通知信息列表无反应问题
        if (this.mInfoMsgCtrl.pageInfos.size() <= 0) {
            HiLog.w(TAG, 'listItemClick pageInfos is empty!')
            this.mInfoMsgCtrl.onInit(this.pageInfos, this.context)
        }
        this.mInfoMsgCtrl.clickInfoToConversation(this.context, item.index);
        if (!this.mInfoMsgCtrl.isMultipleSelectState) {
            this.currentHasReadIndex = item?.index;
            this.mInfoMsgCtrl.markAsReadByThread(this.context, item);
            setTimeout(() => {
                this.currentHasReadIndex = -1;
            }, 100);
        }
    }

    longPressOnAction(item: messageType) {
        this.mInfoMsgCtrl.conversationLongPress(item.index);
    }

    private isUnPin(pinningTime: number): boolean {
        return pinningTime > 0;
    }

    @Builder
    itemEnd(item: messageType, onDeleteBtn: () => void) {
        Row() {
            this.itemReadAndUnReadButton(item);
            if ((this.currentPinOptIndex !== item.index) && this.isUnPin(item.pinningTime)) {
                this.itemUnPinButton(item)
            } else {
                this.itemPinButton(item)
            }
            Stack() {
                this.itemEndDeleteButton();
            }
            .scale({ x: this.itemEndSwipeScale, y: this.itemEndSwipeScale })
            .backgroundColor($r('sys.color.ohos_id_color_warning'))
            .borderRadius('20vp')
            .onClick(onDeleteBtn)
            .id('allRecord_contacts_delete_btn')
        }
        .draggable(false)
        .padding({ left: $r('sys.float.margin_left'), right: $r('sys.float.margin_right') })
        .justifyContent(FlexAlign.Center)
        .height('100%')
        .backgroundColor($r('sys.color.ohos_id_color_hover'))
        .onAreaChange((oldValue: Area, newValue: Area) => {
            if (item.index === this.currentScrollIndex) {
                this.itemEndAnimal(item, oldValue, newValue);
            }
        })
        .id('allRecord_contacts_delete_row')
    }

    /* 侧滑删除按钮动画 */
    itemEndAnimal(item: messageType, oldValue: Area, newValue: Area) {
        if (this.itemEndDustbinAnimationEnabled) {
            let wid: Length = newValue.width;
            if (wid < CommonData.MESSAGEHOME_DELETE.DELETE_SWIPE_BODY_TWOBUTTON_WIDTH) {
                this.isHideReadButton = false;
                this.isShowPinButton = true;
                this.isShowUnPinButton = true;
            }
            this.itemEndHeadAngle = Math.min(CommonData.MESSAGEHOME_DELETE.MAX_HEAD_ANGLE,
                Math.max((Number(wid) - (CommonData.MESSAGEHOME_DELETE.DELETE_SWIPE_HEAD_TWOBUTTON_WIDTH)) /
                CommonData.MESSAGEHOME_DELETE.ACTION_AREA_DISTANCE *
                CommonData.MESSAGEHOME_DELETE.ANGLE_RADIO, 0.0));
            this.itemEndBodyAngle = Math.min(CommonData.MESSAGEHOME_DELETE.MAX_BODY_ANGLE,
                Math.max((Number(wid) - (CommonData.MESSAGEHOME_DELETE.DELETE_SWIPE_BODY_TWOBUTTON_WIDTH)) /
                CommonData.MESSAGEHOME_DELETE.ACTION_AREA_DISTANCE * 24.35, 0.0));
            this.itemEndSwipeScale = Math.min(CommonData.MESSAGEHOME_DELETE.MAX_SCALE_RATIO,
                (Number(wid) - (CommonData.MESSAGEHOME_DELETE.DELETE_SWIPE_HEAD_TWOBUTTON_WIDTH)) /
                CommonData.MESSAGEHOME_DELETE.ACTION_AREA_DISTANCE * 0.05 + 1.0);
            this.itemEndBodyAngle = (-1) * this.itemEndBodyAngle;
        }
    }
    @Builder
    itemReadAndUnReadButton(item: messageType) {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
            // currentHasReadIndex 在这里的作用是触发刷新，本身item?.countOfUnread并不会触发刷新
            SymbolGlyph((this.currentHasReadIndex !== item.index) && item?.countOfUnread > 0 ?
            $r('sys.symbol.checkmark_message_fill') :
            $r('sys.symbol.ellipsis_message_badge_circle_fill'))
                .id('conversationListReadButton')
                .draggable(false)
                .accessibilityLevel('no')
                .fontSize('24vp')
                .fontColor([Color.White])
        }
        .visibility((!this.isHideReadButton && item.messageCount > 0 &&
            item.contactsNum <= 1) ? Visibility.Visible : Visibility.None)
        .onClick(() => {
            stateParam.READ_STATE = item?.countOfUnread > 0 ? 0 : 1;
            this.menuReadOrUnRead(item, item?.countOfUnread, item?.telephone);
            // 列表左滑标记已读打点
            stateParam.PAGE_STATE = 2;
            DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.LIST_SWIPE_LEFT_READ);
        })
        .margin({ end: LengthMetrics.vp(8) })
        .accessibilityText((this.currentHasReadIndex !== item.index) && item?.countOfUnread > 0 ?
        getContext(this).resourceManager.getStringSync($r('app.string.read').id) :
        getContext(this).resourceManager.getStringSync($r('app.string.un_read').id))
        .accessibilityRole(AccessibilityRoleType.BUTTON)
        .width('40vp')
        .height('40vp')
        .backgroundColor($r('sys.color.ohos_id_color_palette2'))
        .borderRadius($r('sys.float.corner_radius_level10'))
    }

    @Builder
    itemPinButton(item: messageType) {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
            SymbolGlyph($r('sys.symbol.arrowshape_up_to_line_fill'))
                .id('conversationListPinButton')
                .draggable(false)
                .accessibilityLevel('no')
                .fontSize('24vp')
                .fontColor([Color.White])
        }
        .onClick(() => {
            try {
                this.listScroller.closeAllSwipeActions();
            } catch (err) {
                HiLog.e(TAG, `itemPinButton closeAllSwipeActions error: ${err}`);
            }
            setTimeout(() => {
                this.onClickPin(item.threadId, item.index);
            }, 350);
            // 左滑置顶打点
            stateParam.PIN_STATE = 0;
            DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.LIST_SWIPE_LEFT_PIN);
        })
        .visibility(this.isShowPinButton ? Visibility.Visible : Visibility.None)
        .margin({ end: LengthMetrics.vp(8) })
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.msg_pin').id))
        .accessibilityRole(AccessibilityRoleType.BUTTON)
        .width('40vp')
        .height('40vp')
        .backgroundColor($r('sys.color.confirm'))
        .borderRadius($r('sys.float.corner_radius_level10'))
    }

    @Builder
    itemUnPinButton(item: messageType) {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
            SymbolGlyph($r('sys.symbol.arrowshape_up_to_line_slash_fill'))
                .id('conversationListPinButton')
                .draggable(false)
                .accessibilityLevel('no')
                .fontSize('24vp')
                .fontColor([Color.White])
        }
        .onClick(() => {
            try {
                this.listScroller.closeAllSwipeActions();
            } catch (err) {
                HiLog.e(TAG, `itemUnPinButton closeAllSwipeActions error: ${err}`);
            }
            setTimeout(() => {
                this.onClickUnPin(item.threadId, item.index);
            }, 350);
            // 左滑取消置顶打点
            stateParam.PIN_STATE = 1;
            DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.LIST_SWIPE_LEFT_PIN);
        })
        .visibility(this.isShowUnPinButton ? Visibility.Visible : Visibility.None)
        .margin({ end: LengthMetrics.vp(8) })
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.msg_unpin').id))
        .accessibilityRole(AccessibilityRoleType.BUTTON)
        .width('40vp')
        .height('40vp')
        .backgroundColor($r('sys.color.confirm'))
        .borderRadius($r('sys.float.corner_radius_level10'))
    }

    private onClickPin(threadId: number, index: number) {
        AccessibilityUtil.announceForAccessibility(getContext(this).resourceManager
            .getStringSync($r('app.string.screen_read_msg_pin').id));
        this.currentPinOptIndex = index;
        try {
            let time = new Date().getTime();
            ConversationListService.getInstance().updateSessionPinningTime(threadId, time, () => {
                this.mInfoMsgCtrl.updateInfoMsg(threadId, time, index);
                setTimeout(() => {
                    this.currentPinOptIndex = -1;
                }, 100);
            }, this.context);
        } catch (error) {
            HiLog.e(TAG, 'onClickPin update pinningTime error : ' + JSON.stringify(error));
        }
    }

    private onClickUnPin(threadId: number, index: number) {
        AccessibilityUtil.announceForAccessibility(getContext(this).resourceManager
            .getStringSync($r('app.string.screen_read_msg_unpin').id));
        this.currentPinOptIndex = index;
        try {
            ConversationListService.getInstance().updateSessionPinningTime(threadId, 0, () => {
                this.mInfoMsgCtrl.updateInfoMsg(threadId, 0, index);
                setTimeout(() => {
                    this.currentPinOptIndex = -1;
                }, 100);
            }, this.context);
        } catch (error) {
            HiLog.e(TAG, 'onClickUnPin update pinningTime  error : ' + JSON.stringify(error));
        }
    }

    @Builder
    itemEndDeleteButton() {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
            Image($rawfile('icon/ic_delete_head.svg'))
                .height(5)
                .width(20)
                .id('infoMsgDeleteButton1')
                .draggable(false)
                .rotate({
                    x: 0,
                    y: 0,
                    z: 1,
                    centerX: '100%',
                    centerY: '100%',
                    angle: this.itemEndHeadAngle,
                })
            Image($rawfile('icon/ic_delete_body.svg'))
                .height(16)
                .width(16)
                .id('infoMsgDeleteButton2')
                .draggable(false)
                .rotate({
                    x: 0,
                    y: 0,
                    z: 1,
                    centerX: '100%',
                    centerY: 0,
                    angle: this.itemEndBodyAngle,
                })
        }
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.delete').id))
        .accessibilityRole(AccessibilityRoleType.BUTTON)
        .width('40vp')
        .height('40vp')
    }

    build() {
        //HdsNavDestination() {
        NavDestination() {
            Stack({ alignContent: Alignment.Bottom }) {
                Column() {
                    //SMS message display list
                    List({ initialIndex: 0 ,scroller: this.listScroller}) {
                        if (this.stages > 1) {
                            LazyForEach(this.mInfoMsgCtrl.conversationListDataSource, (item: messageType, index?: number) => {
                                ListItem() {
                                    this.mmListItemBuilder(item, index as number)
                                }
                                .width('100%')
                                .height(this.fontSizeScale >= 1.45 ? this.fontSizeScale * 60 + 'vp' :
                                    this.fontSizeScale * 80 + 'vp')
                                .swipeAction((!this.mIsMultipleSelectState && !this.isDeleting) ? {
                                    end: {
                                        builder: this.itemEnd(item, () => {
                                            this.deleteAction(item.index);
                                            // 通知列表左滑删除打点
                                            stateParam.PAGE_STATE = 2;
                                            DotUtil.getInstance().reportEvent(stateParam,
                                                dotCommon.eventName.SWIPE_LEFT_TO_DELETE);
                                        }),
                                        onStateChange: (swipeActionState) => {
                                            if (swipeActionState == SwipeActionState.EXPANDED) {
                                                // 通知信息左滑打点
                                                stateParam.PAGE_STATE = 2;
                                                DotUtil.getInstance().reportEvent(stateParam,
                                                    dotCommon.eventName.LIST_SWIPE_LEFT_EVENT);
                                            }
                                        },
                                        actionAreaDistance: 56,
                                        onAction: () => {
                                            //Delete
                                            this.deleteAction(item.index, true);
                                        },
                                    },
                                    onOffsetChange: (offset: number) => {
                                        if (offset !== 0) {
                                            this.isSwipeAction = true;
                                        }
                                    },
                                    edgeEffect: SwipeEdgeEffect.Spring
                                } : { edgeEffect: SwipeEdgeEffect.Spring })
                                .onTouch((event: TouchEvent) => {
                                    this.currentScrollIndex = item.index;
                                    if (event.type === TouchType.Down) {
                                        this.isSwipeAction = false;
                                    }
                                })
                            }, (item: messageType, index: number) => {
                                if (index === this.mInfoMsgCtrl.conversationListDataSource.totalCount() - 1) {
                                    return util.getHash(item)?.toString() + index.toString() + true;
                                }
                                return util.getHash(item)?.toString() + index.toString() + false;
                            })
                        }
                    }
                    .gesture(PanGesture({ direction: PanDirection.Vertical })
                        .onActionStart((event: GestureEvent) => {
                            let params: PanGestureAction = {
                                type: common.SLIDE_ACTION_TYPE.START,
                                event,
                                scroller: this.listScroller,
                                isMultipleSelectState: this.mIsMultipleSelectState,
                                switchNumber: 0,
                                mmsList: this.mInfoMsgCtrl.conversationListDataSource.mmsList
                            }
                            PanGestureUtil.panGestureAction(params)

                        })
                        .onActionUpdate((event: GestureEvent) => {
                            let params: PanGestureAction = {
                                type: common.SLIDE_ACTION_TYPE.UPDATE,
                                event,
                                scroller: this.listScroller,
                                isMultipleSelectState: this.mIsMultipleSelectState,
                                switchNumber: 0,
                                mmsList: this.mInfoMsgCtrl.conversationListDataSource.mmsList,
                                callback: (i: number, startCbChecked: boolean) => {
                                    this.mInfoMsgCtrl.gesTureListCheckBox(i, startCbChecked)
                                },
                                listHeight: this.listHeight - NUMBER_FIFTY_EIGHT,
                                scrollEndIndex: this.scrollEndIndex,
                                scrollStartIndex: this.scrollStartIndex
                            }
                            PanGestureUtil.panGestureAction(params)
                        })
                        .onActionEnd((event: GestureEvent) => {
                            let params: PanGestureAction = {
                                type: common.SLIDE_ACTION_TYPE.END,
                                event,
                                scroller: this.listScroller,
                                isMultipleSelectState: this.mIsMultipleSelectState,
                                switchNumber: 0,
                            }
                            PanGestureUtil.panGestureAction(params)
                        })
                    )
                    .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
                        this.listWidth = newValue.width as number
                        this.listHeight = newValue.height as number
                    })
                    .onGestureRecognizerJudgeBegin((event: BaseGestureEvent, current: GestureRecognizer,
                        recognizers: Array<GestureRecognizer>) => {
                        return PanGestureUtil.gestureRecognizerJudgeBegin(event, current, this.mIsMultipleSelectState,
                            this.listWidth)
                    })
                    .onReachStart(() => {
                        this.isScrollingStart = true;
                        this.initialCurrentYOffset = this.listScroller.currentOffset()?.yOffset;
                    })
                    .onReachEnd(() => {
                        this.scrollReachEnd = true;
                        this.isScrollingEnd = true;
                        if (this.isScrollingStart) {
                            this.isOverView = false;
                            if (this.mListScrolling) {
                                this.mListScrolling = false;
                            }
                        }
                        if (this.isVDE && this.isOverView && this.mListScrolling) {
                            HiLog.i(TAG,'InfoMsg onReachEnd');
                            // 滑动到底部且隐藏状态，显示
                            animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 2000 }, () => {
                                this.listScroller.scrollEdge(Edge.End)
                                this.mListScrolling = false;
                            })
                        }
                    })
                    .onScrollStart(() => {
                        if (this.isScrollingStart && this.isScrollingEnd) {
                            if (this.mListScrolling) {
                                this.mListScrolling = false;
                            }
                        }
                        this.isScrollingStart = false;
                        this.isScrollingEnd = false;
                        this.isOverView = false;
                    })
                    .onScrollStop(() => {
                        this.initialCurrentYOffset = this.listScroller.currentOffset()?.yOffset;
                    })
                    .onScrollVisibleContentChange(() => {
                        if (this.isScrollingStart && this.isScrollingEnd) {
                            this.isOverView = false;
                        } else {
                            this.isOverView = true;
                        }
                        this.isScrollingStart = false;
                        this.isScrollingEnd = false;
                    })
                    .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
                        if (scrollState === ScrollState.Scroll && this.isVDE) {
                            if (scrollOffset > 0 && this.isOverView && !this.mIsMultipleSelectState) {
                                if (!this.mListScrolling && Math.abs(this.initialCurrentYOffset - this.listScroller
                                    .currentOffset()?.yOffset) >= 26 && !this.scrollReachEnd) {
                                    animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 1000 }, () => {
                                        this.mListScrolling = true;
                                    })
                                } else if (this.mListScrolling) {
                                    this.initialCurrentYOffset = this.listScroller.currentOffset()?.yOffset;
                                }
                            } else if (scrollOffset < 0) {
                                if (this.mListScrolling &&
                                    Math.abs(this.initialCurrentYOffset - this.listScroller.currentOffset()?.yOffset) >= 26) {
                                    animateTo({
                                        curve: curves.interpolatingSpring(0, 1, 228, 30),
                                        duration: 1000
                                    }, () => {
                                        this.mListScrolling = false;
                                    })
                                } else if (!this.mListScrolling) {
                                    this.initialCurrentYOffset = this.listScroller.currentOffset()?.yOffset;
                                } else if (this.listScroller.currentOffset()?.yOffset <= -56) {
                                    animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 1000 }, () => {
                                        this.mListScrolling = false;
                                    })
                                }
                            }
                        }
                        this.scrollOffsetY =
                            this.splitInfoModel.isSmall ? 0 : this.listScroller.currentOffset().yOffset;
                        // 向下滑动
                        if (scrollOffset < 0 && this.searchOffsetY !== 0) {
                            if (this.scrollReachEnd && scrollState === ScrollState.Fling) {
                                return;
                            }
                            let distance = -this.searchOffsetY -
                                (this.prevSearchOffsetY - this.scrollOffsetY);
                            let searchOffsetY = distance >= 0 && distance <= NUMBER_FIFTY_EIGHT
                                ? -distance : (distance < 0 && -distance < NUMBER_FIFTY_EIGHT
                                    ? 0 : this.searchOffsetY);
                            if (searchOffsetY > 0) {
                                searchOffsetY = 0
                            }
                            animateTo({ curve: curves.responsiveSpringMotion() }, () => {
                                this.searchOffsetY = searchOffsetY;
                            });
                        }

                        // 向上滑动
                        if (scrollOffset > 0 && this.searchOffsetY !== -NUMBER_FIFTY_EIGHT) {
                            let searchOffsetY: number = 0;
                            if (this.scrollOffsetY > 0) {
                                // 滑动距离
                                if (this.scrollOffsetY > NUMBER_FIFTY_EIGHT) {
                                    if (this.searchOffsetY !== -NUMBER_FIFTY_EIGHT) {
                                        let distance = -this.searchOffsetY +
                                            (this.scrollOffsetY - this.prevSearchOffsetY);
                                        searchOffsetY = distance > 0 &&
                                            distance <= NUMBER_FIFTY_EIGHT
                                            ? -Math.ceil(distance)
                                            : distance < NUMBER_FIFTY_EIGHT + NUMBER_TEN ?
                                                -NUMBER_FIFTY_EIGHT : this.searchOffsetY;
                                    } else {
                                        searchOffsetY = -NUMBER_FIFTY_EIGHT
                                    }
                                } else {
                                    searchOffsetY = -this.scrollOffsetY;
                                }
                            }
                            if (!this.isVDE) {
                                animateTo({ curve: curves.responsiveSpringMotion() }, () => {
                                    this.searchOffsetY = searchOffsetY;
                                });
                            }
                        }

                        if (scrollState === ScrollState.Idle) {
                            animateTo({ curve: curves.responsiveSpringMotion() }, () => {
                                this.searchOffsetY = -this.searchOffsetY >= NUMBER_TWENTY_EIGHT
                                    ? -NUMBER_FIFTY_EIGHT : 0;
                            });
                        }
                        if (this.listScroller.currentOffset().yOffset === 0) {
                            animateTo({ curve: curves.responsiveSpringMotion() }, () => {
                                this.searchOffsetY = 0;
                            });
                        }
                        this.prevSearchOffsetY = this.scrollOffsetY;
                    })
                    .contentEndOffset(this.isVDE ? 52 : 0)
                    .align(Alignment.Top)
                    .scrollBar(BarState.Auto)
                    .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
                    .onScrollIndex((start, end) =>{
                        this.scrollEndIndex = end
                        this.scrollStartIndex = start
                        this.mInfoMsgCtrl.conversationListDataSource.setIndex(start, end);
                        this.scrollReachEnd = false;
                    })
                    .clipContent(ContentClipMode.SAFE_AREA)
                    .margin({
                        top: 0,
                        bottom: this.isVDE ? 0 : this.fullScreenPadding?.bottom as number + 52
                    })
                    .width('100%')
                    .layoutWeight(1)
                    .onTouch((event: TouchEvent) => {
                        let fingers = event.touches.length;
                        this.mInfoMsgCtrl.longPressFingers = fingers;
                    })
                }
                .width('100%')
                .height('100%')
                .visibility(Visibility.Visible)
                    Column() {
                        //Single session press and hold option
                        if (this.mIsMultipleSelectState) {
                            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
                                //Delete
                                Flex({
                                    direction: FlexDirection.Column,
                                    justifyContent: FlexAlign.Center,
                                    alignItems: ItemAlign.Center
                                }) {
                                    SymbolGlyph($r(this.mInfoMsgCtrl.svgDelete))
                                        .width('24vp')
                                        .height('24vp')
                                        .draggable(false)
                                        .fontSize('24vp')
                                        .fontColor([$r('sys.color.ohos_id_color_primary')])
                                        .margin({top: '5vp' })
                                    Text($r('app.string.delete'))
                                        .fontSize('10vp')
                                        .fontWeight(FontWeight.Medium)
                                        .margin({top: '2vp' })
                                        .fontFamily('HarmonyHeiTi')
                                }
                                .height(52)
                                .width('50%')
                                .opacity(this.mInfoMsgCtrl.checkSelectedNumberIsEmpty() ? 0.4 : 1)
                                .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.delete_button')
                                    .id) + (this.mInfoMsgCtrl.checkSelectedNumberIsEmpty() ?
                                getContext(this).resourceManager.getStringSync($r('app.string.not_clickable').id) : ''))
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
                                    if (this.mInfoMsgCtrl.isConversationCheckAll) {
                                        SymbolGlyph($r('sys.symbol.checkmark_square_on_square_fill'))
                                            .fontColor([$r('app.color.brand')])
                                            .fontSize('24vp')
                                            .width('24vp')
                                            .height('24vp')
                                            .draggable(false)
                                            .margin({top: '5vp' })
                                    } else {
                                        SymbolGlyph($r('sys.symbol.checkmark_square_on_square'))
                                            .fontColor([$r('sys.color.ohos_id_color_primary')])
                                            .fontSize('24vp')
                                            .width('24vp')
                                            .height('24vp')
                                            .draggable(false)
                                            .margin({top: '5vp' })
                                    }
                                    Text(this.mInfoMsgCtrl.strCheckBoxSelectTip)
                                        .fontSize('10vp')
                                        .margin({top: '2vp' })
                                        .fontColor(this.mInfoMsgCtrl.isConversationCheckAll ?
                                        $r('sys.color.font_emphasize') :
                                        $r('sys.color.icon_secondary'))
                                        .fontWeight(FontWeight.Medium)
                                        .fontFamily('HarmonyHeiTi')
                                }
                                .height(52)
                                .width('50%')
                                .onClick(() => {
                                    this.mInfoMsgCtrl.clickConversationCheckAll()
                                })
                            }
                            .width('100%')
                            .height(56)
                            .padding({ left: 0, right: 0 })
                            .flexBasis(52)
                            .flexShrink(0)
                            .backgroundColor($r('sys.color.ohos_id_color_background'))
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
                                    /**
                                     * 根据controller中的未读数量判断全部已读按钮可不可以点击
                                     * opacity：控制组件是否高亮的属性，1为高亮，小于1为模糊
                                     **/
                                    SymbolGlyph($r('sys.symbol.doc_plaintext_and_checkmark'))
                                        .width('24vp')
                                        .height('24vp')
                                        .draggable(false)
                                        .fontColor([$r('sys.color.ohos_id_color_primary')])
                                        .fontSize('24vp')
                                        .margin({top: '5vp' })
                                        .opacity(this.mInfoMsgCtrl.unreadTotalOfInfo <= 0 ? 0.4 : 1)
                                    Text($r('app.string.markAllAsRead'))
                                        .fontSize('10vp')
                                        .fontWeight(FontWeight.Medium)
                                        .margin({top: '2vp' })
                                        .fontColor($r('sys.color.font_primary'))
                                        .opacity(this.mInfoMsgCtrl.unreadTotalOfInfo <= 0 ? 0.4 : 1)
                                        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.markAllAsRead').id))
                                }
                                .width('50%')
                                .height(52)
                                .accessibilityRole(AccessibilityRoleType.BUTTON)
                                .enabled(this.mInfoMsgCtrl.unreadTotalOfInfo <= 0 ? false : true)
                                .onClick(() => {
                                    this.mInfoMsgCtrl.clickToMarkAllAsReadForInfo(this.context);
                                    // 通知页-全部已读打点
                                    stateParam.STATE = 1;
                                    DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.NOTIFICATION_LIST_OPERATION);
                                })
                                //more
                                Flex({
                                    direction: FlexDirection.Column,
                                    justifyContent: FlexAlign.Center,
                                    alignItems: ItemAlign.Center
                                }) {
                                    MoreMenu({
                                        menuText: $r('app.string.more'),
                                        curWidth: '50%',
                                        curHeight: '52vp',
                                        isInfoMsg: true
                                    })
                                }
                                .layoutWeight(1)
                            }
                            .width('100%')
                            .height(52)
                            .padding({
                                left: 0, right: 0
                            })
                            .flexBasis(52)
                            .flexShrink(0)
                        }
                        //Setting the background of the navigation bar
                        //Delete pop-up dialog box
                    }.padding({
                        left: this.isPad ? this.padMargin : $r('app.float.infoMsg_list_padding_left'),
                        right: this.isPad ? this.padMargin : $r('app.float.infoMsg_list_padding_left'),
                        bottom: this.fullScreenPadding ? (this.fullScreenPadding.bottom as number) : 56
                    })
                    .backgroundColor($r('sys.color.ohos_id_color_background'))
                    .translate({ y: this.isVDE && this.mListScrolling && !this.mInfoMsgCtrl.isMultipleSelectState ? 52 : 0 })
                    .opacity(this.isVDE && this.mListScrolling && !this.mInfoMsgCtrl.isMultipleSelectState ? 0 : 1)
                    .visibility(Visibility.Visible)
            }.renderGroup(true)
        }
        .title(this.curBp !== common.STR.DEVICE_MOBILE_PHONE ? undefined : $r('app.string.infoMessages'))
        // .titleBar(TitleBarUtil.getTitleBar({mainTitle: TitleBarUtil.isShowTitle &&
        //     this.curBp !== common.STR.DEVICE_MOBILE_PHONE ? undefined : $r('app.string.infoMessages'),
        //     stackBuilder: TitleBarUtil.isShowTitle && this.curBp !== common.STR.DEVICE_MOBILE_PHONE ?
        //     this.navTitle.bind(this) : undefined,
        //     backgroundColor: $r('sys.color.background_primary'),
        //     enableComponentSafeArea: true,
        //     isMultipleSelectState: this.mIsMultipleSelectState, selectedNumber:
        //     this.conversationSelectedNumber, callback: () => {this.destinationBackPress()}}))
        .hideBackButton(DeviceUtil.isTabletOrPC() || this.curBp === common.STR.DEVICE_Folding_SCREEN ||
           DeviceUtil.isTrifoldExpandedState())
       // .dynamicHideTitleBar({hideBottomBuilder: true, mode: HideMode.SCROLL_UP_TO})
        .bindToScrollable([this.listScroller])
        .backgroundColor($r('sys.color.ohos_id_color_background'))
        .hideTitleBar((this.isVDE && this.mListScrolling) ? (this.isVDE && this.mListScrolling) :
            this.splitInfoModel.isSmall ? this.splitInfoModel.isSmall :  (DeviceUtil.isPC() ?
            false:false), this.isVDE ? this.mListScrolling ? true : false : false)
        .onShown(() => {
          this.destinationShow();
        })
        .onAppear(() => {
          this.destinationAppear();
        })
         .onDisAppear(() => {
             this.destinationDisappear();
         })
        .onBackPressed(() => {
            return this.destinationBackPress();
        })
        .onHidden(() => {
          this.destinationPageHide();
        })
    }

    @Builder
    navTitle() {
        Row() {

                if (this.mIsMultipleSelectState) {
                    // 设备分栏并且非扩展小折叠, DeviceUtil.getScreenFoldStatus() !== 2:非折叠态,非分屏状态
                    if ((DeviceUtil.isTabletOrPC() ||
                        (DeviceUtil.isFoldable() && DeviceUtil.getScreenFoldStatus() !== 2 &&
                            this.curNavMode === common.int.NAVIGATION_MODE_SPLIT)) &&
                        !this.isVDEFoldPhoneAndFoldedState) {
                        Button({ type: ButtonType.Circle, stateEffect: true }) {
                            SymbolGlyph($r('sys.symbol.xmark'))
                                .fontColor([$r('sys.color.ohos_id_color_primary')])
                                .fontSize('24vp')
                                .draggable(false)
                                .id('cancelMultipleSelectButton')
                                .width('24vp')
                                .height('24vp')
                        }
                        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.off').id))
                        .width('40vp')
                        .height('40vp')
                        .backgroundColor(this.isPC ? Color.Transparent : $r('sys.color.ohos_id_color_hover'))
                        .draggable(false)
                        .borderRadius($r('sys.float.corner_radius_level10'))
                        .margin(Configuration.getLocale().dir === 'rtl' ?
                            { left: '8vp' } : { right: '8vp' })
                        .onClick(() => {
                            this.exitMultipleSelectState();
                        })
                    }
                    Text(this.mInfoMsgCtrl.conversationSelectedNumber == 0 ?
                    $r('app.string.msg_unselected_tip') :
                    $r('app.plural.msg_selected_tip_new', this.mInfoMsgCtrl.conversationSelectedNumber,
                        LocationUtil.numFormat(this.mInfoMsgCtrl.conversationSelectedNumber)))
                        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
                        .fontColor($r('sys.color.ohos_id_color_text_primary'))
                        .fontWeight(FontWeight.Bold)
                        .height('100%')
                } else {
                    Text($r('app.string.infoMessages'))
                        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
                        .fontColor($r('sys.color.ohos_id_color_text_primary'))
                        .fontWeight(FontWeight.Bold)
                        .height('100%')
                }

        }.height('100%')
        .width('100%')
        .padding(Configuration.getLocale().dir === 'rtl' ?
            { right: this.isPC ? '24vp' : this.isPad ? this.padMargin :
                this.curBp === common.STR.DEVICE_MOBILE_PHONE ? '8vp' : $r('sys.float.margin_left')} :
            { left: this.isPC ? '24vp' : this.isPad ? this.padMargin :
                this.curBp === common.STR.DEVICE_MOBILE_PHONE ? '8vp' : $r('sys.float.margin_left')})
        .gesture(
            TapGesture({ count: 2 })
                .onAction((event: GestureEvent) => {
                    this.searchOffsetY = 0;
                    if (this.mInfoMsgCtrl.unReadQueue.length > 0) {
                        let index: number = this.mInfoMsgCtrl.unReadQueue.pop();
                        HiLog.i(TAG, 'scrollToIndex  index:' + index);
                        this.listScroller.scrollToIndex(index);
                        this.mInfoMsgCtrl.unReadQueue.add(index);
                    } else {
                        this.listScroller.scrollEdge(Edge.Top)
                    }
                })
        )
    }

    navBackButton() {
        if (this.mIsMultipleSelectState) {
            return new SymbolGlyphModifier($r('sys.symbol.xmark'))
        } else {
            return new SymbolGlyphModifier($r('sys.symbol.chevron_backward'))
        }
    }

    @Builder
    mmListItemBuilder(item: messageType, index: number) {
        Column(){
            Row() {
                MmsListItem({
                    item: item,
                    fatherView: 'InfoMsg',
                    isMultipleSelectState: this.mIsMultipleSelectState,
                    isInSetReadThreadIndex: this.currentHasReadIndex,
                    isShowHeadIcon: this.isShowHeadIcon,
                    loadFromDB: true,
                    showCount:
                    !this.conListCtrl.isShowContactHeadIcon &&
                        item.countOfUnread > 1,
                    onClickHead: (clickPosition: number, event: ClickEvent | undefined) => {
                        if (!this.listShowMenu) {
                            this.mInfoMsgCtrl.clickToGroupDetail(clickPosition);
                        }
                    },
                    onClickCheckBox: (checkIndex: number,
                        value: boolean) => {
                        this.mInfoMsgCtrl.clickCheckBox(this.context, checkIndex, value);
                    },
                    menuMultSelect: (pressIndex: number) => {
                        this.mulAction(pressIndex);
                    },
                    menuDelete: (pressIndex: number) => {
                        this.deleteAction(pressIndex);
                    },
                    menuUnPin: (threadId: number, pressIndex: number) => {
                        this.unPinAction(threadId, pressIndex);
                    },
                    menuPin: (threadId: number, pressIndex: number) => {
                        this.pinAction(threadId, pressIndex);
                    },
                    menuReadOrUnRead: (item: messageType, countOfUnread: number, telephone: string) => {
                        this.longPressReadOrUnRead(item, countOfUnread, telephone);
                    },
                    onClickListItem: (index: number) => {
                        item.index = index;
                        this.listItemClick(item, index);
                    },
                    isPad: this.isPad,
                    curBp: this.curBp,
                    showCountOfUnread: this.currentHasReadIndex != item.index
                })
            }
            .width('100%').height('auto').zIndex(1000000 - Number(item.id))
            .accessibilityLevel('no')
            //添加一个空的长按手势是为了屏幕朗读识别播报（单指双击并长按即可执行）
            .parallelGesture(
                GestureGroup(GestureMode.Exclusive, LongPressGesture({ repeat: false, duration: 500 })
                    .onAction(() => {
                    })
                ))
            .onClick((event?: ClickEvent) => {
                HiLog.i(TAG, 'listItemClick');
                item.index = index;
                this.listItemClick(item, index);
            })
            if (index !==
                this.mInfoMsgCtrl.conversationListDataSource.mmsList.length -
                    1) {
                Divider()
                    .strokeWidth(`${Constant.HEIGHT_OF_CONVERSATION_LIST_DIVIDER}px`)
                    .margin({
                        left: this.mInfoMsgCtrl.isShowContactHeadIcon ?
                            72 : 16, right: 16
                    }).color($r('sys.color.comp_divider')).visibility(Visibility.Visible)
            }
        }
    }

    mulAction(pressIndex: number) {
        this.mInfoMsgCtrl.conversationLongPress(pressIndex);
    }

    unPinAction(threadId: number, index: number) {
        this.onClickUnPin(threadId, index);
    }

    pinAction(threadId: number, index: number) {
        this.onClickPin(threadId, index);
    }

    deleteAction(pressIndex: number, hideButton?: boolean) {
        this.currentHasReadIndex = -1;
        this.mIsMultipleSelectState = false;
        this.currentDeleteIndex = pressIndex;
        if (hideButton) {
            this.hideButton();
        }
        this.delDialogController?.open();
    }

    private hideButton() {
        this.isHideReadButton = true;
        this.isShowPinButton = false;
        this.isShowUnPinButton = false;
    }

    menuReadOrUnRead(item: messageType, countOfUnread: number, telephone: string) {
        HiLog.e(TAG, 'menuReadOrUnRead his.item.index' + item?.index + '  countOfUnread: ' + countOfUnread);
        try {
            this.listScroller.closeAllSwipeActions();
        } catch (err) {
            HiLog.w(TAG, `listScroller.closeAllSwipeActions error: ${err}`)
        }
        this.currentHasReadIndex = item?.index;
        if (countOfUnread > 0) {
            AccessibilityUtil.announceForAccessibility(getContext(this).resourceManager
                .getStringSync($r('app.string.screen_read_read').id));
            this.mInfoMsgCtrl.markAsReadByThread(this.context, item);
        } else {
            AccessibilityUtil.announceForAccessibility(getContext(this).resourceManager
                .getStringSync($r('app.string.screen_read_unread').id));
            this.mInfoMsgCtrl.handleMarkAsUnRead(this.context, item);
        }
        setTimeout(() => {
            this.currentHasReadIndex = -1;
            let accessContent = 'infoMsg' + item?.index;
            AccessibilityUtil.requestFocusForAccessibilityNotInterrupt(accessContent);
        }, 100);
    }

    longPressReadOrUnRead(item: messageType, countOfUnread: number, telephone: string) {
        this.menuReadOrUnRead(item, countOfUnread, telephone);
        //长按标记已读未读打点
        stateParam.PAGE_STATE = 2;
        stateParam.READ_STATE = countOfUnread > 0 ? 0 : 1;
        DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.LONGPRESS_UNREAD);
    }
}
