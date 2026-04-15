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

import ConListController, { messageType } from './conversationListController';
import CommonData from '../../data/commonData';
import HiLog from '../../utils/HiLog';
import InfoMsgController from '../infomsg/InfoMsgController';
import { DeleteDialog } from '../../views/MmsDialogs';
import { MmsListItem } from '../../views/MmsListItem';
import { SettingMenu } from '../../views/MmsMenu';
import LooseObject from '../../data/LooseObject';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import ConversationController from '../conversation/conversationController';
import MmsPreferences from '../../utils/MmsPreferences';
import common from '../../data/commonData';
import EmitterConstant from '../../data/EmitterConstant';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import { DoubleClickUtil } from '../../utils/DoubleClickUtil';
import emitter from '@ohos.events.emitter';
import router from '@ohos.router';
import { BusinessError } from '@ohos.base';
import hiTraceMeter from '@ohos.hiTraceMeter';
import TraceConstant from '../../data/TraceConstant';
import DotUtil from '../../utils/MmsDot/DotUtils';
import dotCommon, { dotNoNeedParmas, longPressDeParams, seleteParam,
    stateParam } from '../../utils/MmsDot/DotCommon';
import ReceiveController from '../../views/receive/receiveController';
import { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import StringUtil from '../../utils/StringUtil';
import { ToolBar, ToolBarModifier } from '@ohos.arkui.advanced.ToolBar';
import DeviceUtil from '../../utils/DeviceUtil';
import { VibrationUtils } from '../../utils/VibrationUtils';
import systemParameter from '@ohos.systemparameter';
import UserUtil from '../../utils/UserUtil';
import PatternControl from '../PatternControl';
import { SystemMode } from '../../utils/SystemMode';
import lazy { SplitScreenManager, SplitInfoModel } from '../../utils/SplitScreenManager'
import {
  curves,
  DividerModifier,
  LengthMetrics,
  Popup,
  PopupButtonOptions,
  PopupIconOptions,
  PopupTextOptions,
  SymbolGlyphModifier,
  window,
  uiObserver,
  ToolBarOptions
} from '@kit.ArkUI';
import FavoriteController from '../../pages/favoritepage/favoriteController'
import MmsUtil from '../../utils/MmsUtil';
import PanGestureUtil, { PanGestureAction } from '../../utils/PanGestureUtil';
import AccessibilityUtil from '../../utils/AccessibilityUtil';
import Configuration from '@system.configuration';
import { ContactsUpdateRecords } from './conversationListTool';
import { Settings } from '../settings/settings';
import commonData from '../../data/commonData';
import { dataShare } from '@kit.ArkData';
import myCommon from '@ohos.app.ability.common';
import { CreateNewConversation } from '../conversation/CreateNewConversation';
import { NavDestinationHeaderView } from '../conversation/NavDestinationHeaderView';
import { DraftUtils } from '../../utils/DraftUtils';
import { StorageMessageTimeout } from '../conversation/StorageMessageTimeout';
import TelephoneUtil from '../../utils/TelephoneUtil';
import ReceiveService from '../../StaticSubscriber/ReceiveService';
import ConversationListService from '../../service/ConversationListService';
import { settings } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { ComponentContent } from '@ohos.arkui.node';
import TitleBarUtil, { titleBarParams } from '../../utils/TitleBarUtil';
import SettingsDataUtils from '../../utils/SettingsDataUtils';
import NotificationService from '../../service/NotificationService';
import { DateRefreshUtil } from '../../utils/DateRefreshUtil';
import LocationUtil from '../../utils/LocationUtil';
import { BadgeUtil } from '../../utils/BadgeUtil';
import { EmptyPage } from '../../views/EmptyPage';
import { SearchInfoController } from '../conversation/SearchInfoController';

const NUMBER_FIFTY_EIGHT: number = 56;
const NUMBER_TWENTY_EIGHT: number = 28;
const NUMBER_TEN: number = 10;
const DURATION_TIME: number = 1000 * 60 * 30; // 用户手动退出后30分钟内不再触发短信轰炸逻辑
const TAG = 'ConversationList';

class menuItemObj {
    public value?: Resource | string;
    public action: () => void = () => {
    };
    public enabled: boolean = false;
    public color: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
    public isBlock?: boolean = false;
    public count?: number = 0;
    public visible: boolean = true;
}

class IsNewMessage {
    isNewMsg: boolean = false;
    isConversationNewMsg: boolean = false;
}

enum ItemState {
    ENABLE = 1,
    DISABLE = 2,
    ACTIVATE = 3
}

interface ParamsInterface {
  totalCount: number,
  unreadTotal: number,
  mConListCtrl: ConListController,
  isVDE: boolean,
  settingShow: Function,
  context: myCommon.UIAbilityContext,
  patternControl: PatternControl,
  unReadBlockedNum: number
}

@Component
export default struct ConversationList {
    @StorageProp('fontSizeScale') @Watch('onFontSizeScale') fontSizeScale: number = 1;
    @StorageLink('selectPhoneNumber') selectPhoneNumber: string = '';
    @StorageLink('isGetSim') @Watch('updateGetSimStatus') isGetSim:boolean=true;
    @StorageLink('isOpenRcsStatus') @Watch('updateIsOpenStatus') isOpenRcsStatus:boolean|null=null;
    @StorageLink('isOpenRcsError') isOpenRcsError:boolean = SharedPreferencesUtils.getFromPreferences('isOpenRcsError', false) as boolean;
  private context = getContext(this) as myCommon.UIAbilityContext;
    @StorageLink('cellularDataGet') @Watch('updateCellularDataStatus') isCellularOpen:boolean|null=null;
    @StorageLink('curBp') @Watch('isListenSettingPage') curBp: string = common.STR.DEVICE_MOBILE_PHONE;
    @StorageLink('listShowMenu') listShowMenu: boolean = false;
    @StorageLink('conversationListSelectCount') @Watch('onSelectCountChanged') conversationListSelectCount: number = 0;
    private mConversationCtrl: ConversationController = ConversationController.getInstance();
    @Link @Watch('changeSelectState') mConListCtrl: ConListController;
    @State @Watch('onMultipleSelectState') mIsMultipleSelectState: boolean = false;
    @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding | null = null;
    @StorageLink('isSelectInfoMsg') isSelectInfoMsg: boolean = false;
    @StorageLink('isSelectBeidouMsg') isSelectBeidouMsg: boolean = false;
    @StorageLink('isSelectAppMsg') isSelectAppMsg: boolean = false;
    @StorageLink('isShowFromCheckAll') isShowFromCheckAll: boolean = false;
  @StorageLink('isSearchResultEmpty') isSearchResultEmpty: boolean = false;
    @State subTitle: string = '';
    @State mainTitle: string = '';
    @State touchIndex: number = -1;
    @State isDeleting : boolean = false;
    @State multiSelectToolbarList: ToolBarOptions = new ToolBarOptions();
    @State @Watch('unReadTotalChanged') unreadTotal: number = 0;
    @State @Watch('conversationListMenuItems') totalCount: number = 0;
    @State @Watch('isRepairChanged') isRepair : boolean = false;
    scrollOffsetY: number = 0;
    @State interState:boolean = false;
    @State showMainTitle: Boolean = true;
    @State isShowHeadIcon: boolean = ConListController.getInstance().isShowContactHeadIcon;
    @State messageSwitch: boolean = false;
    @State getPhotoPixelMap: boolean = false;
    @State mInfoMsgCtrl: InfoMsgController = new InfoMsgController();
    @State receiveCtrl: ReceiveController = ReceiveController.getInstance();
    @StorageLink('isNeedHideTitle') isNeedHideTitle: boolean = false;
    @StorageProp('slot0MuteChange') isSlot0Mute: boolean = false;
    @StorageProp('slot1MuteChange') isSlot1Mute: boolean = false;
    @StorageProp('showExitMuteTipChange') showExitMuteTip: boolean = false;
    private patternControl: PatternControl = PatternControl.getInstance();
    @Consume unreadTotalOfInfo: number;
    private animationDuration: number = 200;
    private listScroller: ListScroller = new ListScroller();
    repairModeDialog: CustomDialogController | null = null;
    delDialogController: CustomDialogController | null = null;
    private marginLeft: number = px2vp(getContext(this).resourceManager.getNumber($r('sys.float.margin_left').id));
    private marginRight: number = px2vp(getContext(this).resourceManager.getNumber($r('sys.float.margin_right').id));
    private debounceTimer: number | null = null;

    // List滑动多选
    private listWidth: number = 0
    private listHeight: number = 0
    @State scrollEndIndex: number = -1
    @State scrollStartIndex: number = -1

    /* 侧滑时，删除按钮头部角度 */
    @State itemEndHeadAngle: number = 0;
    /* 侧滑时，删除按钮底部角度 */
    @State itemEndBodyAngle: number = 0;
    /* 侧滑时，删除长滑系数 */
    @State itemEndSwipeScale: number = 1;

    /* 侧滑时，是否可以开始动画 */
    private itemEndDustbinAnimationEnabled: boolean = true;
    private deleteTimerTrue: number = -1;
    private deleteTimerFalse: number = -1;

    /* 当前需要删除的消息 */
    @State currentDeleteIndex: number = -1;
    /* 当前是否需要隐藏已读设置按钮 */
    @State isHideReadButton: boolean = false;

    /* 设备是否为pad */
    @State isPad: boolean = false
    @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();
    /**修复冷启动首次加载滚动条闪动问题。先不显示滚动后在显示*/
    @State isScrolled: boolean = false;
    /**判断当前滑动是否已经振动过**/
    isOnceVibration: boolean = false;
    public changeSelectTimer: number = -1;
    /* 当前长滑的消息 */
    @State currentScrollIndex: number = -1;
    //分屏通知
    @State splitInfoModel: SplitInfoModel = SplitScreenManager.getInstance().infoModel;
    @State searchOffsetY: number = 0;
    @Provide show: boolean = true;
    @Provide index: number = 1;
    @Provide mFavoriteCtrl: FavoriteController = FavoriteController.getInstance();
    prevSearchOffsetY: number = 0;
    scrollReachEnd: boolean = false;
    @StorageLink('hasInfoMsg') @Watch('hasInfoMsgChange') hasInfoMsg: boolean = false;
    //会话列表是否隐藏 搜索出结果前绘画列表和搜索结果之前有段渲染延迟。
    @StorageLink('isNoneSessionList') isNoneSessionList: boolean = false;
    @State currentIndexListDel: number = 0;
    // 根据字体倍数计算高度
    @State sessionListHeight: number = 0;
  //新建短信
  @StorageLink('isShowNewMms') isShowNewMms: boolean = false;
    /**
     * 用于控制ListItem的侧滑布局的显示，默认不加载左滑的删除按钮，当用户第一次点击时，当前item的侧滑组件会加载；
     * 这里设置为长度为2的数组，代表侧滑组件最多显示两个（已经显示侧滑组件的item，在另一个侧滑组件显示的时候，会存在同时存在与页面的场景，
     * 避免收起侧滑组件的item闪动）
     */
    @State swipeActionShowList: number[] = [-1, -1];
    @State currentHasReadIndex: number = -1;
    @State currentPinOptIndex: number = -1;
    // 设置页是否模态
    @StorageLink('isSettingShow') isSettingShow: boolean = false;
    @StorageLink('settingShowFromPath') settingShowFromPath: string =
      CommonData.rcsFromType.CHATBOT_PAGE;
    @StorageLink('isDistributedCallPhoneSharing') isDistributedCallPhoneSharing: boolean = false;
    @StorageLink('isInitSmsSharingViewShow') isInitSmsSharingViewShow: boolean = true;
    private storageMessageTimeout = StorageMessageTimeout.getInstance();
    @StorageLink('isOpenRcsTestSetting')  isOpenRcsState: boolean =
        SharedPreferencesUtils.getFromPreferences('isUIOpenRcs', false) as boolean;
    @StorageLink('rcsChatBotSettingIsOn') isChatbotOn: boolean =
    SharedPreferencesUtils.getFromPreferences('isUIChatbotOpenRcsHasChanged', false) as boolean ?
      SharedPreferencesUtils.getFromPreferences('isUIChatbotOpenRcs', false) as boolean : this.isOpenRcsState;
    /* 是不是已经点击了 增强信息页面的  开启/不用了 */
    @StorageLink('isFirstMms') @Watch('isFirstMmsChange') isFirstMms: boolean = false;
    @State isRcsOpen :boolean = SharedPreferencesUtils.getFromPreferences('isUIOpenRcs', false) as boolean;
    @StorageLink('rcsStatus') @Watch('updateRcsStatus') isRcsStatus :boolean | null =null;
    @State isVisibleRcs: boolean = false;
    private contactUpdateIds: Map<string,string> = new Map<string,string>();
    private toolBarModifier: ToolBarModifier = new ToolBarModifier().stateEffect(false);
    /* 是否启用rcs能力 */
    private isEnableRcsAbility: boolean = SystemMode.getInstance().isEnableRcsAbility;
    @State isPC: boolean = DeviceUtil.isPC();
    @StorageLink('isPCPageRefresh') @Watch('conversationListPageRefresh') isPageRefresh: boolean = false;
    @State isShowPinButton: boolean = true;
    @State isShowUnPinButton: boolean = true;
    /* 首页数据已经加载，同步显示通知信息 */
    @State isSessionVisible: boolean = false;
    /* 设备是否开启无障碍屏幕朗读 */
    @StorageLink('isScreenReaderOpen') isReaderOpen: boolean = false;

  private searchInfoController:SearchInfoController=new SearchInfoController(this)
  @StorageLink('isSearch')@Watch('isSearchChange') isSearch: boolean = false
  @State inputText: string = ''

  isSearchChange() {
    if (!this.isSearch) {
      this.inputText = ''
    }
    AppStorage.setOrCreate('inputText', this.inputText)
  }
    conversationListPageRefresh() {
    HiLog.i(TAG, 'conversationListPageRefresh isPageRefresh:' + this.isPageRefresh);
    if (DeviceUtil.isPC()) {
      this.mConListCtrl.requestItem(this.context);
    }
  }

    @Styles normalStyles() {
        .backgroundColor(Color.Transparent)
    }
    @Styles
    infoNormalStyles() {
        .backgroundColor(Color.Transparent)
    }

    @Styles listItemNormalStyles() {
        .backgroundColor((this.selectPhoneNumber === this.mConversationCtrl.strContactsNumberFormat &&
            this.selectPhoneNumber !== '') && this.curBp !== common.STR.DEVICE_MOBILE_PHONE
            ? Color.Transparent : Color.Transparent)
    }

    @Styles
    pressedStyles() {
        .backgroundColor(this.curBp === common.STR.DEVICE_MOBILE_PHONE ? $r('sys.color.ohos_id_color_click_effect') : Color.Transparent)
    }

    @Styles
    pressedInfoItemStyles() {
        .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    }
@Styles
  interPress(){
    .backgroundColor($r('sys.color.interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level4'))
  }
  @Styles
  rcsPressedStyles() {
    .backgroundColor($r('sys.color.interactive_click'))
  }
    @Styles pressedStylesMenu() {
        .backgroundColor($r('sys.color.interactive_click'))
        .borderRadius($r('sys.float.corner_radius_level4'))
    }

    @Styles pressedStylesColumn() {
        .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
        .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
    }

    @Styles actionButtonPressStyles() {
        .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStylesColumn
        })
    }

    @Styles actionColumnPressStyles() {
        .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStylesColumn
        })
    }
    @State currentIndex: number = 0;
    private tabsController: TabsController = new TabsController();
    @StorageLink('isVDEFoldPhoneAndFoldedState') @Watch('onFoldStatusChange') isVDEFoldPhoneAndFoldedState
        : boolean = false;
    @StorageLink('foldStatus') @Watch('getWallpaper') foldStatus
        : number = 0;
    @State isVDE: boolean = this.isVDEFoldPhoneAndFoldedState && this.foldStatus === 2 ? true : false
    @StorageLink('listIsScrolling') isScrolling: boolean = false;
    @State isNeedReuse: boolean = false;
    @Provide menuItems: Array<menuItemObj> = this.initializingMenuItems();
    @State isScrollingStart: boolean = false;
    @State isScrollingEnd: boolean = false;
    @State isOverView: boolean = false;
    private initialCurrentYOffset: number = 0;
    @State dividerModifier: DividerModifier = new DividerModifier().height(0);
    private clearBlockedPage: boolean = false;
  // 窗口状态变化，当window上滑失去焦点时，折叠机保存草稿后，会话列表设置会话选中状态
  @StorageLink('windowStageEventType') @Watch('windowStageEventTypeChange')
  windowStageEventType: window.WindowStageEventType = window.WindowStageEventType.SHOWN
    private onFoldStatusChange(): void {
        if (this.isVDEFoldPhoneAndFoldedState) {
            HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
        } else {
            HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
        }
    }

  // conversationListMenu(isOsAccountConstraintEnabled: boolean): HdsNavigationBadgeIconOptions[] {
  //   return [
  //   {
  //     content: {
  //       label: $r('app.string.new_message'),
  //       icon: new SymbolGlyphModifier($r('sys.symbol.plus'))
  //         .width($r('app.float.icon_side_length_medium'))
  //         .height($r('app.float.icon_side_length_medium'))
  //         .id('newBuildButton')
  //         .draggable(false)
  //         .fontSize('24vp')
  //         .fontColor([$r('sys.color.ohos_id_color_primary')]),
  //       isEnabled: !isOsAccountConstraintEnabled,
  //       action: () => {
  //         let curBp: string = AppStorage.get('curBp') as string;
  //         if (curBp !== common.STR.DEVICE_MOBILE_PHONE) {
  //           AppStorage.set('selectPhoneNumber', '')
  //           this.mConListCtrl.pageInfos.clear();
  //           this.mConversationCtrl.setDraftModel((draftModelIsNull: boolean) => {
  //             if (!draftModelIsNull) {
  //               DraftUtils.getInstance().saveDraft(this.context)
  //             }
  //             this.mConListCtrl.pageInfos.replacePathByName('CreateNewConversation', {
  //               isNewMsg: true,
  //               isConversationNewMsg: true,
  //             });
  //           })
  //           this.mConListCtrl.lastIndex = -1;
  //         } else {
  //           this.mConListCtrl.pageInfos.pushPathByName('CreateNewConversation', {
  //             isNewMsg: true,
  //             isConversationNewMsg: true,
  //           } as LooseObject);
  //         }
  //         // 新建信息打点
  //         MmsPreferences.getInstance()
  //           .setValueToMap(common.STR.KEY_OF_SELECTED_SLOTID, common.int.SIM_ONE);
  //         DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.SMSLIST_NEWPAGE);
  //       }
  //     }
  //   },
  //   {
  //     content: {
  //       label: $r('app.string.more_options_button'),
  //       icon: new SymbolGlyphModifier($r('sys.symbol.dot_grid_2x2'))
  //         .width('24vp')
  //         .height('24vp')
  //         .draggable(false)
  //         .id('settingMoreButton')
  //         .fontSize('24vp')
  //         .fontColor([$r('sys.color.ohos_id_color_primary')]),
  //       isEnabled: true,
  //       componentId: 'HdsConversationList',
  //       action: () => {
  //         // menu第二个button
  //         let uiContext = this.getUIContext();
  //         let promptAction = uiContext.getPromptAction();
  //         let contentNode = new ComponentContent(uiContext, wrapBuilder<[ParamsInterface]>(menuComponent),
  //           {
  //             totalCount: this.totalCount,
  //             unreadTotal: this.unreadTotal,
  //             mConListCtrl: this.mConListCtrl,
  //             isVDE: this.isVDE,
  //             settingShow: () => {
  //               this.isSettingShow = true
  //             },
  //             context: this.context,
  //             patternControl: this.patternControl,
  //             unReadBlockedNum: SharedPreferencesUtils.getFromPreferences('unReadBlockedNum', 0) as number
  //           } as ParamsInterface);
  //         try {
  //           promptAction.openMenu(
  //             contentNode,
  //             { id: 'HdsConversationList' },
  //             { placement: Placement.BottomRight })
  //         } catch (error) {
  //           let message = (error as BusinessError).message;
  //           let code = (error as BusinessError).code;
  //           HiLog.e(TAG, `zhy openMenu args error code is ${code}, message is ${message}`);
  //         }
  //       }
  //     }
  //   },
  // ]}

  getWallpaper() {
        if (this.isVDEFoldPhoneAndFoldedState) {
            HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
            if (this.foldStatus === 2) {
                this.isVDE = true
              let currentPage: string[] = this.mConListCtrl.pageInfos?.getAllPathName();
              if (currentPage.length >= 1 && (currentPage[0] == 'Settings' ||
                currentPage[0] == 'RcsHomePageChatbotActivity')) {
                HiLog.i(TAG, 'getWallpaper clear!');
                this.mConListCtrl.pageInfos?.clear();
              }
            } else {
                this.isVDE = false
            }
            this.menuItems = this.initializingMenuItems();
            HiLog.i(TAG, 'isVDE :' + this.isVDE);
        } else {
            this.isVDE = false
            HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
        }
    }

    onFontSizeScale() {
        this.sessionListHeight = this.fontSizeScale >= 1.45 ? (this.fontSizeScale * 60) -
        px2vp(1) : (this.fontSizeScale * 80) - px2vp(1);
    }

    isFirstMmsChange() {
        HiLog.i(TAG, 'isFirstMmsChange：' + JSON.stringify(this.isFirstMms))
    }

    public async updateRcsStatus():Promise<void>{
      HiLog.i(TAG, 'isRcsStatus: ' + this.isRcsStatus);
      if(this.isRcsStatus) {
        this.isVisibleRcs = true;
      } else{
        this.isVisibleRcs = false;
      }
      return;
    }
    hasInfoMsgChange() {
        if (this.hasInfoMsg) {
            this.mConListCtrl.messageDataStatus = common.MSG_DATA_STATUS.MSG_NO_EMPTY
        } else {
            this.mConListCtrl.messageDataStatus = this.mConListCtrl.messageList.length > 0 ?
                common.MSG_DATA_STATUS.MSG_NO_EMPTY : common.MSG_DATA_STATUS.MSG_EMPTY
        }
        HiLog.i(TAG, 'hasInfoMsgChange  messageDataStatus:' + this.mConListCtrl.messageDataStatus)
    }

    onMultipleSelectState() {
        if (this.mIsMultipleSelectState) {
            HiLog.i(TAG, 'onMultipleSelectState')
            this.mConListCtrl.closeItemEnd();
        }
    }

    updateGetSimStatus():void{
        HiLog.i(TAG, 'updateGetSimStatus:'+this.isGetSim);
        if(!this.isGetSim){
            HiLog.i(TAG, 'updateGetSimStatus111:'+this.isGetSim);
            this.messageSwitch=false;
            this.interState=false;
        }
    }
    updateIsOpenStatus():void{
        HiLog.i(TAG, 'isRcsStatus:' + this.isOpenRcsStatus);
        if(this.isOpenRcsStatus) {
            this.messageSwitch=false;
        } else{
            this.messageSwitch=true;
            this.interState=false;
            if(this.mConListCtrl.isAirPlaneMode){
                this.messageSwitch=false;
            }
        }
        this.updateCellularDataStatus()
        return;
    }

    async updateCellularDataStatus(): Promise<void> {
        HiLog.i(TAG, 'updateCellularDataStatus:' + this.isCellularOpen);
        if (this.isCellularOpen!==null){
            if (this.isCellularOpen) {
                this.interState = false;
            } else {
                if (this.messageSwitch) {
                    this.interState = false;
                } else {
                    let isFirstInMms: boolean = await this.mConListCtrl.isFirstInMmsGet();
                    if (isFirstInMms) {
                        this.interState = true;
                    } else {
                        this.interState = false;
                    }
                }
            }
        }
        HiLog.i(TAG, 'interState:' + this.interState);
        return;
    }

    changeSelectState() {
        if (!this.isSessionVisible && this.mConListCtrl.isFirstPageReady) {
          this.isSessionVisible = true
          HiLog.i(TAG, 'show infoMsg');
        }
        clearTimeout(this.changeSelectTimer);
        this.mIsMultipleSelectState = this.mConListCtrl.isMultipleSelectState;
        if (this.isVDE && this.mIsMultipleSelectState && this.isScrolling) {
          this.isScrolling = false;
        }
        this.changeSelectTimer = setTimeout(() => {
            this.unreadTotal = this.mConListCtrl.unreadTotal;
            this.unreadTotalOfInfo = this.mConListCtrl.unreadTotalOfInfo;
            this.isShowHeadIcon = this.mConListCtrl.isShowContactHeadIcon;
            this.totalCount = this.mConListCtrl.conversationListDataSource.totalCount();
            this.isRepair = this.mConListCtrl.isRepair;
        }, 100)
    }

  windowStageEventTypeChange() {
    let flag: boolean = AppStorage.get('isWindowStageSaveDraft') as boolean;
    HiLog.i(TAG, 'windowStageEventTypeChange');
    if (flag) {
      HiLog.i(TAG, 'windowStageEventTypeChange setItemSelect');
      AppStorage.setOrCreate('isWindowStageSaveDraft', false);
      if (this.mConListCtrl.conversationListDataSource.mmsList.length > 0) {
        let item: messageType = new messageType();
        item = this.mConListCtrl.conversationListDataSource.mmsList[0];
        item.index = 0;
        this.listItemClick(item);
      }
    }
  }

    unReadTotalChanged() {
      this.conversationListMenuItems();
      if (this.unreadTotal != 0) {
        animateTo({ curve: curves.responsiveSpringMotion() }, () => {
          this.showMainTitle = false;
          this.subTitle =
            this.context.resourceManager.getPluralStringValueSync($r('app.plural.unread_messages').id, this.unreadTotal);
          });
      } else {
        animateTo({ curve: curves.responsiveSpringMotion() }, () => {
          this.showMainTitle = true;
          this.subTitle = '';
        });
      }
      this.mainTitle = this.context.resourceManager.getStringSync($r('app.string.messages').id) + ' ';
    }

    unreadTotalNoZero() {
      if (this.unreadTotal != 0) {
        animateTo({ curve: curves.responsiveSpringMotion() }, () => {
          this.showMainTitle = false;
          this.subTitle =
            this.context.resourceManager.getPluralStringValueSync($r('app.plural.unread_messages').id, this.unreadTotal);
        });
      } else {
        animateTo({ curve: curves.responsiveSpringMotion() }, () => {
          this.showMainTitle = true;
          this.subTitle = '';
        });
      }
      this.mainTitle = this.context.resourceManager.getStringSync($r('app.string.messages').id) + ' ';
    }

    async conversationListMenuItems() {
        HiLog.w(TAG, '[unReadTotalChanged] totalSessionListCount: ' + this.totalCount +
          ', unreadTotal: ' + this.unreadTotal);
        this.unreadTotalNoZero();
        this.menuItems[0].enabled = this.totalCount == 0 ? false : true;
        this.menuItems[2].enabled = this.unreadTotal == 0 ? false : true;
    }

    initializingMenuItems() {
        let menuItems: menuItemObj[] = [
            {
                value: $r('app.string.delete'),
                action: () => {
                    this.jumpToDeleteMenu();
                },
                enabled: this.totalCount == 0 ? false : true,
                //enabled: this.mConListCtrl.conversationListDataSource.totalCount() == 0 ? false : true,
                color: $r('sys.color.ohos_id_color_text_primary'),
                visible: true
            },
            {
                value: $r('app.string.favorites'),
                action: () => {
                    this.jumpToFavoritesMenu();
                },
                enabled: true,
                color: $r('sys.color.ohos_id_color_text_primary'),
                visible: true
            },
            {
                value: $r('app.string.markAllAsRead'),
                action: () => {
                    this.jumpToMarkAllAsReadMenu();
                },
                enabled: this.unreadTotal == 0 ? false : true,
                // enabled: this.mConListCtrl.unreadTotal == 0 ? false : true,
                color: $r('sys.color.ohos_id_color_text_primary'),
                visible: true
            },
            {
                value: $r('app.string.settings'),
                action: () => {
                    this.jumpToSettingsMenu();
                },
                enabled: true,
                color: $r('sys.color.ohos_id_color_text_primary'),
                visible: this.isVDE ? false : true
            }
        ];
        return menuItems;
    }

    isRepairChanged() {
        if (this.isRepair) {
            if (!this.mConListCtrl.isOpenRepairModeDialog) {
                this.getMaintenanceMode();
            }
            this.mConListCtrl.isRepair = false;
        }
    }

    private jumpToDeleteMenu() {
        this.mConListCtrl.showMultipleSelectView();
        // 列表-更多操作打点
        seleteParam.SELECT_STATE = 1;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.LIST_MORE_SELECT_EVENT);
    }

    private jumpToFavoritesMenu() {
        this.mConListCtrl.jumpToFavoritesPage();
        // 列表-更多操作打点
        seleteParam.SELECT_STATE = 2;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.LIST_MORE_SELECT_EVENT);
    }

    private jumpToMarkAllAsReadMenu() {
        this.mConListCtrl.clickToMarkAllAsRead(this.context);
        // 列表-更多操作打点
        seleteParam.SELECT_STATE = 3;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.LIST_MORE_SELECT_EVENT);
    }

    private jumpToSettingsMenu() {
        if (!DoubleClickUtil.isFastClick()) {
        // 打开 设置弹窗
        this.isSettingShow = true;
        // 判断 从短信主页入口，用于更多选项中点击设置后，增强信息模态窗口的返回路由path的判断。标明是从短信主页入口
        this.settingShowFromPath = CommonData.rcsFromType.CHATBOT_PAGE;
            // 列表-更多操作打点
            seleteParam.SELECT_STATE = 4;
            DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.LIST_MORE_SELECT_EVENT);
        }
    }

    changeMenuFontColor() {
        for (let i = 0; i < this.menuItems.length; i++) {
            this.menuItems[i].color = this.menuItems[i].enabled ? $r('sys.color.ohos_id_color_text_primary') :
            $r('sys.color.ohos_id_color_text_tertiary');
        }
    }

    async changeMenuItems() {
        if (!await UserUtil.isMainUser()) {
            HiLog.i(TAG, 'conversationListMenuItems is sub user');
            this.patternControl.setSubUser(true);
        }
    }


    private jumpToMarkAllAsRead() {
        this.mConListCtrl.clickToMarkAllAsRead(this.context);
        // 列表-更多操作打点
        seleteParam.SELECT_STATE = 3;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.LIST_MORE_SELECT_EVENT);
    }

    openRepairModeDialog() {
        this.mConListCtrl.isOpenRepairModeDialog = true;
        this.repairModeDialog = new CustomDialogController({
            builder: AlertDialog({
                content: $r('app.string.in_maintenance_mode'),
                primaryButton: {
                    value: $r('app.string.know'),
                    buttonStyle: ButtonStyleMode.TEXTUAL,
                    action: () => {
                        this.mConListCtrl.isOpenRepairModeDialog = false;
                        router.back()
                    }
                }
            }),
            onWillDismiss: (dismissDialogAction: DismissDialogAction)=>{
                dismissDialogAction.reason == DismissReason.PRESS_BACK
            },
            autoCancel: false,
        })
    }

    getMaintenanceMode() {
        HiLog.i(TAG, 'getMaintenanceMode start!');
        systemParameter.get('persist.hiviewcare.maintenancemode').then((value: string) => {
            this.mConListCtrl.isRepairMode = value;
            HiLog.i(TAG, 'maintenanceMode:' + this.mConListCtrl.isRepairMode);
            if (this.mConListCtrl.isRepairMode == 'true') {
                this.openRepairModeDialog();
                this.repairModeDialog?.open();
            }
        })
    }

    getIntegration() {
        let innerEvent: emitter.InnerEvent = {
            eventId: EmitterConstant.EVENT_INTEGRATION_STATUS,
        };
        emitter.on(innerEvent, (eventData: emitter.EventData) => {
            let notificationIntegration: boolean = eventData.data!['notificationIntegration'];
            let integrationSwitchState: boolean = eventData.data!['integrationSwitchState'];
            HiLog.i(TAG, 'int updateSettingPage: ' + JSON.stringify(notificationIntegration) +
              'integrationSwitchState: ' + integrationSwitchState);
            if (!integrationSwitchState) {
              this.mConListCtrl.pageInfos.removeByName('InfoMsg');
            }
            if (notificationIntegration) {
              this.mConListCtrl.onShow(this.context, this.mConListCtrl.pageInfos);
            }
        });
    }

    getShowContact(context: Context) {
        let innerEvent: emitter.InnerEvent = {
            eventId: EmitterConstant.EVENT_SHOW_CONTACT_STATUS,
        };
        emitter.on(innerEvent, (eventData: emitter.EventData) => {
            let showContact:boolean = eventData.data!['showContact'];
            HiLog.i(TAG, 'int showContact' + JSON.stringify(showContact));
            if (showContact) {
                this.mConListCtrl.onShow(context, this.mConListCtrl.pageInfos);
            }
        });
    }

    isListenSettingPage (context: Context){
        if (this.curBp !== common.STR.DEVICE_MOBILE_PHONE) {
            this.getIntegration();
            this.getShowContact(context);
        } else {
            emitter.off(EmitterConstant.EVENT_INTEGRATION_STATUS);
            emitter.off(EmitterConstant.EVENT_SHOW_CONTACT_STATUS);
        }
    }

    showSelectState(item: messageType) {
        if (this.curBp === common.STR.DEVICE_MOBILE_PHONE) {
            return false;
        } else if (!this.isPC && DeviceUtil.isFloatingScreen()) {
            return false;
        } else if (this.selectPhoneNumber === item.telephone ||
          TelephoneUtil.formatDisplayPhoneNumE164(this.selectPhoneNumber) ===
          TelephoneUtil.formatDisplayPhoneNumE164(item.telephone)) {
            return true;
        } else {
            return false;
        }
    }

    getMargin() {
      if (this.isPad) {
        return (this.isShowHeadIcon ? 56 : 0) + this.padMargin
      } else if (this.isPC) {
        return (this.isShowHeadIcon ? 56 : 0) + 24
      } else {
        return (this.isShowHeadIcon ? 56 : 0) + 16
      }
    }

  onSelectCountChanged() {
    HiLog.i(TAG, ` onSelectCountChanged: ${this.conversationListSelectCount}`);
    if (this.multiSelectToolbarList.length === 0) {
      this.initMultiSelectToolBarList();
      return;
    }
    let newDeleteStatus: number = this.conversationListSelectCount === 0 ? ItemState.DISABLE : ItemState.ENABLE;
    let oldDeleteStatus: number = this.multiSelectToolbarList[0].state ?? -1;
    let newSelectAllContentId: number = this.mConListCtrl.isConversationCheckAll ? $r('app.string.msg_deselect_all').id
      : $r('app.string.msg_select_all').id;
    let oldSelectAllContent = this.multiSelectToolbarList[1].content as Resource;
    let oldSelectAllContentId: number = oldSelectAllContent.id;
    // 控制刷新频率，有变化的时候再去刷新
    if (newDeleteStatus !== oldDeleteStatus || newSelectAllContentId !== oldSelectAllContentId) {
      this.multiSelectToolbarList.splice(0);
      this.initMultiSelectToolBarList();
      return;
    }
  }

  initMultiSelectToolBarList() {
    HiLog.i(TAG, ` initMultiSelectToolBarList`);
    this.multiSelectToolbarList.push({
      content: $r('app.string.delete'),
      action: () => {
        this.mConListCtrl.clickConversationDelete();
        this.delDialogController?.open();
      },
      state: this.conversationListSelectCount === 0 ? ItemState.DISABLE : ItemState.ENABLE,
      toolBarSymbolOptions: {
        normal: new SymbolGlyphModifier($r('sys.symbol.trash')).fontColor([$r('sys.color.icon_primary')])
      }
    });
    this.multiSelectToolbarList.push({
      content: this.mConListCtrl.isConversationCheckAll ? $r('app.string.msg_deselect_all')
        : $r('app.string.msg_select_all'),
      action: () => {
        this.mConListCtrl.clickConversationCheckAll();
      },
      state: ItemState.ACTIVATE,
      toolBarSymbolOptions: {
        normal: new SymbolGlyphModifier($r('sys.symbol.checkmark_square_on_square')).fontColor([$r('sys.color.icon_primary')]),
        activated:
        new SymbolGlyphModifier($r('sys.symbol.checkmark_square_on_square_fill'))
          .fontColor([$r('app.color.brand')]),
      },
      activatedTextColor: $r('sys.color.font_emphasize')
    });
  }

    aboutToAppear() {
      if (!this.context) {
        HiLog.w(TAG, 'Initialize getcontext is null!')
        let times = 2;
        while (times > 0) {
          setTimeout(() => {
            this.context = getContext(this) as myCommon.UIAbilityContext;
          }, 100)
          if (this.context) {
            break;
          }
          times --;
        }
        if (!this.context) {
          HiLog.e(TAG, 'retry getcontext failed,context is null!')
        }
      }
        this.onFontSizeScale();
        this.unreadTotal = SharedPreferencesUtils.getFromPreferences(common.STR.KEY_OF_UNREAD_TOTAL, 0) as number;
        this.isFirstMms = SharedPreferencesUtils.getFromPreferences('isFirstMms', false) as boolean
        this.isOpenRcsState = SharedPreferencesUtils.getFromPreferences('isUIOpenRcs', false) as boolean;
        this.isChatbotOn = SharedPreferencesUtils.getFromPreferences('isUIChatbotOpenRcsHasChanged', false) as boolean ?
          SharedPreferencesUtils.getFromPreferences('isUIChatbotOpenRcs', false) as boolean : this.isOpenRcsState;
        this.updateRcsStatus()
        HiLog.i(TAG, 'isFirstMmss:' + this.isFirstMms + ';isRcsOpen:' + this.isRcsOpen + ';isRcsStatus:' + this.isRcsStatus);
        this.mConListCtrl.unreadTotal = this.unreadTotal;
        let num = SharedPreferencesUtils.getFromPreferences(common.STR.KEY_OF_UNREAD_INFO, 0) as number;
        HiLog.w(TAG, '[aboutToAppear] unread count from preference, unreadTotal: ' +
          this.unreadTotal + ', unreadTotalOfInfo: ' + num);
        this.mConListCtrl.unreadTotalOfInfo = num;
        this.unreadTotalOfInfo = num;
        AppStorage.setOrCreate('unreadTotalOfInfo', this.unreadTotalOfInfo);
        InfoMsgController.getInstance().unreadTotalOfInfo = num;
        HiLog.i(TAG, 'conversationList appear entry');
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_LIST_ABOUT_TO_APPEAR, TraceConstant.TRACE_CONVERSATION_LIST_ABOUT_TO_APPEAR_ID);
        this.buildDelDialog();
        this.getMaintenanceMode();
        this.mConversationCtrl.initSatelliteMode(this.context);
        this.mConListCtrl.registerDataChangeObserver(this.onContactChange, this.context);
        this.mConListCtrl.registerClickStatusBar();
        this.mConListCtrl.simStateChangeInfo();
        this.mConListCtrl.initAirPlaneMode(this.context);
        let innerEvent: emitter.InnerEvent = { eventId: EmitterConstant.EVENT_CHANGE_RCS_SETTING_STATUS }
        emitter.on(innerEvent, (valueObj: emitter.EventData) => {
            HiLog.i(TAG, 'emitter.on' + JSON.stringify(valueObj));
            this.updateIsOpenStatus();
        })
        if (this.unreadTotal != 0) {
            this.showMainTitle = false;
            this.subTitle = this.context.resourceManager.getPluralStringValueSync($r('app.plural.unread_messages').id, this.unreadTotal);
        } else {
            this.showMainTitle = true;
            this.subTitle = '';
        }
        AppStorage.set('isShowFromCheckAll', false);
        this.mainTitle = this.context.resourceManager.getStringSync($r('app.string.messages').id) + ' ';
        if (this.curBp !== common.STR.DEVICE_MOBILE_PHONE) {
            this.getIntegration();
            this.getShowContact(this.context);
        }
        this.changeMenuItems();
        hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_LIST_ABOUT_TO_APPEAR,TraceConstant.TRACE_CONVERSATION_LIST_ABOUT_TO_APPEAR_ID);
        this.isPad = DeviceUtil.isTablet();
        HiLog.i(TAG, 'conversationlist appear end');

        this.storageMessageTimeout.context = getContext(this);
        this.storageMessageTimeout.checkOutMessageStorageByTaskPool();
        setTimeout(()=> {
          if (!this.isSessionVisible) {
            // 如果 1000ms 都没有查询到首页列表，先提前加载通知信息会话
            this.isSessionVisible = true;
            HiLog.e(TAG, 'set isSessionVisible late');
          }
        }, 1000)
      let swipeActionStateInnerEvent: emitter.InnerEvent = { eventId: EmitterConstant.EVENT_SWIPE_ACTION_CLOSE };
      emitter.on(swipeActionStateInnerEvent, () => {
        this.listScroller.closeAllSwipeActions();
        AppStorage.setOrCreate('swipeActionState', SwipeActionState.COLLAPSED);
      });
      this.initMultiSelectToolBarList();
    }

    private buildDelDialog() {
        this.delDialogController = new CustomDialogController({
            builder: CustomContentDialog({
                contentBuilder: () => {
                    this.deleteDialogBuildContent();
                },
                buttons: [
                    {
                        value: $r('app.string.cancel'),
                        buttonStyle: DeviceUtil.isPC() ? ButtonStyleMode.NORMAL : ButtonStyleMode.TEXTUAL,
                        role:ButtonRole.NORMAL,
                        action: () => {
                            if (!this.mIsMultipleSelectState) {
                                MmsPreferences.getInstance().setShowDelDialog(common.bool.TRUE);
                            }
                            this.mConListCtrl.deleteDialogCancel();
                            this.currentDeleteIndex = -1;
                            // 删除会话弹窗-取消打点
                            stateParam.DIALOG_STATE = 2;
                            stateParam.PAGE_STATE = 1;
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
                        buttonStyle: DeviceUtil.isPC() ? ButtonStyleMode.NORMAL : ButtonStyleMode.TEXTUAL,
                        action: () => {
                            this.currentHasReadIndex = -1;
                            if (this.currentDeleteIndex !== -1) {
                                this.mConListCtrl.deleteAction(this.currentDeleteIndex);
                                this.currentDeleteIndex = -1;
                            }
                            this.mConListCtrl.deleteDialogConfirm(this.context);
                            // 删除会话弹窗-确认打点
                            stateParam.DIALOG_STATE = 1;
                            stateParam.PAGE_STATE = 1;
                            DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.DELETE_SESSION_EVENT);
                            this.deleteTimerTrue = setTimeout(() => {
                              this.isDeleting = true;
                              this.deleteTimerFalse = setTimeout(() => {
                                this.isDeleting = false;
                              }, 20);
                            }, 200);
                        },
                        role: DeviceUtil.isPC() ? ButtonRole.NORMAL : ButtonRole.ERROR
                    }
                ]
            }),
          autoCancel: true,
          cancel: () => {
            if (!this.mIsMultipleSelectState) {
              MmsPreferences.getInstance().setShowDelDialog(common.bool.TRUE);
            }
            this.mConListCtrl.deleteDialogCancel();
            this.currentDeleteIndex = -1;
            // 删除会话弹窗-取消打点
            stateParam.DIALOG_STATE = 2;
            stateParam.PAGE_STATE = 1;
            DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.DELETE_SESSION_EVENT);
            try {
              this.listScroller.closeAllSwipeActions();
            } catch (err) {
              HiLog.w(TAG, `listScroller.closeAllSwipeActions error: ${err}`)
            }
          }
        });
    }

    @Builder
    deleteDialogBuildContent(): void {
        DeleteDialog({
            msg: this.mConListCtrl.strMsgDeleteDialogTip,
            mIsMultipleSelectState: this.mIsMultipleSelectState
        })
    }

    public onContactChange = (e: BusinessError, info: dataShare.ChangeInfo) => {
        // 监听到联系人变化，定时任务结束后开始刷新
        let timeoutDelay = ContactsUpdateRecords.getInstance().contactsUpdateEvent()
        HiLog.i(TAG, 'onContactChange: after the timer [' + timeoutDelay +
            ']ms expires, the actual onContactDataChange will start')
        GlobalContext.getContext().setObject('needToUpdate', true)
        clearTimeout(this.debounceTimer);
      if (info.values.length > 0) {
        let changeContactIdString: string = info.values[0]['updateIdStr'] as string;
        if (!StringUtil.isEmpty(changeContactIdString)) {
          let changeRowContactIds: string[] = changeContactIdString.split(',');
          for (let index = 0; index < changeRowContactIds.length; index++) {
            this.contactUpdateIds.set(changeRowContactIds[index],changeRowContactIds[index])
          }
        }
      }
        this.debounceTimer = setTimeout(() => {
            // 定时器结束，开始刷新
            HiLog.i(TAG, 'onContactDataChange: the timer has expired, and onContactDataChange is being triggered');
            if (e) {
                HiLog.e(TAG, 'Contact change error: ' + JSON.stringify(e))
                return;
            }
            let refresh: boolean = false;
            if (DeviceUtil.isPC() && this.mConListCtrl.lastIndex === -1) { // 新建信息时联系人变化刷新页面
              refresh = true;
            }
            this.mConListCtrl.tryUpdateSessionContactInfo(this.context, refresh /* refresh item */);
            this.receiveCtrl.dealRefreshContact(this.context);
            AppStorage.set('contactAvatarShow', this.getPhotoPixelMap = !this.getPhotoPixelMap);
          if (this.contactUpdateIds.size > 0) {
            this.mConListCtrl.refreshListWithUpdateIdStr(this.context, this.contactUpdateIds);
            this.contactUpdateIds.clear();
          }
        }, timeoutDelay);

    }

    onPageShow() {
      hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_LIST_ON_PAGE_SHOW,
        TraceConstant.TRACE_CONVERSATION_LIST_ON_PAGE_SHOW_ID);
      if (this.unreadTotal != 0) {
        this.showMainTitle = false;
        this.subTitle =
          this.context.resourceManager.getPluralStringValueSync($r('app.plural.unread_messages').id, this.unreadTotal);
      } else {
        this.showMainTitle = true;
        this.subTitle = '';
      }
      hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_LIST_ON_PAGE_SHOW,
        TraceConstant.TRACE_CONVERSATION_LIST_ON_PAGE_SHOW_ID);
    }

    /**
     * Function executes before custom component destructor consumption.
     * Allow changes to state variables in the aboutToDisappear function, especially changes to the @Link variable,
     * can cause erratic application behavior.
     */
  aboutToDisappear() {
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_LIST_ABOUT_TO_DISAPPEAR,
      TraceConstant.TRACE_CONVERSATION_LIST_ABOUT_TO_DISAPPEAR_ID);
    this.mConListCtrl.unregisterDataChangeObserver(this.onContactChange, getContext(this));
    this.mConListCtrl.unregisterClickStatusBar();AppStorage.Delete('unreadTotalOfInfo');
    AppStorage.Delete('hasInfoMsg');
    this.mConListCtrl.removeAirPlaneMode();
    this.isSettingShow = false;
    clearTimeout(this.deleteTimerTrue);
    clearTimeout(this.deleteTimerFalse);
    emitter.off(EmitterConstant.EVENT_CHANGE_RCS_SETTING_STATUS);
    emitter.off(EmitterConstant.EVENT_SWIPE_ACTION_CLOSE);
    hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_LIST_ABOUT_TO_DISAPPEAR,
      TraceConstant.TRACE_CONVERSATION_LIST_ABOUT_TO_DISAPPEAR_ID);
    DateRefreshUtil.getInstance().onDestroy();
  }

    private isUnPin(pinningTime: number): boolean {
      return pinningTime > 0;
    }

    @Builder
    itemEnd(item: messageType, onDeleteBtn: () => void) {
        Row() {
            if (this.swipeActionShowList.indexOf(item.index) !== -1) {
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

    isNeedvibrations(item: messageType, widOld: Length, widNew: Length) {
        if ((Number.parseInt(widNew.toString()) >=
        CommonData.MESSAGEHOME_DELETE.DELETE_SWIPE_BODY_TWOBUTTON_WIDTH && Number.parseInt(widOld.toString()) <=
        CommonData.MESSAGEHOME_DELETE.DELETE_SWIPE_BODY_TWOBUTTON_WIDTH) || (Number.parseInt(widNew.toString()) <=
        CommonData.MESSAGEHOME_DELETE.DELETE_SWIPE_BODY_TWOBUTTON_WIDTH && Number.parseInt(widOld.toString()) >=
        CommonData.MESSAGEHOME_DELETE.DELETE_SWIPE_BODY_TWOBUTTON_WIDTH)) {
            if (!this.isOnceVibration) {
                VibrationUtils.onceVibration(common.VIBRATIONEFFECT.DRAG);
            }
            this.isOnceVibration = true;
        } else {
            this.isOnceVibration = false;
        }
    }

  // 计算开关数量
  switchNumber(): number {
    let number = 0
    // 应用号
    if (!this.isVDE && this.isOpenRcsState && this.isRcsStatus && this.isChatbotOn) {
      number++
    }
    // 通知信息
    if (this.mConListCtrl.hasAggregate && this.mConListCtrl.hasInfoMsg) {
      number++
    }
    return number
  }

    /* 侧滑删除按钮动画 */
    itemEndAnimal(item: messageType, oldValue: Area, newValue: Area) {
        if (this.itemEndDustbinAnimationEnabled) {
            let widNew: Length = newValue.width;
            let widOld: Length = oldValue.width;
            this.isNeedvibrations(item, widOld, widNew);
            if (widNew < CommonData.MESSAGEHOME_DELETE.DELETE_SWIPE_BODY_TWOBUTTON_WIDTH) {
              this.isHideReadButton = false;
              this.isShowPinButton = true;
              this.isShowUnPinButton = true;
            }
            this.itemEndHeadAngle = Math.min(CommonData.MESSAGEHOME_DELETE.MAX_HEAD_ANGLE,
                Math.max((Number(widNew) - (CommonData.MESSAGEHOME_DELETE.DELETE_SWIPE_HEAD_TWOBUTTON_WIDTH)) /
                CommonData.MESSAGEHOME_DELETE.ACTION_AREA_DISTANCE *
                CommonData.MESSAGEHOME_DELETE.ANGLE_RADIO, 0.0));
            this.itemEndBodyAngle = Math.min(CommonData.MESSAGEHOME_DELETE.MAX_BODY_ANGLE,
                Math.max((Number(widNew) - (CommonData.MESSAGEHOME_DELETE.DELETE_SWIPE_BODY_TWOBUTTON_WIDTH)) /
                CommonData.MESSAGEHOME_DELETE.ACTION_AREA_DISTANCE * 24.35, 0.0));
            this.itemEndSwipeScale = Math.min(CommonData.MESSAGEHOME_DELETE.MAX_SCALE_RATIO,
                (Number(widNew) - (CommonData.MESSAGEHOME_DELETE.DELETE_SWIPE_HEAD_TWOBUTTON_WIDTH)) /
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
    .visibility((!this.isHideReadButton && item?.messageCount > 0 &&
      item.contactsNum <= 1) ? Visibility.Visible : Visibility.None)
    .onClick(() => {
      stateParam.READ_STATE = item?.countOfUnread > 0 ? 0 : 1;
      this.menuReadOrUnRead(item, item?.countOfUnread, item?.telephone);

      // 列表左滑标记已读打点
      stateParam.PAGE_STATE = 1;
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

    unPinAction(threadId: number, pressIndex:number) {
      this.onClickUnpin(threadId, pressIndex);
    }

    pinAction(threadId: number, pressIndex:number) {
      this.onClickPin(threadId, pressIndex);
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
          this.onClickUnpin(item.threadId, item.index);
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
      this.mConListCtrl.pinSessionSize += 1;
      this.currentPinOptIndex = index;
      try {
        let time = new Date().getTime();
        ConversationListService.getInstance().updateSessionPinningTime(threadId, time, () => {
          this.mConListCtrl.updateConversationListMsg(this.context, index, false);
          setTimeout(() => {
            this.currentPinOptIndex = -1;
          }, 100);
        }, this.context);
      } catch (error) {
        HiLog.e(TAG, 'onClickPin update pinningTime error : ' + JSON.stringify(error));
      }
    }

    private onClickUnpin(threadId: number, index: number) {
      AccessibilityUtil.announceForAccessibility(getContext(this).resourceManager
        .getStringSync($r('app.string.screen_read_msg_unpin').id));
      this.mConListCtrl.pinSessionSize -= 1;
      this.currentPinOptIndex = index;
      try {
        ConversationListService.getInstance().updateSessionPinningTime(threadId, 0, () => {
          this.mConListCtrl.updateConversationListMsg(this.context, index, true);
          setTimeout(() => {
            this.currentPinOptIndex = -1;
          }, 100);
        }, this.context);
      } catch (error) {
        HiLog.e(TAG, 'onClickUnpin update pinningTime error : ' + JSON.stringify(error));
      }
    }

    @Builder
    itemEndDeleteButton() {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
            Image($rawfile('icon/ic_delete_head.svg'))
                .height(5)
                .width(20)
                .id('conversationListDeleteButton1')
                .draggable(false)
                .rotate({
                    x: 0,
                    y: 0,
                    z: 1,
                    centerX: Configuration.getLocale().dir === 'rtl' ? 0 : '100%',
                    centerY: '100%',
                    angle: Configuration.getLocale().dir === 'rtl' ? (-1) * this.itemEndHeadAngle : this.itemEndHeadAngle,
                })
            Image($rawfile('icon/ic_delete_body.svg'))
                .height(16)
                .width(16)
                .id('conversationListDeleteButton2')
                .draggable(false)
                .rotate({
                    x: 0,
                    y: 0,
                    z: 1,
                    centerX: Configuration.getLocale().dir === 'rtl' ? 0 : '100%',
                    centerY: 0,
                    angle: Configuration.getLocale().dir === 'rtl' ? (-1) * this.itemEndBodyAngle : this.itemEndBodyAngle,
                })
        }
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.delete').id))
        .accessibilityRole(AccessibilityRoleType.BUTTON)
        .width('40vp')
        .height('40vp')
    }

    @Builder infoMsgEnd() {
        Row() {
            if (this.mConListCtrl.unreadTotalOfInfo > 0) {
                Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center,
                    alignItems: ItemAlign.Center }) {
                  SymbolGlyph($r('sys.symbol.checkmark_message_fill'))
                    .accessibilityLevel('no')
                    .draggable(false)
                    .fontSize('24vp')
                    .fontColor([Color.White])
                }
                .onClick(() => {
                    this.mInfoMsgCtrl.onShow(this.context);
                  try {
                    this.listScroller.closeAllSwipeActions();
                  } catch (err) {
                    HiLog.w(TAG, `listScroller.closeAllSwipeActions error: ${err}`)
                  }
                    this.mInfoMsgCtrl.clickToMarkAllAsReadForInfo(this.context);
                    this.mConListCtrl.markInfoMsgAllAsRead();
                    // 通知-列表左滑标记已读打点
                    DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.NOTICELIST_SWIPE_LEFT_READ);
                })
                .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.set_read_button').id))
                .width('40vp')
                .height('40vp')
                .backgroundColor($r('sys.color.ohos_id_color_palette2'))
                .borderRadius('20vp')
            }
        }
        .padding({ left: $r('sys.float.margin_left'), right: $r('sys.float.margin_right') })
        .justifyContent(FlexAlign.SpaceEvenly)
        .height('100%')
        .backgroundColor($r('sys.color.ohos_id_color_hover'))
    }

    @Builder
    NavigationMenus() {
        if (!DeviceUtil.isPC()) {
            Row() {
                // Menu Bar
                this.navigationRow();
            }
            .padding(this.isVDE ? { top: 0, right: this.isPad ? this.padMargin : $r('sys.float.margin_right'),
              left: Configuration.getLocale().dir === 'rtl' ? $r('sys.float.padding_level8') : 0 } :
              Configuration.getLocale().dir === 'rtl' ?
                { top: 0, left: this.isPad ? this.padMargin : $r('sys.float.margin_right') } :
                { top: 0, right: this.isPad ? this.padMargin : $r('sys.float.margin_right') })
            .height('56vp')
            .opacity(1)
        } else {
          Row() {
            Row() {
              Image($r('app.media.message_icon'))
                .renderGroup(true)
                .id('ic_bell_fill')
                .width('24vp')
                .height('24vp')
                .draggable(false)
                .syncLoad(true)
              Text($r('app.string.messages'))
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontFamily('HarmonyHeiTi')
                .margin({ left: 12 })
                .onClick(()=>{
                })
            }.margin({ left: 24 }).height('56vp')
            // Menu Bar
            Row() {
              this.navigationRow();
            }.alignItems(VerticalAlign.Center).height('56vp').margin({ right: 24 })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          .height('56vp')
      }
    }

    @Builder
    settingsBuilder() {
      Settings({
        onClose: () => {
          this.onSettingsClose();
        }
      })
        .width('100%')
        .height('100%')
    }

    @Builder
    navigationRow() {
      Row() {
        if (!this.mConListCtrl.isMultipleSelectState) {
          Column() {
            this.navigationImg();
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .actionButtonPressStyles()
          .borderRadius(20)

          Blank().width(24)
          Column() {
            SettingMenu({
              moreMenuItems: this.menuItems,
            })
          }.width(40).height(40)
          .onAppear(() => {
          })
        }
      }
      .width('50%')
      .height($r('app.float.id_item_height_large'))
      .margin({
        // top: this.fullScreenPadding?.top,
        right: $r('app.float.menu_layout_padding_right'),
        left: $r('app.float.menu_layout_padding_left')
      })
      .justifyContent(FlexAlign.End)
    }


    @Builder
    navigationImg() {
        Button() {
            SymbolGlyph($r('sys.symbol.plus'))
                .width($r('app.float.icon_side_length_medium'))
                .height($r('app.float.icon_side_length_medium'))
                .id('newBuildButton')
                .draggable(false)
                .fontSize('24vp')
                .fontColor([$r('sys.color.ohos_id_color_primary')])
        }
        .accessibilityText(this.context.resourceManager.getStringSync($r('app.string.new_message').id))
        .onClick(() => {
            let curBp: string = AppStorage.get('curBp') as string;
            /*AppStorage.setOrCreate('ShowNewMmsParams', {
                isNewMsg: true,
                isConversationNewMsg: true
            });
            this.isShowNewMms = true;*/
            if (curBp !== common.STR.DEVICE_MOBILE_PHONE) {
                AppStorage.set('selectPhoneNumber', '')
                //AppStorage.set('isShowNewMms', true);
                this.mConListCtrl.pageInfos.clear();
                this.mConversationCtrl.setDraftModel((draftModelIsNull: boolean) => {
                    if (!draftModelIsNull) {
                        DraftUtils.getInstance().saveDraft(this.context)
                    }
                    this.mConListCtrl.pageInfos.replacePathByName('CreateNewConversation', {
                        isNewMsg: true,
                        isConversationNewMsg: true,
                    });
                })
                this.mConListCtrl.lastIndex = -1;
            } else {
                this.mConListCtrl.pageInfos.pushPathByName('CreateNewConversation', {
                    isNewMsg: true,
                    isConversationNewMsg: true,
                } as LooseObject);
            }
            // 新建信息打点
            HiLog.i(TAG, `CreateNewConversation, set KEY_OF_SELECTED_SLOTID SIM_ONE`);
            MmsPreferences.getInstance()
                .setValueToMap(common.STR.KEY_OF_SELECTED_SLOTID, common.int.SIM_ONE);
            DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.SMSLIST_NEWPAGE);
        })
        .width('40vp')
        .height('40vp')
        .backgroundColor(DeviceUtil.isPC() ? Color.Transparent : $r('sys.color.ohos_id_color_button_normal'))
        .type(ButtonType.Circle)
        .stateEffect(false)
        .visibility(this.mConListCtrl.isOsAccountConstraintEnabled ? Visibility.None : Visibility.Visible);
    }

    @Builder
    navTitle() {
      if (!DeviceUtil.isPC()) {
        Row() {
            if (this.mConListCtrl.isMultipleSelectState) {
                Button({ type: ButtonType.Circle, stateEffect: true }) {
                    SymbolGlyph($r('sys.symbol.xmark'))
                        .fontColor([$r('sys.color.ohos_id_color_primary')])
                        .fontSize('24vp')
                        .draggable(false)
                        .id('listMoreButton')
                        .width(24)
                        .height(24)
                }
                .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.off').id))
                .width(40)
                .height(40)
                .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
                .draggable(false)
                .borderRadius(20)
                .onClick(() => {
                    this.mConListCtrl.onBackPress(this.context);
                    // 长按取消删除打点
                    longPressDeParams.PAGE_STATE = 1;
                    DotUtil.getInstance()
                        .reportEvent(longPressDeParams, dotCommon.eventName.LONGPRESS_SELECT_CANCEL_DELETE);
                })

                    Text(this.mConListCtrl.conversationSelectedNumber === 0 ?
                    $r('app.string.msg_unselected_tip') :
                    $r('app.plural.msg_selected_tip_new', this.mConListCtrl.conversationSelectedNumber,
                      LocationUtil.numFormat(this.mConListCtrl.conversationSelectedNumber)))
                        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
                        .fontWeight(FontWeight.Bold)
                        .fontFamily('HarmonyHeiTi')
                        .margin({ left: 8 })
                }
            }
        .padding({left: this.isPad ? this.padMargin : $r('sys.float.margin_left')})
        .width('100%')
        .height($r('app.float.action_bar_height'))
      } else {
        Row() {
          if (this.mConListCtrl.isMultipleSelectState) {
            Row(){
              Button({ type: ButtonType.Circle, stateEffect: true }) {
                SymbolGlyph($r('sys.symbol.xmark'))
                  .fontColor([$r('sys.color.ohos_id_color_primary')])
                  .fontSize('24vp')
                  .draggable(false)
                  .id('listMoreButton')
                  .width(24)
                  .height(24)
              }
              .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.off').id))
              .width(40)
              .height(40)
              .backgroundColor(Color.Transparent)
              .draggable(false)
              .borderRadius(20)
              .onClick(() => {
                this.mConListCtrl.onBackPress(this.context);
                // 长按取消删除打点
                longPressDeParams.PAGE_STATE = 1;
                DotUtil.getInstance()
                  .reportEvent(longPressDeParams, dotCommon.eventName.LONGPRESS_SELECT_CANCEL_DELETE);
              })
              Text(this.mConListCtrl.conversationSelectedNumber === 0 ?
              $r('app.string.msg_unselected_tip') :
              $r('app.plural.msg_selected_tip_new', this.mConListCtrl.conversationSelectedNumber,
                LocationUtil.numFormat(this.mConListCtrl.conversationSelectedNumber)))
                .fontSize($r('sys.float.ohos_id_text_size_headline8'))
                .fontWeight(FontWeight.Bold)
                .fontFamily('HarmonyHeiTi')
                .margin({ left: 8 })
            }
            Row() {
              ToolBar({
                toolBarList: [
                  {
                    content: '',
                    action: () => {
                      this.mConListCtrl.clickConversationDelete();
                      this.delDialogController?.open();
                    },
                    state: this.mConListCtrl.conversationSelectedNumber === 0
                      ? ItemState.DISABLE : ItemState.ENABLE,
                    toolBarSymbolOptions: {
                      normal: new SymbolGlyphModifier($r('sys.symbol.trash')).fontColor([$r('sys.color.icon_primary')])
                        .fontSize(24)
                    }
                  },
                  {
                    content: '',
                    action: () => {
                      this.mConListCtrl.clickConversationCheckAll();
                    },
                    state: ItemState.ACTIVATE,
                    toolBarSymbolOptions: {
                      normal: new SymbolGlyphModifier($r('sys.symbol.checkmark_square_on_square')).fontColor([$r('sys.color.icon_primary')])
                        .fontSize(24),
                      activated:
                      new SymbolGlyphModifier($r('sys.symbol.checkmark_square_on_square_fill'))
                        .fontColor([$r('app.color.brand')]).fontSize(24),
                    },
                    activatedTextColor: $r('sys.color.font_emphasize')
                  }
                ],
                activateIndex: this.mConListCtrl.isConversationCheckAll ? 1 : -1,
                toolBarModifier: this.toolBarModifier1,
              }).width(100)
            }
          }
        }
        .padding({ left: 24, right: 24 })
        .width('100%')
        .height($r('app.float.action_bar_height'))
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      }
    }

  private toolBarModifier1: ToolBarModifier =
    new ToolBarModifier().backgroundColor(Color.Transparent).stateEffect(false).padding(LengthMetrics.vp(0));

    @Builder
    showNewMms(){
        CreateNewConversation().height('100%').width('100%');
    }

    build() {
      Navigation() {
        // 搜索框
          this.searchBoxBuilder()
        if (this.isSearch && this.isSearchResultEmpty) {
          EmptyPage({
            emptyDescription: $r('app.string.noMessagesSearchResult'), // 搜索无结果专属提示
          })
        }else {
          if (this.mConListCtrl.messageDataStatus ===
          common.MSG_DATA_STATUS.MSG_EMPTY) {
            if (!this.isVDE && this.isOpenRcsState && this.isRcsStatus && this.isChatbotOn) {
              Row() {
                Column() {
                  this.appServiceAccountEntry()
                  Divider().height($r('app.float.settings_divider_strokeWidth'))
                    .margin(Configuration.getLocale().dir === 'rtl' ?
                      {
                        right: (this.isPad && this.isShowHeadIcon) ?
                          56 + this.padMargin :
                          (this.isPad && !this.isShowHeadIcon) ? this.padMargin :
                            this.isShowHeadIcon ? 72 : 16,
                        left: this.isPad ? this.padMargin : 16
                      } :
                      {
                        left: (this.isPad && this.isShowHeadIcon) ?
                          56 + this.padMargin :
                          (this.isPad && !this.isShowHeadIcon) ? this.padMargin :
                            this.isShowHeadIcon ? 72 : 16,
                        right: this.isPad ? this.padMargin : 16
                      })
                    .color($r('sys.color.comp_divider'))
                    .visibility((this.mConListCtrl.conversationListDataSource.mmsList.length >
                      0 || (this.mConListCtrl.hasAggregate && this.mConListCtrl.hasInfoMsg)) ?
                      Visibility.Visible : Visibility.None)
                }
                .padding({
                  left: DeviceUtil.isPC() ? 24 :
                    this.isPad ? this.padMargin : this.marginLeft,
                  right: DeviceUtil.isPC() ? 24 :
                    this.isPad ? this.padMargin : this.marginRight
                })
                .backgroundColor((this.isSelectAppMsg &&
                  this.curBp !== common.STR.DEVICE_MOBILE_PHONE) ?
                  $r('app.color.mms_msg_fold_select_bg') : Color.Transparent)
              }
              .stateStyles({ normal: this.infoNormalStyles, pressed: this.pressedStyles })
              .width('100%')
              .height((['en', 'bo'].includes(this.mConListCtrl.getAppPreferredLanguage()) &&
                this.fontSizeScale > 1.75) ? this.fontSizeScale * 44 :
                this.fontSizeScale > 2 ? this.fontSizeScale * 48 : NUMBER_FIFTY_EIGHT)
            }
            EmptyView()
          } else if (this.mConListCtrl.messageDataStatus ===
          common.MSG_DATA_STATUS.MSG_NO_EMPTY) {
            Stack({ alignContent: Alignment.TopStart }) {
              //会话列表
              Column() {
                //添加2px是防止不同设备DPI不同导致部分Divider视觉不可见（与像素取整相关，组件提供方案，API16可去除）
                List({ space: '2px', scroller: this.listScroller }) {
                  //通知信息
                  if (this.mConListCtrl.hasAggregate && this.mConListCtrl.hasInfoMsg && this.inputText==='') {
                    ListItem() {
                      Column() {
                        Column() {
                          this.infoMsgItem()
                          Divider().height($r('app.float.settings_divider_strokeWidth'))
                            .margin(Configuration.getLocale().dir === 'rtl' ?
                              {
                                right: (this.isPad && this.isShowHeadIcon) ?
                                  56 :
                                  (this.isPad && !this.isShowHeadIcon) ? 0 :
                                    this.isShowHeadIcon ? 56 : 0,
                                left: this.isPad ? this.padMargin - 16 : 0
                              } :
                              {
                                left: (this.isPad && this.isShowHeadIcon) ?
                                  56 :
                                  (this.isPad && !this.isShowHeadIcon) ? 0 :
                                    this.isShowHeadIcon ? 56 : 0,
                                right: this.isPad ? this.padMargin - 16 : 0
                              })
                            .color($r('sys.color.comp_divider'))
                            .visibility((this.mConListCtrl.conversationListDataSource.mmsList.length > 0) ?
                              Visibility.Visible : Visibility.None)
                        }
                        .padding({
                          left: DeviceUtil.isPC() ? 24 :
                            this.isPad ? this.padMargin : this.marginLeft,
                          right: DeviceUtil.isPC() ? 24 :
                            this.isPad ? this.padMargin : this.marginRight
                        })
                        .backgroundColor((this.isSelectInfoMsg &&
                          this.curBp !== common.STR.DEVICE_MOBILE_PHONE) ?
                          $r('app.color.mms_msg_fold_select_bg') : Color.Transparent)
                      }
                      .stateStyles({ normal: this.infoNormalStyles, pressed: this.pressedStyles })
                    }
                    .visibility(this.isSessionVisible ? Visibility.Visible : Visibility.None)
                    .onAppear(() => {
                      HiLog.i(TAG, 'infoMsg onAppear');
                    })
                    .width('100%')
                    // 放大倍数大于2时，原先的固定高度76会导致文字放不下从而与下面内容重叠；修改高度为放大系数*48增加高度
                    // 后续需要将此处高度重构为根据内容自适应
                    .height((['en', 'bo'].includes(this.mConListCtrl.getAppPreferredLanguage()) &&
                      this.fontSizeScale > 1.75) ? this.fontSizeScale * 44 :
                      this.fontSizeScale > 2 ? this.fontSizeScale * 48 : NUMBER_FIFTY_EIGHT)
                    .swipeAction(!this.mIsMultipleSelectState &&
                      this.mConListCtrl.unreadTotalOfInfo > 0 ? {
                      end: {
                        builder: (type: void): void => {
                          this.infoMsgEnd();
                        },
                        onStateChange: (swipeActionState) => {
                          if (swipeActionState === SwipeActionState.EXPANDED) {
                            // 通知-信息左滑打点
                            DotUtil.getInstance().reportEvent(dotNoNeedParmas,
                              dotCommon.eventName.NOTICELIST_SWIPE_LEFT_EVENT);
                          }
                        }
                      },
                      edgeEffect: SwipeEdgeEffect.None
                    } : { edgeEffect: SwipeEdgeEffect.None })
                  }
                  LazyForEach(this.mConListCtrl.conversationListDataSource,
                    (item: messageType, index: number) => {
                      ListItem() {
                        Column() {
                          Row() {
                            MmsListItem({
                              item: item,
                              fatherView: 'Conversation',
                              isMultipleSelectState: this.mIsMultipleSelectState,
                              isInSetReadThreadIndex: this.currentHasReadIndex,
                              isShowHeadIcon: this.isShowHeadIcon,
                              loadFromDB: !this.isShowFromCheckAll,
                              showCount: !this.isShowHeadIcon &&
                                item.countOfUnread > 1,
                              inputText: this.inputText,
                              onClickHead: (clickPosition: number,
                                event: ClickEvent | undefined) => {
                                if (!this.listShowMenu) {
                                  this.mConListCtrl.clickToGroupDetail(this.context, clickPosition);
                                }
                              },
                              onClickCheckBox: (checkIndex: number,
                                value: boolean) => {
                                this.mConListCtrl.clickCheckBox(checkIndex, value);
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
                              showCountOfUnread: this.currentHasReadIndex != item.index,
                              isShowBottomLine: index !==
                                this.mConListCtrl.conversationListDataSource.mmsList.length -
                                  1,
                            })
                              .reuseId(this.isNeedReuse ? 'conversation_list_item' : undefined)
                          }
                          .alignItems(VerticalAlign.Center)
                          .width('100%')
                          .height(this.sessionListHeight)
                          .accessibilityLevel('no')
                          //添加一个空的长按手势是为了屏幕朗读识别播报（单指双击并长按即可执行）
                          .parallelGesture(
                            GestureGroup(GestureMode.Exclusive,
                              LongPressGesture({ repeat: false, duration: 500 })
                                .onAction(() => {
                                })
                            ))
                          .onClick((event?: ClickEvent) => {
                            HiLog.i(TAG, `conversation list item click,${item.threadId},${index}`);
                            item.index = index;
                            this.listItemClick(item, index);
                          })

                        }
                        .width('100%').height('100%')
                        .backgroundColor(this.showSelectState(item) ?
                          $r('app.color.mms_msg_fold_select_bg') : $r('sys.color.background_primary'))
                      }
                      // The lower level of the deletion selection is - 1.
                      .zIndex(this.currentIndexListDel === index ? -1 : 0)
                      .width('100%')
                      .height(this.fontSizeScale >= 1.45 ? (this.fontSizeScale * 60) + 'vp' :
                        (this.fontSizeScale * 80) + 'vp')
                      .swipeAction((!this.mIsMultipleSelectState && !this.isDeleting) ? {
                        end: {
                          builder: this.itemEnd(item, () => {
                            this.currentIndexListDel = item.index;
                            this.deleteAction(item.index);
                            // 列表左滑删除打点
                            stateParam.PAGE_STATE = 1;
                            DotUtil.getInstance().reportEvent(stateParam,
                              dotCommon.eventName.SWIPE_LEFT_TO_DELETE);
                          }),
                          actionAreaDistance: 56,
                          onAction: () => {
                            this.currentIndexListDel = item.index;
                            this.deleteAction(item.index, true);
                          },
                          onStateChange: (swipeActionState) => {
                            AppStorage.setOrCreate('swipeActionState', swipeActionState)
                            HiLog.i(TAG, `swipeActionState ${swipeActionState}`);
                            if (swipeActionState == SwipeActionState.EXPANDED) {
                              // 信息左滑打点
                              stateParam.PAGE_STATE = 1;
                              DotUtil.getInstance().reportEvent(stateParam,
                                dotCommon.eventName.LIST_SWIPE_LEFT_EVENT);
                            }
                          },

                        },
                        edgeEffect: SwipeEdgeEffect.Spring,
                      } : { edgeEffect: SwipeEdgeEffect.Spring })
                      .onTouch((event: TouchEvent) => {
                        this.currentScrollIndex = item.index;
                        if (event.type === TouchType.Down) {
                          this.swipeActionShowList =
                            [this.swipeActionShowList[1], item.index];
                        }
                      })
                    }, (item: messageType, index: number) => {
                      if (index === this.mConListCtrl.conversationListDataSource.totalCount() - 1) {
                        return util.getHash(item)?.toString() + index.toString() + true;
                      }
                      return util.getHash(item)?.toString() + index.toString() + false;
                    })
                  ListItem() {
                    Row().width('100%').height('100%').backgroundColor(Color.Transparent)
                  }.width('100%').height(this.fullScreenPadding?.bottom)
                }
                .gesture(PanGesture({ direction: PanDirection.Vertical })
                  .onActionStart((event: GestureEvent) => {
                    let params: PanGestureAction = {
                      type: common.SLIDE_ACTION_TYPE.START,
                      event,
                      scroller: this.listScroller,
                      isMultipleSelectState: this.mConListCtrl.isMultipleSelectState,
                      switchNumber: this.switchNumber(),
                      mmsList: this.mConListCtrl.conversationListDataSource.mmsList
                    }
                    PanGestureUtil.panGestureAction(params)
                  })
                  .onActionUpdate((event: GestureEvent) => {
                    let params: PanGestureAction = {
                      type: common.SLIDE_ACTION_TYPE.UPDATE,
                      event,
                      scroller: this.listScroller,
                      isMultipleSelectState: this.mConListCtrl.isMultipleSelectState,
                      switchNumber: this.switchNumber(),
                      mmsList: this.mConListCtrl.conversationListDataSource.mmsList,
                      callback: (i: number, startCbChecked: boolean) => {
                        this.mConListCtrl.gesTureListCheckBox(i, startCbChecked)
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
                      isMultipleSelectState: this.mConListCtrl.isMultipleSelectState,
                      switchNumber: this.switchNumber(),
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
                  return PanGestureUtil.gestureRecognizerJudgeBegin(event, current,
                    this.mConListCtrl.isMultipleSelectState,
                    this.listWidth)
                })
                .clipContent(ContentClipMode.SAFE_AREA)
                .margin({ top: DeviceUtil.isPC() ?
                  common.int.HDS_NAVIGATION_BAR_HEIGHT * 2 + (this.fullScreenPadding?.top as number) : 0 })
                .onReachStart(() => {
                  this.initialCurrentYOffset = this.listScroller.currentOffset()?.yOffset;
                })
                .onReachEnd(() => {
                  this.scrollReachEnd = true;
                  if (this.isOverView && this.isScrolling) {
                    HiLog.i(TAG,'conversationList onReachEnd');
                    // 滑动到底部且隐藏状态，显示
                    animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 2000 }, () => {
                      this.listScroller.scrollEdge(Edge.End)
                      this.isScrolling = false;
                    })
                  }
                })
                .onScrollStart(()=>{
                  this.isNeedReuse = true;
                })
                .onScrollStop(() => {
                  this.isNeedReuse = false;
                  this.initialCurrentYOffset = this.listScroller.currentOffset()?.yOffset;
                })
                .onScrollVisibleContentChange(() => {
                  let currentListNum: number = this.mConListCtrl.messageList.length;
                  if (this.mConListCtrl.hasAggregate && this.mConListCtrl.hasInfoMsg && currentListNum > 3) {
                    this.isOverView = true;
                  } else if (!(this.mConListCtrl.hasAggregate && this.mConListCtrl.hasInfoMsg) && currentListNum > 4) {
                    this.isOverView = true;
                  } else if (this.isScrolling) {
                    this.isOverView = false;
                    this.isScrolling = false;
                  } else {
                    this.isOverView = false;
                  }
                })
                .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
                  if (scrollState === ScrollState.Scroll && this.isVDE) {
                    // >0 向shang滑动
                    if (scrollOffset > 0 && !this.mIsMultipleSelectState && this.isOverView) {
                      if (!this.isScrolling && Math.abs(this.initialCurrentYOffset - this.listScroller.currentOffset()?.yOffset) >= 26) {
                        animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 1000 }, () => {
                          this.isScrolling = true;
                        })
                      } else if (this.isScrolling) {
                        this.initialCurrentYOffset = this.listScroller.currentOffset()?.yOffset;
                      }
                    } else if (scrollOffset < 0) {
                      if (this.isScrolling &&
                        Math.abs(this.initialCurrentYOffset - this.listScroller.currentOffset()?.yOffset) >= 26) {
                        animateTo({
                          curve: curves.interpolatingSpring(0, 1, 228, 30),
                          duration: 1000
                        }, () => {
                          this.isScrolling = false;
                        })
                      } else if (!this.isScrolling) {
                        this.initialCurrentYOffset = this.listScroller.currentOffset()?.yOffset;
                      } else if (this.listScroller.currentOffset()?.yOffset <= -56) {
                        animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 1000 }, () => {
                          this.isScrolling = false;
                        })
                      }
                    }
                  }
                  this.isScrolled = true;
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
                .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
                .scrollBar(BarState.Auto)
                .width('100%')
                .height('100%')
                .listDirection(Axis.Vertical)
                .onScrollIndex((start, end) => {
                  this.scrollEndIndex = end
                  this.scrollStartIndex = start
                  this.mConListCtrl.conversationListDataSource.setIndex(start, end);
                  this.scrollReachEnd = false;
                  this.mConListCtrl.noUiProp.scrollStartIndex = start;
                  if ((start < common.int.SHOW_SESSION_FIRST + this.mConListCtrl.pinSessionSize) &&
                  this.mConListCtrl.scrollTopNeedUpdate) {
                    this.mConListCtrl.subscriberCallBack(this.context);
                  }
                  if(end >= this.mConListCtrl.messageList.length - 3){
                    this.mConListCtrl.onLoadingMore(this.context);
                  }
                })
                .flexShrink(1)
                .friction(0.75)
                .cachedCount(4) // 4 半页数据
                .onTouch((event: TouchEvent) => {
                  let fingers = event.touches.length;
                  this.mConListCtrl.noUiProp.longPressFingers = fingers;
                })

                Blank()

                //Select All Delete button at the bottom
                if (this.mIsMultipleSelectState && !DeviceUtil.isPC()) {
                  ToolBar({
                    toolBarList: this.multiSelectToolbarList,
                    activateIndex: this.mConListCtrl.isConversationCheckAll ? 1 : -1,
                    toolBarModifier: this.toolBarModifier,
                    dividerModifier: this.dividerModifier,
                  }).height(52).margin({
                    bottom: this.fullScreenPadding
                      ? (this.fullScreenPadding.bottom as number) : 0 as number
                  })
                    .visibility(this.isVDE && this.isScrolling ? Visibility.None : Visibility.Visible)
                }
              }
              .width('100%')
              .height('100%')
              .visibility(Visibility.Visible)
              .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              .accessibilityLevel(this.isSearchResultEmpty ? 'no-hide-descendants' : 'auto')
            }
            .margin({ top: 0 })
          }
        }
      }
        .onAppear(() => {
          HiLog.i(TAG, 'this.mConListCtrl.isShowContactHeadIcon:' + this.mConListCtrl.isShowContactHeadIcon);
        })
        .mode(NavigationMode.Stack)
        .hideTitleBar(this.isSearch?true:(DeviceUtil.isPC() ? false : (this.splitInfoModel.isSmall ||
          (this.isVDE && this.isScrolling) ? true : false)),
          this.isVDE ? false : (!this.mConListCtrl.isMultipleSelectState) ? true : false)
      .title(this.mConListCtrl.isMultipleSelectState ? this.navTitle() : $r('app.string.messages'),
        { paddingStart: LengthMetrics.vp(32) })
      .menus(this.NavigationMenus())
      // .menus(menuComponent({
      //   totalCount: this.totalCount,
      //   unreadTotal: this.unreadTotal,
      //   mConListCtrl: this.mConListCtrl,
      //   isVDE: this.isVDE,
      //   settingShow: () => {
      //     this.isSettingShow = true
      //   },
      //   context: this.context,
      //   patternControl: this.patternControl,
      //   unReadBlockedNum: SharedPreferencesUtils.getFromPreferences('unReadBlockedNum', 0) as number
      // } as ParamsInterface))
      // .titleBar(TitleBarUtil.getTitleBar(this.getTitleBarParams()))
      //   .dynamicHideTitleBar({hideBottomBuilder: true, mode: HideMode.SCROLL_UP_TO})
      //   .bindToScrollable([this.listScroller])
      .hideBackButton(this.isVDE ? true : (this.mIsMultipleSelectState ? true : false))
      .titleMode(DeviceUtil.isPC() ? NavigationTitleMode.Mini : this.isVDE ? NavigationTitleMode.Mini :
        this.splitInfoModel.isMediumAndSmall ? NavigationTitleMode.Mini :
          this.mIsMultipleSelectState ? NavigationTitleMode.Mini :
              this.mConListCtrl.hasNoOrdinaryMsg && !(this.mConListCtrl.hasAggregate &&
              this.mConListCtrl.hasInfoMsg) &&
                (!this.messageSwitch && !this.interState) ? NavigationTitleMode.Full :
                NavigationTitleMode.Free)
      // .bindSheet(this.isShowNewMms, this.showNewMms(), {
      //   title: NavDestinationHeaderView({
      //     pageTitle: $r('app.string.new_message'),
      //   }),
      //   dragBar: true,
      //   showClose: false,
      //   preferType: this.curBp === 'sm' ? SheetType.BOTTOM : SheetType.CENTER,
      //   backgroundColor: $r('sys.color.background_secondary'),
      //   shouldDismiss: (sheetDismiss: SheetDismiss) => {
      //
      //   }
      // })
        .bindSheet(this.isSettingShow, this.settingsBuilder(), {
            height: this.curBp === commonData.STR.DEVICE_MOBILE_PHONE ? '100%' : SheetSize.LARGE,
            preferType: SheetType.CENTER,
            showClose: false,
            blurStyle: BlurStyle.Thick,
            shouldDismiss: () => {
                this.onSettingsClose();
            },
            onWillSpringBackWhenDismiss: ((SpringBackAction: SpringBackAction) => {
                //没有注册springBack, 下拉半模态页面无回弹行为
                //若想触发回弹效果，调用springBack()
                // SpringBackAction.springBack()
            })
        })
        .gesture(
          TapGesture({ count: 2 })
            .onAction(() => {
              this.searchOffsetY = 0;
              if (this.unreadTotal > 0 && this.mConListCtrl.unReadQueue.length === 0) {
                HiLog.i(TAG, 'queryAllMessages pageQuery ');
                this.mConListCtrl.onLoadingMore(this.context);
              }
              if (this.mConListCtrl.unReadQueue.length > 0 && this.unreadTotal > 0) {
                this.needLoadMoreData();
                let index: number = this.mConListCtrl.unReadQueue.pop();
                HiLog.i(TAG, 'scrollToIndex  index: ' + index);
                this.listScroller.scrollToIndex(index + this.getCurrentListTopSubListCount());
                this.mConListCtrl.unReadQueue.add(index);
              } else {
                this.listScroller.scrollEdge(Edge.Top)
              }
            })
        )
        .onTitleModeChange(() => {})
    }

  @Builder
  searchBoxBuilder() {
    Row({ space: 12 }) {
      Row() {
        Image($r('app.media.ic_message_back'))
          .width(25)
          .height(25)
      }
      .visibility(this.isSearch ? Visibility.Visible : Visibility.None)
      .padding(6)
      .onClick(() => {
        this.getUIContext().getFocusController().clearFocus()
        this.isSearch = false;
      });

      Search({ placeholder: $r('app.string.search'), value: this.inputText })
        .layoutWeight(1)
        .onClick(() => {
          this.isSearch = true;
          AppStorage.setOrCreate('isSearch', this.isSearch)
        })
        .onChange(async (value) => {
          this.inputText = value.trim()
          AppStorage.set('inputText', this.inputText)
          this.searchInfoController.querySMS(this.inputText, this.context)
        })
    }
    .width('100%')
    .padding({ left: 12, right: 12 })
  }

  onSettingsClose() {
    this.isSettingShow = false;
    if (this.curBp === common.STR.DEVICE_MOBILE_PHONE) {
      this.mConListCtrl.isSettingDismiss = true;
      this.mConListCtrl.onShow(this.context, this.mConListCtrl.pageInfos);
    }
  }

  getNextAccessContentId(): string {
    //增强信息
    if (this.isOpenRcsError) {
      return 'enable_advance_message';
    }
    //应用号
    if (!this.isVDE && this.isOpenRcsState && this.isRcsStatus && this.isChatbotOn &&
    this.isEnableRcsAbility) {
      return 'app_service_account';
    }
    //通知信息
    if (this.mConListCtrl.hasAggregate && this.mConListCtrl.hasInfoMsg) {
      return 'info_msg_item';
    }
    return 'Conversation0';
  }

  // getTitleBarParams(): titleBarParams {
  //   let params: titleBarParams = {
  //     mainTitle: $r('app.string.messages'),
  //     backgroundColor: $r('sys.color.background_primary'),
  //     isMultipleSelectState: this.mConListCtrl.isMultipleSelectState,
  //     selectedNumber: this.mConListCtrl.conversationSelectedNumber,
  //     enableComponentSafeArea: DeviceUtil.isPC() ? false : true,
  //     subTitle: !this.mIsMultipleSelectState ? ((this.isVDE || this.unreadTotal === 0) ? '' : this.context.resourceManager.
  //     getPluralStringValueSync($r('app.plural.unread_messages').id, this.unreadTotal)) : '',
  //     menuValue: this.conversationListMenu(this.mConListCtrl.isOsAccountConstraintEnabled), // 参数为false 表示不受限,为true 表示it本受限
  //     start: LengthMetrics.vp(this.isPad ? this.padMargin : 16),
  //     end: LengthMetrics.vp(this.isPad ? this.padMargin : 16),
  //     subIcon: {content: { icon: (DeviceUtil.isPC() && !this.mConListCtrl.isMultipleSelectState) ? $r('app.media.message_icon') : '' }},
  //     callback: () => { this.mConListCtrl.onBackPress(this.context) }
  //   }
  //   return params
  // }

    getInfomsgContext(): string {
        let unReadTitle = '';
        if (this.unreadTotalOfInfo > 0) {
            unReadTitle = getContext(this).resourceManager.
            getPluralStringValueSync($r('app.plural.unread_messages').id, this.unreadTotalOfInfo);
            unReadTitle += ' ';
        }
        let infoMsg = getContext(this).resourceManager.getStringSync($r('app.string.infoMessages').id);
        return unReadTitle + infoMsg;
    }

  // 应用号
  @Builder
  appServiceAccountEntry() {
    Row() {
      RelativeContainer() {
        this.appServiceAccountHeadIcon()
        this.appServiceText()
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .id('ic_next')
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .width($r('app.float.settings_item_next_image_width'))
          .height($r('app.float.settings_item_next_image_height'))
          .fontColor([$r('sys.color.ohos_id_color_fourth')])
          .fontSize('24vp')
          .draggable(false)
      }
      .width('100%')
    }
    .enabled(!this.mIsMultipleSelectState)
    .opacity(this.mIsMultipleSelectState ? 0.4 : 1)
    .accessibilityGroup(true)
    .id('app_service_account')
    .width('100%')
    .onClick(() => {
      let pages: string[] = this.mConListCtrl.pageInfos?.getAllPathName()
      if (pages && pages[pages.length - 1] === 'RcsHomePageChatbotActivity') {
        HiLog.i(TAG, 'RcsHomePageChatbotActivity is on the top');
        return
      }
      this.mConListCtrl.lastIndex = -1
      if (this.curBp !== common.STR.DEVICE_MOBILE_PHONE) {
        this.mConListCtrl.pageInfos?.clear();
        AppStorage.set('selectPhoneNumber', '')
      }
      if (this.curBp === common.STR.DEVICE_MOBILE_PHONE) {
        HiLog.i(TAG, 'pushPathByName START')
        this.mConListCtrl.pageInfos.pushPathByName('RcsHomePageChatbotActivity', {} as LooseObject)
        HiLog.i(TAG, 'pushPathByName END')
      } else {
        this.mConListCtrl.pageInfos.replacePathByName('RcsHomePageChatbotActivity', {} as LooseObject)
      }
    })
  }

  // 应用号头像
  @Builder
  appServiceAccountHeadIcon() {
    Image($r('app.media.chatBot_icon'))
      .renderGroup(true)
      .id('chatBot_icon')
      .width('40vp')
      .height('40vp')
      .draggable(false)
      .borderRadius(20)
      .padding(8)
      .fillColor($r('sys.color.ohos_id_color_primary_contrary'))
      .backgroundColor($r('app.color.mms_avatar_bg'))
      .visibility(this.isShowHeadIcon ? Visibility.Visible : Visibility.None)
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        left: { anchor: '__container__', align: HorizontalAlign.Start }
      })
  }

  // 应用号文本
  @Builder
  appServiceText() {
    Row({ space: '8vp' }) {
      Text($r('app.string.rcs_chatbot'))
        .id('rcs_chatbot_messages')
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          left: { anchor: '__container__', align: HorizontalAlign.End }
        })
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontWeight(FontWeight.Medium);
    }
    .padding(Configuration.getLocale().dir === 'rtl' ?
      { right: this.isShowHeadIcon ? '56vp' : '0' } :
      {
        left: this.isShowHeadIcon ? (this.isPC ? '48vp' : '56vp') : '0',
        right: (!this.isShowHeadIcon && !this.mConListCtrl.isShowContactHeadIcon && this.unreadTotalOfInfo > 0) ?
        $r('app.float.space_24') : '0'
      })
    .height('100%')
  }

    // info msg item
    @Builder
    infoMsgItem() {
        if (this.isShowHeadIcon) {
            this.infoMsgItemHasHead();
        } else {
            this.infoMsgItemNoHasHead();
        }
    }

    //有头像时，通知显示
    @Builder
    infoMsgItemHasHead(){
        Row() {
            RelativeContainer() {
                this.infoMsgHeadIcon();
                this.infoMsgItemText();
                SymbolGlyph($r('sys.symbol.chevron_right'))
                    .id('ic_next')
                    .alignRules({
                        center: { anchor: '__container__', align: VerticalAlign.Center },
                        right: { anchor: '__container__', align: HorizontalAlign.End }
                    })
                    .width($r('app.float.settings_item_next_image_width'))
                    .height($r('app.float.settings_item_next_image_height'))
                    .fontColor([$r('sys.color.ohos_id_color_fourth')])
                    .fontSize('24vp')
                    .draggable(false)
            }.width('100%')
            .opacity(this.mConListCtrl.isMultipleSelectState ? $r('sys.float.ohos_id_alpha_disabled') : 1)
        }
        .accessibilityText(this.getInfomsgContext())
        .id('info_msg_item')
        .enabled(this.mConListCtrl.isMultipleSelectState ? false : true)
        .width('100%')
        .onClick(() => {
            this.listItemClick()
        })
    }

    //无头像时，通知显示
    @Builder
    infoMsgItemNoHasHead(){
        Row() {
            RelativeContainer() {
                this.infoMsgItemText();
                if (this.unreadTotalOfInfo > 0 && !this.mConListCtrl.isShowContactHeadIcon) {
                    Text(this.unreadTotalOfInfo + '')
                        .id('unread_total_of_next')
                        .alignRules({
                            center: { anchor: '__container__', align: VerticalAlign.Center },
                            right: { anchor: 'ic_next', align: HorizontalAlign.Start }
                        })
                        .margin({
                            right: $r('app.float.settings_item_status_title_margin_right')
                        })
                        .fontSize($r('app.float.settings_item_secondary_title_font_size'))
                        .lineHeight('19vp')
                        .fontWeight(FontWeight.Regular)
                        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                }
                SymbolGlyph($r('sys.symbol.chevron_right'))
                    .id('ic_next')
                    .alignRules({
                        center: { anchor: '__container__', align: VerticalAlign.Center },
                        right: { anchor: '__container__', align: HorizontalAlign.End }
                    })
                    .width($r('app.float.settings_item_next_image_width'))
                    .height($r('app.float.settings_item_next_image_height'))
                    .fontColor([$r('sys.color.ohos_id_color_fourth')])
                    .fontSize('24vp')
                    .draggable(false)
            }.width('100%')
            .opacity(this.mConListCtrl.isMultipleSelectState ? $r('sys.float.ohos_id_alpha_disabled') : 1)
        }
        .accessibilityText(this.getInfomsgContext())
        .id('info_msg_item')
        .width('100%')
        .onClick(() => {
            this.listItemClick()
        })
    }

    @Builder
    infoMsgItemText() {
        Row({ space: '8vp' }) {
            Text($r('app.string.infoMessages'))
                .id('info_messages')
                .alignRules({
                    center: { anchor: '__container__', align: VerticalAlign.Center },
                    left: { anchor: 'ic_bell_fill', align: HorizontalAlign.End }
                })
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontWeight(FontWeight.Medium)
            if (!this.mConListCtrl.isShowContactHeadIcon && this.unreadTotalOfInfo > 0) {
                Text()
                    .alignRules({
                        center: { anchor: '__container__', align: VerticalAlign.Center },
                        left: { anchor: '__container__', align: HorizontalAlign.Start }
                    })
                    .id('un_read_dot')
                    .backgroundColor($r('sys.color.ohos_id_color_activated'))
                    .width(8)
                    .height(8)
                    .borderRadius(4)
            }

        }
        .padding(Configuration.getLocale().dir === 'rtl' ?
            { right: this.isShowHeadIcon ? '56vp' : '0' } :
            { left: this.isShowHeadIcon ? (this.isPC ? '48vp' : '56vp') : '0',
              right: (!this.isShowHeadIcon && !this.mConListCtrl.isShowContactHeadIcon && this.unreadTotalOfInfo > 0) ?
              $r('app.float.space_24') : '0'
            })
      .height('100%')
    }
    // info msg head icon
    @Builder
    infoMsgHeadIcon() {
        if (this.mConListCtrl.isShowContactHeadIcon) {
            Badge({
                count: this.unreadTotalOfInfo,
                position: BadgeUtil.getBadgePosition(this.unreadTotalOfInfo,
                  this.fontSizeScale, this.getUIContext()),
                style: BadgeUtil.getBadgeStyle(this.fontSizeScale)
            }) {
                SymbolGlyph($r('sys.symbol.bell_fill'))
                    .alignRules({
                        center: { anchor: '__container__', align: VerticalAlign.Center },
                        left: { anchor: '__container__', align: HorizontalAlign.Start }
                    })
                    .renderGroup(true)
                    .fontSize('24vp')
                    .fontColor([$r('sys.color.ohos_id_color_primary_contrary')])
                    .id('ic_bell_fill')
                    .width('40vp')
                    .height('40vp')
                    .draggable(false)
                    .borderRadius(20)
                    .backgroundColor($r('app.color.mms_avatar_bg'))
                    .padding(8)
            }
            .alignRules({
                center: { anchor: '__container__', align: VerticalAlign.Center },
                left: { anchor: '__container__', align: HorizontalAlign.Start }
            })
            .id('info_type_icon')
            .width('40vp')
            .height('40vp')
            .accessibilityText(getContext(this).resourceManager
                .getStringSync($r('app.string.contact_avatar_button').id))
            .accessibilityLevel('no')
        }
    }

    // list item click
    listItemClick(item?: messageType, index?: number) {
        if (item) {
          if (this.mConListCtrl.messageList[item.index]?.countOfUnread > common.int.MESSAGE_CODE_ZERO &&
            !this.mIsMultipleSelectState) {
            this.currentHasReadIndex = item.index;
            this.mConListCtrl.markAsReadByThread(this.context, item, this.selectPhoneNumber);
            setTimeout(() => {
              this.currentHasReadIndex = -1;
            }, 100);
          }
            if (this.curBp !== common.STR.DEVICE_MOBILE_PHONE && !this.mIsMultipleSelectState) {
                if (this.selectPhoneNumber !== item.telephone) {
                    this.mConversationCtrl.setDraftModel((draftModelIsNull: boolean) => {
                        if (!draftModelIsNull) {
                            DraftUtils.getInstance().saveDraft(this.context)
                        }
                    })
                }
                this.selectPhoneNumber = item.telephone;
            } else if (item?.telephone && !this.mIsMultipleSelectState) {
                //当增强信息在线并且该会话会话有未读消息时给未读的接收消息的发送端发送增强信息已读报告
                const isOnlineRcs = AppStorage.get<boolean>('isOnlineRcs');
                HiLog.i(TAG, `listItemClick: rcsSendReadReceipt, isOnlineRcs ${isOnlineRcs}`);
                if (isOnlineRcs && item?.countOfUnread > common.int.MESSAGE_CODE_ZERO) {
                  ReceiveService.getInstance().rcsSendReadReceipt({
                    telephone: item.telephone
                  });
                }
            }
            this.mConListCtrl.clickInfoToConversation(index ?? 0);
            // 记录最新点击的会话index
            this.mConListCtrl.currentConversatonIndex = index ?? 0;

        } else {
            HiLog.iw(TAG, 'listItemClick item is null!')
            if (DeviceUtil.isTabletOrPC()) {
                this.mConversationCtrl.setDraftModel((draftModelIsNull: boolean) => {
                    if (!draftModelIsNull) {
                        DraftUtils.getInstance().saveDraft(this.context)
                    }
                })
            }
            GlobalContext.getContext().setObject(commonData.STR.BACK_FROM_CONVERSATION, false);
            this.mConListCtrl.clickToInfoMessages();
            DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.CLICK_NOTIFICATION_LIST);
        }
    }
    mulAction(pressIndex:number) {
        this.mConListCtrl.conversationLongPress(pressIndex);
    }

    deleteAction(pressIndex: number, hideButton?: boolean) {
      this.currentHasReadIndex = -1;
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
    HiLog.i(TAG, ` menuReadOrUnRead index:${item.index},${item.countOfUnread}`);
    try {
      this.listScroller.closeAllSwipeActions();
    } catch (err) {
      HiLog.w(TAG, `listScroller.closeAllSwipeActions error: ${err}`)
    }

    this.currentHasReadIndex = item.index;
    if (countOfUnread > 0) {
      AccessibilityUtil.announceForAccessibility(getContext(this).resourceManager
        .getStringSync($r('app.string.screen_read_read').id));
      this.mConListCtrl.markAsReadByThread(this.context, item, telephone);
    } else {
      AccessibilityUtil.announceForAccessibility(getContext(this).resourceManager
        .getStringSync($r('app.string.screen_read_unread').id));
      this.mConListCtrl.handleMarkAsUnReadByIndex(this.context, item);
    }
    setTimeout(() => {
      this.currentHasReadIndex = -1;
      let accessContent = 'Conversation' + item.index;
      AccessibilityUtil.requestFocusForAccessibilityNotInterrupt(accessContent);
      this.mConListCtrl.sendUpdateAccessibilityStr();
    }, 100);
  }

  longPressReadOrUnRead(item: messageType, countOfUnread: number, telephone: string) {
    this.menuReadOrUnRead(item, countOfUnread, telephone);
    //长按标记已读未读打点
    stateParam.PAGE_STATE = 1;
    stateParam.READ_STATE = countOfUnread > 0 ? 0 : 1;
    DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.LONGPRESS_UNREAD);
  }

  @Builder previewLongPress(item: messageType) {
    Column(){
      Row({ space: this.isShowHeadIcon ? 16 : 0 }) {
        MmsListItem({
          item: item,
          fatherView: 'Conversation',
          isMultipleSelectState: this.mIsMultipleSelectState,
          isInSetReadThreadIndex: this.currentHasReadIndex,
          isShowHeadIcon: this.isShowHeadIcon,
          loadFromDB: !this.isShowFromCheckAll,
          showCount: !this.isShowHeadIcon &&
            item.countOfUnread > 1,
          onClickHead: (clickPosition: number, event: ClickEvent | undefined) => {
              if (!this.listShowMenu) {
                  this.mConListCtrl.clickToGroupDetail(this.context, clickPosition);
              }
          },
          onClickCheckBox: (checkIndex: number, value: boolean) => {
            this.mConListCtrl.clickCheckBox(checkIndex, value);
          },
          isPad: this.isPad,
          curBp: this.curBp,
        })
      }
      .alignItems(VerticalAlign.Center)
      .width('100%')
    }
    .height(this.fontSizeScale > 1 ? (this.fontSizeScale * 68) + 'vp' : '88vp')
    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
    .borderRadius(20)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
  }
  @Builder
  rcsTip() {
    Column() {
      Row() {
        Text($r('app.string.rcs_title'))
          .margin({ top: 16, left: 12, right: 12 })
          .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .opacity(100)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)

      }.width('100%')

      Row() {
        Text($r('app.string.rcs_title_content'))
          .margin({ top: 8, left: 12, right: 12 })
          .fontSize($r('sys.float.ohos_id_text_size_button2'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Start)
          .lineHeight(16)
      }.width('100%')

      Row() {
        Text($r('app.string.rcs_no'))
          .fontSize($r('sys.float.ohos_id_text_size_button2'))
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .fontWeight(FontWeight.Medium)
          .margin({ right: 24, left: 12 })
          .borderRadius(4)
          .onClick(() => {
            AppStorage.SetOrCreate('isFirstMms', true);
            SharedPreferencesUtils.saveToPreferences('isFirstMms', true);
            this.isFirstMms = true
          })
        Text($r('app.string.rcs_start'))
          .margin({ top: 1 })
          .fontSize($r('sys.float.ohos_id_text_size_button2'))
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .fontWeight(FontWeight.Medium)
          .borderRadius(4)
          .onClick(() => {
            HiLog.i(TAG, 'onClick to RcsSettings -Try Advanced Messaging 1')
            if(!AppStorage.get('tipsJumpToRcsSetting')) {
              this.isSettingShow = true
              AppStorage.setOrCreate('tipsJumpToRcsSetting', true);
              AppStorage.SetOrCreate('isFirstMms', true);
              SharedPreferencesUtils.saveToPreferences('isFirstMms', true);
              this.isFirstMms = true
            }
          })
          .id('openAdvancedMessaging1')

      }.width('100%')
      .margin({ top: 8, bottom: 10 })
    }
  }

  /**
   * 计算当前列表除了主数据外，有多少个其他入口（通知列表、应用号等）
   */
  getCurrentListTopSubListCount(): number {
    let count: number = 0;
    if (this.isSlot0Mute || this.isSlot1Mute) {
      count ++;
    }
    if (!this.isSlot0Mute && !this.isSlot1Mute && this.showExitMuteTip) {
      count ++;
    }
    //增强信息
    if (this.isOpenRcsError) {
      count ++;
    }
    //应用号
    if (!this.isVDE && this.isOpenRcsState && this.isRcsStatus && this.isChatbotOn &&
    this.isEnableRcsAbility) {
      count ++;
    }
    //通知信息
    if (this.mConListCtrl.hasAggregate && this.mConListCtrl.hasInfoMsg) {
      count ++;
    }
    return count;
  }

  /**
   * 需要去获取更多数据
   */
  needLoadMoreData() {
    //通知信息打开
    if (this.mConListCtrl.hasAggregate && this.mConListCtrl.hasInfoMsg) {
      if (this.mConListCtrl.unReadQueue.length < (this.unreadTotal - this.unreadTotalOfInfo)) {
        this.mConListCtrl.onLoadingMore(this.context);
      }
    } else {
      if (this.mConListCtrl.unReadQueue.length < this.unreadTotal) {
        this.mConListCtrl.onLoadingMore(this.context);
      }
    }
  }
}

