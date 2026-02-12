/**
 * Copyright (c) 2022-2024 Huawei Device Co., Ltd.
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
import emitter from '@ohos.events.emitter';
import ConversationController, { BaseItemType, mmsListType, RcsChatbotOptions } from './conversationController';
import LooseObject from '../../data/LooseObject';
import { RcsMoreMenu } from '../../views/MmsRcsMenu';
import { RcsNewMoreMenu } from '../../views/MmsRcsNewMenu';
import { MultiSimCardMenu } from '../../views/MultiSimCardMenu';
import WantUtil from '../../utils/WantUtil';
import lazy { ResendDialogRcs, AudioPrompts } from '../../views/MmsDialogs';
import MmsPreferences from '../../utils/MmsPreferences';
import common from '../../data/commonData';
import simCardService from '../../service/SimCardService'
import { Controller, MultiSimCardCallDialog, SelectDialogBuilder } from '../../views/MultiSimCardCallDialog';
import HiLog from '../../utils/HiLog';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import SendEmoji from './EmojiKeyboard';
import ReceiveController from '../../views/receive/receiveController';
import MMTabs from '../../views/AttachmentArea/MMTabs';
import MMAttachAreaDisplay from '../../views/AttachmentArea/MMAttachAreaDisplay';
import lazy { MmsContent } from '../../views/AttachmentArea/MMContent';
import TabUtil from '../../utils/TabUtil';
import MMRecorderController from '../../views/AttachmentArea/MMRecorderController';
import ConListController from '../conversationlist/conversationListController';
import Constant from '../../data/Constant';
import inputMethod from '@ohos.inputMethod';
import {
  componentUtils,
  ComponentContent,
  DividerModifier,
  inspector,
  ItemState,
  LengthMetrics,
  mediaquery,
  ToolBar,
  ToolBarModifier,
  ToolBarOptions,
  uiObserver,
  UIObserver
} from '@kit.ArkUI';
import DataService from '../../service/DataService';
import { AudioPlayerService } from '../../service/AudioPlayerService';
import MMAttachmentAreaController from '../../views/AttachmentArea/MMAttachmentAreaController';
import commonData from '../../data/commonData';
import EmitterConstant from '../../data/EmitterConstant';
import MMPictureController from '../../views/AttachmentArea/MMPictureController';
import curves from '@ohos.curves';
import hiTraceMeter from '@ohos.hiTraceMeter';
import TraceConstant from '../../data/TraceConstant';
import promptAction from '@ohos.promptAction';
import HashMap from '@ohos.util.HashMap';
import { BusinessError } from '@ohos.base';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import lazy { Mms, mmsInfo } from '../../utils/TypesUtils';
import MmsUtil from '../../utils/MmsUtil';
import PanGestureUtil, { PanGestureAction } from '../../utils/PanGestureUtil';
import DotUtil from '../../utils/MmsDot/DotUtils';
import lazy { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import dotCommon, { clickAvatarParams, dotSendParmas, dotNoNeedParmas, writeEventParams, stateParam, seleteParam,
  contentMoreParams, newPageListParams, sendRcsRecordParams,
  onlyStateParam } from '../../utils/MmsDot/DotCommon';
import UDC from '@ohos.data.unifiedDataChannel';
import unifiedDataChannel from '@ohos.data.unifiedDataChannel';
import lazy uniformTypeDescriptor from '@ohos.data.uniformTypeDescriptor';
import lazy UTD from '@ohos.data.uniformTypeDescriptor';
import FileUtil, { formatFileSize, SavedFileInfo } from '../../utils/FileUtil';
import OperatorConfigUtil from '../../../cust/utils/OperatorConfigUtil';
import { Chip, ChipSize, SymbolGlyphModifier, window } from '@kit.ArkUI';
import EnhancedInfoTabs from '../../views/AttachmentArea/EnhancedInfoTabs';
import DeviceUtil from '../../utils/DeviceUtil';
//import { HdsNavDestination, HdsNavDestinationAttribute, HdsNavigationBadgeIconOptions } from '@kit.UIDesignKit';
import TitleBarUtil from '../../utils/TitleBarUtil';
import Prompt from '@ohos.promptAction';
import RcsDataPreferences from '../../utils/RcsDataPreferences';
import { connection } from '@kit.NetworkKit';
import { i18n, intl } from '@kit.LocalizationKit';
import settings from '@ohos.settings';
import StringUtil from '../../utils/StringUtil';
import ConversationDataSource from '../../model/ConversationDataSource';
import { SendFailedButton } from '../../views/SendFailedButton';
import { ReceiveFailedButton } from '../../views/ReceiveFailedButton';
import sms from '@ohos.telephony.sms'
import PatternControl from '../PatternControl';
import lazy { SplitScreenManager, SplitInfoModel } from '../../utils/SplitScreenManager'
import Configuration from '@system.configuration';
import MessageTypeTitleAndCalenderDate from './MessageTypeTitleAndCalenderDate'
import BubbleText from './BubbleText'
import { MenuItemsObj, MenuItemsObjRcs } from './ConversationData';
import lazy { BuildMaliciousWebWarning, MenuBuilder } from './ConversationComponentAndTools';
import AdvancedSettingsController from '../settings/advancedSettings/advancedSettingsController';
import lazy CreateNewConversationViewModle from './CreateNewConversationViewModle';
import { dataShare, ValuesBucket } from '@kit.ArkData';
import myCommon from '@ohos.app.ability.common';
import { DraftUtils } from '../../utils/DraftUtils';
import MessageUtil from '../../../cust/utils/MessageUtil';
import { util } from '@kit.ArkTS';
import { CancelNotificationTimeLock } from '../../utils/Locks/TimeLock';
import ResourceUtils from '../../utils/ResourceUtils';
import {
  BotMessage,
  ChatbotDetail,
  PersistentMenu,
  Entry as ChatbotMenuEntry,
} from '../../chatbot/utils/ChatbotEntitys';
import { call, sim } from '@kit.TelephonyKit';
import { SystemMode, SystemModeType } from '../../utils/SystemMode';
import MMCameraInvocation from '../../views/AttachmentArea/MMCameraInvocation';
import EnvironmentCallback from '@ohos.app.ability.EnvironmentCallback';
import YellowPageService from '../../service/yellowPageService';
import TransmitMsgPage from '../../pages/transmitmsg/transmitMsgPage';
import TransmitSearchMsgPage from '../transmitmsg/transmitSearchMsgPage';
import { DragUtil } from '../../utils/DragUtil';

import { ContactAvatar } from '../../views/ContactAvatar'
import commonService from '../../service/CommonService';
import { DateRefreshUtil } from '../../utils/DateRefreshUtil';
import { DoubleClickUtil } from '../../utils/DoubleClickUtil';
import AvatarColor from '../../model/common/AvatarColor';
import lazy ConversationListController, { photoFirstNamesType } from '../conversationlist/conversationListController';
import { MMCheckVcardDialog, MMSaveVcardDialog, MMAskIsImportDialog } from '../../views/AttachmentArea/MMMoreDialog'
import { VCardUtil } from '../../utils/VCardUtil';
import { abilityAccessCtrl, ConfigurationConstant, Permissions } from '@kit.AbilityKit';
import bundleManager from '@ohos.bundle.bundleManager';
import { VibrationUtils } from '../../utils/VibrationUtils';
import AccessibilityUtil from '../../utils/AccessibilityUtil';
import lazy commonEventManager from '@ohos.commonEventManager';
import LocationUtil from '../../utils/LocationUtil';
import AppStorageKeyConstant from '../../data/AppStorageKeyConstant';
import ConversationListService from '../../service/ConversationListService';
import FileUtils from '../../utils/FileUtils';

const TAG = 'Conversation';

const MIN_MM_PICKER_HEIGHT: number = 112;
const TITLE_HEIGHT: number = 52;
const TEXT_MAX_LENGTH: number = 5000;
const EMOJI_HEIGHT: number = 263;
const ATTACHMENT_MAX_AREA_HEIGHT: number = 100;
const ATTACHMENT_MIN_AREA_HEIGHT: number = 60;
const INPUT_MIN_HEIGHT: number = 40;
const INPUT_MARGIN_BOTTOM: number = 6;
const AVOIDANCE_HEIGHT: number = 28;
const SATELLITE_TEXT_HEIGHT: number = 32;
const RCS_MM_PICKER_HEIGHT: number = 200;
const SATELLITE_HEIGHT: number = 48;
const TWELVE_VP_TO_PX = vp2px(12);
const MMS_MM_PICKER_HEIGHT: number = 200;
@Extend(Text)
function chatbotConversationTitleTextStyle(textLayoutDirection: 'ltr' | 'rtl') {
  .fontFamily('黑体')
  .minFontSize($r('app.float.conversation_title_min_font_size'))
  .maxFontSize($r('sys.float.ohos_id_text_size_headline8'))
  .wordBreak(WordBreak.BREAK_ALL)
  .maxFontScale(1)
  .fontWeight(FontWeight.Bold)
  .lineHeight(23)
  .fontColor($r('sys.color.font_primary'))
  .maxLines(1)
  .width('100%')
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .focusable(true)
}

interface ChatbotPersistentMenuAndButtonParam {
  entries: ChatbotMenuEntry[]
}

@Builder
export function ConversationLoader(param: LooseObject): void {
  Conversation();
}
export class ActionData {
  phoneNumber?: string
  pageFlag?: string
  contactId?:string
  smsType?: number
  page?: number
  limit?: number
  orderByTimeDesc?: boolean
  threadId?: number
  hasRead?: number
  threadIds?: Array<number>
  intValue? : string
  booleanValue? : string
}

@Component
export struct Conversation {
    public strContactsName: string = '';
    public photoFirstName: string = '';
    public reg: RegExp = new RegExp('[\\u4e00-\\u9fa5_a-zA-Z]');
    public allChinese: RegExp = new RegExp('^[\\u3400-\\u4db5_\\u4e00-\\u9fa5]+$');
    public hasChinese: RegExp = new RegExp('[\\u3400-\\u4db5_\\u4e00-\\u9fa5]');
    public hasEnglish: RegExp = new RegExp('[a-zA-Z]');
    public portraitColor: string | Resource = common.STR.EMPTY_STR;
    @StorageProp('fontSizeScale') @Watch('measureTextAreaSize') fontSizeScale: number = 1;
    conversationRcsDataPreferences: RcsDataPreferences = RcsDataPreferences.getInstance();
    public static readonly CONVERSATION_RCS_DATA_PREFERENCES: string = 'rcs_info_first_active';
    public static readonly RCS_INFO_STATUS: number = 1;
    @State public rcsInfoStatus: number = 0;
    @State isWifiConnected: string = '?';
    private context = getContext(this) as myCommon.UIAbilityContext;
    @Consume('pageInfos') pageInfos: NavPathStack;
    @StorageLink('curBp') @Watch('messageBubbleWidthChange') curBp: string = common.STR.DEVICE_MOBILE_PHONE;
    @StorageLink('windowWidth') deviceWidth: number = 0;
    @StorageLink('isOnlineRcs') @Watch('updateRcsState') isOnlineRcs: boolean = false;
    @StorageLink('simSlotId') @Watch('handleSelectedSlotIdChange') simSlotId: number = MmsPreferences.getInstance()
        .getSelectedSlotId();
    @LocalStorageProp('fullScreenPadding') @Watch('fullScreenPaddingChange') fullScreenPadding: Padding | null = null;
    @LocalStorageProp('windowHeight') windowHeight: number = 0;
    private highMessageList: number = 660;
    private tabPickerMaxHeight: number = 700;
    private pubNameRightPadding: number = 50;
    private refreshDateKey: string = Math.random().toString(36).slice(2);
    @State receiveCtrl: ReceiveController = ReceiveController.getInstance();
    @State mConversationCtrl: ConversationController = ConversationController.getInstance();
    @State conversationDataSource : ConversationDataSource = ConversationDataSource.getInstance();
    // ID of the timer for updating the list height
    private listLightTimerId: number = -1;
    @StorageLink('isAirPlaneMode') isAirPlaneMode: boolean = false;
    @State mmAttachmentAreaController: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
    @State recorderController: MMRecorderController = MMRecorderController.getInstance();
    @State MMPictureController: MMPictureController = MMPictureController.getInstance()
    @State conListCtrl: ConListController = this.mConversationCtrl.conListCtrl;
    @State slotId: number = MmsPreferences.getInstance().getSelectedSlotId();
    @State onDestinationShow: boolean = true;
    @State iconOfSlot0: Resource = $r('app.media.ic_simcard_1');
    @State iconOfSlot1: Resource = $r('app.media.ic_simcard_2');
    @State defCellularSlotId: number = 0;
    @State cardImage: boolean = MmsPreferences.getInstance().haveMultiSimCardReady();
    @State @Watch('isShowEmojiChange') isShowEmoji: boolean = false
    @State isFlag: boolean = true;
    @StorageLink('isSelectDelete') isSelectDelete: boolean = false;
    @State isShowMoreMenu: boolean = false;
    @State changeRcsFlag: boolean = false;
    @State haveTwoCards: boolean = false;
    @State isAllCardCanSend: boolean = false;
    sendBarHeight: number = 0;
    @State @Watch('getHeight') textHeight: number = 40;
    @State isFirstChangeTextSize: boolean = true;
    private textAreaWidth: number = 0;
    private dialogGridCount: number = 4;
    private isFirstOnAreaChange: boolean = true;
    private messageListOnAreaChangeHeight: Length = 0;
    private bottomSendBarPositionY: Length = 0;
    private messageListPositionY: Length = 0;
    // Identifies the keyboard status
    private keyboardFocused: boolean = false;
    private isFromInfoMsg: boolean = false;
  @State attachmentSizeDesc: Resource | string = '';
    @State @Watch('showAudioTitleEvent') heightMMContentPicker: number = MIN_MM_PICKER_HEIGHT;
    @State topMMContentPicker: number = 0;
    @State fullHeightMMPicker: boolean = false;
    @State @Watch('showMMContentPickerChange') showMMContentPicker: boolean = false;
    @StorageLink('isConversationNeedChange') @Watch('conversationNeedChanged') isConversationNeedChange: boolean = false;
    @StorageLink('selectPicFromGalleryDone') @Watch('selectPicFromGalleryChanged') selectPicFromGalleryDone: boolean = false;
    @StorageLink('selectPicFromMaxHeightDone') @Watch('selectPicFromMaxHeightChanged') selectPicFromMaxHeightDone: boolean = false;
    @StorageLink('isAreaDisplayChange') @Watch('displayChangedEvent') isAreaDisplayChange: boolean = false;
    @State tabUtil: TabUtil = TabUtil.getInstance();
    private listScroller: Scroller = this.mConversationCtrl.scroller;
    // List滑动多选
    private listWidth: number = 0
    private listHeight: number = 0
    @State scrollEndIndex: number = -1
    @State scrollStartIndex: number = -1
    @State checkBoxStatusHasChanged: boolean = false;
    // 多选状态下统计选中数量
    @StorageLink('conversationSelectNumber') @Watch('getSelectNumber') selectNumber: number = 0;
    /**
     * 非pc设备上，和isShowEmoji一起控制输入框是否可获焦；
     * pc设备，和isPCEmojiVisible一起控制输入框是否可获焦
     */
    @State textareaFocusable: boolean = true;
    /**
     * 非PC设备上，输入框组件是否获得焦点
     */
    isFocusOnTextAreaInNonPCDevice: boolean = false;
    @State currentIndex: number = 1;
    @State isAudioTitle: boolean = false;
    @State recorderPermission: boolean = false;
    @State rawContactId: string = '';
    @State picturePermission: boolean = false;
    controller: TextAreaController = new TextAreaController();
    contactTextController: TextAreaController = new TextAreaController();
    @State isPictureTitle: boolean = false;
    @Consume storagePixelMap: HashMap<string, PixelMap>;
    @StorageLink('pictureSelectedNumber') pictureSelectedNumber: number = 0;
    @State haveSimCard: boolean = MmsPreferences.getInstance().haveSimCardReady();
    @StorageLink('keyboardHeight') @Watch('onKeyboardChange') keyboardHeight: number = 0;
    private oldKeyboardHeight = 0;
    @State mMContentPickerOffsetY: number = 0;
    @State mEmojiOffsetY: number = 0;
    //键盘避让
    @State mOffsetY: number = 0;
    @StorageLink('bottomAvoidHeight') bottomAvoidHeight: number = 0;
    @State isPC: boolean = DeviceUtil.isPC()
    // Record the GlobalY of SendBar at the bottom
    private currentSendBarGlobalY: number = -1;
    // Record the GlobalY of TitleBar at the bottom
    private currentTitleBarGlobalY: number = -1;
    audioPlayerService: AudioPlayerService = AudioPlayerService.getInstance();
    private isResendRcsInfo: boolean = false;
    private resendStateIsRcs: boolean = false;
    @State currentScreenWidth: string = '';
    @State isShowMmsAreaDisplay: boolean = false;
    @State showMmPicTitle: boolean = false;
    @State sendAreaIconAlign: VerticalAlign = VerticalAlign.Center
    @State isTouch: boolean = false;
    @State isDraft: boolean = true;
    @State isOpenRCS: boolean = false
    /**
     * 是否展示增强信息的"按住说话"按钮
     */
    @State isVoicing: boolean = false
    private swipeDownDisplayY: number = 0;
    private swipeUpDisplayY: number = 0;
    @State isPublic: boolean = false
    strChatbotNumber: string = '';
    @State satelliteProp: boolean = false;
    // Indicates whether the permission has been denied.
    @State isPermissionDenied: boolean = false;
    /* 设备是否为pad */
    @State isPad: boolean = false;
    @State isCellularTablet: boolean = false;
    @State isWifiOnlyTablet: boolean = false;
    @State isSubDeviceWithConnected: boolean = false;
    @State mCreateNewConversationViewModle: CreateNewConversationViewModle = new CreateNewConversationViewModle();
    @State isInput: boolean = false;
    CHECK_IMAGE_EVENT: emitter.InnerEvent = {
        eventId: 2,
        priority: emitter.EventPriority.HIGH
    }
    @State isShowAudio: boolean = false
    @State textFocusable: boolean = true;
    @State isSendingAudio: boolean = false;
    @State isTouchDown: boolean = false;
    private isUpperLimit: boolean = false;
    private inputMethodSetting = inputMethod.getSetting();
    /* 附件区底部高度 */
    private attachmentBottomHeight: number = SystemMode.getInstance().attachmentBottomHeight;
    private emitterKeyboard = (info: Array<inputMethod.InputWindowInfo>) => {
        if (this.oldKeyboardHeight == 0) {
            this.showKeyboard();
        }
    }
    @State isAnimation: boolean = false;
    @State offsetY: number = 0;
    @State rcsIsResumeSend: boolean = false;
    @State isSmartOpen: boolean = false;
    @State backIcon: ResourceStr | PixelMap | SymbolGlyphModifier | null =
    new SymbolGlyphModifier($r('sys.symbol.chevron_backward'));
    @Provide('conversation_rcs_recordDuration') recordDuration: number = 0;
    /* 设备是否开启无障碍屏幕朗读 */
    private accessibilitySwitch: string = Constant.ACCESSIBILITY_SCREEN_READER_SWITCH_CLOSED;
    @StorageLink('isScreenReaderOpen') isReaderOpen: boolean = false;
    private proxyMap: Map<string | number, UIExtensionProxy> = new Map();
    @Provide showBubbleMap: Map<string | number | undefined, number> = new Map();
    @State isScrolling: boolean = false;
    @State isScrollingHide: boolean = false;
    @State isScrollingStart: boolean = false;
    private scrollingLastTouch: TouchType = TouchType.Cancel;
    private isFirstScrolling: boolean = false;
    @State isNewPage: boolean = false;
    @StorageLink('VDEisInMore') @Watch('isInMoreStatusChange') VDEisInMore: boolean = false;
    // 判断是否滑动到了底部
    @StorageLink('isAtMsgListBottom') isAtMsgListBottom: boolean = false;
    // 判断是否滑动到了顶部
    @StorageLink('isAtMsgListTop') isAtMsgListTop: boolean = false;
    // 判断是否点击状态栏触发置顶操作
    @StorageLink(AppStorageKeyConstant.CONVERSATION_BACK_TO_UP) @Watch('isBackToUpChange') isBackToUp: boolean = false;
    private initialCurrentYOffset: number = 0;
    private listLength: number = 0;
    private ableSlips: boolean = true;
    private isScrollingTime: number = 0;
    @State topPadding: number = 0;
    @State bottomPadding: number = 0;
    private isPhone: boolean = true;
    private patternControl: PatternControl = PatternControl.getInstance();
    //分屏通知
    @State @Watch('splitScreenTypeChange') splitInfoModel: SplitInfoModel = SplitScreenManager.getInstance().infoModel;
    // 监听横屏事件
    private  mScreenRotationListener = mediaquery.matchMediaSync('(orientation: landscape)');
    @State inputCurrentheight: Length = 'auto';
    @State x: number = 0;
    pageId: number = 0;
    private isFromNotify: boolean = false;
    @State textDirection: string = '';
    @Consume isPageOnFocus: boolean;
    @StorageLink('comeFromContact') mComeFromContact: boolean = false;
    @StorageLink('comeFromServiceaccess') mComeFromServiceaccess: boolean = false;
    @StorageLink('AdvancedSettingsController') mAdvancedSettingsCtrl:
      AdvancedSettingsController = AdvancedSettingsController.getInstance();
    @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();
    // 窗口状态变化，当window上滑失去焦点时，折叠机保存草稿
    @StorageLink('windowStageEventType') @Watch('windowStageEventTypeChange')
    windowStageEventType: window.WindowStageEventType = window.WindowStageEventType.SHOWN
  @StorageLink('isVDEFoldPhoneAndFoldedState') @Watch('onFoldStatusChange') isVDEFoldPhoneAndFoldedState
    : boolean = false;
  @StorageLink('foldStatus') @Watch('getWallpaper') foldStatus
    : number = 0;
  @StorageLink('isNeedHideSuggestions') isNeedHideSuggestion: boolean = false;
  @State isVDE: boolean = this.isVDEFoldPhoneAndFoldedState && this.foldStatus === 2 ? true : false
  @State isSendingAnimate: boolean = false
  @State isShowAnimateView: boolean = true;
  private animatingTextHeight: number = INPUT_MIN_HEIGHT;
  @State toolBarList: ToolBarOptions = new ToolBarOptions();
  @State toolBarList1: ToolBarOptions = new ToolBarOptions();
  @State isMoreMenuShown: boolean = false;
  @State toolBarModifier: ToolBarModifier =
    new ToolBarModifier().height(LengthMetrics.vp(52)).backgroundColor(Color.Transparent).stateEffect(false);
  private toolBarModifier1: ToolBarModifier =
    new ToolBarModifier().backgroundColor(Color.Transparent).stateEffect(false).padding(LengthMetrics.vp(0));
  @State dividerModifier: DividerModifier = new DividerModifier().height(0);
  private uiObserver: UIObserver = this.getUIContext().getUIObserver();
  private reportChabotParam: LooseObject = {};
  private hideToolBarTaskId: number = -1;
  private callbackId: number = 0;
  private inputVdeMaxHeight: number = 2 * 21 + 16;
  @State hideVdeTitle: boolean = false;
  @State isDeviceHasSim: boolean = true;
  @State isPCEmojiVisible: boolean = false
  @State isSlotIdChange: boolean = false;
  @StorageProp('isWindowSizeChange') @Watch('updateIsPCEmojiVisible') isWindowSizeChange: Size | null = null;
  @StorageProp('windowStatusType') @Watch('updateIsPCEmojiVisible') isWindowStatusTypeChange: WindowStatusType = window.WindowStatusType.UNDEFINED;
  private isTextAreaChange: boolean = false;
  private savedFileInfo: SavedFileInfo | null = null
  /**
   * "增强信息发送消息发送成功"公共事件的订阅者对象
   */
  private sendOKEventSubscriber: commonEventManager.CommonEventSubscriber | null = null;
  /**
   * "增强信息发送消息已送达"公共事件的订阅者对象
   */
  private deliveryEventData: commonEventManager.CommonEventSubscriber | null = null;

  listener: (info: uiObserver.RouterPageInfo) => void = (info: uiObserver.RouterPageInfo) => {
    if(DeviceUtil.isFloatingScreen()){
      let routerInfo: uiObserver.RouterPageInfo | undefined = this.queryRouterPageInfo();
      if (info.state == uiObserver.RouterPageState.ON_PAGE_SHOW) {
        HiLog.i(TAG, 'conversation onPageShow');
      } else if (info.state == uiObserver.RouterPageState.ON_PAGE_HIDE) {
        HiLog.i(TAG, 'conversation onPageHide');
        this.mConversationCtrl.saveDraft(this.context, false, this.isChatbotConversation, false, false);
      }
    }
  }
  chatbotServiceId: string = '';
  @State chatbotNumberFromServiceId: string = '';
  /* 附件区底部高度 */
  @State attachmentHeight: number = 0;
  /* 是否启用rcs能力 */
  private isEnableRcsAbility: boolean = SystemMode.getInstance().isEnableRcsAbility;
  /* 系统模式 */
  private systemMode: string = SystemMode.getInstance().mode;
  @State chatbotDetail: ChatbotDetail | null = null;
  @State isChatbotConversation: boolean = false;
  @State isInvokeCamera: boolean = false;
  @State isDisplayFixedMenu: boolean = false;
  @State chatbotFloatMenuData: BotMessage | null = null;
  @State chatbotPersistentMenuData: PersistentMenu | null = null;
  // chatbot is send Hi
  @State isSendHello: boolean = false;
  // 临时刷新时间使用，触发对应元素刷新，待精准刷新后整改
  @State needRefreshTime: boolean = false;
  @StorageProp('currentLanguage') @Watch('sysLocaleChangedFun') currentLanguage: string = '';
  @StorageLink('isNeedReloadToolBar')@Watch('needReloadToolBar') isNeedReloadToolBar: boolean = false;
  @State topValue: number = 0;
  @StorageLink('isPCPageRefresh') @Watch('conversationPageRefresh') isPageRefresh: boolean = false;
  @StorageProp('isPCShowMessageBackButton') isPCShowMessageBackButton: boolean = false;
  @StorageProp('isTransmitShow') isTransmitShow: boolean = false;
  @StorageProp('isTransmitSearch') isTransmitSearch: boolean = false;
  @State transmitParams:LooseObject ={}
  @StorageProp('isShowContactHeadIcon') isShowHeadIcon: boolean = ConListController.getInstance().isShowContactHeadIcon;
  @StorageLink('mmsNavMode') curNavMode: number = 0;
  @StorageLink('simStateValueChanged') @Watch('simStateValueChangedWatch') simStateChanged: boolean = false;
  @State backText: string = getContext(this).resourceManager.getStringSync(
    $r('app.string.guide_action_text_previous').id);
  isInputDot: boolean = false;
  isEmojiDot: boolean = false;
  isTextDot: boolean = false;
  isSlidUp: boolean = true;
  @StorageProp('currentColorMode') currentMode: ConfigurationConstant.ColorMode =
    ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
  @State mmsPickerHeight: number = MIN_MM_PICKER_HEIGHT;
  @StorageProp('displayOrientation') displayOrientation: number = 0;
  private onCheckBoxChangedCallBack: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
    this.checkBoxStatusHasChanged = !this.checkBoxStatusHasChanged;
  }

  simStateValueChangedWatch() {
    HiLog.iw(TAG, 'simStateValueChanged simStateChangeEvent start! canSendMessage:' +
    this.mConversationCtrl.canSendMessage + ', haveSimCard:' + this.haveSimCard);
    this.refreshSimCardStatus();
    this.refreshSimCardIcon();
  }

  needReloadToolBar(): void {
    this.changeConversationSelectedNumberAndCheckAllBool();
  }

  isBackToUpChange() {
    // 触发回顶操作后，在详情页列表的监听方法中将详情页面中标注是否有接触到页面的hasTouch 设置为true
    // 因为详情初始化过程中中识别智能信息接口handlerSmartMmsParseResult回调时候会调用list组件的scrollToEnd（）方法
    HiLog.i(TAG, `isBackToUpChange: ${this.isBackToUp}`);
    this.isTouch = true;
  }

  isInMoreStatusChange() {
    // isInMore
    if (this.isVDE && this.isScrolling) {
      this.isScrolling = false;
      this.isScrollingHide = false;
    }
    this.VDEisInMore = false;
  }

  private onFoldStatusChange(): void {
    if (this.isVDEFoldPhoneAndFoldedState) {
      HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
    } else {
      HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
    }
  }

  conversationPageRefresh() {
    HiLog.i(TAG, 'conversationPageRefresh isPageRefresh:' + this.isPageRefresh);
    if (DeviceUtil.isPC()) {
      this.changeJumpContactButton();
    }
  }

  getWallpaper() {
    if (this.isVDEFoldPhoneAndFoldedState) {
      HiLog.iw(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
      if (this.foldStatus === 2) {
        this.isVDE = true
        HiLog.iw(TAG, 'this.showMMContentPicker is true');
        this.tabUtil.animationIterations = 0;
        this.showMMContentPicker = false;
        if (this.isDisplayFixedMenu) {
          this.isDisplayFixedMenu = !this.isDisplayFixedMenu;
        }
        this.closeKeyboard();
      } else {
        this.isVDE = false
        this.hideVdeTitle = false;
      }
      HiLog.iw(TAG, 'isVDE :' + this.isVDE);
    } else {
      this.isVDE = false
      this.hideVdeTitle = false;
      HiLog.iw(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
    }
  }

    @Styles
    normalStylesOfBack(){
        .backgroundColor(Color.Transparent)
    }

    @Styles
    pressedStylesOfBack(){
        .backgroundColor($r('sys.color.interactive_click'))
    }

   @Styles
   normalStylesOfCancel(){
     .backgroundColor(DeviceUtil.isPC() ? Color.Transparent : $r('sys.color.ohos_id_color_button_normal'))
   }

   @Styles
   pressedStylesOfCancel(){
     .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
     .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
   }

    @Provide
    menuItems: Array<MenuItemsObjRcs> = [
        {
            value: $r('app.string.delete'),
            action: () => {
                this.moreMenuDeleteItemClickEvent();
            },
            enabled: true,
            visible: true,
            id: 1
        },
      // {
      //   value: '',
      //   action: () => {
      //     this.isSlotIdChange = false;
      //     if (this.mConversationCtrl.isRcsMms) {
      //       HiLog.i(TAG, 'Switch from rcs to mms');
      //       this.mConversationCtrl.isRcsMms = false;
      //       this.changeRcsFlag = true;
      //       this.changeMenuItemsRcsValue();
      //       this.mConversationCtrl.resetValuesSwitchBetweenMmsAndRcs(true);
      //     } else {
      //       HiLog.i(TAG, 'Switch from mms to rcs');
      //       this.mConversationCtrl.isRcsMms = true;
      //       this.changeRcsFlag = false;
      //       this.changeMenuItemsRcsValue();
      //       this.tabUtil.animationIterations = 0;
      //       this.textareaFocusable = true;
      //       this.mConversationCtrl.resetValuesSwitchBetweenMmsAndRcs(false);
      //       contentMoreParams.SELECT_STATE = 7;
      //       DotUtil.getInstance().reportEvent(contentMoreParams, dotCommon.eventName.CONTENT_MORE_EVENT);
      //     }
      //   },
      //   enabled: true,
      //   visible: DeviceUtil.isTabletOrPC() ? false : true,
      //   id: 3
      // },
        {
          value: $r('app.string.new_contact'),
          action: () => {
            this.mConversationCtrl.createNewContact(this.context, this.mConversationCtrl.strContactsNumber);
            contentMoreParams.SELECT_STATE = 8;
            DotUtil.getInstance().reportEvent(contentMoreParams, dotCommon.eventName.CONTENT_MORE_EVENT);
          },
          enabled: true,
          visible: true,
          id: 5
        },
        {
          value: $r('app.string.exist_contact'),
          action: () => {
            this.mConversationCtrl.existingContact(this.context, this.mConversationCtrl.strContactsNumber);
            contentMoreParams.SELECT_STATE = 9;
            DotUtil.getInstance().reportEvent(contentMoreParams, dotCommon.eventName.CONTENT_MORE_EVENT);
          },
          enabled: true,
          visible: true,
          id: 6
        },
        {
          value: $r('app.string.msg_view_contacts_mms'),
          action: () => {
            this.mConversationCtrl.viewContacts(this.context);
          },
          enabled: true,
          visible: DeviceUtil.isPC() ? true : false,
          id: 8
        },
        {
          value: '',
          action: () => {
            if (this.mConversationCtrl.contactsNum > 1) {
              this.mConversationCtrl.pushToGroupContactListController();
              // 更多-收件人按钮打点
              contentMoreParams.SELECT_STATE = 3;
              DotUtil.getInstance().reportEvent(contentMoreParams, dotCommon.eventName.CONTENT_MORE_EVENT);
            } else {
              if (this.isChatbotConversation && this.chatbotDetail && this.chatbotDetail.callbackPhoneNumber) {
                this.mConversationCtrl.callbackPhoneNumber = this.chatbotDetail.callbackPhoneNumber;
              } else {
                this.mConversationCtrl.callbackPhoneNumber = '';
              }
              if (this.mConversationCtrl.isCall()) {
                this.checkCallDialogController.open();
              } else {
                this.mConversationCtrl.clickCall(this.context, this.selectDialogBuilder);
              }
              // Call dotting
              contentMoreParams.SELECT_STATE = 2;
              DotUtil.getInstance().reportEvent(contentMoreParams, dotCommon.eventName.CONTENT_MORE_EVENT);
            }
          },
          enabled: true,
          visible: !this.isChatbot(),
          id: 2
        },
       {
          value: $r('app.string.msg_detail_mms'),
          action: () => {
            let params: LooseObject = {
              id: this.mConversationCtrl.strContactsNumber,
              icon: this.mConversationCtrl.chatbotPageIcon,
              name: this.mConversationCtrl.strContactsName,
            }
            this.pageInfos.pushPathByName('RcsDetailsChatbotActivity', params);
            DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.OPEN_CHATBOT_DETAIL);
         },
          enabled: true,
          visible: this.isChatbot() ? true : false,
          id: 7
        }
    ];
    @Provide
    menuItemsResendRcs: Array<MenuItemsObj> = [
        {
            value: $r('app.string.mms_send'),
            action: () => {
                this.resendStateIsRcs = false;
                this.mConversationCtrl.resendMsg(this.context, this.resendStateIsRcs);
                this.resendRcsDialogController.close();
            },
            enabled: true
        },
        {
            value: $r('app.string.rcs_send'),
            action: () => {
                let isSameSoltId: boolean = false;
                if (this.defCellularSlotId !== this.simSlotId && this.cardImage) {
                    isSameSoltId = false;
                } else {
                    isSameSoltId = true;
                }
                this.resendStateIsRcs = true;
                this.mConversationCtrl.resendMsg(this.context, this.resendStateIsRcs, isSameSoltId);
                this.resendStateIsRcs = false;
                this.resendRcsDialogController.close();
            },
            enabled: true
        },
    ];
    @Provide
    menuItemList: Array<MenuItemsObj> = [
        {
            value: '',
            action: () => {
                this.mConversationCtrl && (this.mConversationCtrl.isChangeInputPlaceholder = false);
                this.isSlotIdChange = false;
                if (this.mConversationCtrl.isRcsMms) {
                    this.mConversationCtrl.changeIsRcsMms(false, this.isSlotIdChange);
                    this.changeRcsFlag = true;
                    this.isVoicing = false;
                    this.changeMenuItemsRcsValue();
                    this.mConversationCtrl.resetValuesSwitchBetweenMmsAndRcs(true);
                } else {
                    this.mConversationCtrl.changeIsRcsMms(true, this.isSlotIdChange);
                    this.changeRcsFlag = false;
                    this.changeMenuItemsRcsValue();
                    this.tabUtil.animationIterations = 0;
                    this.textareaFocusable = true;
                    contentMoreParams.SELECT_STATE = 7;
                    this.mConversationCtrl.resetValuesSwitchBetweenMmsAndRcs(false);
                    DotUtil.getInstance().reportEvent(contentMoreParams, dotCommon.eventName.CONTENT_MORE_EVENT);
                }
            },
            enabled: true
        }
    ];
    @State
    selectDialogBuilder: SelectDialogBuilder = {
      title: '',
      multiSimCardItems: [{
        name: '',
        img: $r('sys.symbol.phone_badge_1'),
        phone: '',
        slotId: 0
      }, {
        name: '',
        img: $r('sys.symbol.phone_badge_2'),
        phone: '',
        slotId: 1
      }],
    };

  wifiNoticeController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.text_trafficprompttitle'),
      content: $r('app.string.wifi_notice'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
        }
      },
      secondaryButton: {
        value: $r('app.string.welcome_page_btn_continue_text'),
        action: () => {
          this.rcsInfoStatus = 1;
          this.conversationRcsDataPreferences.putAndFlushInPreferences(Conversation.CONVERSATION_RCS_DATA_PREFERENCES,
            Conversation.RCS_INFO_STATUS);
          this.mConversationCtrl.sendOfEnhancedInfo(this.context);
        }
      },
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  })

    recorderRcsPermissionDialogCtrl: CustomDialogController = new CustomDialogController({
        builder: AlertDialog({
          primaryTitle: $r('app.string.message_requires_access_to_microphone'),
          content: $r('app.string.open_microphone_permission_info'),
          primaryButton: {
            value: $r('app.string.cancel'),
            action: () => {
              this.recorderRcsPermissionDialogCtrl.close();
              onlyStateParam.STATE = 2;
              this.isVoicing = false;
              DotUtil.getInstance().reportEvent(onlyStateParam, dotCommon.eventName.RECORDER_PERMISSION_BUTTON);
            },
          },
          secondaryButton: {
            value: $r('app.string.go_setting'),
            action: async () => {
              HiLog.i(TAG, 'recorderRcsPermissionDialogCtrl confirm');
              let res  = await this.recorderController.permissionOnSettingAsync(getContext(this));
              this.isVoicing = res == abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
              this.recorderRcsPermissionDialogCtrl.close();
              onlyStateParam.STATE = 1;
              DotUtil.getInstance().reportEvent(onlyStateParam, dotCommon.eventName.RECORDER_PERMISSION_BUTTON);
            }
          },
        }),
        backgroundColor:$r('sys.color.ohos_id_color_dialog_bg'),
        autoCancel: false,
        alignment: DialogAlignment.Center
    })

  private moreMenuDeleteItemClickEvent() {
    this.mConversationCtrl.longPressMore(this.context, 0);
    this.selectNumber = 0;
    this.isSelectDelete = true;
    this.closeKeyboard();
    this.mConversationCtrl.isMoreMenuDelete = true;
    if (this.mConversationCtrl.isMessageCheckAll) {
      this.mConversationCtrl.setMessageCheckAll(common.int.CHECKBOX_SELECT_NONE);
      this.conversationDataSource.notifyDataReload();
    }
    if (this.mConversationCtrl.mmsList.length == 1) {
      /*
       * this.mConversationCtrl是一个单实例
       * 会话A有多个会话详情：A1，A2,A3
       * 会话B有一个会话详情:B1
       * ---------------------------------
       * 在会话A执行(long press )选择操作
       * 选择会话详情A3,此时mConversationCtrl.mmsIndex == 2
       * 进入会话B时，只有一个会话是B1时
       * mConversationCtrl.mmsIndex 仍然等于2,
       * 执行右上角删除时，会按照mmsIndex(值为2)执行删除，会造成无法删除的问题。
       * -------------------------------------
       * 解决方案：此时需要将mmsIndex重置为0
       * */
      this.mConversationCtrl.mmsIndex = 0
      setTimeout(() => {
        this.delConversionController.open();
      }, 10);
    }
    this.changeConversationSelectedNumberAndCheckAllBool();
    // 更多-删除按钮打点
    contentMoreParams.SELECT_STATE = 1;
    DotUtil.getInstance().reportEvent(contentMoreParams, dotCommon.eventName.CONTENT_MORE_EVENT);
  }

    async rcsVoicePermission() {
        let authResults: number = await this.recorderController.initPermission('ohos.permission.MICROPHONE');
        this.recorderPermission = authResults === 0;
        return this.recorderPermission;
    }

  fullScreenPaddingChange() {
    this.topPadding = this.fullScreenPadding ? (this.fullScreenPadding.top as number) : 0;
    this.bottomPadding = this.fullScreenPadding ? (this.fullScreenPadding.bottom as number) : 0;
  }

  isChatbot(): boolean {
    let params: RcsChatbotOptions = this.pageInfos.getParamByName('Conversation')[0] as RcsChatbotOptions
    this.strChatbotNumber = params?.strContactsNumber || ''
    return this.strChatbotNumber.startsWith('sip') ? true : false;
  }

    updateRcsState(callBack: (currentIsRcs: boolean) => void): void {
        HiLog.iw(TAG, 'updateRcsState this.isOnlineRcs: ' + this.isOnlineRcs + 'this.defCellularSlotId: '
            + this.defCellularSlotId + 'this.simSlotId:' + this.simSlotId)
        if (this.isOnlineRcs && this.simSlotId === this.defCellularSlotId) {
            this.isShowMoreMenu = true;
            this.isSlotIdChange = false;
            this.mConversationCtrl.changeIsRcsMms(true, this.isSlotIdChange);
          if (this.menuItems.length == 5 && this.menuItems[4].id == 4) {
            // 目前按钮长度为三，第三个按钮是“加入黑名单”，后续更改要更改长度条件
            this.isShowRcsButton(false);
          } else {
            this.isShowRcsButton(true);
          }
          this.changeMenuItemsRcsValue();
          callBack(true);
        } else {
            this.updateRcsMmsStatus();
            this.mConversationCtrl.changeIsRcsMms(false, this.isSlotIdChange);
            this.changeRcsFlag = false;
            this.isShowMoreMenu = false;
            this.isShowRcsButton(false);
            if (this.showMMContentPicker) {
              this.mOffsetY = this.mmsPickerHeight + this.attachmentBottomHeight;
            }
            callBack(false);
        }
    }

    /**
     * 设置会话页面右上角菜单上是否显示增强信息和短彩信相互切换选项
     * @param isShow
     */
    private isShowRcsButton(isShow: boolean) {
      HiLog.i(TAG, `isShowRcsButton isShow: ${isShow}`);
      for (let i = 0; i < this.menuItems.length; i++) {
        if (this.menuItems[i].id === 3) {
          if (isShow) {
            this.menuItems[i].visible = true;
          } else {
            this.menuItems[i].visible = false;
          }
        }
      }
    }

  handleSelectedSlotIdChange(): void {
    HiLog.iw(TAG,
      `handleSelectedSlotIdChange simSlotId:${this.simSlotId}, defCellularSlotId:${this.defCellularSlotId}, cardImage:${this.cardImage}`)
    const lastIsRcs = this.mConversationCtrl.isRcsMms;
    if (this.defCellularSlotId !== this.simSlotId && this.cardImage) {
      if (this.showMMContentPicker) {
        this.mOffsetY = this.mmsPickerHeight + this.attachmentBottomHeight;
      }
      this.isSlotIdChange = true;
      this.mConversationCtrl.changeIsRcsMms(false, this.isSlotIdChange);
      this.isShowMoreMenu = false;
      this.deleteRcsButton();
      if (lastIsRcs === true) {
        this.mConversationCtrl.resetValuesSwitchBetweenMmsAndRcs(true);
      }
    } else {
      if (!this.changeRcsFlag) {
        const tempFunction = (currentIsRcs: boolean) => {
          if (this.showMMContentPicker) {
            if (!currentIsRcs) {
              this.mOffsetY = this.mmsPickerHeight + this.attachmentBottomHeight;
            } else {
              this.mOffsetY = this.splitInfoModel.isSmall ? MIN_MM_PICKER_HEIGHT : RCS_MM_PICKER_HEIGHT;
            }
          }
          (lastIsRcs !== currentIsRcs) && this.mConversationCtrl.resetValuesSwitchBetweenMmsAndRcs(lastIsRcs);
        }
        this.isSlotIdChange = true;
        this.updateRcsState(tempFunction);
      } else {
        if (this.showMMContentPicker) {
          this.mOffsetY = this.mmsPickerHeight + this.attachmentBottomHeight;
        }
        this.handleChangeRcsFlagDetails();
      }
    }
    HiLog.i(TAG, 'change slotid and check maxmmssize from cust file');
    this.mConversationCtrl.maxSizeOfMms =
      OperatorConfigUtil.getInstance().getCustMMSSize(commonData.int.MMS_FILE_MAX_SIZE) || 307200;
  }

  private handleChangeRcsFlagDetails() {
    if (this.menuItems.length == 5 && this.menuItems[4].id == 4) {
      // 目前按钮长度为三，第三个按钮是“加入黑名单”，后续更改要更改长度条件
      this.isShowMoreMenu = true;
      this.isShowRcsButton(false);
      this.changeMenuItemsRcsValue();
    } else {
      this.isShowMoreMenu = true;
      this.isShowRcsButton(true);
      this.changeMenuItemsRcsValue();
    }
  }

    windowStageEventTypeChange() {
        if (this.windowStageEventType === window.WindowStageEventType.PAUSED) {
          // 由于调用相机 picker 导致页面退出时，不保存草稿。否则会导致拍照的图片不能保存。
          if (AppStorage.get('invokeCamera')) {
            return
          }
            // 保存草稿
            this.mConversationCtrl.setDraftModel(() => {
                DraftUtils.getInstance().saveDraft(getContext(this),undefined, true)
            }, false)
        }
    }

    /** Message details dialog box */
    dialogController: CustomDialogController = new CustomDialogController({
        builder: CustomContentDialog({
            primaryTitle: $r('app.string.msgDetails'),
            contentBuilder: () => {
                this.detailsDialogBuildContent();
            },
            buttons: [{
                value: $r('app.string.msg_know'),
                buttonStyle: ButtonStyleMode.TEXTUAL,
                action: () => {
                }
            }]
        }),
        autoCancel: true,
    })

  // 查看 vcard 详情弹框
  mmcheckVcardDialog: CustomDialogController = new CustomDialogController({
    builder: MMCheckVcardDialog({
      path: this.mConversationCtrl.getVcardPath()
    }),
    autoCancel: true,
    cancel: () => {
      this.mmcheckVcardDialog?.close();
    },
    alignment: DialogAlignment.Center,
  })

  importVcard() {
    SharedPreferencesUtils.deletePreferences(this.mConversationCtrl.getVcardPath())
    if (!this.savedFileInfo) {
      return
    }
    let vcfFileInfo: SavedFileInfo = this.savedFileInfo;
    const name: string = 'vcard_temp.vcf'
    promptAction.showToast({
      message: $r('app.string.msg_vCard_import_success', name),
      duration: 200
    });
    VCardUtil.getInstance().importVCard(this.context, vcfFileInfo.path, (result: boolean) => {
      HiLog.i(TAG, 'import vcard result: ' + result);
      setTimeout(() => {
        promptAction.showToast({
          message: $r('app.string.vCard_import_success', name),
          duration: 200
        });
      }, 300)
    })
    this.mmConfirmVcardDialog.close();
  }

  // 确认导入 vcard 弹框
  mmConfirmVcardDialog: CustomDialogController = new CustomDialogController({
    builder: MMAskIsImportDialog({
      confirmed: () => {
        this.importVcard()
      },
    }),
    autoCancel: true,
    cancel: () => {
      this.mmConfirmVcardDialog?.close();
    },
    gridCount: 4
  })

  // 保存 vcard 弹框
  mmSaveVcardDialog: CustomDialogController = new CustomDialogController({
    builder: MMSaveVcardDialog({
      path: this.mConversationCtrl.getVcardPath(),
      confirmed: async (savedFileInfo: SavedFileInfo) => {
        this.handleSaveVcard(savedFileInfo)
      },
    }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
  })

  async handleSaveVcard(savedFileInfo: SavedFileInfo) {
    this.savedFileInfo = savedFileInfo;
    let atManager = abilityAccessCtrl.createAtManager();
    let info = await bundleManager.getApplicationInfo(commonData.STR.BUNDLE_NAME,
      bundleManager.ApplicationFlag.GET_APPLICATION_INFO_WITH_PERMISSION)
    let hasPermission =
      atManager.verifyAccessTokenSync(info.accessTokenId, 'ohos.permission.WRITE_CONTACTS');
    HiLog.i(TAG, 'check permission: ' + hasPermission);
    if (hasPermission === 0) {
      this.mmConfirmVcardDialog.open();
      this.mmSaveVcardDialog.close();
    } else {
      let permissions: Permissions[] = ['ohos.permission.WRITE_CONTACTS'];
      let permissionResult = await atManager.requestPermissionsFromUser(this.context, permissions);
      HiLog.i(TAG, 'check permission: ' + JSON.stringify(permissionResult.authResults));
      if (permissionResult.authResults[0] == 0) {
        this.mmConfirmVcardDialog.open();
        this.mmSaveVcardDialog.close();
      }
    }
  }

    // exsit call dialog box
    checkCallDialogController: CustomDialogController = new CustomDialogController({
      builder: AlertDialog({
        content:  $r('app.string.calling_Alert'),
        primaryButton: {
          value: $r('app.string.msg_know'),
          action: () => {}
        }
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true,
    })

  getMessageType(): Resource | string {
    let str: Resource | string = '';
    if (this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex]?.isIpMsg) {
      str = $r('app.string.intelligent_information')
    } else if (this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex]?.isRcs ===
      common.MESSAGE_TYPE.RCS) {
      str = $r('app.string.enhanced_information')
    } else if (this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex]?.isMsm) {
      str = $r('app.string.mms')
    }  else {
      str = $r('app.string.sms')
    }
    return str;
  }

    @Builder
    displayRcsFileSize() {
        Text() {
            Span($r('app.string.priority')).fontSize(16);
        }
        .fontSize(16)
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: 4 })
        .fontFamily('HarmonyHeiTi')

        Text() {
            if (this.mConversationCtrl?.cbSelectedOnlyOneMsmItemOfMmsList?.totalSize) {
                Span($r('app.string.rcsFileSize',
                    formatFileSize(this.mConversationCtrl.cbSelectedOnlyOneMsmItemOfMmsList.totalSize, 2)
                )).fontSize(16);
            }
        }
        .fontSize(16)
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: 8 })
        .fontFamily('HarmonyHeiTi')
    }

    @Builder
    detailsDialogBuildContent(): void {
      Scroll() {
        Column() {
          Text() {
            Span($r('app.string.type')).fontSize(16)
            Span(this.getMessageType()).fontSize(16)
          }
          .fontSize(16).fontColor($r('sys.color.font_primary'))
          .margin({ bottom: 4 }).fontFamily('HarmonyHeiTi')

          Row() {
            Text(this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex]?.isReceive ? $r('app.string.sender') :
            $r('app.string.putAddresser'))
              .fontSize(16)
              .fontColor($r('sys.color.font_primary'))
              .fontFamily('HarmonyHeiTi')
            Text(this.mConversationCtrl.strContactsName == '' ? this.mConversationCtrl.strContactsNumber :
            this.mConversationCtrl.strContactsName)
              .fontSize(16)
              .fontColor($r('sys.color.font_primary'))
              .fontFamily('HarmonyHeiTi')
              .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
              .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Ltr : Direction.Auto)
          }
          .margin({ bottom: 4 })

          Text() {
            if (this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex]?.isReceive) {
              Span($r('app.string.putTime',
                (this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex].fullDate as string +
                  ' ' + this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex].timeOfSms as string)))
                .fontSize(16)
            } else {
              Span($r('app.string.sendTime')).fontSize(16)
              Span(this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex].fullDate).fontSize(16)
              Span(this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex].timeOfSms).fontSize(16)
            }
          }
          .fontSize(16).fontColor($r('sys.color.font_primary'))
          .margin({ bottom: this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex].isMsm ? 4 : 8 })
          .fontFamily('HarmonyHeiTi')

          if (this.mConversationCtrl.cbSelectedOnlyOneMsmItemOfMmsList &&
          this.mConversationCtrl.cbSelectedOnlyOneMsmItemOfMmsList.isRcs) {
            this.displayRcsFileSize()
          } else if (this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex].isMsm) {
            Text() {
              Span($r('app.string.priority')).fontSize(16)
            }
            .fontSize(16).fontColor($r('sys.color.font_primary'))
            .margin({ bottom: 4 }).fontFamily('HarmonyHeiTi')

            Text() {
              if (MmsUtil.isValidSize(
                this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex].mmsSource)) {
                Span($r('app.string.size',
                (this.getFileSize()).toFixed(0))).fontSize(16)
              }
            }
            .fontSize(16).fontColor($r('sys.color.font_primary'))
            .margin({ bottom: 8 }).fontFamily('HarmonyHeiTi')
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .accessibilityGroup(true)
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollBar(BarState.Off)
    }

    getFileSize(): number {
      const mmsSource: Array<Mms> = MmsUtil.deleteSmil(this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex].mmsSource)
      if (this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex].msgShowType ===
      common.MESSAGE_SHOW_TYPE.MAP) {
        const mmsMapAttach: Mms | undefined = mmsSource.find(item => item.type === commonData.MM_ATTACHMENT_TYPE.MAP);
        return (Number(mmsMapAttach?.size) || 0) / common.int.BYTE_CONVERSION_UNIT;
      }
      if (mmsSource[0].type === commonData.MM_ATTACHMENT_TYPE.VCARD && (mmsSource[0].size || 0) < 1 * common.int.BYTE_CONVERSION_UNIT) {
        // // 如果 vcard文件的大小小于 1 kb，默认设置大小为 1kb
        return 1
      } else {
        return Number(mmsSource[0].size) / common.int.BYTE_CONVERSION_UNIT
      }
    }

    rcsAudioPromptsController: CustomDialogController = new CustomDialogController({
        builder: AudioPrompts({ isResumeSend: this.rcsIsResumeSend }),
        autoCancel: false,
        alignment: DialogAlignment.Center,
        gridCount: 4,
        customStyle: true,
        isModal: false
    })

    acceptFailureDialogController: CustomDialogController = new CustomDialogController({
        builder: AlertDialog({
            content: $r('app.string.msgAcceptFailure'),
            primaryButton: {
                value: $r('app.string.msg_know'),
                action: () => {}

            }
        }),
        autoCancel: true,
    })

    delConversionController: CustomDialogController = new CustomDialogController({
        builder: AlertDialog({
            content: this.mConversationCtrl.strMsgDeleteDialogTip,
            primaryButton: {
                value: $r('app.string.cancel'),
                buttonStyle: DeviceUtil.isPC() ? ButtonStyleMode.NORMAL : ButtonStyleMode.TEXTUAL,
                action: () => {
                    this.textareaFocusable = false;
                    if (this.mConversationCtrl.isMoreMenuDelete) {
                      this.isSelectDelete = true;
                    } else {
                      this.isSelectDelete = false;
                    }
                    // 取消删除会话打点
                    stateParam.STATE = 1;
                    DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.CONTENT_LONGPRESS_DELETE_EVENT);
                }
            },
            secondaryButton: {
                value: $r('app.string.delete'),
                buttonStyle: DeviceUtil.isPC() ? ButtonStyleMode.NORMAL : ButtonStyleMode.TEXTUAL,
                action: () => {
                    if (this.mConversationCtrl.isRcsMms) {
                      this.mConversationCtrl.cancelRcsFile(this.context, String(this.mConversationCtrl.rcsMsgId))
                    }
                    this.mConversationCtrl.deleteDialogConfirm(this.context)
                    this.isSelectDelete = false;
                    // 确认删除会话打点
                    stateParam.STATE = 2;
                    DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.CONTENT_LONGPRESS_DELETE_EVENT);
                },
                role: DeviceUtil.isPC() ? ButtonRole.NORMAL : ButtonRole.ERROR
            }
        }),
    alignment: DialogAlignment.Center,
        autoCancel: false,
    });

    resendDialogController: CustomDialogController = new CustomDialogController({
        builder: AlertDialog({
            primaryTitle: $r('app.string.msg_resend_prompt'),
            primaryButton: {
                value: $r('app.string.cancel'),
                buttonStyle: ButtonStyleMode.TEXTUAL,
                action: () => {
                    // 取消重新发送状态打点
                    stateParam.STATE = 2;
                    DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.CONFIRM_RESEND_SMS_EVENT);
                }
            },
            secondaryButton: {
                value: $r('app.string.msg_resend'),
                buttonStyle: ButtonStyleMode.TEXTUAL,
                action: () => {
                    this.mConversationCtrl.resendMsg(this.context, this.resendStateIsRcs);
                    // 确认重新发送状态打点
                    stateParam.STATE = 1;
                    DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.CONFIRM_RESEND_SMS_EVENT);
                }
            }
        }),
        autoCancel: false,
        alignment: DialogAlignment.Center
    });
    resendRcsDialogController: CustomDialogController = new CustomDialogController({
        builder: CustomContentDialog({
            primaryTitle: $r('app.string.msg_resend_rcs'),
            contentBuilder: () => {
                this.resendDialogRcsBuildContent();
            },
            contentAreaPadding: {left: 0, right: 0, top: 0, bottom: 0},
            buttons: [{
                value: $r('app.string.cancel'),
                buttonStyle: ButtonStyleMode.TEXTUAL,
                action: () => {
                }
            }]
        }),
        autoCancel: false,
    });

  abnormalSceneController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.messageReceiveFailed'),
      content: $r('app.string.cannot_download_image_dialog_message'),
      primaryButton: {
        value: $r('app.string.msg_know'),
        buttonStyle: ButtonStyleMode.TEXTUAL,
        action: () => {
          this.abnormalSceneController.close();
        }
      }
    }),
    cancel: () => {
      this.abnormalSceneController.close();
    },
    alignment: DialogAlignment.Center,
    autoCancel: true,
  });

    @Builder
    resendDialogRcsBuildContent(): void {
        ResendDialogRcs()
    }
    multiSimCardCallDialog: CustomDialogController = new CustomDialogController({
        builder: CustomContentDialog({
            primaryTitle: this.selectDialogBuilder.title,
            contentBuilder: () => {
                this.multiSimCardCallDialogBuildContent()
            },
            buttons: [{
                value: $r('app.string.cancel'),
                buttonStyle: ButtonStyleMode.TEXTUAL,
                action: () => {
                }
            }],
            contentAreaPadding: { left: 0, right: 0, top: 0, bottom: 0 }
        }),
        autoCancel: true,
    })

    @Builder
    multiSimCardCallDialogBuildContent(): void {
        MultiSimCardCallDialog({
            builder: $selectDialogBuilder,
            controller: this.multiSimCardCallDialog
        })
    }

    transmitAudioDialogController: CustomDialogController = new CustomDialogController({
        builder: AlertDialog({
            primaryTitle: $r('app.string.translate_other'),
            content: $r('app.string.translate_audio'),
            primaryButton: {
                value: $r('app.string.cancel'),
                buttonStyle: ButtonStyleMode.TEXTUAL,
                action: () => {
                }
            },
            secondaryButton: {
                value: $r('app.string.confirm'),
                buttonStyle: ButtonStyleMode.TEXTUAL,
                action: () => {
                    GlobalContext.getContext().setObject('notUpdateData', true)
                    this.mConversationCtrl.transmitMsg(this.context);
                }
            }
        }),
        autoCancel: false,
    });

    securityModeController: CustomDialogController = new CustomDialogController({
        builder: CustomContentDialog({
            contentBuilder: () => {
                this.advancedSecurityDialogBuildContent();
            },
            buttons: [{
                value: $r('app.string.setting_konw'),
                buttonStyle: ButtonStyleMode.TEXTUAL,
                action: () => {
                }
            }]
        }),
    })

    @Builder
    advancedSecurityDialogBuildContent(): void {
      Row() {
        SymbolGlyph($r('sys.symbol.security_shield'))
          .fontSize(32)
          .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
          .fontColor([$r('sys.color.icon_primary'), $r('sys.color.icon_emphasize')])
      }
      .width('100%')
      .margin({ bottom: 16 })
      .justifyContent(FlexAlign.Center)

      Row() {
        Text($r('app.string.in_advanced_mode'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontFamily('HarmonyHeiTi')
          .lineHeight(24)
          .fontColor($r('sys.color.font_primary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .maxFontScale(2)
      }
      .width('100%')
      .margin({ bottom: 16 })
      .justifyContent(FlexAlign.Center)
      Scroll() {
        Column() {
          Row() {
            Text(this.mAdvancedSettingsCtrl.isAdvancedSecurity ? $r('app.string.setting_advanced_mode') : $r('app.string.leave_setting_advanced_mode'))
              .fontSize(16)
              .fontWeight(FontWeight.Regular)
              .fontFamily('HarmonyHeiTi')
              .lineHeight(20)
              .fontColor($r('sys.color.font_primary'))
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
        }.width("100%")
      }
      .scrollBar(BarState.Off)
      .layoutWeight(this.fontSizeScale > 3 ? 1 : 0)
    }

    async getCellularData(): Promise<number> {
        this.defCellularSlotId = await DataService.getDefaultCellularDataSlotId();
        AppStorage.setOrCreate('defCellularSlotId', this.defCellularSlotId);
        return this.defCellularSlotId;
    }

    handleSwitchCard() {
        this.isSlotIdChange = false;
        if (this.isOnlineRcs && this.simSlotId === this.defCellularSlotId) {
            if (!this.changeRcsFlag) {
                this.mConversationCtrl.changeIsRcsMms(true, this.isSlotIdChange);
                this.changeMenuItemsRcsValue();
            }
        } else {
            this.mConversationCtrl.changeIsRcsMms(false, this.isSlotIdChange);
            this.isShowMoreMenu = false;
            this.updateRcsMmsStatus();
        }
    }

    updateRcsMmsStatus() {
        DataService.getDefaultCellularDataSlotId().then(res => {
            this.defCellularSlotId = res;
            if (this.simSlotId !== this.defCellularSlotId) {
                AppStorage.setOrCreate('rcsMmsStatus', true);
            } else {
                AppStorage.setOrCreate('rcsMmsStatus', !this.changeRcsFlag);
            }
        })
    }

    imageCompleteEventOn() {
        emitter.on(this.CHECK_IMAGE_EVENT, () => {
            if (this.mConversationCtrl.searchContent === '') {
                this.mConversationCtrl.scrollToEnd();
            }
        });
    }

  async aboutToAppear() {
    HiLog.i(TAG, ` aboutToAppear in. `);
    await this.initAvatarPhoto();
    this.mConversationCtrl.isFromBackground = false;
    AppStorage.setOrCreate('receiveSessionArray', []);
    AppStorage.setOrCreate('isFromNotification', false);
    if (!this.context) {
      HiLog.w(TAG, 'Initialize getcontext is null!')
      this.context = getContext(this) as myCommon.UIAbilityContext;
      if (!this.context) {
        HiLog.e(TAG, 'retry getcontext failed,context is null!')
      }
    }
    this.uiObserver.on('routerPageUpdate', this.listener);
    this.mConversationCtrl.registerDataChangeObserver(this.onContactChange, getContext(this));
    this.fullScreenPaddingChange()
    this.conversationDataSource.clear();
    this.conversationAppear(); // 加载详情数据源
    this.mConversationCtrl.getHasSimCard().then(() => {
      this.haveTwoCards = this.mConversationCtrl.haveTwoCards
      if (this.mConversationCtrl.haveTwoCards) {
        this.getCellularData().then(val => {
          this.defCellularSlotId = val;
          this.handleSelectedSlotIdChange();
          this.handleSwitchCard();
        })
      } else if (this.isOnlineRcs && this.isEnableRcsAbility) {
        this.isShowMoreMenu = true;
        this.isSlotIdChange = false;
          if (!this.changeRcsFlag) {
              this.mConversationCtrl.changeIsRcsMms(true, this.isSlotIdChange);
          }
        this.changeMenuItemsRcsValue();
      } else {
        this.isShowMoreMenu = false;
        this.isSlotIdChange = false;
        this.mConversationCtrl.changeIsRcsMms(false, this.isSlotIdChange);
        this.deleteRcsButton();
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, error.message);
    });
    this.mConversationCtrl.onShow(this.context);
    this.mConversationCtrl.setMessageTimeoutContent(this.context);
    this.changeMenuItemsValue();
    let that = this;
    const controllerMethods: Controller = {
      open() {
        that.multiSimCardCallDialog.open();
      },
      close() {
        that.multiSimCardCallDialog.close();
      }
    }
    this.selectDialogBuilder.controller = controllerMethods;
    this.setAppearData();
    hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_ABOUT_TO_APPEAR,
      TraceConstant.TRACE_CONVERSATION_ABOUT_TO_APPEAR_ID);
    this.handleWithPadStatus();
    this.accessibilitySwitch = settings.getValueSync(getContext(this), 'accessibility_screenreader_enabled',
      Constant.ACCESSIBILITY_SCREEN_READER_SWITCH_CLOSED);
    try {
      this.inputMethodSetting.on('imeShow', this.emitterKeyboard);
      this.mScreenRotationListener.on('change', this.onPortrait.bind(this));
    } catch (err) {
      HiLog.i(TAG, `Failed to unsubscribing inputMethodProperty. err: ${JSON.stringify(err)}`);
    }
    this.subscribeConfigurationUpdate();
    DateRefreshUtil.getInstance()
      .subscribeTimeRefresh(this.refreshDateKey, () => {
        this.mConversationCtrl.refreshConversationDate(getContext(this));
        this.needRefreshTime = !this.needRefreshTime;
      });
    this.mConversationCtrl.resetIsInitParam();
    if (this.isVoicing) {
      let authResults: number = await this.recorderController.initPermission('ohos.permission.MICROPHONE');
      let recorderPermission: boolean = authResults === 0;
      if (!recorderPermission) {
        this.recorderRcsPermissionDialogCtrl.open();
      }
    }
  }

  private async initAvatarPhoto() {
    try {
      const rowsTemplateValue =
        this.mmAttachmentAreaController.tabsRowsTemplateValue(this.displayOrientation, this.curBp)
      this.mmsPickerHeight = rowsTemplateValue === '1fr 1fr' ? MMS_MM_PICKER_HEIGHT : MIN_MM_PICKER_HEIGHT

      this.transmitParams = this.pageInfos.getParamByName('Conversation')[0] as RcsChatbotOptions
      if (this.transmitParams.photoFirstNames && this.transmitParams.photoFirstNames.length > 0) {
        let photoObj: photoFirstNamesType = this.transmitParams.photoFirstNames[0];
        this.portraitColor = photoObj.portraitColor ? photoObj.portraitColor : this.portraitColor;
      } else {
        this.portraitColor = AvatarColor.background.Color[Number(this.rawContactId.split(',')[0] || '0') % 6];
      }
      if (!this.transmitParams?.photoFirstNames) {
        let photoFirstNames: Array<photoFirstNamesType> = new Array()
        if (this.transmitParams?.selectContacts) {
          HiLog.i(TAG, `transmitParams.selectContacts.length: ${this.transmitParams?.selectContacts?.length}`);
          for (let i = 0; i < this.transmitParams?.selectContacts.length; i++) {
            await this.photoFirstNameDeal(this.transmitParams?.selectContacts[i].contactName);
            let params: photoFirstNamesType = {
              portraitColor: this.portraitColor,
              firstName: this.photoFirstName
            }
            photoFirstNames.push(params)
          }
        } else {
          await this.photoFirstNameDeal(this.transmitParams?.strContactsName);
          let params: photoFirstNamesType = {
            portraitColor: this.portraitColor,
            firstName: this.photoFirstName
          }
          photoFirstNames.push(params)
        }

        this.transmitParams.photoFirstNames = photoFirstNames;
      }
      HiLog.i(TAG, `transmitParams.photoFirstNames.length: ${this.transmitParams?.photoFirstNames?.length}`);
    } catch (err) {
      HiLog.e(TAG, `initAvatarPhoto failed, code is ${err?.code}, message is ${err?.message}`);
    }
  }

  sysLocaleChangedFun() {
    // 因分钟数需要国际化，需在语言切换时重新初始化
    this.mConversationCtrl.refreshConversationDate(getContext(this), true);
    this.needRefreshTime = !this.needRefreshTime;
  }

  photoFirstNameDeal(strContactsName: string) {
    // Get first initials
    if (strContactsName !== common.STR.EMPTY_STR && strContactsName.indexOf(',') > -1) {
      this.photoFirstName = common.FIRST_NAME_TYPE.GROUP_SMS;
    } else {
      if (strContactsName !== common.STR.EMPTY_STR && this.reg.test(strContactsName)) {
        if (this.allChinese.test(strContactsName)) {
          this.photoFirstName = strContactsName.substring(strContactsName.length - 1, strContactsName.length);
        } else if (this.hasChinese.test(strContactsName)) {
          for (let index = strContactsName.length - 1; index >= 0; --index) {
            if (this.hasChinese.test(strContactsName[index])) {
              this.photoFirstName = strContactsName[index];
              break;
            }
          }
        } else if (this.hasEnglish.test(strContactsName[0])) {
          this.photoFirstName = strContactsName[0].toUpperCase();
        } else {
          this.photoFirstName = ' ';
        }
      } else {
        this.photoFirstName = ' ';
      }
    }

  }

  /*
   获取黄页信息
   */
  getYellowPageInfo() {
    YellowPageService.getInstance()
      .judgeYellowPageByTelephone(this.mConversationCtrl.strContactsNumber, this.context)
      .then((res: LooseObject) => {
      });
  }

  initToolBarList() {
    this.toolBarList.splice(0)
    if (this.isSelectDelete) {
      this.toolBarList.push({
        content: $r('app.string.delete'),
        toolBarSymbolOptions: {
          normal: new SymbolGlyphModifier($r('sys.symbol.trash')).fontColor([$r('sys.color.icon_primary')])
        },
        action: () => {
          if (this.selectNumber != 0) {
            this.mConversationCtrl.clickGroupDelete(this.selectNumber);
            setTimeout(() => {
              this.delConversionController.open();
            }, 10);
          }
          // 详情-更多组件打点
          seleteParam.SELECT_STATE = 1;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_SELECT_ITEM);
        },
        state: this.selectNumber === 0
          ? ItemState.DISABLE : ItemState.ENABLE
      })
      this.toolBarList.push({
        content: this.mConversationCtrl.isMessageCheckAll ? $r('app.string.msg_deselect_all')
          : $r('app.string.msg_select_all'),
        icon: this.mConversationCtrl.isMessageCheckAll ?
        $rawfile('icon/ic_select_all_filled.svg')
          : $rawfile('icon/ic_select_all.svg'),
        action: () => {
          this.mConversationCtrl.clickGroupCheckAll()
          this.changeConversationSelectedNumberAndCheckAllBool();
          // 详情-更多组件打点
          seleteParam.SELECT_STATE = 4;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_SELECT_ITEM);
        },
        state: ItemState.ACTIVATE
      })
    } else {
      this.toolBarList.push({
        content: $r('app.string.delete'),
        toolBarSymbolOptions: {
          normal: new SymbolGlyphModifier($r('sys.symbol.trash')).fontColor([$r('sys.color.icon_primary')])
        },
        action: () => {
          if (this.selectNumber != 0) {
            this.mConversationCtrl.clickGroupDelete(this.selectNumber);
            setTimeout(() => {
              this.delConversionController.open();
            }, 10);
          }
          // 详情-更多组件打点
          seleteParam.SELECT_STATE = 1;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_SELECT_ITEM);
        },
        state: this.selectNumber === 0
          ? ItemState.DISABLE : ItemState.ENABLE
      })
      this.toolBarList.push({
        content: $r('app.string.msg_transmit'),
        icon: $rawfile('icon/ic_transfer.svg'),
        action: () => {
          if (this.selectNumber !== 0) {
            if (this.mConversationCtrl.audioStatus !== common.MMS_AUDIO_STATUS.NO_AUDIO &&
            this.mConversationCtrl.isNeedTransmitTip()) {
              this.transmitAudioDialogController.open();
            } else {
              GlobalContext.getContext().setObject('notUpdateData', true)
              this.mConversationCtrl.transmitMsg(this.context);
            }
          }
          // 详情-更多组件打点
          seleteParam.SELECT_STATE = 2;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_SELECT_ITEM);
        },
        state: (!this.mConversationCtrl.getMmsCount() &&
          this.selectNumber > 0 &&
          this.selectNumber <= 30 &&
          this.mConversationCtrl.audioStatus !== common.MMS_AUDIO_STATUS.ONLY_AUDIO &&
          this.mConversationCtrl.richMediaCards !== common.MMS_AUDIO_STATUS.ONLY_AUDIO) &&
          !this.mConversationCtrl.hasRcsFileNotDownload &&
          !this.mConversationCtrl.isSelectedContainIpCardMsgItems()
          ? ItemState.ENABLE : ItemState.DISABLE
      })
      this.toolBarList.push({
        content: $r('app.string.msg_star'),
        icon: $rawfile('icon/ic_msg_favorite_m.svg'),
        action: () => {
          if (this.selectNumber !== 0) {
            this.mConversationCtrl.mmsFavorite(this.context);
            this.mConversationCtrl.setSelectStatus(false)
          }
          this.mConversationCtrl.favorite()
          // 详情-更多组件打点
          seleteParam.SELECT_STATE = 3;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_SELECT_ITEM);
        },
        state: (!this.mConversationCtrl.getMmsCount() && this.selectNumber > 0
          && this.selectNumber <= 30 && !this.mConversationCtrl.hasRcsFileNotDownload) &&
          !this.mConversationCtrl.isSelectedContainIpCardMsgItems()
          ? ItemState.ENABLE : ItemState.DISABLE
      })
      this.toolBarList.push({
        content: this.mConversationCtrl.isMessageCheckAll ? $r('app.string.msg_deselect_all')
          : $r('app.string.msg_select_all'),
        icon: this.mConversationCtrl.isMessageCheckAll ?
        $rawfile('icon/ic_select_all_filled.svg')
          : $rawfile('icon/ic_select_all.svg'),
        action: () => {
          this.mConversationCtrl.clickGroupCheckAll()
          this.changeConversationSelectedNumberAndCheckAllBool();
          // 详情-更多组件打点
          seleteParam.SELECT_STATE = 4;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_SELECT_ITEM);
        },
        state: ItemState.ACTIVATE
      })
      this.toolBarList.push({
        content: $r('app.string.more'),
        icon: $rawfile('icon/ic_public_more.svg'),
        action: () => {
          this.isMoreMenuShown = true;
        },
        state: (this.selectNumber === 0 ||
        this.mConversationCtrl.isSelectedContainIpCardMsgItems())
          ? ItemState.DISABLE : ItemState.ENABLE
      })
    }

    this.toolBarList1.splice(0)
    if (this.isSelectDelete) {
      this.toolBarList1.push({
        content: '',
        icon: $rawfile('icon/ic_public_delete.svg'),
        action: () => {
          if (this.selectNumber != 0) {
            this.mConversationCtrl.clickGroupDelete(this.selectNumber);
            setTimeout(() => {
              this.delConversionController.open();
            }, 10);
          }
          // 详情-更多组件打点
          seleteParam.SELECT_STATE = 1;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_SELECT_ITEM);
        },
        state: this.selectNumber === 0
          ? ItemState.DISABLE : ItemState.ENABLE
      })
      this.toolBarList1.push({
        content: '',
        icon: this.mConversationCtrl.isMessageCheckAll ?
        $rawfile('icon/ic_select_all_filled.svg')
          : $rawfile('icon/ic_select_all.svg'),
        action: () => {
          this.mConversationCtrl.clickGroupCheckAll()
          this.changeConversationSelectedNumberAndCheckAllBool();
          // 详情-更多组件打点
          seleteParam.SELECT_STATE = 4;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_SELECT_ITEM);
        },
        state: ItemState.ACTIVATE
      })
    } else {
      this.toolBarList1.push({
        content:'',
        icon: $rawfile('icon/ic_public_delete.svg'),
        action: () => {
          if (this.selectNumber != 0) {
            this.mConversationCtrl.clickGroupDelete(this.selectNumber);
            setTimeout(() => {
              this.delConversionController.open();
            }, 10);
          }
          // 详情-更多组件打点
          seleteParam.SELECT_STATE = 1;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_SELECT_ITEM);
        },
        state: this.selectNumber === 0
          ? ItemState.DISABLE : ItemState.ENABLE
      })
      this.toolBarList1.push({
        content: '',
        icon: $rawfile('icon/ic_transfer.svg'),
        action: () => {
          if (this.selectNumber !== 0) {
            if (this.mConversationCtrl.audioStatus !== common.MMS_AUDIO_STATUS.NO_AUDIO &&
            this.mConversationCtrl.isNeedTransmitTip()) {
              this.transmitAudioDialogController.open();
            } else {
              GlobalContext.getContext().setObject('notUpdateData', true)
              this.mConversationCtrl.transmitMsg(this.context);
            }
          }
          // 详情-更多组件打点
          seleteParam.SELECT_STATE = 2;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_SELECT_ITEM);
        },
        state: (!this.mConversationCtrl.getMmsCount() &&
          this.selectNumber > 0 &&
          this.selectNumber <= 30 &&
          this.mConversationCtrl.audioStatus !== common.MMS_AUDIO_STATUS.ONLY_AUDIO &&
          this.mConversationCtrl.richMediaCards !== common.MMS_AUDIO_STATUS.ONLY_AUDIO) &&
          !this.mConversationCtrl.hasRcsFileNotDownload &&
          (!this.mConversationCtrl.isSelectedContainIpCardMsgItems() && !this.conListCtrl.isOsAccountConstraintEnabled)
          ? ItemState.ENABLE : ItemState.DISABLE
      })
      this.toolBarList1.push({
        content: '',
        icon: $rawfile('icon/ic_msg_favorite_m.svg'),
        action: () => {
          if (this.selectNumber !== 0) {
            this.mConversationCtrl.mmsFavorite(this.context);
            this.mConversationCtrl.setSelectStatus(false)
          }
          this.mConversationCtrl.favorite()
          // 详情-更多组件打点
          seleteParam.SELECT_STATE = 3;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_SELECT_ITEM);
        },
        state: (!this.mConversationCtrl.getMmsCount() && this.selectNumber > 0
          && this.selectNumber <= 30 && !this.mConversationCtrl.hasRcsFileNotDownload) &&
          !this.mConversationCtrl.isSelectedContainIpCardMsgItems()
          ? ItemState.ENABLE : ItemState.DISABLE
      })
      this.toolBarList1.push({
        content: '',
        icon: this.mConversationCtrl.isMessageCheckAll ?
        $rawfile('icon/ic_select_all_filled.svg')
          : $rawfile('icon/ic_select_all.svg'),
        action: () => {
          this.mConversationCtrl.clickGroupCheckAll()
          this.changeConversationSelectedNumberAndCheckAllBool();
          // 详情-更多组件打点
          seleteParam.SELECT_STATE = 4;
          DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.CONTENT_MORE_SELECT_ITEM);
        },
        state: ItemState.ACTIVATE
      })
      this.toolBarList1.push({
        content: '',
        icon: $rawfile('icon/ic_public_more.svg'),
        action: () => {
          this.isMoreMenuShown = true;
        },
        state: (this.selectNumber === 0 ||
        this.mConversationCtrl.isSelectedContainIpCardMsgItems())
          ? ItemState.DISABLE : ItemState.ENABLE
      })
    }
  }

  getSelectNumber() {
    this.selectNumber = this.conversationDataSource.selectList.length
  }

  //选择列表数改变
  changeConversationSelectedNumberAndCheckAllBool() {
    this.initToolBarList();
  }

  imeShowWindow(info: Array<inputMethod.InputWindowInfo>) {
    if (this.keyboardHeight > 0 && this.keyboardFocused) {
      this.showMMContentPicker = false;
      this.isShowEmoji = false;
    }
  }

  public onContactChange = (e: BusinessError, info: dataShare.ChangeInfo) => {
    // 监听到联系人变化
    for (let i = 0; i < info.values.length; i++) {
      this.mConversationCtrl.refreshUserInfoWithUpdateIdStr(this.context, info.values[i]['updateIdStr'] as string,() => {
        HiLog.i(TAG, 'refresh userInfo');
      });
    }

  }

  public async clickToContacts(actionData: ActionData) {
    let str = await commonService.commonContactParam(actionData);
    (this.context as myCommon.UIAbilityContext).startAbility(str).then((data) => {
      HiLog.iw(TAG, 'jumpToContact, startAbility success');
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'jumpToContact, failed Cause: ' + JSON.stringify(error.message));
      if (error.code == 16200001) {
        this.againJumpToContact(this.context, actionData);
      }
    })
  }

  private handleWithPadStatus() {
    this.isPad = DeviceUtil.isTablet();
    this.isCellularTablet = DeviceUtil.isCellularTablet();
    this.isWifiOnlyTablet = DeviceUtil.isWifiOnlyTablet();
    this.isSubDeviceWithConnected = DeviceUtil.isSubDeviceWithConnected(this.context);
  }

  private setSendOKEventSubscriber = (data: commonEventManager.CommonEventSubscriber | null) => {
    this.sendOKEventSubscriber = data;
  }
  private setDeliveryEventData = (data: commonEventManager.CommonEventSubscriber | null) => {
    this.deliveryEventData = data;
  }

  private subscribeRcsCommonEvents = () => {
    this.mConversationCtrl.sendOKReceiveEvent(this.setSendOKEventSubscriber);
    this.mConversationCtrl.deliveryEvent(this.setDeliveryEventData);
  }
  private unSubscribeRcsCommonEvents = () => {
    this.mConversationCtrl.unsubscribeSendOKEventSubscriber(this.sendOKEventSubscriber, this.setSendOKEventSubscriber);
    this.mConversationCtrl.unSubscribeDeliveryEvent(this.deliveryEventData, this.setDeliveryEventData);
  }

  private conversationAppear() {
    let rcsFirstStatus = this.conversationRcsDataPreferences
      .getSyncByPreferences(Conversation.CONVERSATION_RCS_DATA_PREFERENCES, 0);
    this.rcsInfoStatus = rcsFirstStatus === 1 ? 1 : 0;
    connection.getDefaultNet().then((netHandle: connection.NetHandle) => {
      connection.getNetCapabilities(netHandle, (error: BusinessError, data: connection.NetCapabilities) => {
        if (data?.bearerTypes) {
          this.isWifiConnected = '' + data.bearerTypes;
        }
      });
    });
    this.imageCompleteEventOn();
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_ABOUT_TO_APPEAR,
      TraceConstant.TRACE_CONVERSATION_ABOUT_TO_APPEAR_ID);
    this.mConversationCtrl.setMMsFlag = false;
    this.isSelectDelete = false;
    let isNewMsg: boolean = (this.pageInfos.getParamByIndex(this.pageInfos.size() - 1) as LooseObject)?.isNewMsg;
    isNewMsg = isNewMsg == null ? false : isNewMsg;
    let isFromInfoMsgView: boolean =
      (this.pageInfos.getParamByIndex(this.pageInfos.size() - 1) as LooseObject)?.isFromInfoMsgView
    this.isFromInfoMsg = isFromInfoMsgView == null ? false : isFromInfoMsgView
    this.subscribeRcsCommonEvents();
    this.mConversationCtrl.onInit(this.context, this.pageInfos); // 加载详情
    this.mConversationCtrl.resetMmsSource()
  }

    private setAppearData() {
      let top = this.fullScreenPadding ? (this.fullScreenPadding.top as number) : 0;
      this.tabPickerMaxHeight = this.windowHeight - TITLE_HEIGHT - top - AVOIDANCE_HEIGHT;
      this.mConversationCtrl.rawContactId =
        (this.pageInfos.getParamByIndex(this.pageInfos.size() - 1) as LooseObject).rawContactId;
      let receiveEvent: emitter.InnerEvent = { eventId: EmitterConstant.EVENT_CHANGE_RCS_ACCEPT_FAIL };
      emitter.on(receiveEvent, (valueObj: emitter.EventData) => {
        this.acceptFailureDialogController.open();
      })
      this.isOpenRCS = SharedPreferencesUtils.getFromPreferences('isUIOpenRcs', '') as boolean;
    }

    private emitterInit() {
        emitter.on(simCardService.SIM_STATE_CHANGE_EVENT, () => {
            HiLog.iw(TAG, 'emitterInit simStateChangeEvent start! canSendMessage:' +
            this.mConversationCtrl.canSendMessage + ', haveSimCard:' + this.haveSimCard);
            this.refreshSimCardStatus();
        });
        emitter.on(simCardService.SLOTID_CHANGE_EVENT, () => {
            this.slotId = MmsPreferences.getInstance().getSelectedSlotId();
            console.log('receive SLOTID_CHANGE_EVENT, this.slotId: ' + this.slotId);
        });
        emitter.on(this.receiveCtrl.receiveAddContactEVENT, () => {
            this.textareaFocusable = true;
            let res = focusControl.requestFocus(Constant.MMS_INPUT_TEXTAREA_Id);
            HiLog.i(TAG, `requestFocus MMS_INPUT_TEXTAREA_Id res : ` + res);
        });
        this.emitterInitNext();
        this.emitterInitTwo();
        emitter.on(EmitterConstant.EVENT_CHECK_BOX_CHANGED, this.onCheckBoxChangedCallBack);
    }

  private refreshSimCardStatus() {
    this.cardImage = MmsPreferences.getInstance().haveMultiSimCardReady();
    this.mConversationCtrl.getHasSimCard().then(() => {
      this.haveTwoCards = this.mConversationCtrl.haveTwoCards;
      HiLog.i(TAG, `getHasSimCard : ` + this.haveTwoCards);
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, error.message);
    });
    this.haveSimCard = MmsPreferences.getInstance().haveSimCardReady();
    DataService.getDefaultCellularDataSlotId().then(res => {
      if (this.defCellularSlotId !== res) {
        this.defCellularSlotId = res;
        this.changeRcsFlag = false;
        this.handleSwitchCard();
      }
    });
  }

  private emitterInitNext() {
    let innerEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EVENT_RECEIVE_IN_CONTACT,
    };
    emitter.on(innerEvent, (data) => {
      HiLog.i(TAG, `emitter.on EVENT_RECEIVE_IN_CONTACT In, haveTwoCards: ${this.mConversationCtrl.haveTwoCards}`);
      if (this.mConversationCtrl.haveTwoCards) {
        this.isSlotIdChange = false;
        HiLog.i(TAG, `emitterInitNext: isOnlineRcs: ${this.isOnlineRcs}, current simSlotId: ${
        this.simSlotId}, defCellularSlotId: ${this.defCellularSlotId}`);
        if (this.isOnlineRcs && this.simSlotId === this.defCellularSlotId) {//增强信息已登录且当前选择的SIM卡为默认移动数据卡
          HiLog.i(TAG, `emitterInitNext: handle rcs`);
          if (!this.changeRcsFlag) {
            this.mConversationCtrl.changeIsRcsMms(true, this.isSlotIdChange);
          } else {
            this.mConversationCtrl.changeIsRcsMms(false, this.isSlotIdChange);
          }
          this.changeMenuItemsRcsValue();
        } else {
          HiLog.i(TAG, `emitterInitNext: rcs is not online, or simSlotId is not default cellular card`);
          this.mConversationCtrl.changeIsRcsMms(false, this.isSlotIdChange);
          this.isShowMoreMenu = false;
          this.deleteRcsButton();
        }
      }
    });
  }

  private deleteRcsButton() {
    // 防止删除Rcs按钮时删除“加入黑名单”按钮，当前无Rcs时第三个按钮为“加入黑名单”
    if (this.menuItems[4]?.id !== 4) {
      this.isShowRcsButton(false)
    }
  }

  private changeJumpContactButton() {
    for (let i = 0; i < this.menuItems.length; i++) {
      if (this.menuItems[i].id === 5 || this.menuItems[i].id === 6) {
        if (this.mConversationCtrl.contactsNum > 1 ||
          this.mConversationCtrl.strContactsName !== '') {
          this.menuItems[i].visible = false;
        } else if (this.menuItems[i].id === 5 || this.menuItems[i].id === 6) {
          this.menuItems[i].visible = true;
        }
      }
      if (DeviceUtil.isPC() && this.menuItems[i].id === common.WEBVIEW_MENU_ID.SERVICE_KIND) {
        if (this.mConversationCtrl.formatStrContactsName != '' && this.mConversationCtrl.contactsNum === 1) {
          this.menuItems[i].visible = true;
        } else {
          this.menuItems[i].visible = false;
        }
        HiLog.i(TAG, 'changeJumpContactButton menuItems visible： ' + this.menuItems[i].visible);
      }
    }
  }

    private emitterInitTwo() {
        let innerEvent: emitter.InnerEvent = {
            eventId: EmitterConstant.EVENT_CHANGE_ALL_ACTIVE,
        }

        emitter.on(innerEvent, (data) => {
            this.isAllCardCanSend = this.mConversationCtrl.isAllCardCanSend;
        })
        HiLog.i(TAG, 'emitterInitTwo start');
        emitter.on(this.mConversationCtrl.isSelectEVENT, (evenData) => {
          if (evenData == null || evenData.data == null) {
            HiLog.e(TAG, 'emitterInitTwo isSelectEVENT on evenData or evenData.data is null');
            return;
          }
          let isSelect: boolean = evenData.data.isSelect;
          HiLog.i(TAG, 'emitterInitTwo isSelectEVENT on isSelect : ' + isSelect);
          this.updateBackIcon(isSelect);
          if(this.mConversationCtrl.isSelectStatus){
            this.closeKeyboard();
            this.isShowEmoji = false;
          };
        });
    }

    private updateBackIcon(isSelect: boolean) {
      this.isPhone = this.curBp === common.STR.DEVICE_MOBILE_PHONE ||
        this.isFromInfoMsg === true;
      HiLog.i(TAG, 'updateBackIcon isSelectEVENT on isSelect : ' + isSelect + ' , this.curBp: ' + this.curBp +
        ' , isFromInfoMsg :' + this.isFromInfoMsg);
      if (isSelect) {
        this.backIcon = new SymbolGlyphModifier($r('sys.symbol.xmark'))
        this.backText = getContext(this).resourceManager.getStringSync($r('app.string.disable').id);
      } else {
        this.backIcon = this.isPhone ? new SymbolGlyphModifier($r('sys.symbol.chevron_backward')) : null;
        this.backText = getContext(this).resourceManager.getStringSync($r('app.string.guide_action_text_previous').id);
      }
    }

    private removeEmitter(curBp: string) {
      emitter.off(EmitterConstant.EVENT_IN_BLOCKED_LIST);
      emitter.off(EmitterConstant.EVENT_CHANGE_BUBBLE_MODE);
      emitter.off(EmitterConstant.EVENT_SIM_STATE_CHANGE);
      emitter.off(EmitterConstant.EVENT_SLOTID_CHANGE);
      emitter.off(EmitterConstant.EVENT_CHANGE_RCS_ACCEPT_FAIL);
      emitter.off(EmitterConstant.EVENT_RECEIVE_ADD_CONTACT);
      emitter.off(EmitterConstant.EVENT_RECEIVE_IN_CONTACT);
      emitter.off(EmitterConstant.EVENT_CHANGE_MESSAGE_STATUS);
      if (curBp === common.STR.DEVICE_MOBILE_PHONE) {
        emitter.off(EmitterConstant.EVENT_CHANGE_NEW_INPUT_STATUS);
      }
      emitter.off(EmitterConstant.EVENT_CONVERSION_IS_SELECT);
      emitter.off(EmitterConstant.EVENT_CHECK_BOX_CHANGED, this.onCheckBoxChangedCallBack);
    }

    private onPortrait(mediaQueryResult: mediaquery.MediaQueryResult) {
      HiLog.d(TAG,
        'mediaQueryResult.matches:' + mediaQueryResult.matches + 'windowStatusType:' + DeviceUtil.isSplitScreen())
    }

  private updateIsPCEmojiVisible() {
    this.isPCEmojiVisible = false
  }

  subscribeConfigurationUpdate() {
    let systemLanguage: string | undefined = this.context.config.language;
    let applicationContext = this.context.getApplicationContext();
    let environmentCallback: EnvironmentCallback = {
      onConfigurationUpdated(newConfig: Configuration) {
        HiLog.i(TAG,
          `onConfigurationUpdated systemLanguage is ${systemLanguage}, newConfig: ${JSON.stringify(newConfig)}`);
        ConversationController.getInstance().onlyRefreshTime();
        GlobalContext.getContext().setObject('needToUpdate', true);
      },
      onMemoryLevel(level) {
        HiLog.i(TAG, `onMemoryLevel level: ${level}`);
      },
    }
    this.callbackId = applicationContext.on('environment', environmentCallback);
  }

    aboutToDisappear() {
        HiLog.i(TAG, 'aboutToDisappear')
        this.mScreenRotationListener.off('change', this.onPortrait.bind(this));
        this.inputMethodSetting.off('imeShow', this.emitterKeyboard);
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_ABOUT_TO_DISAPPEAR,
          TraceConstant.TRACE_CONVERSATION_ABOUT_TO_DISAPPEAR_ID);
        /* 不要设置conversationController中的selectContactsMap为[], 防止获取不到联系人而走新建草稿流程，表现为草稿丢失 */
        this.mConversationCtrl.clearSelectContacts(true); // only clear threadId = 0 when aboutToDisappear.
        AppStorage.setOrCreate('stopAudio', { duration: '', type: -1, path: '', name: '' } as Mms);
        this.audioPlayerService.stopAudio();
        this.mConversationCtrl.removeAirPlaneMode();
      let pathNames = this.pageInfos.getAllPathName();
      HiLog.i(TAG, 'aboutToDisappear pathNames length' + pathNames.length);
      if (pathNames.length === 0) {
        this.mConversationCtrl.removeSatelliteMode();
      } else if (pathNames.length > 0 && pathNames[pathNames.length-1] !== 'Conversation' &&
        pathNames[pathNames.length-1] !== 'CreateNewConversation') {
        // 已经在会话详情页面，再通过联系拉起短信，会走先走destinationShow再走aboutToDisappear方法，导致注册的天通卫星链接监听被remove
        // remove前判断如果当前还是在Conversation或者CreateNewConversation页面不移除监听
        this.mConversationCtrl.removeSatelliteMode();
      }
        this.mConversationCtrl.resetSelectData();
      inputMethod.getSetting().off('imeShow', this.imeShowWindow);
      this.mConversationCtrl.unregisterDataChangeObserver(this.onContactChange, this.context);
      hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_ABOUT_TO_DISAPPEAR,
          TraceConstant.TRACE_CONVERSATION_ABOUT_TO_DISAPPEAR_ID);
        this.uiObserver.off('routerPageUpdate', this.listener);
      AppStorage.setOrCreate('currentSessionId', undefined);
      this.unSubscribeRcsCommonEvents()
      this.mConversationCtrl.disAppearUnsubscribe();
      DateRefreshUtil.getInstance().unsubscribeTimeRefresh(this.refreshDateKey);
    }

    handleMenuList() {
        if (this.menuItems.length > 5) {
            if (this.menuItems[1].value !== $r('app.string.switch_to_SMS_MMS') && this.menuItems[1].value !== $r('app.string.handover_to_enhanced_message')) {
              HiLog.i(TAG, 'handleMenuList isShowRcsButton true' );
              this.isShowRcsButton(true)
            }
        } else {
          HiLog.i(TAG, 'handleMenuList isShowRcsButton false' );
          this.isShowRcsButton(false)
        }
    }

    changeMenuItemsRcsValue() {
        AppStorage.setOrCreate('rcsMmsStatus', this.mConversationCtrl.isRcsMms);
        GlobalContext.getContext().setObject('fileTotalSize', 0);
        AppStorage.setOrCreate('setTotalSizeFlag', false);
        this.updateRcsMmsStatus();
        if (this.mConversationCtrl.isRcsMms) {
            this.menuItemList[0].value = $r('app.string.switch_to_SMS_MMS');
            this.handleMenuList();
            this.menuItems[1].value = $r('app.string.switch_to_SMS_MMS');
            this.tabUtil.animationIterations = 0;
            if (this.showMMContentPicker) {
              animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37) }, () => {
                this.mOffsetY = this.splitInfoModel.isSmall ? MIN_MM_PICKER_HEIGHT : RCS_MM_PICKER_HEIGHT;
              });
            }
            this.textareaFocusable = true;
        } else {
            this.calculateTextInputCount();
            this.menuItemList[0].value = $r('app.string.handover_to_enhanced_message');
            this.handleMenuList();
            this.menuItems[1].value = $r('app.string.handover_to_enhanced_message');
            contentMoreParams.SELECT_STATE = 6;
            if (this.showMMContentPicker) {
              animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37) }, () => {
                this.mOffsetY = this.mmsPickerHeight + this.attachmentBottomHeight;
              });
            }
            DotUtil.getInstance().reportEvent(contentMoreParams, dotCommon.eventName.CONTENT_MORE_EVENT);
        }
    }

    changeMenuItemsValue() {
      for (let i = 0; i < this.menuItems.length; i++) {
        if (this.menuItems[i].id === 2) {
          if ( this.mConversationCtrl.contactsNum > 1) {
            this.menuItems[i].value = $r('app.string.recipients');
            contentMoreParams.AVATAR_NUMBER = 2;
          } else {
            this.menuItems[i].value = $r('app.string.msg_call');
            contentMoreParams.AVATAR_NUMBER = 1;
          }
        }
      }
    }

    destinationDisappear() {
    }

    destinationShow() {
        if (this.isVDE && this.isScrolling) {
          animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 2000 }, () => {
            this.isScrolling = false;
          })
          this.isScrollingHide = false;
        }
        if (this.isDraft) {
          this.isInputDot = true;
        }
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_DESTINATION_SHOW,TraceConstant.TRACE_CONVERSATION_DESTINATION_SHOW_ID);
        HiLog.i(TAG, 'destinationShow');
        this.mConversationCtrl.isPageHide = false;
        this.textDirection = Configuration.getLocale().dir;
        this.checkFocusable();
        this.destinationShowMConversationCtrl();
        if (!this.mConversationCtrl.isSelectStatus && !this.mConversationCtrl.isNewMsg) {
            this.mConversationCtrl.checkIfNeedRefresh(this.context);
        }
        WantUtil.getWant(this.context, this.pageInfos);
        this.mConversationCtrl.getAirPlaneMode();
        if ( !this.mConversationCtrl.isNewMsg ) {
            HiLog.e(TAG, 'isNewMsg: ' + this.mConversationCtrl.isNewMsg);
            this.mConversationCtrl.publishData(true, this.mConversationCtrl.threadId);
            GlobalContext.getContext().setObject('currentConversationContactsNum', this.mConversationCtrl.strContactsNumber);
        }
        if (GlobalContext.getContext().getObject('notUpdateData') !== undefined && !GlobalContext.getContext().getObject('notUpdateData')) {
            GlobalContext.getContext().setObject('notUpdateData', false)
        }
        if (GlobalContext.getContext().getObject('transmitFlag')) {
            this.mConversationCtrl.initTransmit(this.context);
            this.mmAttachmentAreaController.refreshDisplay();
        }
        this.mConversationCtrl.listHeight = this.highMessageList;
        if(this.receiveCtrl && this.mConversationCtrl.isNewMsg) {
            this.receiveCtrl.refreshContactDataOnPageShow(this.context);
        }
        HiLog.w(TAG, 'conversation onShow markAllAsRead');
        this.mConversationCtrl.markAllAsReadByItem(this.context);
        this.checkTabPermission();
        hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_DESTINATION_SHOW,TraceConstant.TRACE_CONVERSATION_DESTINATION_SHOW_ID);
        if (this.currentScreenWidth === common.STR.EMPTY_STR){
            this.messageBubbleWidthChange(false)
        }
        this.changeJumpContactButton();
        this.isDraft = this.mConversationCtrl.isDraft;
        if (this.isFromInfoMsg == true) { AppStorage.set('isSelectInfoMsg', true) }
        let strContactsNumber: string =
          (this.pageInfos.getParamByIndex(this.pageInfos.size() - 1) as LooseObject)?.strContactsNumber;
        AppStorage.set('selectPhoneNumber', strContactsNumber)

        if (GlobalContext.getContext().getObject('isFromNewCreatMessage')) {
            //RCS开启情况下，点击切换成短彩信后changeRcsFlag为true，其他均为false。同步新建页面的设置
            this.changeRcsFlag = AppStorage.Get('changeRcsFlagFromNewCreatView') ?? false
            this.mConversationCtrl.fromNewConversationSend(this.context);
            GlobalContext.getContext().setObject('fileTotalSize', 0);
            AppStorage.setOrCreate('setTotalSizeFlag', false);
        }
        if (this.isNeedHideSuggestion && this.chatbotFloatMenuData?.suggestions) {
          this.chatbotFloatMenuData.suggestions = [];
          AppStorage.setOrCreate('isNeedHideSuggestions', false);
        }
        this.onDestinationShow = !this.onDestinationShow;
        setTimeout(() => {
          this.refreshSimCardIcon();
        }, 30);
    }

    private sendChatbotMessage(): boolean {
      HiLog.iw(TAG, "sendChatbotMessage: isSendHello:" + this.isSendHello);
      if (this.isOnlineRcs && this.isChatbotConversation && this.isSendHello) {
        let displayText = ResourceUtils.getStringSync($r('app.string.chatbot_send_greet'));
        this.mConversationCtrl.sendChatbot(this.context, this.mConversationCtrl.strContactsNumber, displayText,
          '', this.isOnlineRcs);
        if (this.chatbotFloatMenuData?.suggestions) {
          this.chatbotFloatMenuData.suggestions = [];
        }
        this.isSendHello = false;
        return true;
      }
      return false;
    }

  private subscribeChatbotEvent = () => {
    if (this.isChatbotConversation) {
      this.mConversationCtrl.subscribeChatbotReceivedSuggestionsEvent((serviceId: string, botMessage: BotMessage) => {
        if (this.chatbotServiceId === serviceId) {
          this.chatbotFloatMenuData = botMessage;
        }
      });
      this.mConversationCtrl.subscribeChatbotCardDownloadOriginFile((msgId: string, serviceId: string,
        newMmsSourceList: Mms[]) => {
        if (this.chatbotServiceId !== serviceId) {
          return;
        }
        let mmsListItem: mmsListType | undefined = this.mConversationCtrl.findMmsListItemByMsgIdOfRcs(msgId);
        if (!mmsListItem) {
          return;
        }
        let tempList = (mmsListItem.mmsSource && mmsListItem.mmsSource.length > 0) ? [...mmsListItem.mmsSource] : [];
        tempList.push(...newMmsSourceList);
        mmsListItem.mmsSource = tempList;
        this.mConversationCtrl.resetItem(mmsListItem);
      });
    }
  }
    destinationShowMConversationCtrl() {
      // destinationShow 操作 MConversationCtrl 方法
      this.mConversationCtrl.scrollToSlideIndex();
      this.mConversationCtrl.setIsShow();
      this.mConversationCtrl.subscribeDetail(this.context, this.isChatbotConversation);
      this.subscribeChatbotEvent();
    }

    checkFocusable() {
        if (AppStorage.get('invokeCamera')) {
          this.showMMContentPicker = true;
          AppStorage.setOrCreate('invokeCamera', false);
        } else if (AppStorage.get('isFromMenu')) {
            this.textareaFocusable = true;
            AppStorage.setOrCreate('isFromMenu', false);
        }
    }

    async stopRecord(height: number) {
        this.isTouchDown = false;
        this.isAnimation = false;
        this.isSendingAudio = false;
        this.rcsAudioPromptsController.close();
        this.showMMContentPicker = false;
        this.closeKeyboard();
        focusControl.requestFocus(Constant.MMS_INPUT_TEXTAREA_Id);
        this.textareaFocusable = true;

        let authResults: number = await this.recorderController.initPermission('ohos.permission.MICROPHONE');
        let recorderPermission: boolean = authResults === 0;
        if (!recorderPermission) {
            this.recorderRcsPermissionDialogCtrl.open();
            return;
        }
        if (height > -133) {
            this.mConversationCtrl.sendAudio(this.context);
            if (this.chatbotFloatMenuData?.suggestions) {
              this.chatbotFloatMenuData.suggestions = [];
            }
        }
    }

    onAudioTouch = (event: TouchEvent) => {
        event.stopPropagation();
        this.audioPlayerService.stopAudio()
        if (event === undefined) {
            HiLog.e(TAG, 'event is undefined in onTouch event');
            return;
        }
        if (event.type === TouchType.Down && !this.isTouchDown) {
            VibrationUtils.onceVibration(common.VIBRATIONEFFECT.DRAG);
            AudioPlayerService.setAudioFilePlayState(undefined, 'stopped');
            this.isTouchDown = true;
            this.isSendingAudio = true;
            this.recorderController.checkCallState(() => {
                this.isUpperLimit = this.recorderController.mmAreaController
                    .isAttachmentUpperLimit();
                if (!this.isUpperLimit) {
                    HiLog.i(TAG, 'size is exceed!');
                    this.rcsAudioPromptsController.open();
                    this.recordDuration = 0
                    this.textareaFocusable = false;
                }
            })
        } else if ((event.type === TouchType.Up || event.type === TouchType.Cancel) &&
        this.isTouchDown) {
            HiLog.i(TAG, 'touchType up or cancel');
            if (!this.isUpperLimit) {
                this.stopRecord(event.touches[0].y);
            } else {
                this.isTouchDown = false;
                this.isUpperLimit = false;
                this.isSendingAudio = false;
                this.rcsIsResumeSend = false;
            }
            this.rcsAudioPromptsController.close();
          this.isSlidUp = true;
        } else if (event.type === TouchType.Move && this.isTouchDown) {
            this.isSendingAudio = true;
            if (event.touches[0].y < -100) {
                this.rcsIsResumeSend = true;
              if (this.isSlidUp) {
                sendRcsRecordParams.SLID_DIRECTION = 1;
              }
              this.isSlidUp = false;
            } else {
                this.rcsIsResumeSend = false;
              if (!this.isSlidUp) {
                sendRcsRecordParams.SLID_DIRECTION = 2;
              }
              this.isSlidUp = true;
            }
        }
    }

    destinationPageHide() {
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_DESTINATION_HIDE,TraceConstant.TRACE_CONVERSATION_DESTINATION_HIDE_ID);
        this.mConversationCtrl.onHide();
        this.audioPlayerService.stopAudio()
        AudioPlayerService.setAudioFilePlayState(undefined, 'stopped');
        if (this.isFromInfoMsg == true) { AppStorage.set('isSelectInfoMsg', false) }
        this.mConversationCtrl.publishData(false, common.int.NUMBER_ZERO);
        GlobalContext.getContext().setObject('currentConversationContactsNum', '');
        if (!GlobalContext.getContext().getObject('notUpdateData')) {
            GlobalContext.getContext().setObject('notUpdateData', false)
        }
        hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_DESTINATION_HIDE,TraceConstant.TRACE_CONVERSATION_DESTINATION_HIDE_ID);
        if (this.oldKeyboardHeight > 0) {
          this.mOffsetY = 0;
        }
    }

    destinationBackPress(): boolean {
        HiLog.iw(TAG, 'destinationBackPress start!')
        HiLog.iw(TAG, 'text input length: ' + this.mConversationCtrl?.textValue?.length)
        AppStorage.setOrCreate('invokeCamera', false);
        AppStorage.setOrCreate('selectPhoneNumber', '')
        AudioPlayerService.setAudioFilePlayState(undefined, 'stopped');
        if (!this.mConversationCtrl.isSelectStatus && !this.showMMContentPicker) {
          this.mConversationCtrl.chatbotPageIcon = '';
        }
        if (this.showMMContentPicker && this.currentIndex === 0) {
            HiLog.iw(TAG, 'destinationBackPress showMMContentPicker and currentIndex zero!')
            animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37) }, () => {
                this.showMMContentPicker = false;
                this.mOffsetY = 0;
            })
            this.currentIndex = 1;
            this.resetTitle();
            return true;
        } else if (this.isAudioTitle || this.isPictureTitle) {
            HiLog.iw(TAG, 'destinationBackPress audio or picture title show!')
            this.resetTitle();
            return true;
        } else if (this.showMMContentPicker && this.currentIndex !== 0) {
            HiLog.iw(TAG, 'destinationBackPress showMMContentPicker and currentIndex not zero!')
            animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37) }, () => {
              this.showMMContentPicker = false;
              this.mOffsetY = 0;
            })
            this.resetTitle();
            return true;
        } else if (this.isShowEmoji) {
            HiLog.iw(TAG, 'destinationBackPress isShowEmoji')
            animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37) }, () => {
              this.isShowEmoji = false;
              inputMethod.getController().hideTextInput();
              this.mOffsetY = 0;
              this.getUIContext().getFocusController().clearFocus();
            })
            return true;
        } else if (this.curNavMode === common.int.NAVIGATION_MODE_SPLIT && !DeviceUtil.isPC()) {
          HiLog.iw(TAG, 'destinationBackPress curNavMode: ' + this.curNavMode);
          GlobalContext.getContext().setObject(commonData.STR.BACK_FROM_CONVERSATION, true);
          this.mConversationCtrl.setDraftModel(() => {
            DraftUtils.getInstance().saveDraft(this.context, undefined, true)
          }, false);
          return this.conListCtrl.onBackPress(this.context);
        } else {
            HiLog.iw(TAG, 'destinationBackPress else!')
            this.isSelectDelete = false;
            return this.mConversationCtrl.onBackPress(this.context, this.isChatbotConversation, false);
        }
    }

    changeNeedExpandSafeArea() {
        if (this.messageListOnAreaChangeHeight == undefined) {
            HiLog.e(TAG, 'messageListOnAreaChangeHeight is undefined');
            this.messageListOnAreaChangeHeight = 0;
        }
        if (this.messageListPositionY == undefined) {
            HiLog.e(TAG, 'messageListPositionY is undefined');
            this.messageListPositionY = 0;
        }
        if (this.bottomSendBarPositionY == undefined) {
            HiLog.e(TAG, 'bottomSendBarPositionY is undefined');
            this.bottomSendBarPositionY = 0;
        }
        let messageListHeightInt: number = this.messageListOnAreaChangeHeight?.valueOf() as number;
        let messageListPositionYInt: number = this.messageListPositionY?.valueOf() as number;
        let bottomSendBarPositionYInt: number = this.bottomSendBarPositionY?.valueOf() as number;
        this.highMessageList = bottomSendBarPositionYInt - messageListPositionYInt
        if (bottomSendBarPositionYInt <= 0) {
            HiLog.e(TAG, 'changeNeedExpandSafeArea bottomSendBarPositionYInt is err');
            return;
        }

        if (bottomSendBarPositionYInt > 700 || (DeviceUtil.isSplitScreen() && this.mConversationCtrl.isSelectStatus)) {
            this.mConversationCtrl.updateListHeightInsensitive(this.highMessageList, this.listLightTimerId);
            HiLog.i(TAG,'updateListHeightInsensitive,highMessageList : '+ this.highMessageList);
        } else {
          this.mConversationCtrl.adjustLowListHeight(this.currentSendBarGlobalY,
            this.isVDE ? 56 : messageListPositionYInt, this.listLightTimerId);
            HiLog.i(TAG,'adjustLowListHeight , currentSendBarGlobalY : '+this.currentSendBarGlobalY+', messageListPositionYInt : '+messageListPositionYInt);
        }
        if (this.mConversationCtrl.isSelectStatus) {
            this.mConversationCtrl.updateListHeightInsensitive(this.highMessageList, this.listLightTimerId);
            HiLog.i(TAG,'updateListHeightInsensitive,isSelectStatus = true, highMessageList : '+ this.highMessageList);
        }
    }

    messageAreaFocus() {
        let changeFlag:boolean | undefined = AppStorage.get('messageAreaFocusFlag');
        AppStorage.setOrCreate('messageAreaFocusFlag', !changeFlag);
    }

    checkTabPermission() {
      if (this.showMMContentPicker && this.currentIndex === common.TAB_TYPE.AUDIO) {
          this.recorderPermission = this.recorderController.checkAccessToken('ohos.permission.MICROPHONE')
      }
    }

    conversationNeedChanged() {
        HiLog.i(TAG, 'conversationNeedChanged');
        if (this.isConversationNeedChange) {
            if (this.mConversationCtrl.mAttachAreaCtrl.mmDisplaySource.length === 0) {
                this.mConversationCtrl.isChangeInputPlaceholder = false;
            } else {
                this.changeNeedExpandSafeArea();
                this.mConversationCtrl.isChangeInputPlaceholder = true;
                this.resetTitle();
            }
            this.mConversationCtrl.refreshSendMessageStatus();
            this.measureTextAreaSize();
            AppStorage.setOrCreate('isConversationNeedChange', false);
        }
        this.refreshSizeDesc();
    }

  refreshSizeDesc() {
    let fileSize: number = (GlobalContext.getContext()
      .getObject('fileTotalSize') as number) / commonData.int.BYTE_CONVERSION_UNIT;
    let maxSize: number = OperatorConfigUtil.getInstance()
      .getCustMMSSize(commonData.int.MMS_FILE_MAX_SIZE) / commonData.int.BYTE_CONVERSION_UNIT;
    if (fileSize > maxSize) {
      fileSize = maxSize;
    }
    fileSize = this.updateFileSizeOfVcard(fileSize)
    if (this.mmAttachmentAreaController.mmDisplaySource.length > 0) {
      let countryId = i18n.System.getSystemRegion();
      let numberFormat = new intl.NumberFormat(countryId, { style: 'unit', unit: 'kilobyte', unitDisplay: 'short' });
      let masxSiseStr = numberFormat.format(maxSize);
      this.attachmentSizeDesc = $r('app.string.attachment_current_size_new', LocationUtil.numFormat(Math.floor(fileSize)), masxSiseStr);
      this.mmAttachmentAreaController.mmDisplaySource[0].size = GlobalContext.getContext()
        .getObject('fileTotalSize') as string;
      if (!this.mConversationCtrl.isRcsMms) {
        this.isExceedMaxFileSize(maxSize)
      }
    } else {
      this.isShowMmsAreaDisplay = false;
      this.calculateTextInputCount();
    }
  }

  isExceedMaxFileSize(maxSize: number) {
    let fileSize: number = (GlobalContext.getContext()
      .getObject('fileTotalSize') as number) / commonData.int.BYTE_CONVERSION_UNIT;
    for (let i = 0; i < this.mmAttachmentAreaController.mmDisplaySource.length; i++) {
      if (this.mmAttachmentAreaController.mmDisplaySource[i].name.startsWith('OriginImage_RCS')) {
        if (fileSize > maxSize) {
          let countryId = i18n.System.getSystemRegion();
          let numberFormat =
            new intl.NumberFormat(countryId, { style: 'unit', unit: 'kilobyte', unitDisplay: 'short' });
          let masxSiseStr = numberFormat.format(maxSize);
          promptAction.showToast({
            message: $r('app.string.attachment_failed', masxSiseStr),
            duration: 2000
          });
          return;
        }
      }
    }
  }


  // 如果 vcard文件的大小小于 1 kb，默认设置大小为 1kb
  updateFileSizeOfVcard(fileSize: number) {
    const mmsVcard = this.mmAttachmentAreaController.mmDisplaySource.find((item: Mms) => item.type === commonData.MM_ATTACHMENT_TYPE.VCARD)
    if (mmsVcard && fileSize < 1) {
      fileSize = 1
    }
    return fileSize
  }

  calculateTextInputCount() {
    this.isInput = this.mConversationCtrl.textValue.length > 0
    let inputText = this.mConversationCtrl.getSendText(this.context, this.mConversationCtrl.textValue, false);
    if (this.isInput && !this.mConversationCtrl.isRcsMms) {
      //如果框架splitMessage没问题使用框架的方法分割短信，如果有问题就自己统计字数
      sms.splitMessage(inputText, (err: BusinessError, data: string[]) => {
        if (err != undefined && err.code !== 0) {
          this.calculateTextInputStatisticalCount(false, inputText);
          return;
        }
        let messageCount = data.length
        HiLog.w(TAG, 'sms splitMessage start');
        this.calculateTextInputStatisticalCount(true, inputText, messageCount, data[messageCount - 1]);
      });
    } else {
      HiLog.i(TAG, `calculateTextInputCount，this.isShowMmsAreaDisplay:${this.isShowMmsAreaDisplay}`);
      if (this.mConversationCtrl?.textValue.length == 0 && this.isShowMmsAreaDisplay) {
        HiLog.i(TAG, `measureTextAreaSize.length is 0, need refresh size Desc`)
        this.refreshSizeDesc();
      }
    }
  }

  async calculateTextInputStatisticalCount(isFramework: boolean, oldInputString: string, messageCount?: number,
        lastMessage?: string,) {
        let isTextAsMms: boolean = await this.calculateTextInputStatisticalCountFirst(oldInputString, messageCount);
        if (isTextAsMms) {
          HiLog.i(TAG, 'calculisDisableNotificationateTextInputStatisticalCountFirst');
          return;
        }
        if (this.mmAttachmentAreaController.mmDisplaySource.length > 0) {
          return;
        }
        let containChinese: boolean = this.mConversationCtrl.hasChinese.test(oldInputString)
        let containEmoji: boolean = this.mConversationCtrl.isHasEmoji(oldInputString)
        let chineseStrFirstCount: number = 70
        let englishStrFrisrCount: number = 160
        let chineseStrCount: number = 67
        let englishStrCount: number = 153
        let isChinese: boolean = containChinese || containEmoji
        let statisticCount: number = isChinese ? chineseStrFirstCount : englishStrFrisrCount
        if (isFramework && messageCount !== undefined && lastMessage !== undefined) {
            if (messageCount > 1) {
                statisticCount = isChinese ? chineseStrCount : englishStrCount
            }
        } else {
            if (oldInputString.length > statisticCount) {
                statisticCount = isChinese ? chineseStrCount : englishStrCount
            }
            messageCount = Math.ceil(oldInputString.length / statisticCount)
        }
      let smsToMmsThreshold = OperatorConfigUtil.getInstance().getCustomSmsToMmsThreshold(
        commonData.int.SMS_TO_MMS_THRESHOLD_DEFAULT);
      if (smsToMmsThreshold === commonData.int.NOT_SUPPORT_SMS_TO_MMS) {
        if (messageCount > 10) {
          this.mConversationCtrl.showToast($r('app.string.text_input_limit'));
          let inputMaxLength = statisticCount * 10;
          if (oldInputString.length > this.mConversationCtrl.textValue.length) {
            inputMaxLength = inputMaxLength - (oldInputString.length - this.mConversationCtrl.textValue.length)
          }
          this.mConversationCtrl.textValue = this.mConversationCtrl.textValue.slice(0, inputMaxLength)
          this.attachmentSizeDesc = LocationUtil.numFormat(0) + '/' + LocationUtil.numFormat(10)
          return;
        }
      }
      let currentInputLength = 0
      if (isFramework && lastMessage !== undefined) {
        currentInputLength = statisticCount - lastMessage.length
      } else {
        currentInputLength = statisticCount * messageCount - oldInputString.length
      }
    this.attachmentSizeDesc = `${LocationUtil.numFormat(currentInputLength)}/${LocationUtil.numFormat(messageCount)}`
    HiLog.w(TAG, 'calculateTextInputStatisticalCount attachmentSizeDesc = ' + this.attachmentSizeDesc);
    AppStorage.setOrCreate('currentMessagePage', messageCount);

  }

    async calculateTextInputStatisticalCountFirst(inputString: string, messageCount?: number): Promise<boolean> {
      let isTextAsMms: boolean = await MessageUtil.isMmsText(
        MessageUtil.replaceForLossy7Bit(this.slotId, inputString, 0, inputString.length));
      if (messageCount) {
        if (isTextAsMms || this.mmAttachmentAreaController.mmDisplaySource.length === common.int.MESSAGE_CODE_ONE) {
          let encoder: util.TextEncoder = new util.TextEncoder('utf-8');
          let bytes: Uint8Array = encoder.encodeInto(inputString);
          let messageSize: number = Math.ceil(bytes.length / common.int.BYTE_CONVERSION_UNIT);
          let allSize: number = messageSize;
          for (let index = 0; index < this.mmAttachmentAreaController.mmDisplaySource.length; index++) {
            let element = this.mmAttachmentAreaController.mmDisplaySource[index];
            if (element.size !== undefined) {
              allSize += (Number(element.size) / common.int.BYTE_CONVERSION_UNIT);
            }
          }
          let maxSize: number = OperatorConfigUtil.getInstance()
            .getCustMMSSize(commonData.int.MMS_FILE_MAX_SIZE) / commonData.int.BYTE_CONVERSION_UNIT;
          let countryId = i18n.System.getSystemRegion();
          let numberFormat = new intl.NumberFormat(countryId, { style: 'unit', unit: 'kilobyte', unitDisplay: 'short' });
          let maxSizeStr: string = numberFormat.format(maxSize);
          this.attachmentSizeDesc = $r('app.string.attachment_current_size_new', LocationUtil.numFormat(Math.floor(allSize)), maxSizeStr);
          return true;
        }
      }
      return false;
    }

    updateMMSPickerHeight() {
      const rowsTemplateValue = this.mmAttachmentAreaController.tabsRowsTemplateValue(this.displayOrientation, this.curBp);
      this.mmsPickerHeight = rowsTemplateValue === '1fr 1fr' ? MMS_MM_PICKER_HEIGHT : MIN_MM_PICKER_HEIGHT

      // 附件区高度改变，更新输入区 mOffsetY 和滚动条
      if (this.showMMContentPicker && !this.mConversationCtrl?.isRcsMms) {
        this.mOffsetY = this.mmsPickerHeight + this.attachmentBottomHeight;
        this.mConversationCtrl.scrollToEnd();
      }
    }

    messageBubbleWidthChange(isCurBpChange: boolean) {
      // 屏幕宽度发生变化，更新附件区高度
      if (isCurBpChange !== false) {
        this.updateMMSPickerHeight()
      }

      if (this.curBp === common.STR.DEVICE_MOBILE_PHONE) {
            //When the device is a mobile phone, the maximum bubble width is 80% of the screen.
            this.currentScreenWidth = (this.deviceWidth * 0.8 ) + 'vp';
        } else if (this.curBp === common.STR.DEVICE_Folding_SCREEN) {
            //When the device is a folding screen or tablet, the maximum bubble width is 75% of the screen.
      this.currentScreenWidth = (this.deviceWidth / 2 * 0.8) + 'vp';
        } else {
      this.currentScreenWidth = (this.deviceWidth * 0.6 * 0.8) + 'vp';
        }
    }

  selectPicFromGalleryChanged() {
    if (this.selectPicFromGalleryDone) {
      HiLog.i(TAG, 'selectPicFromGalleryChanged Info');
      this.showMMContentPicker = false;
      this.mOffsetY = 0;
      this.textareaFocusable = true;
      focusControl.requestFocus(Constant.MMS_INPUT_TEXTAREA_Id);
    }
  }

    selectPicFromMaxHeightChanged() {
        if (this.selectPicFromMaxHeightDone) {
            HiLog.i(TAG, 'selectPicFromMaxHeightChanged Info')
            this.heightMMContentPicker = MIN_MM_PICKER_HEIGHT;
        }
    }

    closeKeyboard(){
      //附件区关闭，关闭键盘。
      this.mOffsetY = 0;
      this.mMContentPickerOffsetY = 0;
      this.mEmojiOffsetY = 0;
    }

    splitScreenTypeChange() {
        //小屏情况下会隐藏导航栏，重新获取list的Y值
        this.isFirstOnAreaChange = true;
        this.changeTextAreaHeight();
    }

    changeTextAreaHeight() {
      if (this.showMMContentPicker && this.splitInfoModel.isLimitOne) {
        let height = this.getMaxFontSizeScale() * 21 + 8 * 2;
        // 需要splitInfoModel提供一个动态的最小高度值以供一行或多行切换(此处以及TextArea的constraintSize)
        let minHeight: number = this.getMaxFontSizeScale() * INPUT_MIN_HEIGHT;
        let maxHeight: number = this.isVDE ? this.inputVdeMaxHeight : this.splitInfoModel.inputMaxheight;
        height = Math.max(minHeight, Math.min(maxHeight, height))
        this.inputCurrentheight = height;
        this.textHeight = this.inputCurrentheight;
      } else {
        this.inputCurrentheight = 'auto';
        this.measureTextAreaSize();
      }
    }

    showAudioTitleEvent() {
        if (this.heightMMContentPicker >= this.tabPickerMaxHeight &&
            (this.currentIndex === common.TAB_TYPE.PICTURE || this.currentIndex === common.TAB_TYPE.AUDIO)) {
            this.heightMMContentPicker = this.tabPickerMaxHeight;
            this.isAudioTitle = true;
            this.isPictureTitle = true;
            AppStorage.setOrCreate('canPictureScroll', true);
        } else {
            let isScroll: boolean = AppStorage.get('canPictureScroll') as boolean;
            if (isScroll) {
              AppStorage.setOrCreate('canPictureScroll', false);
            }
            this.isAudioTitle = false;
            this.isPictureTitle = false;
        }
    }

    resetTitle() {
        HiLog.i(TAG, 'resetTitle');
        this.isAudioTitle = false;
        this.isPictureTitle = false;
        this.showMmPicTitle = false;
        this.heightMMContentPicker = MIN_MM_PICKER_HEIGHT;
        this.fullHeightMMPicker = false;
        this.topMMContentPicker = this.windowHeight - MIN_MM_PICKER_HEIGHT;
        this.tabUtil.setTabUtilData(this.heightMMContentPicker, this.fullHeightMMPicker, this.topMMContentPicker);
    }

    getPageTitle(): ResourceStr {
        let str: ResourceStr = '';
        if (this.isAudioTitle && this.currentIndex === common.TAB_TYPE.AUDIO) {
            str = $r('app.string.msg_record');
        } else if (((this.isPictureTitle || this.showMmPicTitle) && this.currentIndex === common.TAB_TYPE.PICTURE)) {
            str = this.pictureSelectedNumber == 0 ? $r('app.string.msg_unselected_tip') :
            $r('app.plural.msg_selected_tip_new', this.pictureSelectedNumber, LocationUtil.numFormat(this.pictureSelectedNumber));
        } else {
            str = $r('app.string.new_message')
        }
        return str;
    }

    private onKeyboardChange() {
        // The keyboard will open when you add the contact info or input content of a message.
        // There should be no other irrelevant logic in this method.
        // Only focus on state change.
      this.isTextAreaChange = false;
      if (this.keyboardHeight === 0) {
          this.oldKeyboardHeight = this.keyboardHeight;
        if (!this.isShowEmoji && !this.showMMContentPicker) {
          this.closeKeyboard();
        }
      } else {
        this.oldKeyboardHeight = px2vp(this.keyboardHeight);
        this.showKeyboard();
      }
    }

  showKeyboard() {
    HiLog.iw(TAG, `emitterKeyboard==1222` + this.oldKeyboardHeight);
    let abilityStatus = GlobalContext.getContext().getObject('abilityStatus');
    if (abilityStatus === 'onBackground') {
      HiLog.i(TAG, 'Ability is in background Keyboard not need show.');
      return;
    }
    this.isShowEmoji = false;
    this.isVoicing = false;
    this.showMMContentPicker = false;
    //表情区关闭，弹出键盘。
    this.mOffsetY = this.oldKeyboardHeight - this.bottomPadding;
    if (this.mOffsetY < 0) {
      this.mOffsetY = 0;
    }
    this.mConversationCtrl.scrollToEnd();
    if (this.mConversationCtrl?.isRcsMms) {
      this.mMContentPickerOffsetY = this.oldKeyboardHeight -
        (this.splitInfoModel.isSmall ? MIN_MM_PICKER_HEIGHT : RCS_MM_PICKER_HEIGHT);
    } else {
      this.mMContentPickerOffsetY = this.oldKeyboardHeight - MIN_MM_PICKER_HEIGHT;
    }
    this.mEmojiOffsetY =
      this.oldKeyboardHeight - (this.splitInfoModel.isEmojiLow ? MIN_MM_PICKER_HEIGHT : EMOJI_HEIGHT) -
      this.bottomPadding;
  }

    showMMContentPickerChange() {
      if (this.showMMContentPicker) {
        this.isShowEmoji = false;
        inputMethod.getController().hideTextInput();
      }
      this.changeTextAreaHeight();
  }
    isShowEmojiChange() {
      if (this.isShowEmoji) {
        this.showMMContentPicker = false;
        inputMethod.getController().hideTextInput();
      }
    }

    displayChangedEvent() {
        this.isShowMmsAreaDisplay = this.mmAttachmentAreaController.mmDisplaySource.length > 0 ? true : false;
    }

  measureTextAreaSize() {
    let text: string | Resource = this.mConversationCtrl?.textValue?.length ? this.mConversationCtrl?.textValue :
      this.getMsgText()

    let textSize: SizeOptions = this.getUIContext().getMeasureUtils().measureTextSize({
      textContent: text,
      fontSize: this.getMaxFontSizeScale() * 16 + 'vp',
      lineHeight: this.getMaxFontSizeScale() * 21 + 'vp',
      fontWeight: FontWeight.Regular,
      fontFamily: 'HarmonyHeiTi',
      constraintWidth: this.textAreaWidth - 16 * 2,
    })
    let minHeight: number = this.getMaxFontSizeScale() * INPUT_MIN_HEIGHT;
    let maxHeight: number = this.isVDE ? this.inputVdeMaxHeight : this.splitInfoModel.inputMaxheight;
    let height = px2vp(textSize.height as number) + 8 * 2;
    height = Math.max(minHeight, height);
    height = Math.min(maxHeight, height);
    if (!this.isTextAreaChange) {
      this.textHeight = height;
    } else {
      if (this.textHeight < height) {
        this.textHeight = height;
      }
    }
    if(this.mConversationCtrl?.textValue?.length == 0){
        this.animatingTextHeight = this.textHeight < INPUT_MIN_HEIGHT ? INPUT_MIN_HEIGHT : this.textHeight;
    }
  }

    getHeight() {
        HiLog.i(TAG, 'mmDisplaySource.length is:' + JSON.stringify(this.mmAttachmentAreaController.mmDisplaySource.length))
        let height = TITLE_HEIGHT + this.textHeight - INPUT_MIN_HEIGHT
        if (this.mmAttachmentAreaController.mmDisplaySource.length >= 1) {
            if (this.mmAttachmentAreaController.mmDisplaySource.length > 1) {
                if (this.mmAttachmentAreaController.mmDisplaySource.some(item => item.type ==
                    commonData.MM_ATTACHMENT_TYPE.VIDEO || item.type == commonData.MM_ATTACHMENT_TYPE.IMAGE ||
                    item.type == commonData.ENHANCED_INFO_ITEM_TYPE.MAP)) {
                    height += ATTACHMENT_MAX_AREA_HEIGHT;
                } else {
                    height += ATTACHMENT_MIN_AREA_HEIGHT;
                }
            } else if (this.mmAttachmentAreaController.mmDisplaySource.length == 1) {
                if (this.mmAttachmentAreaController.mmDisplaySource.some(item =>
                item.type == commonData.MM_ATTACHMENT_TYPE.AUDIO)) {
                    height += ATTACHMENT_MIN_AREA_HEIGHT;
                } else {
                    height += ATTACHMENT_MAX_AREA_HEIGHT;
                }
            }
        }
        if (this.showMMContentPicker) {
          if (this.mConversationCtrl.isRcsMms) {
            height += this.splitInfoModel.isSmall ? this.heightMMContentPicker : RCS_MM_PICKER_HEIGHT;
          } else {
            height += MIN_MM_PICKER_HEIGHT;
          }
        }
        if (this.isShowEmoji) {
          height += this.isVDE ? 192 :
            this.splitInfoModel.isEmojiLow ? MIN_MM_PICKER_HEIGHT : EMOJI_HEIGHT + this.bottomPadding
        }
        height = this.setKeyboardTextHeight(height)
        if (this.mConversationCtrl.isSelectStatus) {
            this.isShowEmoji = false;
            this.textareaFocusable = false;
            this.showMMContentPicker = false;
            height = TITLE_HEIGHT
        }
        this.sendBarHeight = height;
        HiLog.i(TAG,'height is:'+height)
        return height;
    }

    setKeyboardTextHeight(height: number) {
      let textHeight = height;
      if (this.keyboardHeight > 0 && !this.isShowEmoji) {
        if (this.curBp === common.STR.DEVICE_FLAT_PLATE && DeviceUtil.isFloatingScreen()) {
          textHeight = TITLE_HEIGHT
        } else {
          textHeight += px2vp(this.keyboardHeight) - this.bottomPadding
        }
      }
      return textHeight;
    }

    @Styles normalStylesMenu(){
        .backgroundColor(Color.Transparent)
    }
    @Styles pressedStylesMenu(){
        .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
        .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
    }
    @Styles  actionButtonPressStyles(){
        .stateStyles({
            normal: this.normalStylesMenu,
            pressed: this.pressedStylesMenu
        })
    }

    @Builder
    navTitle() {
        Row() {
          if (this.isFromInfoMsg == true || this.curBp == common.STR.DEVICE_MOBILE_PHONE) {
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph(this.mConversationCtrl.isSelectStatus ? $r('sys.symbol.xmark') :
              $r('sys.symbol.chevron_backward'))
                .fontColor([$r('sys.color.ohos_id_color_primary')])
                .fontSize('24vp')
                .id('back_image')
                .draggable(false)
                .width(24)
                .height(24)
            }
            .margin(Configuration.getLocale().dir === 'rtl' ? { left: $r('sys.float.ohos_id_elements_margin_horizontal_m') } :
              { right: $r('sys.float.ohos_id_elements_margin_horizontal_m') })
            .width(40)
            .height(40)
            .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
            .draggable(false)
            .borderRadius($r('sys.float.corner_radius_level10'))
            .id('back_button')
            .accessibilityText(this.backButtonAccessibilityText())
            .onClick(() => {
              if (this.isShowEmoji || this.showMMContentPicker) {
                this.destinationBackPress();
              } else if (!this.mConversationCtrl.isSelectStatus) {
                if (this.pageInfos && this.pageInfos.getIndexByName('RcsChatbotSearchBarActivity').length > 0) {
                  this.pageInfos.popToName('RcsChatbotSearchBarActivity');
                }
                if (this.pageInfos && this.pageInfos.getIndexByName('RcsHomePageChatbotActivity').length > 0) {
                  this.pageInfos.popToName('RcsHomePageChatbotActivity');
                } else if (this.pageInfos && this.pageInfos.getIndexByName('InfoMsg').length > 0) {
                  this.pageInfos.popToName('InfoMsg')
                } else {
                  this.pageInfos?.clear()
                }
                this.destinationBackPress()
              } else {
                this.cancelMultiStatus()
              }
            })
          }

            // <!--Top titleBar-->
          if (!this.mConversationCtrl.isSelectStatus && (this.isAudioTitle || this.isPictureTitle)) {
                Text(this.getPageTitle())
                  .fontSize($r('sys.float.ohos_id_text_size_headline8'))
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .fontWeight(FontWeight.Bold)
                  .focusable(true)

                // Page for viewing SMS details
            } else {
                // Select Status
                this.buildDetailsTitle()
          }

          if (!DeviceUtil.isPC()) {
            this.navMenu()
          }
        }
        .accessibilityLevel('no')
        .width('100%')
        .onClick(() => {
          if (this.isShowEmoji) {
            animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37) }, () => {
              this.isShowEmoji = false;
              this.mOffsetY = 0;
            })
          }
        })
        .padding(
          {
            left: DeviceUtil.isPC() ? '' : this.curBp === common.STR.DEVICE_MOBILE_PHONE ||
              this.isFromInfoMsg === true ? 16 : this.isPad ? this.padMargin : $r('sys.float.margin_left'),
            right: DeviceUtil.isPC() ? '' : this.curBp === common.STR.DEVICE_MOBILE_PHONE ||
              this.isFromInfoMsg === true ? 16 : this.isPad ? this.padMargin : $r('sys.float.margin_left'),
          })
    }

    @Builder
    buildDetailsTitle() {
        // Select Status
        if (this.mConversationCtrl.isSelectStatus) {
          Row() {
            if (this.curNavMode === common.int.NAVIGATION_MODE_SPLIT && !this.isFromInfoMsg || DeviceUtil.isPC()) {
              this.buildCancel()
            }
            Text(this.selectNumber == 0
              ? $r('app.string.msg_unselected_tip')
              : $r('app.plural.msg_selected_tip_new', this.selectNumber,
              LocationUtil.numFormat(this.selectNumber)))
              .fontSize($r('sys.float.ohos_id_text_size_headline8'))
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Bold)
          }
            // Non-Selected Status
        } else {
            Row() {
              if (DeviceUtil.isPC() && this.mConversationCtrl.smsType === common.sms_type.NOTICE &&
                this.isPCShowMessageBackButton) {
                Column() {
                  Image($rawfile('icon/ic_chevron_left.png'))
                    .width(24)
                    .height(40)
                    .draggable(false)
                }
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .width(40)
                .height(40)
                .borderRadius(24)
                .margin({ end: LengthMetrics.vp(8) })
                .onClick(() => {
                  CancelNotificationTimeLock.getInstance().freeLock('conversation->onBackPressed')
                  return this.destinationBackPress();
                })
              }
              this.buildContact()
            }
            .width('calc(100% - 88vp)');
        }
    }

  //报The caller has been released，再拉起一次联系人
  againJumpToContact(context: Context, actionData: ActionData) {
    let str = commonService.commonContactParam(actionData);
    (context as myCommon.UIAbilityContext).startAbility(str).then((data) => {
      HiLog.i(TAG, 'jumpToContact, startAbility success');
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'jumpToContact, failed Cause: ' + JSON.stringify(error.message));
    })
  }

  @Builder
  buildCancel() {
    Column() {
      SymbolGlyph($r('sys.symbol.xmark'))
        .width(24)
        .height(24)
        .draggable(false)
        .fontColor([$r('sys.color.ohos_id_color_primary')])
        .fontSize('24vp')
    }
    .width(40)
    .height(40)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .borderRadius(20)
    .margin({ end: LengthMetrics.vp(8) })
    .stateStyles({
      normal: this.normalStylesOfCancel,
      pressed: this.pressedStylesOfCancel
    })
    .onClick(() => {
      this.mConversationCtrl.resetSelectData();
      this.mConversationCtrl.resetMmsCount();
      this.mConversationCtrl.cancelCheckedAll();
      this.conversationDataSource.refresh(this.mConversationCtrl.mmsList)
    })
  }

    @Builder
    buildContact() {
      Row() {
        //  单聊显示头像，群聊不显示头像
        if ((this.transmitParams?.photoFirstNames?.length === 1 || this.mConversationCtrl.contactsNum === 1) &&
        this.isShowHeadIcon) {
          ContactAvatar({
            hasYellowPageIcon: this.mConversationCtrl.hasYellowPageIcon,
            rawContactId: this.mConversationCtrl.rawContactId,
            contactId: this.mConversationCtrl.contactId,
            phoneNumber: this.transmitParams?.strContactsNumber,
            yellowPageId: this.transmitParams?.yellowPageId,
            firstPhotoName: this.mConversationCtrl.photoFirstName,
            portraitColor: this.transmitParams?.portraitColor,
            imgSize: this.transmitParams?.imgSize,
            loadFromDB: this.transmitParams?.loadFromDB,
            fontSize: this.transmitParams?.fontSize,
            marginLength: this.transmitParams?.marginLength,
            index: this.transmitParams?.index,
            smsType: this.transmitParams?.smsType,
            avatarIcon: this.transmitParams?.icon,
            chatbotPageIcon: this.transmitParams?.chatbotPageIcon,
          })
            .onClick(() => {
              let actionData: ActionData = {
                phoneNumber: this.mConversationCtrl.strContactsNumber,
                pageFlag: common.contactPage.PAGE_FLAG_CONTACT_DETAILS,
                contactId: this.mConversationCtrl.contactId,
              };
              this.clickToContacts(actionData)
            })
            .margin({end: LengthMetrics.vp(8)})
            .alignRules({
              center: { anchor: '__container__', align: VerticalAlign.Center },
              left: { anchor: '__container__', align: HorizontalAlign.Start }
            })
            .accessibilityLevel('yes')
        }
        Column() {
          if (this.mConversationCtrl.contactsNum > 1) {
            Text(this.mConversationCtrl.formatStrContactsNumberFormat)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .minFontSize($r('app.float.conversation_title_min_font_size'))
              .maxFontSize($r('sys.float.ohos_id_text_size_headline8'))
              .wordBreak(WordBreak.BREAK_ALL)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Bold)
              .focusable(true)
              .width('100%')
              .wordBreak(WordBreak.BREAK_ALL)
              .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
              .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Ltr : Direction.Auto)
            Text($r('app.plural.members', this.mConversationCtrl.contactsNum,
              this.mConversationCtrl.contactsNum))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontSize('14vp')
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontWeight(FontWeight.Regular)
              .width('100%')
              .margin({ top: 2 })
              .textAlign(i18n.isRTL(i18n.System.getSystemLanguage()) ? TextAlign.End : TextAlign.Start)
              .direction(i18n.isRTL(i18n.System.getSystemLanguage()) ? Direction.Ltr : Direction.Auto)
          } else if (this.mConversationCtrl.strContactsName == '' ||
            this.mConversationCtrl.strContactsName == null) {
            Text(this.mConversationCtrl.formatStrContactsNumberFormat)
              .direction(Direction.Ltr)
              .maxLines(1)
              .width('100%')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .minFontSize($r('app.float.conversation_title_min_font_size'))
              .maxFontSize($r('sys.float.ohos_id_text_size_headline8'))
              .wordBreak(WordBreak.BREAK_ALL)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Bold)
              .focusable(true)
              .textAlign(Configuration.getLocale().dir === 'rtl' ? TextAlign.End : TextAlign.Start)
          } else {
            this.buildContactText()
          }
        }
        .renderGroup(true)
        .width(this.isShowHeadIcon ? 'calc(100% - 48vp)' : '100%')
        .justifyContent(FlexAlign.Center)
        .padding({
          right: Configuration.getLocale().dir === 'rtl' ?
            0 : (this.isPad ? 120 + this.padMargin : 0),
          left: Configuration.getLocale().dir === 'rtl' ?
            (this.isPad ? 120 + this.padMargin : 0) : 0
        })
      }
    }

  @Builder
  buildContactText() {
      Text(this.mConversationCtrl.formatStrContactsName)
        .direction(Direction.Ltr)
        .maxLines(1)
        .width('100%')
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .minFontSize($r('app.float.conversation_title_min_font_size'))
        .maxFontSize($r('sys.float.ohos_id_text_size_headline8'))
        .wordBreak(WordBreak.BREAK_ALL)
        .fontColor($r('sys.color.icon_primary'))
        .fontWeight(FontWeight.Bold)
        .focusable(true)
        .fontFamily('HarmonyHeiTi')
        .textAlign(Configuration.getLocale().dir === 'rtl' ? TextAlign.End : TextAlign.Start)
     if (this.mConversationCtrl.contactsNameIsNotEqualToContactsNumberFormat) {
      Text(this.mConversationCtrl.formatStrContactsNumberFormat)
        .direction(Direction.Ltr)
        .maxLines(1)
        .width('100%')
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontSize('14vp')
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .margin({ top: 2 })
        .textAlign(Configuration.getLocale().dir === 'rtl' ? TextAlign.End : TextAlign.Start)
    }
  }

    @Builder
    navMenu() {
      if (!this.isVDE) {
        Column() {
          // <!--Top titleBar-->
          // New page
          if ((this.mConversationCtrl.isNewMsg || this.mConversationCtrl.isNewMsgWithDraft ||
            (!this.mConversationCtrl.isSelectStatus && (this.isAudioTitle || this.isPictureTitle)))) {
            this.buildNewPageMenu()
            // Page for viewing SMS details
          } else {
            this.buildDetailsMenu()
          }
        }
        .accessibilityLevel('no')
        .alignItems(HorizontalAlign.End)
        .onClick(() => {
          if (this.isShowEmoji) {
            animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37) }, () => {
              this.isShowEmoji = false;
              this.mOffsetY = 0;
            })
          }
        })
      }
    }

    @Builder
    buildDetailsMenu() {
        Row() {
            // Select Status
            if (this.mConversationCtrl.isSelectStatus) {
                // Non-Selected Status
            } else {
                this.buildDetailsNoSelectMenu()
            }
        }
        .height(56)
        .constraintSize({ minHeight: 56 })
        .padding(Configuration.getLocale().dir === 'rtl' ?
          {
            right: this.curBp === common.STR.DEVICE_MOBILE_PHONE ||
              this.isFromInfoMsg === true ? 0 : 48,
            left: this.isPad ? this.padMargin : $r('sys.float.padding_level8')
          } :
          {
            left: this.curBp === common.STR.DEVICE_MOBILE_PHONE ||
              this.isFromInfoMsg === true ? 0 : 48,
            right: this.isPad ? this.padMargin : $r('sys.float.padding_level8')
          }
        )
        .zIndex(2)
    }

    @Builder
    buildDetailsNoSelectMenu() {
        Row() {
            Row() {
              RcsMoreMenu()
            }
            .width(40)
            .height(40)
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
        }
    .constraintSize({maxWidth:96})
        .justifyContent(FlexAlign.End)
    }

    @Builder
    buildNewPageMenu() {
        Row() {
            Row() {
                Column() {
                    RcsNewMoreMenu();
                };
            }
            .id('titleButton')
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .alignRules({
                top: { anchor: '__container__', align: VerticalAlign.Top },
                right: { anchor: '__container__', align: HorizontalAlign.End }
            })
            .height('100%')
            .visibility((this.isShowMoreMenu && !this.fullHeightMMPicker)
                ? Visibility.Visible : Visibility.None);
            if (this.isPictureTitle && this.currentIndex === common.TAB_TYPE.PICTURE) {
              Row() {
                SymbolGlyph($r('sys.symbol.checkmark'))
                  .width(24)
                  .height(24)
                  .fontColor([$r('sys.color.ohos_id_color_primary')])
                  .fontSize('24vp')
                  .draggable(false);
              }
        .width(40)
        .height(40)
                .actionButtonPressStyles()
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .padding({ right: 4 })
                .onClick(() => {
                    this.resetTitle();
                });
            }
        }
        .justifyContent(FlexAlign.End)
        .width('100%')
        .height(56)
        .flexShrink(0)
        .padding({
      left: $r('sys.float.margin_left'),
      right: this.isPad ? this.padMargin : $r('sys.float.margin_right')
        })
        .zIndex(2)
    }

  handleTextValueChange(value:string) {
    if (value.length > TEXT_MAX_LENGTH) {
      this.mConversationCtrl.showToast($r('app.string.text_input_limit'))
      this.mConversationCtrl.textValue = value;
      this.mConversationCtrl.textValue =
          this.mConversationCtrl.textValue.substring(0, TEXT_MAX_LENGTH);
    } else {
      this.mConversationCtrl.changeValue(value);
      this.mConversationCtrl.handleProtocolChange(value);
    }
    // 写信息——输入普通文字打点
    if (this.mConversationCtrl.textValue.length !== 0 && !this.isInputDot) {
      if (this.mConversationCtrl.newEmojiLength > 0) {
        writeEventParams.INPUT_STATE = 2;
        this.isEmojiDot = true;
        DotUtil.getInstance().reportEvent(writeEventParams, dotCommon.eventName.WRITE_SMS_EVENT);
      }
      if (!this.isTextDot &&
        this.mConversationCtrl.textValue.length - this.mConversationCtrl.newEmojiLength > 0) {
        writeEventParams.INPUT_STATE = 1;
        this.isTextDot = true;
        DotUtil.getInstance().reportEvent(writeEventParams, dotCommon.eventName.WRITE_SMS_EVENT);
      }
      if (this.isEmojiDot && this.isTextDot) {
        this.isInputDot = true;
      }
    }
    this.calculateTextInputCount();
    this.measureTextAreaSize();
    if (this.isShowEmoji) {
      this.controller.caretPosition(this.mConversationCtrl.newEmojiLength +
      this.mConversationCtrl.caretPosition)
    }
  }

  backButtonAccessibilityText(): string {
    return this.mConversationCtrl.isSelectStatus ?
    getContext(this).resourceManager.getStringSync($r('app.string.disable').id) :
    getContext(this).resourceManager.getStringSync($r('app.string.guide_action_text_previous').id)
  }

  multiCheckBoxChange(item: LooseObject, index: number) {
    if (this.mConversationCtrl.isSelectStatus &&
    ConversationDataSource.getInstance().mmsList[index]) {
      this.mConversationCtrl.multiSelectMmsMsg(index);
      this.mConversationCtrl.listCheckBoxChange(index,
        !ConversationDataSource.getInstance().mmsList[index].isCbChecked);
      this.changeConversationSelectedNumberAndCheckAllBool();
    }
    if (item.isRcs === common.MESSAGE_TYPE.RCS) {
      if (item.isAdvancedSecurity) {
        this.securityModeController.open();
      }
    }
  }
  build() {
    // HdsNavDestination() {
    NavDestination() {
            RelativeContainer() {
              if (DeviceUtil.isPC()) {
                Column() {
                  Row() {
                    Row() {
                      if (this.mConversationCtrl.isSelectStatus) {
                        ToolBar({
                          toolBarList: this.toolBarList1,
                          activateIndex: this.mConversationCtrl.isMessageCheckAll ? (this.isSelectDelete ? 1 : 3) : -1,
                          toolBarModifier: this.toolBarModifier1,
                        }).width(280)
                          .bindMenu(this.isMoreMenuShown, MenuBuilder(this.context, {
                            mmsListItem: this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex],
                            mConversationCtrl: this.mConversationCtrl,
                            textDirection: this.textDirection,
                            cancelMultiStatusAction: () => {
                              this.isMoreMenuShown = false;
                              this.cancelMultiStatus();
                            },
                            updateBackIconAction: () => {
                              this.updateBackIcon(false);
                            },
                            showDialogController: () => {
                              this.dialogController.open();
                            }
                          }),
                            {
                              placement: Placement.BottomRight,
                              onDisappear: () => {
                                this.isMoreMenuShown = false;
                              }
                            }
                          )
                          .onAreaChange((oldValue: Area, newValue: Area) => {
                            HiLog.i(TAG, 'newValue globalPosition.y:' + newValue.globalPosition.y)
                            if (newValue.globalPosition.y != undefined) {
                              this.bottomSendBarPositionY = newValue.globalPosition.y as Length;
                            }
                            this.changeNeedExpandSafeArea();
                          })
                      }
                    }
                  }
                  .height(56)
                  .justifyContent(FlexAlign.End)
                  .width('100%')
                  .padding({ right: 135 })

                  Row() {
                    this.navTitle()
                  }.height(56).padding({ left: 24 })

                }
                .id('topbar')
                .alignRules({
                  top: { anchor: '__container__', align: VerticalAlign.Top },
                  left: { anchor: '__container__', align: HorizontalAlign.Start },
                  right: { anchor: '__container__', align: HorizontalAlign.End },
                })
                .height(112)
              }
                // SMS message contents
                // <!--Information List-->
              List({
                space: 16,
                initialIndex: this.isChatbotConversation ? this.mConversationCtrl.mmsList.length :
                  this.mConversationCtrl.mmsList.length - 1,
                scroller: this.mConversationCtrl.scroller
              }) {
                LazyForEach(this.conversationDataSource, (item: LooseObject, index) => {
                  ListItem() {
                    Column() {
                      MessageTypeTitleAndCalenderDate({
                        mmsItem: item as mmsListType
                      }).margin({ top: index == 0 ? 16 : 0 })
                      // <!--Information Sending Item-->
                      if (!item.isReceive && !item.isDraft) {
                        //messageTitleAndCalenderDate
                        Flex({
                          justifyContent: FlexAlign.Center,
                          alignItems: ItemAlign.Start
                        }) {
                          Column() {
                            Row() {
                              // <!--Sending failed icon-->
                              if (item.sendStatus == commonData.int.RCS_SEND_CANCELED ||
                                (this.mConversationCtrl.contactsNum == 1 &&
                                  item.sendStatus == commonData.int.SEND_MESSAGE_FAILED) ||
                                (this.mConversationCtrl.contactsNum > 1 &&
                                  item.failuresNumber > 0 &&
                                  item.completeNumber ==
                                  this.mConversationCtrl.contactsNum)) {
                                SendFailedButton({
                                  mmsItem: item as mmsListType,
                                  contactsNum: this.mConversationCtrl.contactsNum,
                                  onSendFailedButtonClick: () => {
                                      if (this.mConversationCtrl.canResendMms(item.isMsm)) {
                                        this.mConversationCtrl.setResendIndex(index);
                                        this.isResendRcsInfo = false;
                                        this.resendStateIsRcs = false;
                                        if (!this.conListCtrl.isOsAccountConstraintEnabled) {
                                          this.resendDialogController.open();
                                        }
                                        // 发信息发送失败点击重发按钮打点
                                        DotUtil.getInstance()
                                          .reportEvent(dotNoNeedParmas,
                                            dotCommon.eventName.SENDING_FAILED_AND_RESEND);
                                      }
                                  }
                                }).margin({ end: LengthMetrics.vp(8) })
                              }
                              // Message Bubble
                              Column() {
                                if (item.isMsm) {
                                  MmsContent({
                                    isTouch: $isTouch,
                                    conversationCtrl: $mConversationCtrl,
                                    mmsInfo: item as mmsInfo,
                                    item: item.mmsSource,
                                    contentType: item.contentType,
                                    bubbleTextDirection: 'right',
                                    itemIndex: index,
                                    delConversionController: this.delConversionController,
                                    showMMContentPicker: $showMMContentPicker,
                                    content: item.content,
                                    mmsItem: item as mmsListType,
                                    scrollEndIndex: this.scrollEndIndex,
                                    scrollStartIndex: this.scrollStartIndex,
                                    changeConversationSelectedNumberAndCheckAllBool: ()=>{
                                      this.changeConversationSelectedNumberAndCheckAllBool();
                                    },
                                    mmsContentBackgroundColor: $r('app.color.brand'),
                                  }).id('mms_content_right_id')
                                }
                                if (!item.isMsm || (item.msgTitle && item.content == '') ||
                                    (item.isMsm &&
                                      item.content !== ''&&  
                                      item.msgShowType !== common.MESSAGE_SHOW_TYPE.MAP && //彩信位置消息不展示BubbleText
                                      !MmsUtil.isSlideType(item.contentType))) {
                                  BubbleText({
                                    conversationCtrl: $mConversationCtrl,
                                    bubbleTextBorderRadius: [2, 16],
                                    bubbleTextDirection: 'right',
                                    content: item.content,
                                    detectResContent: item.detectResContent,
                                    isRcs: item.isRcs,
                                    bubbleTextBackgroundColor: $r('app.color.brand'),
                                    itemIndex: index,
                                    mmsItem: item as mmsListType,
                                    delConversionController: this.delConversionController,
                                    showMMContentPicker: $showMMContentPicker,
                                    currentScreenWidth: this.currentScreenWidth,
                                    isMsm: item.isMsm,
                                    controller: this.controller,
                                    isPermissionDenied:
                                    this.isPermissionDenied,
                                    isScrolling: this.isScrolling,
                                    isGeometryAnimate: this.isSendingAnimate,
                                    scrollEndIndex: this.scrollEndIndex,
                                    scrollStartIndex: this.scrollStartIndex,
                                    isLastItem: index == this.mConversationCtrl.mmsList.length - 1,
                                    changeConversationSelectedNumberAndCheckAllBool: ()=>{
                                      this.changeConversationSelectedNumberAndCheckAllBool();
                                    },
                                    smsType: this.mConversationCtrl.smsType,
                                    changeFocusAble: () => {
                                      this.textareaFocusable = false;
                                    }
                                  })
                                }
                              }
                              .accessibilityLevel('no')
                              .id(item.id.toString())
                              .alignItems(HorizontalAlign.End)
                              .onClick(() => {
                                let bubleTextFlag: boolean = (!item?.isRcs &&
                                  (!item.isMsm || (item.msgTitle && item.content == '') ||
                                    (item.isMsm &&
                                      item.content !== '' &&
                                      !MmsUtil.isSlideType(item.contentType)))) ||
                                  item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.TEXT;
                                if (this.mConversationCtrl.isSelectStatus &&
                                ConversationDataSource.getInstance().mmsList[index] && !bubleTextFlag) {
                                  this.mConversationCtrl.multiSelectMmsMsg(index);
                                  this.mConversationCtrl.listCheckBoxChange(index,
                                    !ConversationDataSource.getInstance().mmsList[index].isCbChecked);
                                  this.changeConversationSelectedNumberAndCheckAllBool();
                                }
                              })
                            }
                            .justifyContent(FlexAlign.End)
                            .alignItems(VerticalAlign.Center);
                            // <!--Sending time and sending status-->
                            Flex({
                              alignItems: ItemAlign.Center,
                              justifyContent: FlexAlign.End,
                              space: {
                                main: LengthMetrics.vp(4)
                              }
                            }) {
                              if (this.mConversationCtrl.contactsNum > 1 && !item.isMsm) {
                                Text($r('app.string.msg_detail_mms'))
                                  .fontSize(10)
                                  .lineHeight(13)
                                  .fontColor($r('sys.color.font_emphasize'))
                                  .margin(this.textDirection === 'rtl' ?
                                    { top: 8 } :
                                    { top: 8 })
                                  .onClick(() => {
                                    HiLog.i(TAG, 'onClick to GroupDetail')
                                    this.mConversationCtrl.pushToGroupDetail(index);
                                  })
                                  .accessibilityLevel('yes')
                              }
                              if (item.sendStatus !=
                              common.int.SEND_MESSAGE_SENDING) {
                                Text(this.needRefreshTime ? item.detailTime : item.detailTime)
                                  .textAlign(TextAlign.Start)
                                  .lineHeight(13)
                                  .fontSize(10)
                                  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                                  .margin({
                                    top: LengthMetrics.vp(8)
                                  })
                              }
                              // Card 1 or Card 2
                              if (this.cardImage &&
                              this.mConversationCtrl.isAllCardActive && item.subId != -1) {
                                Image(item.subId === common.int.SLOT_ZERO ? this.iconOfSlot0 : this.iconOfSlot1)
                                  .width(10)
                                  .height(10)
                                  .draggable(false)
                                  .opacity(0.4)
                                  .margin({
                                    top: LengthMetrics.vp(8)
                                  })
                                  .fillColor($r('sys.color.ohos_id_color_foreground'))
                                  .onComplete(() => {
                                    this.slotId = item.subId
                                  })
                                  .accessibilityRole(AccessibilityRoleType.TEXT)
                                  .accessibilityText(AccessibilityUtil.getSimIconAccessibilityText(item.subId,
                                    getContext(this)))
                              }
                              Text(this.mConversationCtrl.contactsNum === 1 ?
                              $r('app.string.messageSendFailed') :
                              $r('app.string.msg_send_failed_number_new', LocationUtil.numFormat(item.failuresNumber)))
                                .textAlign(TextAlign.Start)
                                .fontSize(10)
                                .lineHeight(13)
                                .margin({ top: LengthMetrics.vp(8) })
                                .fontColor($r('sys.color.warning'))
                                .visibility(item.sendStatus == 2 ?
                                Visibility.Visible : Visibility.None)
                              Row() {
                                Progress({
                                  value: this.mConversationCtrl.progressValue,
                                  total: 100,
                                  type: ProgressType.Linear
                                })
                                  .width(64)
                                  .height(4)
                                  .visibility(item.showProgress &&
                                    this.mConversationCtrl.contactsNum === 1 ?
                                  Visibility.Visible : Visibility.None)
                              }
                              .width(64)
                              .height(24)
                              .margin({ top: 2 })
                              .justifyContent(FlexAlign.Center)
                              .visibility(item.showProgress &&
                                this.mConversationCtrl.contactsNum === 1 ?
                              Visibility.Visible : Visibility.None)

                                Text(item.sendStatus == common.int.RCS_SEND_OK ? '' : $r('app.string.messageSending'))
                                  .textAlign(TextAlign.Start)
                                  .fontSize(10)
                                  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                                  .lineHeight(13)
                                  .margin(this.textDirection === 'rtl' ?
                                    { top: 8 } :
                                    { top: 8 })
                                  .visibility((item.sendStatus ==
                                  common.int.SEND_MESSAGE_SENDING ||
                                    item.sendStatus == common.int.RCS_SEND_OK) ?
                                  Visibility.Visible : Visibility.None)

                              if (this.mConversationCtrl.contactsNum > 1 &&
                                item.sendStatus === 1) {
                                Text(`(${item.completeNumber}/${this.mConversationCtrl.contactsNum})`)
                                  .textAlign(TextAlign.Start)
                                  .fontSize($r('sys.float.ohos_id_text_size_caption'))
                                  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                                  .lineHeight(13)
                                  .margin(Configuration.getLocale().dir === 'rtl' ?
                                    { top: 8 } :
                                    { top: 8 })
                              }
                            }.width('100%')
                            .padding({ end: LengthMetrics.vp(12) })
                            .visibility(item?.isRcs ? Visibility.None :
                            Visibility.Visible)
                            //发送状态动画
                            .transition(this.isSendingAnimate
                                && index == this.mConversationCtrl.mmsList.length - 1
                                ? TransitionEffect.OPACITY.animation(
                                { delay: 150, curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1) })
                                : TransitionEffect.IDENTITY)

                          }
                          .width('100%')
                          .alignItems(HorizontalAlign.End)

                          // Sender's avatar, which is available only for group messages.
                          Flex({
                            direction: FlexDirection.Column,
                            justifyContent: FlexAlign.Start,
                            alignItems: ItemAlign.Center
                          }) {
                            Image($rawfile('icon/ic_user_portrait.svg'))
                              .width(32)
                              .height(32)
                              .id('contactPicture')
                              .borderRadius(16)
                              .objectFit(ImageFit.Fill)
                              .backgroundColor($r('app.color.mms_avatar_bg'))
                              .foregroundColor($r('sys.color.ohos_id_color_primary_contrary'))
                              .draggable(false)
                          }
                          .margin(this.textDirection === 'rtl' ?
                            { left: 0, right: 8 } :
                            { left: 8, right: 0 })
                          .flexShrink(0)
                          .visibility((this.mConversationCtrl.contactsNum > 1 &&
                          this.conListCtrl.isShowContactHeadIcon) ?
                          Visibility.Visible : Visibility.None)

                          if (this.mConversationCtrl.isSelectStatus &&
                            typeof this.selectNumber === 'number') {
                            Row() {
                              Checkbox()
                                .select(this.checkBoxStatusHasChanged ?
                                  ConversationDataSource.getInstance().mmsList[index]?.isCbChecked :
                                  ConversationDataSource.getInstance().mmsList[index]?.isCbChecked)
                                .shape(CheckBoxShape.CIRCLE)
                                .selectedColor($r('sys.color.font_emphasize'))
                                .width(20)
                                .height(20)
                                .margin(2)
                                .offset({ y: this.mConversationCtrl.contactsNum > 1 ? 0 : 4 })
                                .onClick((event: ClickEvent) => {
                                  if (!ConversationDataSource.getInstance().mmsList[index]) {
                                    return;
                                  }
                                  this.mConversationCtrl.multiSelectMmsMsg(index);
                                  this.mConversationCtrl.listCheckBoxChange(index,
                                    !ConversationDataSource.getInstance().mmsList[index].isCbChecked);
                                  this.changeConversationSelectedNumberAndCheckAllBool();
                                  setTimeout(() => {
                                    AccessibilityUtil.requestFocusForAccessibility(item.id.toString()+'Checkbox');
                                  }, 50);
                                })
                                .id(item.id.toString()+'Checkbox')
                                .accessibilityLevel('yes')
                            }
                            .alignItems(VerticalAlign.Center)
                            .justifyContent(FlexAlign.Center)
                            .width(24)
                            .height(32)
                            .flexShrink(0)
                            .margin({ start: LengthMetrics.vp(12) })
                          }
                        }
                      }
                      // <!--Information receiving item-->
                      else if (item.isReceive) {
                        Flex({
                          justifyContent: FlexAlign.Center,
                          alignItems: ItemAlign.Start
                        }) {
                          Column() {
                            Flex({
                              alignItems: ItemAlign.Center,
                              justifyContent: FlexAlign.Start
                            }) {
                              // Message Bubble
                              Column() {
                                if (item.isMsm) {
                                  MmsContent({
                                    isTouch: $isTouch,
                                    conversationCtrl: $mConversationCtrl,
                                    mmsInfo: item as mmsInfo,
                                    item: item.mmsSource,
                                    contentType: item.contentType,
                                    bubbleTextDirection: 'left',
                                    itemIndex: index,
                                    delConversionController: this.delConversionController,
                                    showMMContentPicker: $showMMContentPicker,
                                    mmsItem: item as mmsListType,
                                    scrollEndIndex: this.scrollEndIndex,
                                    scrollStartIndex: this.scrollStartIndex,
                                    changeConversationSelectedNumberAndCheckAllBool: ()=>{
                                      this.changeConversationSelectedNumberAndCheckAllBool();
                                    },
                                    mmsContentBackgroundColor: $r('sys.color.ohos_id_color_card_bg'),
                                  }).id('mms_content_left_id')
                                } else {
                                  MmsContent({
                                    isTouch: $isTouch,
                                    conversationCtrl: $mConversationCtrl,
                                    mmsInfo: item as mmsInfo,
                                    item: item.mmsSource,
                                    contentType: item.contentType,
                                    bubbleTextDirection: 'left',
                                    itemIndex: index,
                                    isRcs: item.isRcs,
                                    delConversionController: this.delConversionController,
                                    showMMContentPicker: $showMMContentPicker,
                                    mmsItem: item as mmsListType,
                                    scrollEndIndex: this.scrollEndIndex,
                                    scrollStartIndex: this.scrollStartIndex,
                                    changeConversationSelectedNumberAndCheckAllBool: ()=>{
                                      this.changeConversationSelectedNumberAndCheckAllBool();
                                    }
                                  }).id('mms_content_left_id')
                                }
                                if (!item.isMsm || (item.msgTitle && item.content == '') ||
                                    (item.isMsm && item.content !== ''&&
                                      item.msgShowType !== common.MESSAGE_SHOW_TYPE.MAP && //彩信位置消息不展示BubbleText
                                      !MmsUtil.isSlideType(item.contentType))) {
                                  BubbleText({
                                    conversationCtrl: $mConversationCtrl,
                                    bubbleTextBorderRadius: [2, 16],
                                    bubbleTextDirection: 'left',
                                    content: item.content,
                                    detectResContent: item.detectResContent,
                                    isRcs: item.isRcs,
                                    bubbleTextBackgroundColor: $r('sys.color.ohos_id_color_card_bg'),
                                    itemIndex: index,
                                    delConversionController: this.delConversionController,
                                    showMMContentPicker: $showMMContentPicker,
                                    isReceive: item.isReceive,
                                    isAdvancedSecurity: item.isAdvancedSecurity,
                                    isReport: item.isReport,
                                    isPermissionDenied: this.isPermissionDenied,
                                    currentScreenWidth: this.currentScreenWidth,
                                    isMsm: item.isMsm,
                                    controller: this.controller,
                                    mmsItem: item as mmsListType,
                                    isScrolling: this.isScrolling,
                                    isLastItem: index == this.mConversationCtrl.mmsList.length - 1,
                                    scrollEndIndex: this.scrollEndIndex,
                                    scrollStartIndex: this.scrollStartIndex,
                                    updateHeight: ((hei: number) => {
                                      if (!this.isTouch) {
                                        this.mConversationCtrl.scrollToEnd();
                                      }
                                    }),
                                    isTouch: this.isTouch,
                                    changeConversationSelectedNumberAndCheckAllBool: ()=>{
                                      this.changeConversationSelectedNumberAndCheckAllBool();
                                    },
                                    smsType: this.mConversationCtrl.smsType,
                                    changeFocusAble: () => {
                                      this.textareaFocusable = false;
                                    }
                                  })
                                }
                              }
                              .accessibilityLevel('no')
                              .id(item.id.toString())
                              .alignItems(HorizontalAlign.Start)
                              .onClick(() => {
                                this.multiCheckBoxChange(item, index);
                              })

                              if ((this.mConversationCtrl.contactsNum == 1 &&
                                item.receiveState == commonData.int.SEND_MESSAGE_FAILED) ||
                                item.sendStatus == commonData.int.SEND_MESSAGE_FAILED) {
                                ReceiveFailedButton({
                                  mmsItem: item as mmsListType,
                                  contactsNum: this.mConversationCtrl.contactsNum,
                                  onReceiveFailedButtonClick: () => {
                                    if (this.mConversationCtrl.contactsNum == 1 &&
                                      item.receiveState == 2) {
                                      this.mConversationCtrl.reReceivedRcsSms(this.context,index, item.id);
                                    }
                                  }
                                }).margin(this.textDirection === 'rtl' ? { right: 8 } : { left: 8 })
                              }
                            }
                            .accessibilityLevel('no')

                            // <!--Sending time and sending status except Rcs-->
                            // <!--Sending time and sending status-->
                            Flex({
                              alignItems: ItemAlign.Center,
                              justifyContent: FlexAlign.Start,
                              space: {
                                main: LengthMetrics.vp(4)
                              }
                            }) {
                              Text($r('app.string.messageReceivingFailed'))
                                .textAlign(TextAlign.Start)
                                .fontSize(10)
                                .lineHeight(13)
                                .margin(Configuration.getLocale().dir === 'rtl' ?
                                  { top: 8 } :
                                  { top: 8 })
                                .fontColor($r('sys.color.warning'))
                                .visibility(item.receiveState == 2 ?
                                Visibility.Visible : Visibility.None)
                              Text(this.needRefreshTime ? item.detailTime : item.detailTime)
                                .textAlign(TextAlign.Start)
                                .fontSize(10)
                                .lineHeight(13)
                                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                                .margin({
                                  top: LengthMetrics.vp(8)
                                })
                                .visibility((item.sendStatus <= 1 ||
                                  item.receiveState == 2) ?
                                Visibility.Visible : Visibility.None)
                              // Card 1 or Card 2
                              if (this.cardImage &&
                              this.mConversationCtrl.isAllCardActive) {
                                Image(item.subId === common.int.SLOT_ZERO ? this.iconOfSlot0 : this.iconOfSlot1)
                                  .width(10)
                                  .height(10)
                                  .id('cardToggle')
                                  .draggable(false)
                                  .opacity(0.4)
                                  .margin({
                                    top: LengthMetrics.vp(8)
                                  })
                                  .fillColor($r('sys.color.ohos_id_color_foreground'))
                                  .onComplete(() => {
                                    this.slotId = item.subId
                                  })
                                  .accessibilityRole(AccessibilityRoleType.TEXT)
                                  .accessibilityText(AccessibilityUtil.getSimIconAccessibilityText(item.subId,
                                    getContext(this)))
                              }
                              Text($r('app.string.messageReported'))
                                .textAlign(TextAlign.Start)
                                .fontSize(10)
                                .fontColor($r('sys.color.ohos_id_color_warning'))
                                .lineHeight(13)
                                .margin({
                                  top: LengthMetrics.vp(8),
                                  end: LengthMetrics.vp(1)
                                })
                                .visibility(item.isReport ==
                                commonData.is_report.REPORT ?
                                Visibility.Visible : Visibility.None)
                              Text($r('app.string.messageReceiveFailed'))
                                .textAlign(TextAlign.Start)
                                .fontSize(10)
                                .lineHeight(13)
                                .margin({ top: 8 })
                                .fontColor($r('sys.color.warning'))
                                .visibility(item.msgState == 6 ?
                                Visibility.Visible : Visibility.None)
                            }
                            .width('70%')
                            .padding({ start: LengthMetrics.vp(12) })
                            .visibility(item?.isRcs ? Visibility.None :
                            Visibility.Visible)

                          }
                          .width('100%')
                          .alignItems(HorizontalAlign.Start)
                          //接收消息的动效
                          .transition(
                              (index ==
                                  this.mConversationCtrl.mmsList.length - 1 &&
                                  AppStorage.get('mmsReceivedToRunGeoTransition') ==
                                      true)
                                  ? TransitionEffect.translate({ y: 120 })
                                  .animation({
                                      curve: curves.interpolatingSpring(0, 1, 342,
                                          37)
                                  })
                                  .combine(TransitionEffect.OPACITY
                                      .animation({
                                          delay: 66.7,
                                          duration: 150,
                                          curve: curves.cubicBezierCurve(0.33, 0,
                                              0.67, 1),
                                      })
                                  )
                                  : TransitionEffect.IDENTITY
                          )

                          if (this.mConversationCtrl.isSelectStatus &&
                            typeof this.selectNumber === 'number') {
                            Row() {
                              Checkbox()
                                .select(this.checkBoxStatusHasChanged ?
                                  ConversationDataSource.getInstance().mmsList[index]?.isCbChecked :
                                  ConversationDataSource.getInstance().mmsList[index]?.isCbChecked)
                                .shape(CheckBoxShape.CIRCLE)
                                .selectedColor($r('sys.color.font_emphasize'))
                                .width(20)
                                .height(20)
                                .margin(2)
                                .offset({ y: this.mConversationCtrl.contactsNum > 1 ? 0 : 4 })
                                .onClick((event: ClickEvent) => {
                                  if (!ConversationDataSource.getInstance().mmsList[index]) {
                                    return;
                                  }
                                  this.mConversationCtrl.multiSelectMmsMsg(index);
                                  this.mConversationCtrl.listCheckBoxChange(index,
                                    !ConversationDataSource.getInstance().mmsList[index].isCbChecked);
                                  setTimeout(() => {
                                    AccessibilityUtil.requestFocusForAccessibility(item.id.toString()+'Checkbox');
                                  }, 50);
                                  this.changeConversationSelectedNumberAndCheckAllBool();
                                })
                                .id(item.id.toString()+'Checkbox')
                                .accessibilityLevel('yes')
                            }
                            .alignItems(VerticalAlign.Center)
                            .justifyContent(FlexAlign.Center)
                            .width(24)
                            .height(32)
                            .flexShrink(0)
                            .margin({ start: LengthMetrics.vp(12) })
                          }
                        }

                      }
                    }
                    .layoutWeight(1)
                    .padding((item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.CHATBOT_CARD &&
                      !this.mConversationCtrl.isSelectStatus) ? {
                      left: 0,
                      right: 0
                    } : {
                      left: DeviceUtil.isPC() ? 24 : this.isPad ? this.padMargin : 16,
                      right: DeviceUtil.isPC() ? 24 : this.isPad ? this.padMargin : 16
                    })
                    .width('100%')
                    .alignItems(HorizontalAlign.Center)
                    .accessibilityGroup(true, { accessibilityPreferred: true })
                  }
                  .transition(
                    TransitionEffect.asymmetric(
                      this.mConversationCtrl.isSendPicture ?
                      TransitionEffect.OPACITY.animation({ curve: Curve.Sharp, duration: 350 })
                        .combine(TransitionEffect.scale({ centerX: 0.8, centerY: 0.8 })
                          .animation({ curve: curves.interpolatingSpring(10, 1, 228, 30) }))
                        : TransitionEffect.IDENTITY,
                      TransitionEffect.OPACITY.animation({ curve: Curve.Friction, duration: 50 })
                    )
                  )
                }, (item: LooseObject, itemIndex) => (JSON.stringify(item) + itemIndex))

                // 最后一个留空白
                ListItem() {
                  Row() {
                  }
                  .width('100%')
                  .height(1)
                  .visibility(Visibility.Hidden)
                }

              }
              .accessibilityLevel("no")
              .gesture(PanGesture({ direction: PanDirection.Vertical })
                .onActionStart((event: GestureEvent) => {
                  let params: PanGestureAction = {
                    type: common.SLIDE_ACTION_TYPE.START,
                    event,
                    scroller: this.mConversationCtrl.scroller,
                    isMultipleSelectState: this.mConversationCtrl.isSelectStatus,
                    switchNumber: 0,
                    mmsList: this.conversationDataSource.mmsList
                  }
                  PanGestureUtil.panGestureAction(params)
                })
                .onActionUpdate((event: GestureEvent) => {
                  let params: PanGestureAction = {
                    type: common.SLIDE_ACTION_TYPE.UPDATE,
                    event,
                    scroller: this.mConversationCtrl.scroller,
                    isMultipleSelectState: this.mConversationCtrl.isSelectStatus,
                    switchNumber: 0,
                    mmsList: this.conversationDataSource.mmsList,
                    callback: (i: number, startCbChecked: boolean) => {
                      this.conversationDataSource.selectData(i, startCbChecked)
                      this.mConversationCtrl.gesTureListCheckBox(this.selectNumber)
                      this.changeConversationSelectedNumberAndCheckAllBool();
                    },
                    listHeight: this.listHeight,
                    scrollEndIndex: this.scrollEndIndex,
                    scrollStartIndex: this.scrollStartIndex
                  }
                  PanGestureUtil.panGestureAction(params)
                })
                .onActionEnd((event: GestureEvent) => {
                  let params: PanGestureAction = {
                    type: common.SLIDE_ACTION_TYPE.END,
                    event,
                    scroller: this.mConversationCtrl.scroller,
                    isMultipleSelectState: this.mConversationCtrl.isSelectStatus,
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
                return PanGestureUtil.gestureRecognizerJudgeBegin(event, current,
                  this.mConversationCtrl.isSelectStatus,
                  this.listWidth)
              })
              .onClick((event?: ClickEvent) => {
                if (this.isScrolling )  {
                  animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 2000 }, () => {
                    this.isScrolling = false;
                  })
                  this.isScrollingHide = false;
                }
              })
              .onTouch((event: TouchEvent) => {
                this.isTouch = true;
                if (this.isVDE && event !== undefined ) {
                  if (event.type === TouchType.Down) {
                    this.scrollingLastTouch = event.type;
                  } else if (event.type === TouchType.Up) {
                    this.scrollingLastTouch = event.type;
                  }
                }
              })
              .clipContent(ContentClipMode.SAFE_AREA)
              .margin({
                top: DeviceUtil.isPC() || this.isVDE ? 0 :  !this.isDeviceHasSim || !this.isOpenRCS ? this.topValue : 0,
                bottom: this.isPC ? 207 : this.isVDE && this.isScrolling ? 0 :
                  this.mOffsetY + this.getListMargin() + this.bottomPadding + this.locationMargin()
              })
              .chainAnimation(true)
              .backToTop(false)
              .listDirection(Axis.Vertical) // Arrange Direction
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
              .scrollBar(this.isVDE && this.isScrolling ? BarState.On : BarState.Auto)
              .onScrollIndex((start, end) => {
                this.scrollStartIndex = start;
                this.scrollEndIndex = end;
              })
              .width('100%')
              .alignRules({
                top: {
                  anchor: DeviceUtil.isPC() ? 'topbar' : '__container__',
                  align: DeviceUtil.isPC() ? VerticalAlign.Bottom : VerticalAlign.Top
                },
                left: { anchor: '__container__', align: HorizontalAlign.Start },
                bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
              })
              .onAreaChange((oldValue: Area, newValue: Area) => {
                this.messageListOnAreaChangeHeight = newValue.height;
                if (this.isFirstOnAreaChange && newValue.globalPosition.y != undefined) {
                  this.messageListPositionY = newValue.globalPosition.y as Length;
                  this.isFirstOnAreaChange = false;
                }
                if (this.isShowMmsAreaDisplay && !this.mConversationCtrl.isSelectStatus) {
                  if (newValue.globalPosition.y != undefined) {
                    this.bottomSendBarPositionY = newValue.globalPosition.y as Length;
                  }
                }
                this.changeNeedExpandSafeArea();
              })
              .id('messageList')
              .onScrollFrameBegin((offset: number, state: ScrollState) => {
                this.mConversationCtrl.yOffset = -1;
                return { offsetRemain: offset }
              })
              .animation(this.isSendingAnimate ? { curve: curves.interpolatingSpring(0, 1, 342, 37)} : null)
              .parallelGesture(
                SwipeGesture({ direction: SwipeDirection.All, speed: 1 })
                  .onAction((event: GestureEvent) => {
                    this.controller.stopEditing();
                    if (this.currentIndex === 2) {
                      AppStorage.setOrCreate('stopRecordTime', new Date().getTime());
                    }
                    animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37) }, () => {
                      this.isShowEmoji = false;
                      this.showMMContentPicker = false;
                      this.mOffsetY = 0;
                    })
                  })
              )
              .allowDrop(null)
              .friction(1)
              .onScrollStart(() => {
                this.isTouch = true;
                this.scrollingLastTouch = TouchType.Move;
                this.isFirstScrolling = true;
                this.isScrollingStart = true;
                if (!this.isVDE) {
                  this.isScrolling = true;
                }
                this.isAtMsgListBottom = false;
                this.isAtMsgListTop = false;
              })
              .contentStartOffset(this.isVDE && !this.isScrollingHide ? 56 : 0)
              .onReachStart(() => {
                if (this.isVDE) {
                  if (this.initialCurrentYOffset === 0 && this.mConversationCtrl.scroller.currentOffset()?.yOffset === -56) {
                    this.ableSlips = false;
                  }
                  if (this.ableSlips && this.isScrolling && (new Date().getTime() - this.isScrollingTime > 100)) {
                    animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 1000 }, () => {
                      this.isScrolling = false;
                      this.mConversationCtrl.scroller.scrollEdge(Edge.Top)
                    })
                    this.isScrollingTime = new Date().getTime();
                    this.isScrollingHide = false;
                  }
                }
                this.isAtMsgListTop = true;
              })
              .onScrollStop(() => {
                this.initialCurrentYOffset = this.mConversationCtrl.scroller.currentOffset()?.yOffset;
                if (!this.isVDE) {
                  this.isScrolling = false;
                }
              })
              .onReachEnd(() => {
                // yOffset > 0 不用管
                if (this.isVDE && this.listLength != this.mConversationCtrl.mmsList.length) {
                  HiLog.i(TAG, 'listLength is : ' + this.listLength + ' ,length: ' + this.mConversationCtrl.mmsList.length)
                  this.isScrollingStart = false;
                }
                if (this.isVDE && !this.isScrollingStart && this.keyboardHeight == 0 && !this.isShowEmoji) {
                  this.listLength  = this.mConversationCtrl.mmsList.length;
                  if (this.mConversationCtrl.scroller.currentOffset()?.yOffset <= 56) {
                    this.ableSlips = false;
                    this.isScrolling = false;
                    this.isScrollingHide = false;
                  } else {
                    this.ableSlips = true;
                    this.mConversationCtrl.scroller.scrollEdge(Edge.End)
                  }
                  HiLog.i(TAG,'onReachEnd ableSlips is '+ this.ableSlips + ' yOffset is :' +
                  this.mConversationCtrl.scroller.currentOffset().yOffset);
                }
                if (this.isVDE && this.ableSlips && this.isScrolling && (new Date().getTime() - this.isScrollingTime > 100)) {
                  animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 2000 }, () => {
                    HiLog.i(TAG,'conversationList onReachEnd');
                    this.isScrolling = false;
                    this.mConversationCtrl.scroller.scrollEdge(Edge.End)
                  })
                  this.isScrollingTime = new Date().getTime();
                  this.isScrollingHide = false;
                }
                this.initialCurrentYOffset = this.mConversationCtrl.scroller.currentOffset()?.yOffset;
                this.isAtMsgListBottom = true;
                this.isAtMsgListTop = false;
              })
              .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
                if (scrollState === ScrollState.Scroll) {
                  this.isTouch = true;
                }
                if (scrollState === ScrollState.Scroll && this.isVDE && (new Date().getTime() - this.isScrollingTime > 100) &&
                this.ableSlips && !this.mConversationCtrl.isSelectStatus) {
                  // >0 向下滑动
                  if (scrollOffset != 0 && !this.isScrolling &&
                    Math.abs(this.initialCurrentYOffset - this.mConversationCtrl.scroller.currentOffset()?.yOffset) >= 26) {
                    animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30), duration: 2000 }, () => {
                      HiLog.i(TAG, 'onDidScroll scrollOffset != 0 :' + scrollOffset);
                      this.isScrolling = true;
                    })
                    this.isScrollingHide = true;
                  }
                  this.isScrollingTime = new Date().getTime();
                }
              })
              if (this.isShowMmsAreaDisplay && !this.mConversationCtrl.isSelectStatus) {
                Column() {
                  MMAttachAreaDisplay({
                    textareaFocusable: $textareaFocusable,
                    isDraft: this.isDraft,
                    addButtonId: 'add_attachment_button_id'
                  })
                }
                .width('100%')
                .alignRules({
                  left: { anchor: '__container__', align: HorizontalAlign.Start },
                  bottom: { anchor: 'inputBoxBottom', align: VerticalAlign.Top }
                })
                .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
                .translate({ y: this.isVDE && this.isScrolling ? this.mOffsetY + this.getListMargin() : 0 })
                .opacity(this.isVDE && this.isScrolling ? 0 : 1)
                .animation({ curve: curves.interpolatingSpring(0, 1, 342, 37) })
                .onAreaChange((oldValue: Area, newValue: Area) => {
                  if (newValue.height) {
                    this.attachmentHeight = newValue.height as number
                  }
                })
              }
              if (this.isPCEmojiVisible && DeviceUtil.isPC()) {
                Column() {
                  SendEmoji({
                    ctrl: this.mConversationCtrl,
                    mIsNew: false,
                    mCreateNewConversationViewModle: new CreateNewConversationViewModle(),
                    controller: this.controller,
                  })
                }
                .width(370)
                .height(356)
                .position({ bottom: 210, left: 24 })
                .onTouch((event: TouchEvent)=>{
                  event.stopPropagation()
                })
                .onMouse((event: MouseEvent)=>{
                  if (event.action === MouseAction.Release) {
                    event.stopPropagation()
                  }
                })
              }
              if (DeviceUtil.isPC()) {
                Stack(({ alignContent: Alignment.Bottom })) {
                  Divider()
                    .height($r('app.float.settings_divider_strokeWidth'))
                    .color($r('sys.color.comp_divider'))
                    .position({ bottom: 206 })
                    .width('100%')
                  Column() {
                    Row() {
                      Button({ type: ButtonType.Normal, stateEffect: true }) {
                        SymbolGlyph($r('sys.symbol.face_smiling'))
                          .fontColor([$r('sys.color.ohos_id_color_primary')])
                          .fontSize('24vp')
                          .draggable(false)
                          .id('listMoreButton')
                          .width(24)
                          .height(24)
                      }
                      .width(40)
                      .height(40)
                      .backgroundColor(this.isPCEmojiVisible ? $r('sys.color.ohos_id_color_button_normal') :
                      Color.Transparent)
                      .draggable(false)
                      .borderRadius(5)
                      .onClick(() => {
                        this.isPCEmojiVisible = !this.isPCEmojiVisible
                      })
                      .onTouch((event: TouchEvent)=>{
                        event.stopPropagation()
                      })
                      .onMouse((event: MouseEvent)=>{
                        if (event.action === MouseAction.Release) {
                          event.stopPropagation()
                        }
                      })
                    }
                    .justifyContent(FlexAlign.Start)
                    .alignItems(VerticalAlign.Center)
                    .height(40)
                    .width('100%')
                    .padding({ left: 24 })
                    Row() {
                      TextArea({
                        placeholder: '',
                        text: this.mConversationCtrl?.textValue || '',
                        controller: this.controller,
                      })
                        .padding({ left: 24, right: 24 })
                        .enableKeyboardOnFocus(false)
                        .height('106vp')
                        .width('100%')
                        .placeholderColor($r('sys.color.font_secondary'))
                        .caretColor($r('sys.color.font_emphasize'))
                        .defaultFocus(this.isFocus())
                        .placeholderFont({
                          size: this.getMaxFontSizeScale() * 16 + 'vp',
                          weight: FontWeight.Regular
                        })
                        .fontSize(this.getMaxFontSizeScale() * 16 + 'vp')
                        .lineHeight(this.getMaxFontSizeScale() * 21 + 'vp')
                        .fontColor($r('sys.color.ohos_id_color_text_primary'))
                        .fontWeight(FontWeight.Regular)
                        .fontFamily('HarmonyHeiTi')
                        .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
                        .id(Constant.MMS_INPUT_TEXTAREA_Id)
                        .focusable(this.textareaFocusable || this.isPCEmojiVisible)
                        .enablePreviewText(false)
                        .constraintSize({ minHeight: INPUT_MIN_HEIGHT })
                        .onChange(value => {
                          if (value.length > TEXT_MAX_LENGTH) {
                            this.mConversationCtrl.showToast($r('app.string.text_input_limit'))
                            this.mConversationCtrl.textValue = value;
                            this.mConversationCtrl.textValue =
                              this.mConversationCtrl.textValue.substring(0, TEXT_MAX_LENGTH);
                          } else {
                            this.mConversationCtrl.changeValue(value);
                           if (this.mConversationCtrl.isEmoChange) {
                              this.controller.caretPosition(this.mConversationCtrl.caretPosition)
                              this.mConversationCtrl.caretPosition = this.controller.getCaretOffset().index;
                              this.mConversationCtrl.isEmoChange = false;
                            }
                            this.mConversationCtrl.handleProtocolChange(value);
                          }
                          // 写信息——输入普通文字打点
                          writeEventParams.INPUT_STATE = 1;
                          DotUtil.getInstance().reportEvent(writeEventParams,
                            dotCommon.eventName.WRITE_SMS_EVENT);
                          this.calculateTextInputCount();
                          this.measureTextAreaSize();
                          if (this.isShowEmoji) {
                            this.controller.caretPosition(this.mConversationCtrl.newEmojiLength +
                            this.mConversationCtrl.caretPosition)
                          }
                        })
                        .onClick(() => {
                          this.mCreateNewConversationViewModle.caretPosition = this.controller.getCaretOffset().index;
                          if (!StringUtil.isEmpty(this.accessibilitySwitch)) {
                            if (this.accessibilitySwitch ===
                            Constant.ACCESSIBILITY_SCREEN_READER_SWITCH_OPEN) {
                              this.focusMethod();
                            }
                          }
                        })
                        .onTouch((event) => {
                          if (DeviceUtil.isFloatingScreen() &&
                            (this.isShowEmoji || this.showMMContentPicker)) {
                            this.isShowEmoji = false;
                            this.showMMContentPicker = false;
                          }
                          if (!StringUtil.isEmpty(this.accessibilitySwitch)) {
                            if (this.accessibilitySwitch !==
                            Constant.ACCESSIBILITY_SCREEN_READER_SWITCH_OPEN) {
                              if (event === undefined) {
                                HiLog.e(TAG, 'event is undefined in onTouch event');
                                return;
                              }
                              HiLog.i(TAG, 'event.type: ' + event.type);
                              if (event.type === TouchType.Up) {
                                this.focusMethod();
                              }
                            }
                          }
                        })
                        .onFocus(async () => {
                          await this.receiveCtrl.checkReceive(
                            (receiverData: BaseItemType) => {
                              this.mConversationCtrl
                                .setReceiveContactValue(this.context, receiverData);
                            });
                          this.receiveCtrl.myText = common.STR.EMPTY_STR;
                          if (this.isVDE) {
                            this.hideVdeTitle = true;
                          }
                        })
                        .onBlur(() => {
                          if (this.isVDE) {
                            this.hideVdeTitle = false;
                          }
                        })
                        .allowDrop([UTD.UniformDataType.PLAIN_TEXT,
                          UTD.UniformDataType.IMAGE])
                        .onDrop((event?: DragEvent, extraParams?: string) => {
                          event?.setResult(DragResult.DRAG_SUCCESSFUL)
                          HiLog.i(TAG, `TextArea onDrop DragResult:` + event?.getResult());
                          let dragData: UnifiedData
                          dragData = (event as DragEvent).getData() as UnifiedData;
                          if (dragData === undefined ||
                            dragData.getRecords() === undefined) {
                            HiLog.i(TAG, 'dragData or dragData.getRecords is undefined')
                            return;
                          }
                          let dragText = DragUtil.getInstance().dragHandle(dragData, this.context);
                          this.mConversationCtrl.textValue =
                            StringUtil.isEmpty(dragText) ? this.mConversationCtrl.textValue : dragText;
                        })
                    }
                    .alignItems(VerticalAlign.Top)
                    .justifyContent(FlexAlign.Start)
                    .width('100%')
                    .height('106vp')
                    Button($r('app.string.transmit_send'), { type: ButtonType.Normal, stateEffect: true })
                      .borderRadius(8)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .width(120)
                      .height(40)
                      .onClick(() => {
                        console.log('ButtonType.Normal')
                      })
                      .position({ bottom: 16, right: 24 })
                      .enabled((this.mConversationCtrl.canSendMessage && !this.isAirPlaneMode &&
                      this.haveSimCard && !this.mConversationCtrl.isNoCardActive &&
                      this.mConversationCtrl.canSendMmsMessage) ||
                        (!(this.mConversationCtrl.textValue === '') &&
                          !this.conListCtrl.isOsAccountConstraintEnabled &&
                        DeviceUtil.isSubDeviceWithConnected(getContext(this)) && !this.isAirPlaneMode))
                      .onClick(() => {
                        HiLog.iw(TAG, 'sendMessage: ' + this.mConversationCtrl.canSendMessage);
                        let dsdaState =
                          this.mConversationCtrl.shouldEnableSendButtonForSlot(this.simSlotId);
                        if (this.mConversationCtrl.isCall()) {
                            if (!dsdaState) {
                            this.mConversationCtrl.showToast($r('app.string.unsupport_sim_card_content',
                              this.mConversationCtrl.callingSlotId + 1, this.simSlotId + 1));
                            return;
                          }
                        }
                        //  Click Send.
                        if (this.mConversationCtrl.isRcsMms) {
                          if (this.mConversationCtrl.mAttachAreaCtrl.mmDisplaySource.length > 0 &&
                            this.rcsInfoStatus != Conversation.RCS_INFO_STATUS &&
                            this.isWifiConnected != '1') {
                            this.wifiNoticeController.open();
                          } else {
                            this.sendMeaasgeWithRCS(true);
                          }
                        } else {
                          this.sendMeaasgeWithRCS(false);
                        }
                        this.changeMenuItemsValue();
                        this.changeJumpContactButton();
                      })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .height(202)
                  .id('pc_bottom_input')
                  .position({ bottom: 0 })
                }
                .width('100%')
                .height(207)
                .id('pc_bottom_stack')
                .alignRules({
                    top: { anchor: 'messageList', align: VerticalAlign.Bottom },
                    left: { anchor: '__container__', align: HorizontalAlign.Start },
                })
              }
              // 手机会话详情页，服务号端口不显示输入框，isSelectStatus控制服务号端口时底部的ToolBar显示，showSmartMmsMenuStatus控制菜单显示
              if (!DeviceUtil.isPC()) {
                // Input box at the bottom
                Stack(({ alignContent: Alignment.Bottom })) {
                  // More options at the bottom
                  if (this.mConversationCtrl.isSelectStatus && !this.mConversationCtrl.hasDetailDelete &&
                    !DeviceUtil.isPC()) {
                    ToolBar({
                      toolBarList: this.toolBarList,
                      activateIndex: this.mConversationCtrl.isMessageCheckAll ? (this.isSelectDelete ? 1 : 3) : -1,
                      toolBarModifier: this.toolBarModifier,
                      dividerModifier: this.dividerModifier,
                    })
                      .bindMenu(this.isMoreMenuShown, MenuBuilder(this.context, {
                        mmsListItem: this.mConversationCtrl.mmsList[this.mConversationCtrl.mmsIndex],
                        mConversationCtrl: this.mConversationCtrl,
                        textDirection: this.textDirection,
                        cancelMultiStatusAction: () => {
                          this.cancelMultiStatus();
                        },
                        updateBackIconAction: () => {
                          this.updateBackIcon(false);
                        },
                        showDialogController: () => {
                          this.dialogController.open();
                        },
                        showVcardDetailsDialogController: () => {
                          this.mmcheckVcardDialog.open();
                        },
                        showSaveVcardDialogController: () => {
                          this.mmSaveVcardDialog.open();
                        }
                      }),
                        {
                          placement: Placement.TopRight,
                          offset: { x: -16, y: 4 },
                          onDisappear: () => {
                            this.isMoreMenuShown = false;
                          }
                        }
                      )
                      .margin({ bottom: this.bottomPadding })
                      .padding({ top: '3vp' })
                      .width('100%')
                      .onAreaChange((oldValue: Area, newValue: Area) => {
                        HiLog.i(TAG, 'newValue.globalPosition.y:' + newValue.globalPosition.y)
                        if (newValue.globalPosition.y != undefined) {
                          this.bottomSendBarPositionY = newValue.globalPosition.y as Length;
                        }
                        this.changeNeedExpandSafeArea();
                      })
                  }

                  // <!--Bottom Send Bar-->
                  if (!this.mConversationCtrl.isSelectStatus) {
                    // <!--Left More and Full Screen Display-->
                    Column() {
                      //input field
                      Column() {
                        Row() {

                        if (!this.isDisplayFixedMenu) {
                          Button() {
                            SymbolGlyph(this.isShowEmoji ? $r('sys.symbol.keyboard') : $r('sys.symbol.face_smiling'))
                              .width(24)
                              .height(24)
                              .visibility(Visibility.Visible)
                              .key('emojiButton')
                              .focusable(true)
                              .draggable(false)
                              .fontSize('24vp')
                              .fontColor([$r('sys.color.ohos_id_color_primary')])
                              .renderGroup(true)
                          }
                          .onClick(() => {
                            if (DoubleClickUtil.isFastClick(Constant.CLICK_EMOJI_BUTTON_TIME_INTERVAL)) {
                              HiLog.i(TAG, 'fastClick conversation')
                              return;
                            }
                            this.mConversationCtrl.caretPosition = this.controller.getCaretOffset().index;
                            if (this.mConversationCtrl.isRcsMms) {
                              this.isVoicing = false;
                              HiLog.i(TAG, 'this.isRcsMms is true');
                              this.MMPictureController.isRcs = true;
                            } else {
                              this.MMPictureController.isRcs = false;
                            }
                            if (!this.isShowEmoji) {
                              this.mEmojiOffsetY = 0;
                              if (this.showMMContentPicker) {
                                this.showMMContentPicker = false;
                                this.tabUtil.animationIterations = 0;
                              }
                              // The requestFocus is not always very reliable.
                              // Call hideTextInput make double insurance.
                              animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37) }, () => {
                                this.isShowEmoji = true;
                                if (this.isVDE) {
                                  this.hideVdeTitle = true;
                                }
                                //表情区显示，关闭键盘。输入框高度为表情区高度
                                this.mOffsetY = this.isVDE ? 192 :
                                  (this.splitInfoModel.isEmojiLow ? MIN_MM_PICKER_HEIGHT : EMOJI_HEIGHT);
                                this.mConversationCtrl.scrollToEnd();
                             })
                              focusControl.requestFocus('emojiButton');
                              if (canIUse('SystemCapability.MiscServices.InputMethodFramework')) {
                                inputMethod.getController().hideTextInput();
                              }
                            } else {
                              this.getUIContext().getFocusController().clearFocus();
                              animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37) }, () => {
                                this.isShowEmoji = false;
                                this.textareaFocusable = true;
                                if (DeviceUtil.isPC()) {
                                  this.mOffsetY = 0;
                                }
                              })
                              focusControl.requestFocus(Constant.MMS_INPUT_TEXTAREA_Id);
                              if (DeviceUtil.isFloatingScreen() && this.isShowEmoji) {
                                this.isShowEmoji = false;
                              }
                            }
                            // textarea只有获焦时才显示光标，表情键盘和输入法都要请求组件的焦点
                            focusControl.requestFocus(Constant.MMS_INPUT_TEXTAREA_Id);
                          })
                          .accessibilityText(this.isShowEmoji ?
                          getContext(this).resourceManager.getStringSync($r('app.string.open_keypad_button').id) :
                          getContext(this).resourceManager.getStringSync($r('app.string.emoticon_button').id))
                          .align(Alignment.Center)
                          .type(ButtonType.Normal)
                          .margin({ bottom: 2 })
                          .actionButtonPressStyles()
                          .width('40vp')
                          .height('48vp');
                        }
                          if (!this.isDisplayFixedMenu) {
                            Blank().width(8)
                          }
                          if (!this.isDisplayFixedMenu) {
                          Row() {
                            if (this.isAllCardCanSend) {
                              MultiSimCardMenu({
                                slotId: this.slotId,
                                onDestinationShow: this.onDestinationShow,
                                resetValues: () => {
                                  if (this.mConversationCtrl) {
                                    this.mConversationCtrl.isChangeInputPlaceholder =
                                      false;
                                  }
                                }
                              })
                                .padding(Configuration.getLocale().dir === 'rtl' ?
                                  { right: $r('app.float.id_card_margin_xxl') } :
                                  { left: $r('app.float.id_card_margin_xxl') })
                            }
                            Stack({ alignContent: Alignment.Center }) {
                                if (!this.isSendingAnimate) {
                                    //伪共享动画使用的视图。1.用于定位动画起始位置2.动画过程中下树导致失焦
                                    TextArea({ text: this.mConversationCtrl?.textValue || '' })
                                        .geometryTransition(`geometry_transition_id`,
                                            { follow: false })
                                        .transition(TransitionEffect.OPACITY)
                                        .opacity(0)
                                        .fontSize(this.getMaxFontSizeScale() * 16 + 'vp')
                                        .lineHeight(this.getMaxFontSizeScale() * 21 + 'vp')
                                        .fontWeight(FontWeight.Regular)
                                        .fontFamily('HarmonyHeiTi')
                                        .accessibilityLevel('no')
                                        .position({
                                            y: this.isShowAnimateView ? 0 :
                                                this.animatingTextHeight - this.textHeight
                                        })
                                      .accessibilityLevel('no')
                                      .enableKeyboardOnFocus(false)
                                }
                              TextArea({
                                placeholder: this.getPlaceholder(),
                                text: this.mConversationCtrl?.textValue || '',
                                controller: this.controller,
                              })
                                .align(Alignment.Center)
                                .placeholderColor($r('sys.color.font_secondary'))
                                .caretColor($r('sys.color.font_emphasize'))
                                .defaultFocus(this.isFocus())
                                .enableKeyboardOnFocus(this.isShowEmoji ? false : true)
                                .placeholderFont({
                                  size: this.getMaxFontSizeScale() * 16 + 'vp',
                                  weight: FontWeight.Regular
                                })
                                .fontSize(this.getMaxFontSizeScale() * 16 + 'vp')
                                .lineHeight(this.getMaxFontSizeScale() * 21 + 'vp')
                                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                                .fontWeight(FontWeight.Regular)
                                .fontFamily('HarmonyHeiTi')
                                .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
                                .id(Constant.MMS_INPUT_TEXTAREA_Id)
                                .opacity(this.isShowAnimateView ? 1 : 1)
                                .focusable(this.textareaFocusable || this.isShowEmoji)
                                .enablePreviewText(true)
                                .constraintSize({ minHeight: INPUT_MIN_HEIGHT })
                                .onChange(value => {
                                  this.handleTextValueChange(value)
                                })
                                .onClick(() => {
                                  this.isInputDot = this.mConversationCtrl.textValue.length !== 0;
                                  if (!StringUtil.isEmpty(this.accessibilitySwitch)) {
                                    if (this.accessibilitySwitch ===
                                    Constant.ACCESSIBILITY_SCREEN_READER_SWITCH_OPEN) {
                                      this.focusMethod();
                                    }
                                  }
                                })
                                .onTouch((event) => {
                                  // Long press or click will focus the TextArea
                                  // and open Keyboard.
                                  // Therefore, the OnClick logic is moved to the TouchUp
                                  // event.
                                  if (DeviceUtil.isFloatingScreen() &&
                                    (this.isShowEmoji || this.showMMContentPicker)) {
                                    this.isShowEmoji = false;
                                    this.showMMContentPicker = false;
                                  }
                                  if (!StringUtil.isEmpty(this.accessibilitySwitch)) {
                                    if (this.accessibilitySwitch !==
                                    Constant.ACCESSIBILITY_SCREEN_READER_SWITCH_OPEN) {
                                      if (event === undefined) {
                                        HiLog.e(TAG, 'event is undefined in onTouch event');
                                        return;
                                      }
                                      HiLog.i(TAG, 'event.type: ' + event.type);
                                      if (event.type === TouchType.Up) {
                                        this.focusMethod();
                                      }
                                    }
                                  }
                                })
                                .onFocus(async () => {
                                  this.isFocusOnTextAreaInNonPCDevice = true;
                                  await this.receiveCtrl.checkReceive(
                                    (receiverData: BaseItemType) => {
                                      this.mConversationCtrl
                                        .setReceiveContactValue(this.context, receiverData);
                                    });
                                  this.receiveCtrl.myText = common.STR.EMPTY_STR;
                                  if (this.isVDE) {
                                    this.hideVdeTitle = true;
                                  }
                                })
                                .onBlur(() => {
                                  this.isFocusOnTextAreaInNonPCDevice = false;
                                  if (this.isVDE) {
                                    this.hideVdeTitle = false;
                                  }
                                })
                                .allowDrop([UTD.UniformDataType.PLAIN_TEXT,
                                  UTD.UniformDataType.IMAGE])
                                .onDrop((event?: DragEvent, extraParams?: string) => {
                                  event?.setResult(DragResult.DRAG_SUCCESSFUL)
                                  HiLog.i(TAG, `TextArea onDrop DragResult:` + event?.getResult());
                                  let dragData: UnifiedData
                                  dragData = (event as DragEvent).getData() as UnifiedData;
                                  if (dragData === undefined ||
                                    dragData.getRecords() === undefined) {
                                    HiLog.i(TAG, 'dragData or dragData.getRecords is undefined')
                                    return;
                                  }
                                  let dragText = DragUtil.getInstance().dragHandle(dragData, this.context);
                                  this.mConversationCtrl.textValue =
                                    StringUtil.isEmpty(dragText) ? this.mConversationCtrl.textValue : dragText;
                                })
                            }
                            .constraintSize({
                              minHeight: this.getMaxFontSizeScale() * INPUT_MIN_HEIGHT,
                              maxHeight: this.isVDE ? this.inputVdeMaxHeight : this.splitInfoModel.inputMaxheight
                            })
                            .height(this.inputCurrentheight)
                            .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
                              this.isFirstChangeTextSize = this.textAreaWidth === 0;
                              if (this.isFirstChangeTextSize) {
                                this.textAreaWidth = Number(newValue.width);
                                this.measureTextAreaSize();
                                setTimeout(() => {
                                  this.isFirstChangeTextSize = false;
                                }, 100)
                              } else if (this.textAreaWidth !== Number(newValue.width)) {
                                this.textAreaWidth = Number(newValue.width);
                                this.measureTextAreaSize();
                              }
                            })
                          }
                          .onAreaChange((oldValue: Area, newValue: Area) => {
                            this.isTextAreaChange = true;
                            if (!this.mConversationCtrl.isRcsMms || !this.isVoicing) {
                              this.textHeight = Math.floor(Number(newValue.height));
                            }
                          })
                          .backgroundColor($r('sys.color.comp_background_tertiary'))
                          .padding(Configuration.getLocale().dir === 'rtl' ?
                            {
                              left: this.isAllCardCanSend ? 56 : 0
                            } :
                            {
                              right: this.isAllCardCanSend ? 56 : 0
                            })
                          .margin({ top: 6, bottom: INPUT_MARGIN_BOTTOM })
                          .borderRadius(20)
                          .width('100%')
                          .layoutWeight(1)
                          .constraintSize({ minHeight: INPUT_MIN_HEIGHT })
                          .visibility(!this.mConversationCtrl.isRcsMms ? Visibility.Visible :
                            (!this.isVoicing ? Visibility.Visible : Visibility.None))

                          Blank().width(8)
                          Button() {
                            SymbolGlyph($r('sys.symbol.plus_circle'))
                              .id('show_mmContent_picker_id')
                              .key('icPublicAddNormBtn')
                              .focusable(true)
                              .enabled(this.isWifiOnlyTablet || this.isSubDeviceWithConnected ? false : true)
                              .width(24)
                              .height(24)
                              .draggable(false)
                              .fontSize('24vp')
                              .fontColor([$r('sys.color.ohos_id_color_primary')])
                              .renderGroup(true)
                          }
                          .visibility(this.isVDE ? Visibility.None :
                            this.isWifiOnlyTablet || this.isSubDeviceWithConnected ? Visibility.None : Visibility.Visible)
                          .onClick(() => {
                            HiLog.iw(TAG, 'enter click event');
                            if (this.splitInfoModel.isSmall) {
                              Prompt.showToast({
                                message: $r('app.string.split_screen_prompt'),
                                duration: 2000
                              });
                              return;
                            }
                            if (this.mConversationCtrl.isRcsMms) {
                              HiLog.i(TAG, 'this.isRcsMms is true');
                              this.MMPictureController.isRcs = true;
                            } else {
                              this.MMPictureController.isRcs = false;
                            }
                            if (this.isVoicing) { //点击加号按钮时，如果当前显示增强信息的“按住说话”按钮，则隐藏该按钮
                              this.isVoicing = false;
                            }
                            if (this.showMMContentPicker) {
                              HiLog.iw(TAG, 'this.showMMContentPicker is true');
                              this.tabUtil.animationIterations = 0;
                              this.textareaFocusable = true;
                              focusControl.requestFocus(Constant.MMS_INPUT_TEXTAREA_Id);
                            } else {
                              if (!this.getAttachmentButtonDisplay()) {
                                this.mConversationCtrl.showToast($r('app.string.attachment_limit_one'))
                                return;
                              }
                              HiLog.iw(TAG, 'this.showMMContentPicker is false');
                              if (this.isShowEmoji) {
                                this.isShowEmoji = false;
                              }
                              this.mMContentPickerOffsetY = 0;
                              focusControl.requestFocus('icPublicAddNormBtn');
                              animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37) }, () => {
                                this.showMMContentPicker = true;
                                //附件区显示，关闭键盘。输入框高度为附件区高度
                                if (this.mConversationCtrl?.isRcsMms) {
                                                    this.mOffsetY =
                                                      this.splitInfoModel.isSmall ? this.heightMMContentPicker :
                                                        RCS_MM_PICKER_HEIGHT;
                                } else {
                                  this.mOffsetY = this.mmsPickerHeight + this.attachmentBottomHeight;
                                }
                                  this.mConversationCtrl.scrollToEnd();
                              })
                              this.tabUtil.animationIterations = 0;
                              this.textareaFocusable = false;
                            }
                            // 写信息——添加附件打点
                            DotUtil.getInstance()
                              .reportEvent(writeEventParams, dotCommon.eventName.WRITE_ADD_ATTACHMENTS);
                          })
                          .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.add_attachment_button').id))
                          .id('add_attachment_button_id')
                          .enabled(!this.splitInfoModel.isSmall)
                          .opacity(this.getAttachmentButtonDisplay() ? 1.0 : 0.4)
                          .type(ButtonType.Normal)
                          .align(Alignment.Center)
                          .margin({ bottom: 2 })
                          .actionButtonPressStyles()
                          .width('40vp')
                          .height('48vp')

                          // <!--send-->
                          Stack({ alignContent: Alignment.Top }) {
                            Row() {
                              SymbolGlyph($r('sys.symbol.arrow_up_circle_fill'))
                                .width(24)
                                .height(24)
                                .renderGroup(true)
                                .draggable(false)
                                .id('sendButton')
                                .fontSize('24vp')
                                .fontColor([$r('app.color.brand'), $r('sys.color.white')])
                                .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
                                .opacity((this.mConversationCtrl.canSendMessage &&
                                  !this.isAirPlaneMode && this.haveSimCard &&
                                this.mConversationCtrl.canSendMmsMessage &&
                                  !this.mConversationCtrl.isNoCardActive) ||
                                  (!(this.mConversationCtrl.textValue === '') &&
                                  !this.conListCtrl.isOsAccountConstraintEnabled &&
                                  DeviceUtil.isSubDeviceWithConnected(getContext(this)) && !this.isAirPlaneMode) ?
                                  1.0 : 0.4)
                                .enabled(this.mConversationCtrl.canSendMessage &&
                                  !this.isAirPlaneMode && this.haveSimCard &&
                                  !this.mConversationCtrl.isNoCardActive &&
                                this.mConversationCtrl.canSendMmsMessage ||
                                  (!(this.mConversationCtrl.textValue === '') &&
                                  DeviceUtil.isSubDeviceWithConnected(getContext(this)) && !this.isAirPlaneMode))
                            }.visibility(this.isVoicing && this.isVDE ? Visibility.None : Visibility.Visible)
                            .width(40)
                            .height('100%')
                            .justifyContent(FlexAlign.Center)

                            if (!this.mConversationCtrl.isRcsMms) {
                              Row() {
                                Text(this.attachmentSizeDesc)
                                  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                                  .fontSize('8vp')
                                  .textAlign(TextAlign.Center)
                                  .maxLines(1)
                                  .visibility((this.isShowMmsAreaDisplay || this.isInput) ?
                                  Visibility.Visible : Visibility.None)
                              }
                              .constraintSize({
                                minWidth: '40vp',
                                maxWidth: '68vp'
                              })
                              .height('11vp')
                              .justifyContent(FlexAlign.Center)
                            }
                          }
                          .enabled((this.mConversationCtrl.canSendMessage && !this.isAirPlaneMode &&
                          this.haveSimCard && !this.mConversationCtrl.isNoCardActive &&
                          this.mConversationCtrl.canSendMmsMessage) ||
                            (!(this.mConversationCtrl.textValue === '') &&
                            !this.conListCtrl.isOsAccountConstraintEnabled &&
                            DeviceUtil.isSubDeviceWithConnected(getContext(this)) && !this.isAirPlaneMode))
                          .onClick(() => {
                            HiLog.i(TAG, 'sendMessage: ' + this.mConversationCtrl.canSendMessage);
                            let dsdaState =
                              this.mConversationCtrl.shouldEnableSendButtonForSlot(this.simSlotId);
                            if (this.mConversationCtrl.isCall()) {
                              if (!dsdaState) {
                                this.mConversationCtrl.showToast($r('app.string.unsupport_sim_card_content',
                                  this.mConversationCtrl.callingSlotId + 1, this.simSlotId + 1));
                                return;
                              }
                            }
                            //  Click Send.
                            if (this.mConversationCtrl.isRcsMms) {
                              if (this.mConversationCtrl.mAttachAreaCtrl.mmDisplaySource.length > 0 &&
                                this.rcsInfoStatus != Conversation.RCS_INFO_STATUS &&
                                this.isWifiConnected != '1') {
                                this.wifiNoticeController.open();
                              } else {
                                  this.sendMeaasgeWithRCS(true);
                                if (this.mConversationCtrl.mAttachAreaCtrl.mmDisplaySource.length === 0) {
                                  this.controller.deleteText();
                                }
                              }
                            } else {
                              this.audioPlayerService.stopAudio();
                                this.sendMeaasgeWithRCS(false);
                                this.controller.deleteText()
                            }
                            this.changeMenuItemsValue();
                            this.changeJumpContactButton();
                            this.controller.clearPreviewText();
                          })
                          .accessibilityText(getContext(this)
                            .resourceManager
                            .getStringSync($r('app.string.send_button').id))
                          .accessibilityRole(AccessibilityRoleType.BUTTON)
                          .accessibilityDescription((this.mConversationCtrl.canSendMessage && !this.isAirPlaneMode &&
                          this.haveSimCard && !this.mConversationCtrl.isNoCardActive &&
                          this.mConversationCtrl.canSendMmsMessage) ?
                            '' : getContext(this).resourceManager.getStringSync($r('app.string.not_clickable').id))
                          .margin({ bottom: 2 })
                          .actionButtonPressStyles()
                          .height('48vp')
                      }
                        }
                        .padding({
                          left: this.mConversationCtrl.isSelectStatus && !this.mConversationCtrl.hasDetailDelete ? 0 :
                            this.isPad ?
                              this.padMargin - 8 :
                            $r('app.float.settings_items_margin_top'),
                          right: this.isDisplayFixedMenu ? 0 :
                            (this.mConversationCtrl.isSelectStatus && !this.mConversationCtrl.hasDetailDelete ? 0 :
                              this.isPad ?
                                this.padMargin - 8 : $r('app.float.settings_items_margin_top'))
                        })
                        .width('100%')
                        .alignItems(VerticalAlign.Bottom)
                        }
                      }
                    .margin({ bottom: this.mOffsetY + this.bottomPadding })
                    .animation({
                      duration: 300,
                      curve: curves.interpolatingSpring(0, 1, 342, 37),
                    })
                    .constraintSize({ minHeight: 52 })
                    .onAreaChange((oldValue: Area, newValue: Area) => {
                        if (newValue.globalPosition.y != undefined) {
                            this.bottomSendBarPositionY = newValue.globalPosition.y as Length;
                        }
                        this.changeNeedExpandSafeArea();
                    })
                    // attachment function button area
                    if (this.showMMContentPicker) {
                      Row() {
                        MMTabs({
                          fullHeightMMPicker: $fullHeightMMPicker,
                          heightMMContentPicker: $heightMMContentPicker,
                          topMMContentPicker: $topMMContentPicker,
                          textareaFocusable: $textareaFocusable,
                          showMMContentPicker: $showMMContentPicker,
                          currentIndex: $currentIndex,
                          recorderPermission: $recorderPermission,
                          picturePermission: $picturePermission,
                          onTextValueChange: (value) => {
                            if (!StringUtil.isEmpty(value)) {
                              value = this.mConversationCtrl.textValue + value
                              this.handleTextValueChange(value)
                            }
                            this.focusMethod();
                          },
                        }).backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
                      }
                      .visibility(Visibility.Visible)
                      .padding({ top: -8 })
                      .height(this.mmsPickerHeight)
                      .margin({
                        bottom: this.mMContentPickerOffsetY + this.bottomPadding + this.attachmentBottomHeight
                      })
                      .width('100%')
                      .id('bottomTabs')

                      if (this.attachmentBottomHeight !== 0) {
                        Row() {
                          Text($r('app.string.penglai_limit_function'))
                            .fontSize($r('sys.float.Body_S'))
                            .fontColor($r('sys.color.font_secondary'))
                            .fontFamily('HarmonyHeiTi')
                            .fontWeight(FontWeight.Regular)
                            .padding({ bottom: 8, top: 8 })
                        }.margin({ bottom: 92 })
                      }
                    }
                    if (this.isShowEmoji) {
                      Column() {
                        SendEmoji({
                          ctrl: $mConversationCtrl,
                          mIsNew: false,
                          mCreateNewConversationViewModle: new CreateNewConversationViewModle(),
                        })
                      }
                      .width('100%')
                      .margin({ bottom: this.mEmojiOffsetY })
                      .height(this.isVDE ? 192 : this.splitInfoModel.isEmojiLow ? MIN_MM_PICKER_HEIGHT :
                        EMOJI_HEIGHT + this.bottomPadding)
                    }
                  }
                }
                .width('100%')
                .id('inputBoxBottom')
                .translate({ y: this.isVDE && this.isScrolling ? this.mOffsetY + this.getListMargin() +
                this.bottomPadding + this.locationMargin() : 0 })
                .opacity(this.isVDE && this.isScrolling ? 0 : 1)
                .backgroundColor((this.mConversationCtrl.isSelectStatus && !this.mConversationCtrl.hasDetailDelete) ?
                $r('sys.color.background_secondary') : $r('sys.color.ohos_id_color_list_card_bg'))
                .onAreaChange((oldValue: Area, newValue: Area) => {
                    if (newValue.globalPosition.y) {
                        this.currentSendBarGlobalY = newValue.globalPosition.y.valueOf() as number;
                    }
                    HiLog.i(TAG, 'onAreaChange currentSendBarGlobalY: ' + this.currentSendBarGlobalY);
                    if (this.splitInfoModel.isSmall && this.showMMContentPicker) {
                      this.showMMContentPicker = false;
                      this.mOffsetY = 0;
                      this.mConversationCtrl.scroller.scrollEdge(Edge.End);
                    }
                    this.changeNeedExpandSafeArea();
                    if (this.isFocusOnTextAreaInNonPCDevice) {
                      this.mConversationCtrl.scroller.scrollEdge(Edge.End);
                    }
                })
                .alignRules({
                  left: { anchor: '__container__', align: HorizontalAlign.Start },
                  bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
                })
                .constraintSize({ minHeight: this.isVDE && this.isScrolling ? 0 : 52 })
                .animation({ curve: curves.interpolatingSpring(0, 1, 342, 37) })
              }
            }
            .width('100%')
            .height('100%')
        }
        .bindSheet(this.isTransmitShow && this.isPC, this.transmitBuilder(), {
          height: SheetSize.LARGE,
          blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
          showClose: true,
          preferType: SheetType.CENTER,
          title: { title: ResourceUtils.getStringSync($r('app.string.transmitHeadText'))},
          shouldDismiss: () => {
            AppStorage.setOrCreate('isTransmitShow', false);
          },
        })
        .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .border({ color: $r('sys.color.background_secondary') })
        .backgroundColor($r('sys.color.background_secondary'))
        .hideTitleBar(DeviceUtil.isPC() || this.splitInfoModel.isSmall || this.hideVdeTitle ||
          (this.isVDE && this.isScrolling), true)
        .focusable(this.isPageOnFocus)
        .hideBackButton(true)
        .bindToScrollable([this.listScroller])
        .title(this.navTitle)
        // .titleBar(TitleBarUtil.getTitleBar({ stackBuilder: this.navTitle.bind(this),
        //   enableComponentSafeArea: true,
        //   callback: () => { this.destinationBackPress() }}))
        .onShown(() => {
            this.destinationShow();
            this.emitterInit();
            this.initToolBarList();
            this.mConversationCtrl.checkMessageDownloadTimeout();
            if (this.isInvokeCamera) {
              MMCameraInvocation.invokeCamera(this.context, this.mConversationCtrl?.isRcsMms);
              this.isInvokeCamera = false;
            }
        })
        .onBackPressed(() => {
            CancelNotificationTimeLock.getInstance().freeLock('conversation->onBackPressed')
            return this.destinationBackPress();
        })
        .onHidden(() => {
            this.destinationPageHide();
            // 取消监听从conversation界面提前到onBackPress，否则需耗时600ms+才会执行，若此期间进入其他conversation会对应取消掉所有监听
            let curBp: string = AppStorage.get('curBp') as string;
            this.removeEmitter(curBp);
        })
        .onReady((context: NavDestinationContext) => {
          this.pageInfos = context.pathStack
          this.mConversationCtrl.pageInfos = context.pathStack
        })
        .onTouch((event: TouchEvent)=>{
          if (this.isPCEmojiVisible) {
            this.isPCEmojiVisible = false
          }
        })
        .onMouse((event: MouseEvent)=>{
          if (event.action === MouseAction.Release && this.isPCEmojiVisible) {
            this.isPCEmojiVisible = false
          }
        })
    }

  @Builder
  transmitBuilder() {
    if (this.isTransmitSearch) {
      TransmitSearchMsgPage();
    } else {
      TransmitMsgPage()
    }
  }

  private getSimCardIcon(slotId: number): Resource {
    let slotType = MmsPreferences.getInstance().getTypeOfSlot(slotId);
    let slotIndex = MmsPreferences.getInstance().getIndexOfSlot(slotId);
    HiLog.i(TAG, ` getSimCardIcon ${slotId},${slotType},${slotIndex}`);
    if (slotType === common.simType.ESIM) {
      return $r('app.media.ic_simcard_e');
    } else {
      return slotIndex === 1 ? $r('app.media.ic_simcard_1') : $r('app.media.ic_simcard_2');
    }
  }

  private refreshSimCardIcon() {
    this.iconOfSlot0 = this.getSimCardIcon(common.int.SLOT_ZERO);
    this.iconOfSlot1 = this.getSimCardIcon(common.int.SLOT_ONE);
  }

  private focusMethod() {
    this.textareaFocusable = true;
    focusControl.requestFocus(Constant.MMS_INPUT_TEXTAREA_Id);
    this.mConversationCtrl.changeReceiveInputStatus();
    this.messageAreaFocus();
  }

  private isFocus() {
    if (this.mComeFromContact || this.mComeFromServiceaccess){
      return true
    } else {
      return false
    }
  }

  getListMargin(): number {
    let listMargin: number = TITLE_HEIGHT + this.textHeight - INPUT_MIN_HEIGHT;
    if (this.keyboardHeight === 0 && !this.isShowEmoji && !this.showMMContentPicker) {
      if (this.isShowMmsAreaDisplay && !this.mConversationCtrl.isSelectStatus) {
        if (this.isVDE) {
          listMargin += 84;
        } else {
          listMargin += this.attachmentHeight;
          this.mConversationCtrl.scrollToEnd(); // 有彩信草稿的时候，进入会话，需要滑动到最新一条信息
        }
      } else {
        return listMargin;
      }
    } else {
      if (this.isShowMmsAreaDisplay && !this.mConversationCtrl.isSelectStatus) {
        if (this.isVDE) {
          listMargin += 84;
        } else {
          listMargin += this.attachmentHeight;
          this.mConversationCtrl.scrollToEnd();
        }
      } else {
          return listMargin;
      }
    }
    return listMargin;
  }

  locationMargin(): number {
    let locationMargin: number = 0;
    return locationMargin;
  }

    private getMaxFontSizeScale(): number {
        return this.fontSizeScale <= 2 ? this.fontSizeScale : 2;
    }

    private getAttachmentButtonDisplay(): boolean {
        if (this.splitInfoModel.isSmall) {
            return false;
        }
        //RCS模式返回 true 不受附件区数量限制
        if (this.mConversationCtrl?.isRcsMms) {
            return true;
        }
        //短信模式下 不受附件区数量限制
        return true;
    }

  public cancelMultiStatus() {
    this.mConversationCtrl.isSelectStatus = false;
    this.updateBackIcon(false);
    this.mConversationCtrl.isMessageCheckAll = false;
    this.mConversationCtrl.cancelCheckedAll();
  }

    sendMeaasgeWithRCS(isRcs: boolean) {
        if (this.isChatbotConversation && this.chatbotFloatMenuData?.suggestions) {
          this.chatbotFloatMenuData.suggestions = [];
        }
        let isTextMessage = this.mConversationCtrl.mAttachAreaCtrl.mmDisplaySource.length == 0 &&
            this.mConversationCtrl.textValue != common.STR.EMPTY_STR;
        if (isTextMessage) {
            this.isShowAnimateView = false;
            //文字框发送动画
            animateTo({
                curve: curves.interpolatingSpring(0, 1, 342, 37), onFinish: () => {
                    this.isShowAnimateView = true;
                    //动效完成，恢复正常刷新
                    this.conversationDataSource.setIsSendingAnimate(false)
                    HiLog.i(TAG,'sending animation is finish, the refresh is restored.');
                    this.isSendingAnimate = false;
                }
            }, () => {
                this.isSendingAnimate = true;
                if (isRcs) {
                    this.mConversationCtrl.sendOfEnhancedInfo(this.context);
                } else {
                    if (!this.mConversationCtrl.sendMessageIsHasMap()) {
                      return;
                    }
                    //发送普通文本消息
                    this.mConversationCtrl.send(this.context);
                }
                //执行发送动效期间，刷新会导致动效跳帧。阻断刷新
                this.conversationDataSource.setIsSendingAnimate(true)
                this.animatingTextHeight = INPUT_MIN_HEIGHT;
                HiLog.i(TAG,'Do not refresh temporarily while sending animation');
            })
        } else {
            if (isRcs) {
                this.mConversationCtrl.sendOfEnhancedInfo(this.context);
            } else {
                if (!this.mConversationCtrl.sendMessageIsHasMap()) {
                  return;
                }
                //发送多媒体消息
                this.mConversationCtrl.send(this.context);
            }
            HiLog.i(TAG, 'The MMS message does not have animation effect.')
        }
    }

  private getPlaceholder(): ResourceStr {
    if (this.mConversationCtrl?.isChangeInputPlaceholder) {
      return $r('app.string.msg_note_mms2');
    }
    if (this.mConversationCtrl?.isRcsMms) {
      return $r('app.string.msg_note_rcs');
    }
    if (!this.isPad) {
      return $r('app.string.msg_note_mms');
    }
    return '';
  }

  private getMsgText(): ResourceStr {
    if (this.mConversationCtrl?.isChangeInputPlaceholder) {
      return $r('app.string.msg_note_mms2');
    }
    if (this.mConversationCtrl?.isRcsMms) {
      return $r('app.string.msg_note_rcs');
    }
    return $r('app.string.msg_note_mms');
  }
}




