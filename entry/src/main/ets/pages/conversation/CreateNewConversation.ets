/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import inputMethod from '@ohos.inputMethod';
import promptAction from '@ohos.promptAction';
import { BusinessError, emitter, settings } from '@kit.BasicServicesKit';
import { ComponentContent, componentUtils, Configuration, curves, LengthMetrics, window } from '@kit.ArkUI';
import lazy { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import LooseObject from '../../data/LooseObject';
import { SplitInfoModel, SplitScreenManager } from '../../utils/SplitScreenManager';
import { Receive } from '../../views/receive/receive';
import ReceiveController from '../../views/receive/receiveController';
import ConversationController, { BaseItemType } from './conversationController';
import common from '../../data/commonData';
import lazy CreateNewConversationViewModle from './CreateNewConversationViewModle';
import dotCommon, {
  writeEventParams,
  newPageListParams,
  contentMoreParams,
  dotNoNeedParmas,
} from '../../utils/MmsDot/DotCommon';
import DotUtil from '../../utils/MmsDot/DotUtils';
import Constant from '../../data/Constant';
import StringUtil from '../../utils/StringUtil';
import HiLog from '../../utils/HiLog';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import simCardService from '../../service/SimCardService'
import OperatorConfigUtil from '../../../cust/utils/OperatorConfigUtil';
import commonData from '../../data/commonData';
import { i18n, intl } from '@kit.LocalizationKit';
import { MultiSimCardMenu } from '../../views/MultiSimCardMenu';
import MmsPreferences from '../../utils/MmsPreferences';
import MmpictureController from '../../views/AttachmentArea/MMPictureController';
import TabUtil from '../../utils/TabUtil';
import lazy SendEmoji from './EmojiKeyboard';
import { PermissionDialog } from '../../views/PermissionDialogs';
import MMRecorderController from '../../views/AttachmentArea/MMRecorderController';
import DataService from '../../service/DataService';
import { MenuItemsObj, MenuItemsObjRcs } from './ConversationData';
import { SelectDialogBuilder } from '../../views/MultiSimCardCallDialog';
import { sms } from '@kit.TelephonyKit';
import { AudioPlayerService } from '../../service/AudioPlayerService';
import lazy { AudioPrompts } from '../../views/MmsDialogs';
import MMAttachmentAreaController from '../../views/AttachmentArea/MMAttachmentAreaController';
import { Conversation } from './conversation';
import RcsDataPreferences from '../../utils/RcsDataPreferences';
import EnhancedInfoTabs from '../../views/AttachmentArea/EnhancedInfoTabs';
import MMTabs from '../../views/AttachmentArea/MMTabs';
import MMAttachAreaDisplay from '../../views/AttachmentArea/MMAttachAreaDisplay';
import { connection } from '@kit.NetworkKit';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import PatternControl from '../PatternControl';
import EmitterConstant from '../../data/EmitterConstant';
import WantUtil from '../../utils/WantUtil';
import { RcsNewMoreMenu } from '../../views/MmsRcsNewMenu';
import TitleBarUtil from '../../utils/TitleBarUtil';
import DeviceUtil from '../../utils/DeviceUtil';
import myCommon from '@ohos.app.ability.common';
import { DraftUtils } from '../../utils/DraftUtils';
import MessageUtil from '../../../cust/utils/MessageUtil';
import { util } from '@kit.ArkTS';
import { SystemMode, SystemModeType } from '../../utils/SystemMode';
import Prompt from '@ohos.promptAction';
import lazy UTD from '@ohos.data.uniformTypeDescriptor';
import { DragUtil } from '../../utils/DragUtil';
import { VibrationUtils } from '../../utils/VibrationUtils';
import { Mms } from '../../utils/TypesUtils';
import LocationUtil from '../../utils/LocationUtil';
import { AccessCtrlUtils } from '../../utils/AccessCtrlUtils';
import ConListController from '../conversationlist/conversationListController';

const TAG = 'CreateNewConversation';
const MIN_MM_PICKER_HEIGHT: number = 112;
const TEXT_MAX_LENGTH: number = 5000;
const EMOJI_HEIGHT: number = 263;
const INPUT_MIN_HEIGHT: number = 40;
const INPUT_MARGIN_BOTTOM: number = 6;
const RCS_MM_PICKER_HEIGHT: number = 200;
const PC_INPUT_HEIGHT: number = 214;
const TIMEOUT_TWO_HUNDRED_MS: number = 200;
const MMS_MM_PICKER_HEIGHT: number = 200;

interface ParamsInterface {
  changeMenuItemsValue: Function,
  menuItem: ResourceStr,
  isVDE: boolean
}

@Builder
export function CreateNewConversationLoader(param: LooseObject): void {
  CreateNewConversation();
}

@Component
export struct CreateNewConversation {
  @LocalStorageProp('windowHeight') windowHeight: number = 0;
  @LocalStorageProp('fullScreenPadding') @Watch('fullScreenPaddingChange') mFullScreenPadding: Padding | null = null;
  @StorageProp('fontSizeScale') mFontSizeScale: number = 1;
  @StorageLink('curBp') @Watch('messageBubbleWidthChange') mCurBp: string = common.STR.DEVICE_MOBILE_PHONE;
  @StorageLink('isSettingsAppear') isSettingsAppear: boolean = false; // 设置半模态是否拉起
  @Consume('pageInfos') mPageInfos: NavPathStack;
  //分屏通知
  @State @Watch('splitScreenTypeChange') splitInfoModel: SplitInfoModel = SplitScreenManager.getInstance().infoModel;
  //输入框高度
  @State inputCurrentheight: Length = 'auto';
  @State @Watch('showMMContentPickerChange') showMMContentPicker: boolean = false;
  controller: TextAreaController = new TextAreaController();
  contactTextController: TextAreaController = new TextAreaController();
  @State receiveCtrl: ReceiveController = ReceiveController.getInstance();
  @State mConversationCtrl: ConversationController = ConversationController.getInstance();
  @State conListCtrl: ConListController = this.mConversationCtrl.conListCtrl;
  @State textareaFocusable: boolean = true;
  @State mCreateNewConversationViewModle: CreateNewConversationViewModle = new CreateNewConversationViewModle();
  @StorageLink('isConversationNeedChange') @Watch('conversationNeedChanged') isConversationNeedChange: boolean = false;
  @StorageLink('isConversationNeedChangeOfRcs') @Watch('conversationNeedChangedOfRcs') isConversationNeedChangeOfRcs:
    boolean = false;
  @StorageLink('isAreaDisplayChange') @Watch('displayChangedEvent') isAreaDisplayChange: boolean = false;
  @StorageLink('selectPicFromGalleryDone') @Watch('selectPicFromGalleryChanged') selectPicFromGalleryDone: boolean =
    false;
  @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();
  //镜像
  @State textDirection: string = '';
  /* 设备是否开启无障碍屏幕朗读 */
  @StorageLink('isScreenReaderOpen') isReaderOpen: boolean = false;
  //来自联系人应用
  @StorageLink('comeFromContact') mComeFromContact: boolean = false;
  @StorageLink('comeFromServiceaccess') mComeFromServiceaccess: boolean = false;
  @StorageLink('isSelectContactsFromPickDone') @Watch('selectContactsFromPickDone') isSelectContactsFromPickDone: boolean = false;
  //是否语音模式
  @State isVoicing: boolean = false;
  @State isAllCardCanSend: boolean = false;
  //监听键盘
  @StorageProp('keyboardHeight') @Watch('onKeyboardChange') mKeyboardHeight: number = 0;
  //记录键盘高度
  private mOldKeyboardHeight = 0;
  private context = getContext(this) as myCommon.UIAbilityContext;
  /* 系统模式 */
  private systemMode: string = SystemMode.getInstance().mode;
  @State mMContentPickerOffsetY: number = 0;
  @State mEmojiOffsetY: number = 0;
  //键盘避让
  @State mOffsetY: number = 0;
  @State mSlotId: number = MmsPreferences.getInstance().getSelectedSlotId();
  @State onDestinationShow: boolean = true;
  //是否显示表情列表
  @State isShowEmoji: boolean = false;
  @State mMpictureController: MmpictureController = MmpictureController.getInstance();
  @State mTabUtil: TabUtil = TabUtil.getInstance();
  //顶部安全区避让，避免界面刷新menus和输入框抢焦点。
  @State topPadding: number = 0;
  @State bottomPadding: number = 0;
  @State recorderController: MMRecorderController = MMRecorderController.getInstance();
  //语音权限
  @State recorderPermission: boolean = false;
  //是否有双卡
  @State haveTwoCards: boolean = false;
  @State defCellularSlotId: number = 0;
  @State rcsInfoStatus: number = 0;
  //拍照 图库 联系人 文件 选中标记
  @State currentIndex: number = 1;
  @StorageLink('simSlotId') @Watch('handleSelectedSlotIdChange') simSlotId: number = MmsPreferences.getInstance()
    .getSelectedSlotId();
  @State cardImage: boolean = MmsPreferences.getInstance().haveMultiSimCardReady();
  @State isShowMoreMenu: boolean = false;
  @StorageLink('isOnlineRcs') @Watch('updateRcsState') isOnlineRcs: boolean = false;
  @State changeRcsFlag: boolean = false;
  @State isInput: boolean = false;
  @State isShowMmsAreaDisplay: boolean = false;
  //发送信息大小
  @State attachmentSizeDesc: Resource | string = '';
  @State isSendingAudio: boolean = false;
  @State rcsIsResumeSend: boolean = false;
  @State isTouchDown: boolean = false;
  @State haveSimCard: boolean = MmsPreferences.getInstance().haveSimCardReady();
  @Provide('conversation_rcs_recordDuration') recordDuration: number = 0;
  @State mmAttachmentAreaController: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
  @StorageLink('isAirPlaneMode') isAirPlaneMode: boolean = false;
  //wifi是否链接
  @State isWifiConnected: string = '?';
  @State heightMMContentPicker: number = MIN_MM_PICKER_HEIGHT;
  @State fullHeightMMPicker: boolean = false;
  @State topMMContentPicker: number = 0;
  @State picturePermission: boolean = false;
  @State slotId: number = MmsPreferences.getInstance().getSelectedSlotId();
  @State satelliteProp: boolean = false;
  private patternControl: PatternControl = PatternControl.getInstance();
  private isUpperLimit: boolean = false;
  private inputMethodSetting = inputMethod.getSetting();
  /* 附件区底部高度 */
  private attachmentBottomHeight: number = SystemMode.getInstance().attachmentBottomHeight;
  private emitterKeyboard = (info: Array<inputMethod.InputWindowInfo>) => {
    //键盘弹出监听 当在分屏上屏、悬浮窗模式的时候，键盘弹出了但是键盘高度还是0，无法关闭表情键盘和附件区。注意事项：此方法调用太频繁
    if (this.mOldKeyboardHeight == 0) {
      this.showKeyboard();
    }
  }
  audioPlayerService: AudioPlayerService = AudioPlayerService.getInstance();
  conversationRcsDataPreferences: RcsDataPreferences = RcsDataPreferences.getInstance();
  // 窗口状态变化，当window上滑失去焦点时，折叠机保存草稿
  @StorageLink('windowStageEventType') @Watch('windowStageEventTypeChange')
  windowStageEventType: window.WindowStageEventType = window.WindowStageEventType.SHOWN
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
  @StorageLink('isVDEFoldPhoneAndFoldedState') @Watch('onFoldStatusChange') isVDEFoldPhoneAndFoldedState
    : boolean = false;
  @StorageLink('foldStatus') @Watch('getWallpaper') foldStatus
    : number = 0;
  @State isVDE: boolean = this.isVDEFoldPhoneAndFoldedState && this.foldStatus === 2 ? true : false
  @State isHideNewTitle: boolean = false;
  private inputVdeMaxHeight: number = 2 * 21 + 16;
  @State isSlotIdChange: boolean = false;
  @State isPCEmojiVisible: boolean = false
  @StorageProp('isWindowSizeChange') @Watch('updateIsPCEmojiVisible') isWindowSizeChange: Size | null = null;
  @StorageProp('windowStatusType') @Watch('updateIsPCEmojiVisible') isWindowStatusTypeChange: WindowStatusType = window.WindowStatusType.UNDEFINED;
  @State isSendButtonClicked: boolean = false;
  @StorageLink('isSettingShow') isSettingShow: boolean = false;
  @State mmsPickerHeight: number = MIN_MM_PICKER_HEIGHT;
  @StorageProp('displayOrientation') displayOrientation: number = 0;

  private onFoldStatusChange(): void {
    if (this.isVDEFoldPhoneAndFoldedState) {
      HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
    } else {
      HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
    }
  }

  private updateIsPCEmojiVisible() {
    this.isPCEmojiVisible = false
  }

  getWallpaper() {
    if (this.isVDEFoldPhoneAndFoldedState) {
      HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
      if (this.foldStatus === 2) {
        this.isVDE = true
        HiLog.i(TAG, 'this.showMMContentPicker is true');
        this.mTabUtil.animationIterations = 0;
        this.showMMContentPicker = false;
        this.closeKeyboard();
      } else {
        this.isVDE = false
        this.isHideNewTitle = false;
      }
      HiLog.i(TAG, 'isVDE :' + this.isVDE);
    } else {
      this.isVDE = false
      this.isHideNewTitle = false;
      HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
    }

    // 判断如果是表情面板的时候，需要获取面板高度用于偏移
    if (this.isShowEmoji) {
      const timeOutId = setTimeout(() => {
        const sendEmojiColumnHeight: number = this.getHeightByKey('creat_new_conversation_send_emoji_column');
        this.mOffsetY = sendEmojiColumnHeight - this.bottomPadding;

        // 如果是vde小屏，需要隐藏标题栏
        if (this.isVDE) {
          animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37) }, () => {
            this.isHideNewTitle = true;
          });
        }

        clearTimeout(timeOutId);
      }, TIMEOUT_TWO_HUNDRED_MS);
    }
  }

  // menusCreateNewConversation: Array<HdsNavigationBadgeIconOptions> = [
  //   {
  //     content: {
  //       label: $r('app.string.more_options_button'),
  //       icon: $r('sys.symbol.dot_grid_2x2'),
  //       componentId: 'createNewConversation',
  //       isEnabled: true,
  //       action: () => {
  //         // menu第二个button
  //         let uiContext = this.getUIContext();
  //         let promptAction = uiContext.getPromptAction();
  //         let contentNode = new ComponentContent(uiContext, wrapBuilder<[ParamsInterface]>(menuComponent),
  //           {
  //             menuItem: this.menuItems[0].value,
  //             isVDE: this.isVDE,
  //             changeMenuItemsValue: () => {
  //               this.isSlotIdChange = false;
  //               if (this.mCreateNewConversationViewModle.isRcsMms) {
  //                 this.mCreateNewConversationViewModle.isRcsMms = false;
  //                 this.changeRcsFlag = true;
  //                 this.changeMenuItemsRcsValue();
  //                 this.mCreateNewConversationViewModle.resetValuesSwitchBetweenMmsAndRcs(true);
  //               } else {
  //                 this.mCreateNewConversationViewModle.isRcsMms = true;
  //                 this.changeRcsFlag = false;
  //                 this.changeMenuItemsRcsValue();
  //                 this.mTabUtil.animationIterations = 0;
  //                 this.textareaFocusable = true;
  //                 this.mCreateNewConversationViewModle.resetValuesSwitchBetweenMmsAndRcs(false);
  //                 contentMoreParams.SELECT_STATE = 7;
  //                 DotUtil.getInstance().reportEvent(contentMoreParams, dotCommon.eventName.CONTENT_MORE_EVENT);
  //               }
  //             }
  //           } as ParamsInterface);
  //         try {
  //           promptAction.openMenu( contentNode, { id: 'createNewConversation' },  // 目标组件id为开发者指定的ImageWithMenu'
  //             { placement: Placement.BottomRight })
  //         } catch (error) {
  //           let message = (error as BusinessError).message;
  //           let code = (error as BusinessError).code;
  //           HiLog.e(TAG, `zhy openMenu args error code is ${code}, message is ${message}`);
  //         }
  //       }
  //     }
  //   },
  // ]

  menuItems: Array<MenuItemsObjRcs> = [
    {
      value: '',
      action: () => {
        this.isSlotIdChange = false;
        if (this.mCreateNewConversationViewModle.isRcsMms) {
          this.mCreateNewConversationViewModle.changeIsRcsMms(false, this.isSlotIdChange);
          this.changeRcsFlag = true;
          this.changeMenuItemsRcsValue();
          this.mCreateNewConversationViewModle.resetValuesSwitchBetweenMmsAndRcs(true);
        } else {
          this.mCreateNewConversationViewModle.changeIsRcsMms(true, this.isSlotIdChange);
          this.changeRcsFlag = false;
          this.changeMenuItemsRcsValue();
          this.mTabUtil.animationIterations = 0;
          this.textareaFocusable = true;
          this.mCreateNewConversationViewModle.resetValuesSwitchBetweenMmsAndRcs(false);
          contentMoreParams.SELECT_STATE = 7;
          DotUtil.getInstance().reportEvent(contentMoreParams, dotCommon.eventName.CONTENT_MORE_EVENT);
        }
      },
      enabled: true,
      visible: this.mCurBp == common.STR.DEVICE_FLAT_PLATE ? false : true,
      id: 3
    }
  ];
  @Provide
  menuItemList: Array<MenuItemsObj> = [
    {
      value: '',
      action: () => {
        this.mCreateNewConversationViewModle && (this.mCreateNewConversationViewModle.isChangeInputPlaceholder = false);
        this.isSlotIdChange = false;
        if (this.mCreateNewConversationViewModle.isRcsMms) {
          this.mCreateNewConversationViewModle.isRcsMms = false;
          this.changeRcsFlag = true;
          this.isVoicing = false;
          this.changeMenuItemsRcsValue();
          this.mCreateNewConversationViewModle.resetValuesSwitchBetweenMmsAndRcs(true);
        } else {
          this.mCreateNewConversationViewModle.isRcsMms = true;
          this.changeRcsFlag = false;
          this.changeMenuItemsRcsValue();
          this.mTabUtil.animationIterations = 0;
          this.textareaFocusable = true;
          contentMoreParams.SELECT_STATE = 7;
          this.mCreateNewConversationViewModle.resetValuesSwitchBetweenMmsAndRcs(false);
          DotUtil.getInstance().reportEvent(contentMoreParams, dotCommon.eventName.CONTENT_MORE_EVENT);
        }
      },
      enabled: true
    }
  ];
  recorderRcsPermissionDialogCtrl: CustomDialogController = new CustomDialogController({
    builder: PermissionDialog({
      icon: $rawfile('icon/ic_public_voice_filled.svg'),
      title: $r('app.string.message_requires_access_to_microphone'),
      mainContent: $r('app.string.open_microphone_permission_info'),
      iconBackgroundColor: $r('sys.color.ohos_id_color_palette11'),
      confirm: () => {
        HiLog.i(TAG, 'recorderRcsPermissionDialogCtrl confirm');
        this.recorderController.permissionOnSetting(getContext(this));
        this.recorderRcsPermissionDialogCtrl.close();
      },
      cancel: () => {
        this.recorderRcsPermissionDialogCtrl.close();
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  })
  rcsAudioPromptsController: CustomDialogController = new CustomDialogController({
    builder: AudioPrompts({ isResumeSend: this.rcsIsResumeSend }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    gridCount: 4,
    customStyle: true,
    isModal: false
  })
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
          this.mCreateNewConversationViewModle.sendOfEnhancedInfo();
        }
      },
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  })

  aboutToAppear(): void {
    const rowsTemplateValue = this.mmAttachmentAreaController.tabsRowsTemplateValue(this.displayOrientation, this.mCurBp)
    this.mmsPickerHeight = rowsTemplateValue === '1fr 1fr' ? MMS_MM_PICKER_HEIGHT : MIN_MM_PICKER_HEIGHT

    this.fullScreenPaddingChange();
    let rcsFirstStatus = this.conversationRcsDataPreferences
      .getSyncByPreferences(Conversation.CONVERSATION_RCS_DATA_PREFERENCES, 0);
    this.rcsInfoStatus = rcsFirstStatus === 1 ? 1 : 0;
    connection.getDefaultNet().then((netHandle: connection.NetHandle) => {
      connection.getNetCapabilities(netHandle, (error: BusinessError, data: connection.NetCapabilities) => {
        if (data?.bearerTypes) {
          this.isWifiConnected = '' + data.bearerTypes;
        }
      });
    })
    this.mCreateNewConversationViewModle.resetMmsSource();
    this.mCreateNewConversationViewModle.onInit(this.context, this.mPageInfos);
    this.mCreateNewConversationViewModle.onShow(this.context);
    this.mCreateNewConversationViewModle.getHasSimCard().then(() => {
      this.haveTwoCards = this.mCreateNewConversationViewModle.haveTwoCards
      if (this.mCreateNewConversationViewModle.haveTwoCards) {
        this.getCellularData().then(val => {
          this.defCellularSlotId = val;
          this.handleSelectedSlotIdChange();
          this.handleSwitchCard();
        })
      } else if (this.isOnlineRcs) {
        this.isShowMoreMenu = true;
        this.isSlotIdChange = false;
        this.mCreateNewConversationViewModle.changeIsRcsMms(true, this.isSlotIdChange);
        this.changeMenuItemsRcsValue();
      } else {
        this.isShowMoreMenu = false;
        this.isSlotIdChange = false;
        this.mCreateNewConversationViewModle.changeIsRcsMms(false, this.isSlotIdChange);
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, error.message);
    });
    try {
      this.inputMethodSetting.on('imeShow', this.emitterKeyboard);
    } catch (err) {
      HiLog.i(TAG, `Failed to unsubscribing inputMethodProperty. err: ${JSON.stringify(err)}`);
    }
  }

  aboutToDisappear(): void {
    this.inputMethodSetting.off('imeShow', this.emitterKeyboard);
    this.mCreateNewConversationViewModle.removeAirPlaneMode();
    this.mCreateNewConversationViewModle.removeSatelliteMode();
    AppStorage.delete(commonData.STR.CREATE_NEW_CONVERSATION_FROM_RECORD);
  }

  destinationShow(): void {
    this.textDirection = Configuration.getLocale().dir;
    this.checkFocusable();
    this.destinationShowMConversationCtrl();
    WantUtil.getWant(this.context, this.mPageInfos);
    this.receiveCtrl.refreshContactDataOnPageShow(this.context);
    this.mCreateNewConversationViewModle.getAirPlaneMode();
    if (GlobalContext.getContext().getObject('transmitFlag')) {
      this.mmAttachmentAreaController.refreshDisplay();
    }
    if (this.mCurBp !== common.STR.DEVICE_MOBILE_PHONE) {
      let strContactsNumber: string =
        (this.mPageInfos.getParamByIndex(this.mPageInfos.size() - 1) as LooseObject)?.strContactsNumber;
      AppStorage.set('selectPhoneNumber', strContactsNumber)
    }
    this.emitterInit();
    this.onDestinationShow = !this.onDestinationShow;
  }

  destinationPageHide() {
    this.mCreateNewConversationViewModle.onHide();
    this.audioPlayerService.stopAudio()
    AudioPlayerService.setAudioFilePlayState(undefined, 'stopped');
    if (!GlobalContext.getContext().getObject('notUpdateData')) {
      GlobalContext.getContext().setObject('notUpdateData', false)
    }
    // if (this.mOldKeyboardHeight > 0) {
    //   this.mOffsetY = 0;
    // }
  }

  destinationBackPress(): boolean {
    HiLog.i(TAG, 'destinationBackPress start!')
    AppStorage.setOrCreate('invokeCamera', false);
    AudioPlayerService.setAudioFilePlayState(undefined, 'stopped');
    this.resetTitle();
    if (AppStorage.get('curBp') as string !== common.STR.DEVICE_MOBILE_PHONE) {
      return false;
    }
    return this.mCreateNewConversationViewModle.onBackPress(this.context);
  }

  @Builder
  navTitle() {
    Column() {
      Text($r('app.string.new_message'))
        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Bold)
    }
    .accessibilityLevel('no')
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
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
        start: LengthMetrics.vp(Number(this.handlePaddingInDiffDevice()))
      })
  }

  private handlePaddingInDiffDevice = () => {
    return DeviceUtil.isPC() ? '24' : this.mCurBp === common.STR.DEVICE_MOBILE_PHONE ? 8 :
      common.STR.DEVICE_FLAT_PLATE ? this.padMargin : $r('sys.float.margin_left')
  }

  @Builder
  navMenu() {
    Column() {
      // <!--Top titleBar-->
      // New page
      RcsNewMoreMenu()
        .visibility((this.isShowMoreMenu && !this.fullHeightMMPicker)
          ? Visibility.Visible : Visibility.None);
    }
    .visibility(this.isVDE ? Visibility.None : Visibility.Visible)
    .justifyContent(FlexAlign.Center)
    .height(56)
    .padding({
      left: $r('sys.float.margin_left'),
      right: this.mCurBp === common.STR.DEVICE_FLAT_PLATE ? 24 : $r('sys.float.margin_right')
    })
    .accessibilityLevel('no')
    .width(200)
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

  @Styles
  normalStylesMenu(){
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStylesMenu(){
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  actionButtonPressStyles(){
    .stateStyles({
      normal: this.normalStylesMenu,
      pressed: this.pressedStylesMenu
    })
  }

  handleTextValueChange(value:string) {
    if (value.length > TEXT_MAX_LENGTH) {
      this.mCreateNewConversationViewModle.showToast($r('app.string.text_input_limit'))
        this.mCreateNewConversationViewModle.textValue = value;
        this.mCreateNewConversationViewModle.textValue =
          this.mCreateNewConversationViewModle.textValue.substring(0, TEXT_MAX_LENGTH);
    } else {
      this.mCreateNewConversationViewModle.changeValue(value);
      this.mCreateNewConversationViewModle.handleProtocolChange(value);
    }

    // 写信息——输入普通文字打点
    writeEventParams.INPUT_STATE = 1;
    DotUtil.getInstance().reportEvent(writeEventParams,
      dotCommon.eventName.WRITE_SMS_EVENT);
    this.calculateTextInputCount();
    if (this.isShowEmoji) {
      this.controller.caretPosition(this.mCreateNewConversationViewModle.newEmojiLength +
      this.mCreateNewConversationViewModle.caretPosition)
    }
  }

  build() {
    NavDestination() {
      RelativeContainer() {
        Receive({
          mReceiveController: $receiveCtrl,
          mCreateNewConversationViewModle: this.mCreateNewConversationViewModle,
          contactTextController: this.contactTextController,
          showMMContentPicker: $showMMContentPicker,
          textareaFocusable: $textareaFocusable,
          threadId: this.mCreateNewConversationViewModle.threadId,
          isVdeStatus: this.isVDE
        })
          .layoutWeight(1)
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            bottom: { anchor: 'bottomView', align: VerticalAlign.Top }
          })
          .id('topTitleBar')
          .margin({ top: 8, bottom: DeviceUtil.isPC() ? PC_INPUT_HEIGHT : 0})
        if (this.isPCEmojiVisible) {
          Column() {
            SendEmoji({
              ctrl: $mConversationCtrl,
              mIsNew: true,
              mCreateNewConversationViewModle: this.mCreateNewConversationViewModle,
              controller:this.controller,
            })
          }
          .width(371)
          .height(320)
          .position({ bottom: 210, left: 24 })
          .zIndex(9999)
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
              .backgroundColor(this.isPCEmojiVisible ? $r('sys.color.ohos_id_color_button_normal') : Color.Transparent)
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
                text: this.mCreateNewConversationViewModle?.textValue || '',
                controller: this.controller,
              })
                .padding({ left: 24, right: 24 })
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
                    this.mCreateNewConversationViewModle.showToast($r('app.string.text_input_limit'))
                    this.mCreateNewConversationViewModle.textValue = value;
                    this.mCreateNewConversationViewModle.textValue =
                      this.mCreateNewConversationViewModle.textValue.substring(0, TEXT_MAX_LENGTH);
                  } else {
                    this.mCreateNewConversationViewModle.changeValue(value);
                    if (this.mCreateNewConversationViewModle.isEmoChange) {
                      this.controller.caretPosition(this.mCreateNewConversationViewModle.caretPosition)
                      this.mCreateNewConversationViewModle.caretPosition = this.controller.getCaretOffset().index;
                      this.mCreateNewConversationViewModle.isEmoChange = false;
                    }
                    this.mCreateNewConversationViewModle.handleProtocolChange(value);
                  }
                  // 写信息——输入普通文字打点
                  writeEventParams.INPUT_STATE = 1;
                  DotUtil.getInstance().reportEvent(writeEventParams,
                    dotCommon.eventName.WRITE_SMS_EVENT);
                  this.calculateTextInputCount();})
                .onTouch((event) => {
                  if (!this.isReaderOpen) {
                    if (event === undefined) {
                      HiLog.e(TAG, 'event is undefined in onTouch event');
                      return;
                    }
                    HiLog.i(TAG, 'event.type: ' + event.type);
                    if (event.type === TouchType.Up) {
                      this.focusMethod();
                    }
                  }

                })
                .onFocus(async () => {
                  this.handleReceiveContactsData();
                })
                .onClick(()=>{
                  this.mCreateNewConversationViewModle.caretPosition = this.controller.getCaretOffset().index;
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
              .enabled((this.mCreateNewConversationViewModle.canSendMessage && !this.isAirPlaneMode &&
              this.haveSimCard && !this.mCreateNewConversationViewModle.isNoCardActive &&
              this.mCreateNewConversationViewModle.canSendMmsMessage) ||
                (!(this.mCreateNewConversationViewModle.textValue === '') && !this.conListCtrl.isOsAccountConstraintEnabled &&
                DeviceUtil.isSubDeviceWithConnected(getContext(this)) && !this.isAirPlaneMode) &&
                  this.receiveCtrl.selectContacts.length > 0)
              .onClick(() => {
                let dsdaState =
                  this.mCreateNewConversationViewModle.shouldEnableSendButtonForSlot(this.simSlotId);
                if (this.mCreateNewConversationViewModle.isCall()) {
                  if (!dsdaState) {
                    this.mCreateNewConversationViewModle.showToast($r('app.string.unsupport_sim_card_content',
                      this.mCreateNewConversationViewModle.callingSlotId + 1, this.simSlotId + 1));
                    return;
                  }
                }
                AppStorage.setOrCreate('changeRcsFlagFromNewCreatView', this.changeRcsFlag)
                //  Click Send.
                if (this.mCreateNewConversationViewModle.isRcsMms) {
                  if (this.mCreateNewConversationViewModle.mAttachAreaCtrl.mmDisplaySource.length > 0 &&
                    this.rcsInfoStatus != Conversation.RCS_INFO_STATUS &&
                    this.isWifiConnected != '1') {
                    this.wifiNoticeController.open();
                  } else {
                    this.mCreateNewConversationViewModle.sendOfEnhancedInfo();
                  }
                } else {
                  if (this.mCreateNewConversationViewModle.sendMessageIsHasMap()) {
                    promptAction.showToast({
                      message: $r('app.string.not_loggedin_RCS'),
                      duration: 2000,
                    });
                  } else {
                    this.mCreateNewConversationViewModle.send();
                  }
                }
              })
              .position({ bottom: 16, right: 24 })
          }
          .alignItems(HorizontalAlign.Start)
          .height(202)
          .id('pc_bottom_input')
          .position({ bottom: 0 })
        }

        if (!DeviceUtil.isPC()) {
        Stack({ alignContent: Alignment.Bottom }) {

          Column() {
            if (this.isShowMmsAreaDisplay) {
              MMAttachAreaDisplay({
                textareaFocusable: $textareaFocusable,
                isDraft: this.mCreateNewConversationViewModle.isDraft,
                addButtonId: 'create_add_attachment_button'
              })
            }
            //input field
            Row() {
              //表情切换按钮
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
              }
              .onClick(() => {
                this.mCreateNewConversationViewModle.caretPosition = this.controller.getCaretOffset().index;
                if (this.mCreateNewConversationViewModle.isRcsMms) {
                  this.isVoicing = false;
                  HiLog.i(TAG, 'this.isRcsMms is true');
                  this.mMpictureController.isRcs = true;
                } else {
                  this.mMpictureController.isRcs = false;
                }

                if (this.isShowEmoji) {
                  this.getUIContext().getFocusController().clearFocus();
                  animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37) }, () => {
                    this.isShowEmoji = false;
                    this.textareaFocusable = true;
                    if (DeviceUtil.isPC()) {
                      this.mOffsetY = 0;
                    }
                  })
                  focusControl.requestFocus(Constant.MMS_INPUT_TEXTAREA_Id);
                } else {
                  this.mEmojiOffsetY = 0;
                  if (this.showMMContentPicker) {
                    this.showMMContentPicker = false;
                    this.mTabUtil.animationIterations = 0;
                  }
                  animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37) }, () => {
                    this.isShowEmoji = true;
                    if (this.isVDE) {
                      this.isHideNewTitle = true;
                    }
                    this.mOldKeyboardHeight = 0;
                    //表情区显示，关闭键盘。输入框高度为表情区高度
                    this.mOffsetY = this.isVDE ? 192 :
                      (this.splitInfoModel.isEmojiLow ? MIN_MM_PICKER_HEIGHT : EMOJI_HEIGHT);
                  })
                  focusControl.requestFocus('emojiButton');
                  if (canIUse('SystemCapability.MiscServices.InputMethodFramework')) {
                    inputMethod.getController().hideTextInput();
                  }
                }

                if (this.isShowEmoji) {
                  // 写信息——添加表情打点
                  writeEventParams.INPUT_STATE = 2;
                  DotUtil.getInstance()
                    .reportEvent(writeEventParams, dotCommon.eventName.WRITE_SMS_EVENT);
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
              .height('48vp')

              Blank().width(8)
              //输入框
              Row() {
                if (this.isAllCardCanSend) {
                  //卡切换
                  MultiSimCardMenu({
                    slotId: this.mSlotId,
                    onDestinationShow: this.onDestinationShow,
                    resetValues: () => {
                      this.mCreateNewConversationViewModle.isChangeInputPlaceholder = false;
                    }
                  })
                    .padding(Configuration.getLocale().dir === 'rtl' ?
                      { right: $r('app.float.id_card_margin_xxl') } :
                      { left: $r('app.float.id_card_margin_xxl') })
                }
                //输入内容
                Row() {
                  TextArea({
                    placeholder: this.getPlaceholder(),
                    text: this.mCreateNewConversationViewModle?.textValue || '',
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
                    .focusable((this.textareaFocusable || this.isShowEmoji) && !this.isSettingShow)
                    .enablePreviewText(true)
                    .onChange(value => {
                      this.handleTextValueChange(value)
                    })
                    .onClick(() => {
                      if (this.isReaderOpen) {
                        this.focusMethod();
                      }
                    })
                    .onTouch((event) => {
                      // Long press or click will focus the TextArea
                      // and open Keyboard.
                      // Therefore, the OnClick logic is moved to the TouchUp
                      // event.
                      if (!this.isReaderOpen) {
                        if (event === undefined) {
                          HiLog.e(TAG, 'event is undefined in onTouch event');
                          return;
                        }
                        if (event.type === TouchType.Up) {
                          this.focusMethod();
                        }
                      }

                    })
                    .onFocus(async () => {
                      this.handleReceiveContactsData();
                    })
                    .constraintSize({ minHeight: INPUT_MIN_HEIGHT })
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
                        this.mCreateNewConversationViewModle.textValue =
                          StringUtil.isEmpty(dragText) ? this.mConversationCtrl.textValue : dragText;
                    })
                }
                .alignItems(VerticalAlign.Center)
                .height(this.inputCurrentheight)
                .constraintSize({
                  minHeight: this.getMaxFontSizeScale() * INPUT_MIN_HEIGHT,
                  maxHeight: this.isVDE ? this.inputVdeMaxHeight : this.splitInfoModel.inputMaxheight
                })
              }
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
              .visibility(this.isVoicing ? Visibility.None : Visibility.Visible)
              .constraintSize({ minHeight: INPUT_MIN_HEIGHT })

              Blank().width(8)

              Button() {
                SymbolGlyph($r('sys.symbol.plus_circle'))
                  .id('show_mmContent_picker_id')
                  .key('icPublicAddNormBtn')
                  .focusable(true)
                  .enabled(true)
                  .width(24)
                  .height(24)
                  .draggable(false)
                  .fontSize('24vp')
                  .fontColor([$r('sys.color.ohos_id_color_primary')])
              }
              .visibility(this.isVDE ? Visibility.None : DeviceUtil.isWifiOnlyTablet() ||
              DeviceUtil.isSubDeviceWithConnected(this.context) ? Visibility.None : Visibility.Visible)
              .onClick(() => {
                HiLog.i(TAG, 'enter click event');
                if (this.splitInfoModel.isSmall) {
                  Prompt.showToast({
                    message: $r('app.string.split_screen_prompt'),
                    duration: 2000
                  });
                  return;
                }
                if (this.mCreateNewConversationViewModle.isRcsMms) {
                  HiLog.i(TAG, 'this.isRcsMms is true');
                  this.mMpictureController.isRcs = true;
                } else {
                  this.mMpictureController.isRcs = false;
                }
                if (this.isVoicing) { //点击加号按钮时，如果当前显示增强信息的“按住说话/松手发送”按钮，则隐藏该按钮
                  this.isVoicing = false;
                }
                if (this.showMMContentPicker) {
                  HiLog.i(TAG, 'this.showMMContentPicker is true');
                  this.mTabUtil.animationIterations = 0;
                  this.textareaFocusable = true;
                  focusControl.requestFocus(Constant.MMS_INPUT_TEXTAREA_Id);
                } else {
                  HiLog.i(TAG, 'this.showMMContentPicker is false');
                  if (this.isShowEmoji) {
                    this.isShowEmoji = false;
                  }
                  this.mMContentPickerOffsetY = 0;
                  focusControl.requestFocus('icPublicAddNormBtn');
                  animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37) }, () => {
                    this.showMMContentPicker = true;
                    this.mOldKeyboardHeight = 0;
                    //附件区显示，关闭键盘。输入框高度为附件区高度
                    if (this.mCreateNewConversationViewModle?.isRcsMms) {
                      this.mOffsetY = this.splitInfoModel.isSmall ? MIN_MM_PICKER_HEIGHT : RCS_MM_PICKER_HEIGHT;
                    } else {
                      this.mOffsetY = this.mmsPickerHeight + this.attachmentBottomHeight;
                    }
                  })
                  this.mTabUtil.animationIterations = 0;
                  this.textareaFocusable = false;
                }
                // 写信息——添加附件打点
                DotUtil.getInstance()
                  .reportEvent(writeEventParams, dotCommon.eventName.WRITE_ADD_ATTACHMENTS);
              })
              .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.add_attachment_button').id))
              .id('create_add_attachment_button')
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
                    .draggable(false)
                    .id('sendButton')
                    .fontSize('24vp')
                    .fontColor([$r('app.color.brand'), $r('sys.color.white')])
                    .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
                    .opacity(((this.mCreateNewConversationViewModle.canSendMessage &&
                      !this.isAirPlaneMode && this.haveSimCard &&
                    this.mCreateNewConversationViewModle.canSendMmsMessage &&
                      !this.mCreateNewConversationViewModle.isNoCardActive) ||
                      (!(this.mCreateNewConversationViewModle.textValue === '') &&
                      DeviceUtil.isSubDeviceWithConnected(getContext(this)) && !this.isAirPlaneMode)) &&
                      this.receiveCtrl.selectContacts.length > 0 && !this.isSendButtonClicked ? 1.0 :
                    $r('sys.float.interactive_disable'))
                    .enabled(this.mCreateNewConversationViewModle.canSendMessage &&
                      !this.isAirPlaneMode && this.haveSimCard &&
                      !this.mCreateNewConversationViewModle.isNoCardActive &&
                    this.mCreateNewConversationViewModle.canSendMmsMessage ||
                      (!(this.mCreateNewConversationViewModle.textValue === '') &&
                      DeviceUtil.isSubDeviceWithConnected(getContext(this)) && !this.isAirPlaneMode) &&
                        this.receiveCtrl.selectContacts.length > 0)
                }
                .width(40)
                .height('100%')
                .justifyContent(FlexAlign.Center)
                .visibility(this.isVoicing && this.isVDE ? Visibility.None : Visibility.Visible)

                if (!this.mCreateNewConversationViewModle.isRcsMms && this.receiveCtrl.selectContacts.length > 0) {
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
              .enabled(((this.mCreateNewConversationViewModle.canSendMessage && !this.isAirPlaneMode &&
              this.haveSimCard && !this.mCreateNewConversationViewModle.isNoCardActive &&
              this.mCreateNewConversationViewModle.canSendMmsMessage) ||
                (!(this.mCreateNewConversationViewModle.textValue === '') &&
                DeviceUtil.isSubDeviceWithConnected(getContext(this)) && !this.isAirPlaneMode)) &&
                this.receiveCtrl.selectContacts.length > 0)
              .onClick(() => {
                this.isSendButtonClicked = true; //  点击后刷新透明度，延迟200ms切页面。保证响应时延在100ms以内
                setTimeout(()=> {
                  this.isSendButtonClicked = false; // 发送失败场景，需要重置高亮
                  let dsdaState =
                    this.mCreateNewConversationViewModle.shouldEnableSendButtonForSlot(this.simSlotId);
                  if (this.mCreateNewConversationViewModle.isCall()) {
                    if (!dsdaState) {
                      this.mCreateNewConversationViewModle.showToast($r('app.string.unsupport_sim_card_content',
                        this.mCreateNewConversationViewModle.callingSlotId + 1, this.simSlotId + 1));
                      return;
                    }
                  }
                  AppStorage.setOrCreate('changeRcsFlagFromNewCreatView', this.changeRcsFlag)
                  //  Click Send.
                  if (this.mCreateNewConversationViewModle.isRcsMms) {
                    if (this.mCreateNewConversationViewModle.mAttachAreaCtrl.mmDisplaySource.length > 0 &&
                      this.rcsInfoStatus != Conversation.RCS_INFO_STATUS &&
                      this.isWifiConnected != '1') {
                      this.wifiNoticeController.open();
                    } else {
                      this.mCreateNewConversationViewModle.sendOfEnhancedInfo();
                    }
                  } else {
                    if (this.mCreateNewConversationViewModle.sendMessageIsHasMap()) {
                      promptAction.showToast({
                        message: $r('app.string.not_loggedin_RCS'),
                        duration: 2000,
                      });
                    } else {
                      this.audioPlayerService.stopAudio();
                      AccessCtrlUtils.checkReadContactsAccessToken();
                      this.mCreateNewConversationViewModle.send();
                    }
                  }
                }, 200)
              })
              .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.transmit_send').id))
              .accessibilityRole(AccessibilityRoleType.BUTTON)
              .accessibilityDescription((this.mCreateNewConversationViewModle.canSendMessage && !this.isAirPlaneMode &&
              this.haveSimCard && !this.mCreateNewConversationViewModle.isNoCardActive &&
              this.mCreateNewConversationViewModle.canSendMmsMessage) ?
                '' : getContext(this).resourceManager.getStringSync($r('app.string.not_clickable').id))
              .margin({ bottom: 2 })
              .actionButtonPressStyles()
              .height('48vp')
            }
            .padding({
              left: this.mCurBp === common.STR.DEVICE_FLAT_PLATE ?
                this.padMargin - 8 : $r('app.float.settings_items_margin_top'),
              right: this.mCurBp === common.STR.DEVICE_FLAT_PLATE ?
                this.padMargin - 6 : $r('app.float.settings_items_margin_top')
            })
            .width('100%')
            .alignItems(VerticalAlign.Bottom)
          }
          .id('inputBoxBottom')
          .constraintSize({ minHeight: 52 })
          .onAreaChange((oldValue: Area, newValue: Area) => {
            if (this.splitInfoModel.isSmall && this.showMMContentPicker) {
              this.showMMContentPicker = false;
              this.mOffsetY = 0;
            }
          })
          .margin({ bottom: this.mOldKeyboardHeight > 0 ? this.mOffsetY : this.mOffsetY + this.bottomPadding })
          .animation({
            duration: 300,
            curve: curves.interpolatingSpring(0, 1, 342, 37),
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
                      value = this.mCreateNewConversationViewModle.textValue + value
                      this.handleTextValueChange(value)
                    }
                    this.focusMethod();
                  },
                }).backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
              }
              .height(this.mmsPickerHeight)
              .margin({ bottom: this.mMContentPickerOffsetY + this.bottomPadding + this.attachmentBottomHeight })
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
          //表情输入
          if (this.isShowEmoji) {
            Column() {
              SendEmoji({
                ctrl: $mConversationCtrl,
                mIsNew: true,
                mCreateNewConversationViewModle: this.mCreateNewConversationViewModle,
              })
            }
            .key('creat_new_conversation_send_emoji_column')
            .width('100%')
            .height(this.isVDE ? 192 :
              (this.splitInfoModel.isEmojiLow ? MIN_MM_PICKER_HEIGHT : EMOJI_HEIGHT) + this.bottomPadding)
            .margin({ bottom: this.mEmojiOffsetY })
          }
        }
        .visibility(!this.isVDE ? Visibility.Visible :
          (this.receiveCtrl.isHideTextArea ? Visibility.None : Visibility.Visible))
        .id('bottomView')
        .constraintSize({ minHeight: 52 })
        .alignRules({
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
        })
        .animation({ curve: curves.interpolatingSpring(0, 1, 342, 37) })
        .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
        }
      }
      .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .border({ color: $r('sys.color.background_secondary') })
    .hideTitleBar(this.splitInfoModel.isSmall || this.isHideNewTitle, true)
    // .titleBar(TitleBarUtil.getTitleBar({ mainTitle: TitleBarUtil.isShowTitle &&
    //   this.mCurBp !== common.STR.DEVICE_MOBILE_PHONE ? undefined : $r('app.string.new_message'),
    //   enableComponentSafeArea: this.isHideNewTitle || true,
    //   stackBuilder: TitleBarUtil.isShowTitle && this.mCurBp !== common.STR.DEVICE_MOBILE_PHONE ?
    //   this.navTitle.bind(this) : undefined,
    //   menuValue: (this.isShowMoreMenu && !this.fullHeightMMPicker) ? this.menusCreateNewConversation : undefined,
    //   backgroundColor: $r('sys.color.background_secondary'), callback: () => { this.destinationBackPress() } }))
    .title(this.navTitle())
    .hideBackButton(DeviceUtil.isTabletOrPC() || this.mCurBp === common.STR.DEVICE_Folding_SCREEN ||
       DeviceUtil.isTrifoldExpandedState())
    .padding({ top: DeviceUtil.isPC() ? 56 : '' })
    .onShown(() => {
      this.destinationShow();
    })
    .onBackPressed(() => {
      return this.destinationBackPress();
    })
    .onHidden(() => {
      this.destinationPageHide();
      // 取消监听从conversation界面提前到onBackPress，否则需耗时600ms+才会执行，若此期间进入其他conversation会对应取消掉所有监听
      this.removeEmitter();
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
    .onWillDisappear(() => {
      if (this.mCurBp === common.STR.DEVICE_MOBILE_PHONE) {
        emitter.off(EmitterConstant.EVENT_IS_INPUT_STATUS)
        emitter.off(EmitterConstant.EVENT_CHANGE_NEW_INPUT_STATUS)
      }
    })
  }

  /**
   * 新建会话页面中处理收件人的逻辑,主要是校验收件人输入框数据和给收件人赋值
   */
  private handleReceiveContactsData = async (): Promise<boolean> => {
    HiLog.i(TAG, 'handleReceiveContactsData');
    return new Promise(async (resolve, reject) => {
      try {
        let result = await this.receiveCtrl.checkReceive((receiverData: BaseItemType) => {
          HiLog.i(TAG, 'handleReceiveContactsData checkReceive callback');
          this.mCreateNewConversationViewModle.setReceiveContactValue(receiverData);
          HiLog.i(TAG, 'handleReceiveContactsData end');
          resolve(true);
        });
        HiLog.i(TAG, `handleReceiveContactsData useCallBack: ${result.useCallBack}, isCheckPass:${result.isCheckPass}`);
        this.receiveCtrl.myText = common.STR.EMPTY_STR;
        if (!result.useCallBack) {
          HiLog.i(TAG, 'handleReceiveContactsData end');
          resolve(true);
        }
      } catch (e) {
        HiLog.e(TAG, `handleReceiveContactsData error: ${e?.code} ${e?.message}`);
        resolve(false);
      }
    });
  }

  destinationShowMConversationCtrl() {
    // destinationShow 操作 MConversationCtrl 方法
    this.mCreateNewConversationViewModle.setIsShow();
  }

  checkFocusable() {
    if (AppStorage.get('invokeCamera')) {
      this.showMMContentPicker = true;
      AppStorage.setOrCreate('invokeCamera', false);
    } else if (AppStorage.get('isFromMenu')) {
      this.textareaFocusable = true;
      AppStorage.setOrCreate('isFromMenu', false);
    }
    if (AppStorage.get(commonData.STR.CREATE_NEW_CONVERSATION_FROM_RECORD)) {
      AppStorage.setOrCreate(commonData.STR.CREATE_NEW_CONVERSATION_FROM_RECORD, false);
      return;
    }
    if (this.isFocus()) {
      this.focusMethod();
    }
  }
  selectContactsFromPickDone() {
    if (this.isSelectContactsFromPickDone) {
      if (this.isFocus()) {
        this.focusMethod();
      }
    }
  }
  private emitterInit() {
    emitter.on(simCardService.SIM_STATE_CHANGE_EVENT, () => {
      HiLog.i(TAG, 'simStateChangeEvent start! canSendMessage:' + this.mCreateNewConversationViewModle.canSendMessage +
        ', haveSimCard:' + this.haveSimCard);
      this.cardImage = MmsPreferences.getInstance().haveMultiSimCardReady();
      this.mCreateNewConversationViewModle.getHasSimCard().then(() => {
        this.haveTwoCards = this.mCreateNewConversationViewModle.haveTwoCards;
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
  }

  private emitterInitNext() {
    let innerEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EVENT_CHANGE_ALL_ACTIVE,
    }
    emitter.on(innerEvent, (eventData) => {
      this.isAllCardCanSend = eventData?.data?.isAllCardCanSend;
    })
    emitter.on({
      eventId: EmitterConstant.EVENT_RECEIVE_IN_CONTACT,
    }, (data) => {
      HiLog.i(TAG, `emitter.on EVENT_RECEIVE_IN_CONTACT In`);
      if (this.mCreateNewConversationViewModle.haveTwoCards) {
        let slotId: number = data.data!['slotId'];
        this.isSlotIdChange = false;
        if (this.isOnlineRcs && slotId === this.defCellularSlotId) {
          if (!this.changeRcsFlag) {
            this.mCreateNewConversationViewModle.changeIsRcsMms(true, this.isSlotIdChange);
          } else {
            this.mCreateNewConversationViewModle.changeIsRcsMms(false, this.isSlotIdChange);
          }
        } else {
          this.mCreateNewConversationViewModle.changeIsRcsMms(false, this.isSlotIdChange);
          this.isShowMoreMenu = false;
        }
        this.changeMenuItemsRcsValue();
      }
    });
  }

  private removeEmitter() {
    emitter.off(EmitterConstant.EVENT_CHANGE_ALL_ACTIVE);
    emitter.off(EmitterConstant.EVENT_SIM_STATE_CHANGE);
    emitter.off(EmitterConstant.EVENT_SLOTID_CHANGE);
    emitter.off(EmitterConstant.EVENT_RECEIVE_ADD_CONTACT);
    emitter.off(EmitterConstant.EVENT_RECEIVE_IN_CONTACT);
  }

  showKeyboard() {
    this.isShowEmoji = false;
    this.showMMContentPicker = false;
    //表情区关闭，弹出键盘。
    this.mOffsetY = this.mOldKeyboardHeight;
    if (this.mCreateNewConversationViewModle?.isRcsMms) {
      this.mMContentPickerOffsetY = this.mOldKeyboardHeight -
        (this.splitInfoModel.isSmall ? MIN_MM_PICKER_HEIGHT : RCS_MM_PICKER_HEIGHT) - this.bottomPadding;
    } else {
      this.mMContentPickerOffsetY = this.mOldKeyboardHeight - MIN_MM_PICKER_HEIGHT - this.bottomPadding;
    }
    this.mEmojiOffsetY =
      this.mOldKeyboardHeight - (this.splitInfoModel.isEmojiLow ? MIN_MM_PICKER_HEIGHT : EMOJI_HEIGHT);
  }

  showMMContentPickerChange() {
    if (this.showMMContentPicker) {
      this.getUIContext().getFocusController().clearFocus();
      inputMethod.getController().hideTextInput();
    }

    this.changeTextAreaHeight();
  }

  closeKeyboard() {
    //附件区关闭，关闭键盘。
    this.mOffsetY = 0;
    this.mMContentPickerOffsetY = 0;
    this.mEmojiOffsetY = 0;
  }

  splitScreenTypeChange() {
    this.changeTextAreaHeight();
  }

  /**
   * 获取当前key对应的控件高度
   *
   * @param key 控件key/id
   * @returns 控件高度
   */
  private getHeightByKey(key: string): number {
    let height: number = 0;
    if (!key) {
      HiLog.w(TAG, 'return default height zero');
      return height;
    }
    try {
      height = this.getUIContext()
        .px2vp(this.getUIContext()
          .getComponentUtils()
          .getRectangleById(key)
          .size
          .height);
    } catch (e) {
      let err = e as BusinessError;
      HiLog.e(TAG, `getRectangleById error message:${err?.message},code:${err?.code}`);
    }
    HiLog.i(TAG, `getHeightByKey input key: ${key}, and its height: ${height}`);
    return height;
  }

  private getMaxFontSizeScale(): number {
    return this.mFontSizeScale <= 2 ? this.mFontSizeScale : 2;
  }

  changeTextAreaHeight() {
    let currentLine: number = this.controller.getTextContentLineCount();
    this.inputCurrentheight = currentLine * 21 + 16;
    if (this.showMMContentPicker) {
      if (this.splitInfoModel.isLimitOne) {
        this.inputCurrentheight = this.getMaxFontSizeScale() * INPUT_MIN_HEIGHT;
        return
      }
    }
    setTimeout(() => {
      this.inputCurrentheight = 'auto'
    }, 100);
  }

  private isFocus() {
    if (this.receiveCtrl.myText === '' && this.receiveCtrl.selectContacts.length === 0 && !this.mComeFromContact) {
      return false
    } else {
      return true
    }
  }

  private focusMethod() {
    // 根据设置页面显示与否的标记位判断输入框是否需要主动获焦-->设置页面不显示的时候新建页面输入框才主动获取焦点
    if (!this.isSettingsAppear) {
      this.textareaFocusable = true;
      focusControl.requestFocus(Constant.MMS_INPUT_TEXTAREA_Id);
      this.mCreateNewConversationViewModle.changeReceiveInputStatus();
      this.messageAreaFocus();
    }
  }

  messageAreaFocus() {
    let changeFlag: boolean | undefined = AppStorage.get('messageAreaFocusFlag');
    AppStorage.setOrCreate('messageAreaFocusFlag', !changeFlag);
  }

  onKeyboardChange() {
    if (this.mKeyboardHeight === 0) {
      this.mOldKeyboardHeight = this.mKeyboardHeight;
      if (!this.isShowEmoji && !this.showMMContentPicker) {
        if (this.isVDE) {
          this.isHideNewTitle = false;
        }
        this.closeKeyboard();
      }
    } else {
      if (this.isVDE) {
        this.isHideNewTitle = true;
      }
      this.mOldKeyboardHeight = px2vp(this.mKeyboardHeight);
      this.showKeyboard();
    }
  }

  async rcsVoicePermission() {
    let authResults: number = await this.recorderController.initPermission('ohos.permission.MICROPHONE');
    this.recorderPermission = authResults === 0;
    return this.recorderPermission;
  }

  async getCellularData(): Promise<number> {
    this.defCellularSlotId = await DataService.getDefaultCellularDataSlotId();
    AppStorage.setOrCreate('defCellularSlotId', this.defCellularSlotId);
    return this.defCellularSlotId;
  }

  handleSelectedSlotIdChange(): void {
    HiLog.i(TAG,
      `handleSelectedSlotIdChange simSlotId${this.simSlotId}----defCellularSlotId${this.defCellularSlotId}`)
    const lastIsRcs = this.mCreateNewConversationViewModle.isRcsMms;
    if (this.defCellularSlotId !== this.simSlotId && this.cardImage) {
      if (this.showMMContentPicker) {
        this.mOffsetY = this.mmsPickerHeight + this.attachmentBottomHeight;
      }
      this.isSlotIdChange = true;
      this.mCreateNewConversationViewModle.changeIsRcsMms(false, this.isSlotIdChange);
      this.isShowMoreMenu = false;
      if (lastIsRcs === true) {
        this.mCreateNewConversationViewModle.resetValuesSwitchBetweenMmsAndRcs(true);
      }
    } else {
      if (!this.changeRcsFlag) {
        const tempFunction = (currentIsRcs: boolean) => {
          if (this.showMMContentPicker) {
            this.mOffsetY = currentIsRcs ? RCS_MM_PICKER_HEIGHT :
              (this.mmsPickerHeight + this.attachmentBottomHeight);
          }
          (lastIsRcs !== currentIsRcs) &&
          this.mCreateNewConversationViewModle.resetValuesSwitchBetweenMmsAndRcs(lastIsRcs);
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
    this.mCreateNewConversationViewModle.maxSizeOfMms =
      OperatorConfigUtil.getInstance().getCustMMSSize(commonData.int.MMS_FILE_MAX_SIZE) || 307200;
  }

  private handleChangeRcsFlagDetails() {
    this.isShowMoreMenu = true;
    this.isShowRcsButton(true);
    this.changeMenuItemsRcsValue();
  }

  windowStageEventTypeChange() {
    if (this.windowStageEventType === window.WindowStageEventType.PAUSED) {
      // 保存草稿
      this.mCreateNewConversationViewModle.setDraftModel(() => {
        DraftUtils.getInstance().saveDraft(getContext(this), undefined, true, true)
      }, false)
    }
  }

  handleSwitchCard() {
    this.isSlotIdChange = false;
    if (this.isOnlineRcs && this.simSlotId === this.defCellularSlotId) {
      this.mCreateNewConversationViewModle.changeIsRcsMms(true, this.isSlotIdChange);
      this.changeMenuItemsRcsValue();
    } else {
      this.mCreateNewConversationViewModle.changeIsRcsMms(false, this.isSlotIdChange);
      this.isShowMoreMenu = false;
      this.updateRcsMmsStatus();
    }
  }

  changeMenuItemsRcsValue() {
    AppStorage.setOrCreate('rcsMmsStatus', this.mCreateNewConversationViewModle.isRcsMms);
    GlobalContext.getContext().setObject('fileTotalSize', 0);
    AppStorage.setOrCreate('setTotalSizeFlag', false);
    this.updateRcsMmsStatus();
    if (this.mCreateNewConversationViewModle.isRcsMms) {
      this.menuItemList[0].value = $r('app.string.switch_to_SMS_MMS');
      this.handleMenuList();
      this.menuItems[0].value = $r('app.string.switch_to_SMS_MMS');
      this.mTabUtil.animationIterations = 0;
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
      this.menuItems[0].value = $r('app.string.handover_to_enhanced_message');
      contentMoreParams.SELECT_STATE = 6;
      if (this.showMMContentPicker) {
        animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 37) }, () => {
          this.mOffsetY = this.mmsPickerHeight + this.attachmentBottomHeight;
        });
      }
      DotUtil.getInstance().reportEvent(contentMoreParams, dotCommon.eventName.CONTENT_MORE_EVENT);
    }
  }

  updateRcsState(callBack: (currentIsRcs: boolean) => void): void {
    HiLog.i(TAG, 'updateRcsState this.isOnlineRcs: ' + this.isOnlineRcs + 'this.defCellularSlotId: ' +
    this.defCellularSlotId + 'this.simSlotId:' + this.simSlotId)
    if (this.isOnlineRcs && this.simSlotId === this.defCellularSlotId) {
      this.isShowMoreMenu = true;
      this.isSlotIdChange = false;
      this.mCreateNewConversationViewModle.changeIsRcsMms(true, this.isSlotIdChange);
      this.isShowRcsButton(true);
      this.changeMenuItemsRcsValue();
      callBack(true);
    } else {
      this.mCreateNewConversationViewModle.changeIsRcsMms(false, this.isSlotIdChange);
      this.changeRcsFlag = false;
      this.isShowMoreMenu = false;
      this.isShowRcsButton(false);
      if (this.showMMContentPicker) {
        this.mOffsetY = this.mmsPickerHeight + this.attachmentBottomHeight;
      }
      callBack(false);
    }
  }

  private isShowRcsButton(isShow: boolean) {
    if (isShow) {
      this.menuItems[0].visible = true;
    } else {
      this.menuItems[0].visible = false;
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

  handleMenuList() {
    this.isShowRcsButton(false)
  }

  calculateTextInputCount() {
    this.isInput = this.mCreateNewConversationViewModle.textValue.length > 0
    let inputText =
      this.mCreateNewConversationViewModle.getSendText(this.mCreateNewConversationViewModle.textValue, false);
    if (!this.isShowMmsAreaDisplay && this.isInput && !this.mCreateNewConversationViewModle.isRcsMms) {
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
    }
  }

  async calculateTextInputStatisticalCount(isFramework: boolean, oldInputString: string, messageCount?: number,
    lastMessage?: string,) {
    let isTextAsMms: boolean = await this.calculateTextInputStatisticalCountFirst(oldInputString, messageCount);
    if (isTextAsMms) {
      HiLog.i(TAG, 'calculateTextInputStatisticalCountFirst');
      return;
    }
    if (this.mmAttachmentAreaController.mmDisplaySource.length > 0) {
      return;
    }
    let containChinese: boolean = this.mCreateNewConversationViewModle.hasChinese.test(oldInputString)
    let containEmoji: boolean = this.mCreateNewConversationViewModle.isHasEmoji(oldInputString)
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
        this.mCreateNewConversationViewModle.showToast($r('app.string.text_input_limit'));
        let inputMaxLength = statisticCount * 10;
        if (oldInputString.length > this.mCreateNewConversationViewModle.textValue.length) {
          inputMaxLength =
            inputMaxLength - (oldInputString.length - this.mCreateNewConversationViewModle.textValue.length)
        }
        this.mCreateNewConversationViewModle.textValue =
          this.mCreateNewConversationViewModle.textValue.slice(0, inputMaxLength)
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
  }

  async calculateTextInputStatisticalCountFirst(inputString: string, messageCount?: number): Promise<boolean> {
    let isTextAsMms: boolean = await MessageUtil.isMmsText(
      MessageUtil.replaceForLossy7Bit(this.slotId, inputString, 0, inputString.length));
    if (messageCount) {
      if (isTextAsMms || this.mmAttachmentAreaController.mmDisplaySource.length ===
      common.int.MESSAGE_CODE_ONE) {
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
    HiLog.i(TAG, 'calculateTextInputStatisticalCountFirst false');
    return false;
  }

  messageBubbleWidthChange() {
    // 屏幕宽度发生变化，更新附件区高度
    const rowsTemplateValue = this.mmAttachmentAreaController.tabsRowsTemplateValue(this.displayOrientation, this.mCurBp);
    this.mmsPickerHeight = rowsTemplateValue === '1fr 1fr' ? MMS_MM_PICKER_HEIGHT : MIN_MM_PICKER_HEIGHT

    // 附件区高度改变，更新输入区 mOffsetY
    if (this.showMMContentPicker && !this.mCreateNewConversationViewModle?.isRcsMms) {
      this.mOffsetY = this.mmsPickerHeight + this.attachmentBottomHeight;
    }
  }

  async stopRecord(height: number) {
    this.isTouchDown = false;
    this.rcsIsResumeSend = false;
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
      await this.handleReceiveContactsData();
      this.mCreateNewConversationViewModle.sendAudio();
    }
  }

  private getAttachmentButtonDisplay(): boolean {
    if (this.splitInfoModel.isSmall) {
      return false;
    }
    //RCS模式返回 true 不受附件区数量限制
    if (this.mCreateNewConversationViewModle?.isRcsMms) {
      return true;
    }
    //短信模式下 不受附件区数量限制
    return true;
  }

  resetTitle() {
    this.fullHeightMMPicker = false;
    this.topMMContentPicker = this.windowHeight - MIN_MM_PICKER_HEIGHT;
    this.mTabUtil.setTabUtilData(MIN_MM_PICKER_HEIGHT, false, this.windowHeight - MIN_MM_PICKER_HEIGHT);
  }

  conversationNeedChangedOfRcs() {
    HiLog.i(TAG, 'conversationNeedChangedOfRcs');
    if (this.mCreateNewConversationViewModle.mAttachAreaCtrl.mmDisplaySource.length === 0) {
      this.mCreateNewConversationViewModle.isChangeInputPlaceholder = false;
    } else {
      this.mCreateNewConversationViewModle.isChangeInputPlaceholder = true;
      this.resetTitle();
    }
    this.mCreateNewConversationViewModle.refreshSendMessageStatus();
    let fileSize: number = (GlobalContext.getContext()
      .getObject('fileTotalSize') as number) / commonData.int.BYTE_CONVERSION_UNIT;
    fileSize = this.updateFileSizeOfVcard(fileSize)
    const maxSize: number = OperatorConfigUtil.getInstance()
      .getCustMMSSize(commonData.int.MMS_FILE_MAX_SIZE) / commonData.int.BYTE_CONVERSION_UNIT;
    const mmDisplaySource = this.mmAttachmentAreaController?.mmDisplaySource || [];
    this.mCreateNewConversationViewModle.canSendMessage = (
      (this.mCreateNewConversationViewModle.textValue && (mmDisplaySource.length === 0)) ||
        (mmDisplaySource.length > 0 && fileSize <= maxSize)
    ) ? true : false;
    if (mmDisplaySource.length > 0) {
      let countryId = i18n.System.getSystemRegion();
      let numberFormat = new intl.NumberFormat(countryId, { style: 'unit', unit: 'kilobyte', unitDisplay: 'short' });
      let masxSiseStr = numberFormat.format(maxSize);
      this.attachmentSizeDesc = $r('app.string.attachment_current_size_new', LocationUtil.numFormat(Math.floor(fileSize)), masxSiseStr);
      if (fileSize > maxSize) {
        promptAction.showToast({
          message: $r('app.string.attachment_failed', masxSiseStr),
          duration: 2000
        });
      }
    } else {
      this.isShowMmsAreaDisplay = false;
      this.calculateTextInputCount();
    }
  }

  // 如果 vcard文件的大小小于 1 kb，默认设置大小为 1kb
  updateFileSizeOfVcard(fileSize: number) {
    const mmsVcard = this.mmAttachmentAreaController.mmDisplaySource
      .find((item: Mms) => item.type === commonData.MM_ATTACHMENT_TYPE.VCARD)
    if (mmsVcard && fileSize < 1) {
      fileSize = 1
    }
    return fileSize
  }

  conversationNeedChanged() {
    HiLog.i(TAG, 'conversationNeedChanged');
    if (this.isConversationNeedChange) {
      if (this.mCreateNewConversationViewModle.mAttachAreaCtrl.mmDisplaySource.length === 0) {
        this.mCreateNewConversationViewModle.isChangeInputPlaceholder = false;
      } else {
        this.mCreateNewConversationViewModle.isChangeInputPlaceholder = true;
        this.resetTitle();
      }
      this.mCreateNewConversationViewModle.refreshSendMessageStatus();
      AppStorage.setOrCreate('isConversationNeedChange', false);
    }
    let fileSize: number = (GlobalContext.getContext()
      .getObject('fileTotalSize') as number) / commonData.int.BYTE_CONVERSION_UNIT;
    fileSize = this.updateFileSizeOfVcard(fileSize)
    let maxSize: number = OperatorConfigUtil.getInstance()
      .getCustMMSSize(commonData.int.MMS_FILE_MAX_SIZE) / commonData.int.BYTE_CONVERSION_UNIT;
    if (fileSize > maxSize) {
      fileSize = maxSize;
    }
    if (this.mmAttachmentAreaController.mmDisplaySource.length > 0) {
      let countryId = i18n.System.getSystemRegion();
      let numberFormat = new intl.NumberFormat(countryId, { style: 'unit', unit: 'kilobyte', unitDisplay: 'short' });
      let masxSiseStr = numberFormat.format(maxSize);
      this.attachmentSizeDesc = $r('app.string.attachment_current_size_new', LocationUtil.numFormat(Math.floor(fileSize)), masxSiseStr);
      this.mmAttachmentAreaController.mmDisplaySource[0].size = GlobalContext.getContext()
        .getObject('fileTotalSize') as string;
    } else {
      this.isShowMmsAreaDisplay = false;
      this.calculateTextInputCount();
    }
  }

  displayChangedEvent() {
    this.isShowMmsAreaDisplay = this.mmAttachmentAreaController.mmDisplaySource.length > 0 ? true : false;
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

  fullScreenPaddingChange() {
    this.topPadding = this.mFullScreenPadding ? (this.mFullScreenPadding.top as number) : 0;
    this.bottomPadding = this.mFullScreenPadding ? (this.mFullScreenPadding.bottom as number) : 0;
  }

  private getPlaceholder(): ResourceStr {
    if ( this.mCreateNewConversationViewModle.isChangeInputPlaceholder) {
      return  $r('app.string.msg_note_mms2');
    }
    if (this.mCreateNewConversationViewModle.isRcsMms) {
      return $r('app.string.msg_note_rcs');
    }
    return $r('app.string.msg_note_mms');
  }
}

@Builder
function menuComponent(params: ParamsInterface) {
  Menu() {
    MenuItem({ content: params.menuItem })
      .visibility(params.isVDE ? Visibility.None : Visibility.Visible)
      .onClick(() => {
        params.changeMenuItemsValue()
      })
  }
  .width(224).menuItemDivider({ strokeWidth: LengthMetrics.px(1), color: $r('sys.color.comp_divider') })
}