@Component
struct EmptyView {
    @StorageLink('isDistributedCallPhoneSharing') isDistributedCallPhoneSharing: boolean = false;
    @StorageLink('isInitSmsSharingViewShow') isInitCallSharingViewShow: boolean = true;
    @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding | null = null;
    @StorageLink('isOpenRcsTestSetting') isOpenRcsState: boolean =
      SharedPreferencesUtils.getFromPreferences('isUIOpenRcs', false) as boolean;

    aboutToAppear(): void {
      HiLog.i(TAG, 'EmptyView aboutToAppear');
    }

    build() {
        Column() {
          EmptyPage()
        }
        .padding({ bottom: this.fullScreenPadding?.bottom })
        .size({ height: this.isOpenRcsState ? 'calc(100% - 56vp)' : '100%' })
        .width('100%')
    }
}

@Builder
function menuComponent(params: ParamsInterface) {
  Menu() {
    MenuItem({ content: $r('app.string.delete')})
      .enabled(params.totalCount == 0 ? false : true)
      .visibility(Visibility.Visible)
      .onClick(()=>{
        params.mConListCtrl.showMultipleSelectView()
        seleteParam.SELECT_STATE = 1;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.LIST_MORE_SELECT_EVENT);
      })
    MenuItem({ content: $r('app.string.favorites')})
      .enabled(true)
      .visibility(Visibility.Visible)
      .onClick(()=>{
        params.mConListCtrl.jumpToFavoritesPage();
        seleteParam.SELECT_STATE = 2;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.LIST_MORE_SELECT_EVENT);
      })
    MenuItem({ content: $r('app.string.markAllAsRead')})
      .enabled(params.unreadTotal == 0 ? false : true)
      .visibility(Visibility.Visible)
      .onClick(()=>{
        params.mConListCtrl.clickToMarkAllAsRead(params.context);
        seleteParam.SELECT_STATE = 3;
        DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.LIST_MORE_SELECT_EVENT);
      })
    MenuItem({ content: $r('app.string.settings')})
      .enabled(true)
      .visibility(params.isVDE ? Visibility.None : Visibility.Visible)
      .onClick(()=>{
        if (!DoubleClickUtil.isFastClick()) {
          params.settingShow()
          seleteParam.SELECT_STATE = 4;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.LIST_MORE_SELECT_EVENT);
        }
      })
    // MenuItem({ content: $r('app.string.help_and_feedback')})
    //   .enabled(true)
    //   .visibility(params.isVDE ? Visibility.None : Visibility.Visible)
    //   .onClick(()=>{
    //     params.mConListCtrl.jumpToFeedbackMenu(); // 跳转至帮助和反馈组件
    //     seleteParam.SELECT_STATE = 5; // 设置状态为 5
    //     DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.LIST_MORE_SELECT_EVENT);
    //   })

  }
  .width(224).menuItemDivider({strokeWidth:LengthMetrics.px(1),color:$r('sys.color.comp_divider')})
}