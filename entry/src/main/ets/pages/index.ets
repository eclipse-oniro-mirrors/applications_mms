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
import IndexController from './indexController'
import ConversationList from './conversationlist/conversationList'
import ConListController from './conversationlist/conversationListController';
import common from '../data/commonData';
import MmsPreferences from '../utils/MmsPreferences';
import HashMap from '@ohos.util.HashMap';
import HiLog from '../utils/HiLog'
import WantUtil from '../utils/WantUtil';
import hiTraceMeter from '@ohos.hiTraceMeter';
import TraceConstant from '../data/TraceConstant';
import { Mms } from '../utils/TypesUtils';
import { emitter } from '@kit.BasicServicesKit';
import EmitterConstant from '../data/EmitterConstant';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import SearchUtil, { SearchType } from '../utils/SearchUtil';
import DeviceUtil from '../utils/DeviceUtil';
import ConversationController from './conversation/conversationController';
import { EnhancedInfoTemporaryDataSource } from '../model/EnhancedInfoTemporaryDataSource';
import { CustomContentDialog, display, mediaquery } from '@kit.ArkUI';
import myCommon from '@ohos.app.ability.common'
import { AnimateCallback, CustomNavigationUtils } from '../utils/CustomNavigationUtils';
import lazy fs from '@ohos.file.fs';
import commonData from '../data/commonData';
import SettingsController from './settings/settingsController';
import EnableNotificationDialogContent from './EnableNotificationDialogContent';
import AppStorageKeyConstant from '../data/AppStorageKeyConstant';

const TAG = 'Index';
let storage = LocalStorage.getShared()


@Entry(storage)
@Component
struct Index {
  @LocalStorageProp('fullScreenPadding') fullScreenPadding:Padding | null = null;
  @StorageLink('curBp') @Watch('onBreakPointChanged') curBp: string = common.STR.DEVICE_MOBILE_PHONE;
  @StorageLink('indexNeedShow') @Watch('showIndexPage') indexNeedShow: boolean = false;
  @StorageLink('selectPhoneNumber') selectPhoneNumber: string = '';
  @StorageLink('isOpenRcsTestSetting') isOpenRcsState: boolean =
    SharedPreferencesUtils.getFromPreferences('isUIOpenRcs', false) as boolean;
  @StorageLink('rcsChatBotSettingIsOn') isChatbotOn: boolean =
    SharedPreferencesUtils.getFromPreferences('isUIChatbotOpenRcsHasChanged', false) as boolean ?
      SharedPreferencesUtils.getFromPreferences('isUIChatbotOpenRcs', false) as boolean : this.isOpenRcsState;
  @StorageLink('showChatbotNotice') showChatbotNotice: boolean =
    !(SharedPreferencesUtils.getFromPreferences('notShowChatbotNotice', false) as boolean);
  @Provide('pageInfos') pageInfos : NavPathStack = new NavPathStack()
  @Provide storagePixelMap: HashMap<string, PixelMap> = new HashMap<string, PixelMap>();
  @Provide cactusPixelMap: HashMap<string, string> = new HashMap<string, string>();
  @State mIndexCtrl: IndexController = IndexController.getInstance();
  @State mConListCtrl: ConListController = ConListController.getInstance();
  @State mConversationCtrl: ConversationController = ConversationController.getInstance();
  @StorageLink('mmsScreenPercentage') screenPercentage: string = '50%';
  @StorageLink('mmsNavMode') curNavMode: number = 0;
  @Provide unreadTotalOfInfo: number = 0;
  @Provide isPageOnFocus: boolean = true;
  @State isSmartOpen: boolean = false;
  private context = getContext(this) as myCommon.UIAbilityContext;
  private listener = mediaquery.matchMediaSync('(orientation: landscape)')
  private portraitFunc: Callback<mediaquery.MediaQueryResult> | undefined
  private landscapeRatio: string = '40%'
  private portraitRatio: string = '50%'
  @StorageProp('isHideIndexPage') isHideIndexPage: boolean = false;
  @State textDirection: string = '';
  @StorageLink('isSearching') isSearching: boolean = false;
  @StorageProp(AppStorageKeyConstant.IS_NEW_WANT_FROM_HOME) @Watch('isNewWantFromHomeChange') isNewWantFromHome: boolean =
    true;
  // 获取是否进入坚盾守护模式
  private isAdvancedMode: boolean = SharedPreferencesUtils.getFromPreferences('isAdvancedMode', false) as boolean;
  private checkNotificationEnabledCallback: Function = () => {
    this.enableNotificationDialog?.open();
  }
  /**
   * 打开短信通知提醒弹窗
   */
  private enableNotificationDialog: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.enableNotificationDialogContent();
      },
      buttons: [
        {
          value: $r('app.string.enable_notification_dialog_not_allowed'),
          action: () => {
            this.mIndexCtrl.notAllowedSetEnableNotification();
          }
        },
        {
          value: $r('app.string.enable_notification_dialog_allowed'),
          action: () => {
            this.mIndexCtrl.setNotificationEnable();
          }
        }],
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      HiLog.i(TAG, `enableNotificationDialog onWillDismiss reason: ${dismissDialogAction.reason}`);
      if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
        return;
      }
    },
    showInSubWindow: true,
    autoCancel: false,
  })

  @Builder
  enableNotificationDialogContent(): void {
    EnableNotificationDialogContent();
  }

  showIndexPage() {
    HiLog.i(TAG, 'showIndex...' );
    this.onPageShow();
  }

  refreshLayout() {
    try {
      let orientation = display.getDefaultDisplaySync().orientation;
      HiLog.i(TAG, `refreshLayout curBp:${this.curBp}, orientation:${orientation}`);
      if (this.curBp === common.STR.DEVICE_FLAT_PLATE) {
        if ((orientation === display.Orientation.LANDSCAPE ||
          orientation === display.Orientation.LANDSCAPE_INVERTED)) {
          this.screenPercentage = this.landscapeRatio;
        } else {
          this.screenPercentage = this.portraitRatio;
        }
      } else {
        this.screenPercentage = this.portraitRatio;
      }
      AppStorage.setOrCreate('mmsPadMargin', DeviceUtil.padMargin());
    } catch (err) {
      HiLog.e(TAG, `refreshLayout err code:${err?.code}, msg:${err?.msg}.`);
    }
  }

  onBreakPointChanged() {
    this.refreshLayout();
  }

  onScreenChanged(mediaQueryResult: mediaquery.MediaQueryResult) {
    this.refreshLayout();
  }

  isNewWantFromHomeChange() {
    // 热启动时，非桌面图标进入短信，需要关闭应用通知提醒弹窗
    if (!this.isNewWantFromHome) {
      HiLog.w(TAG, `isNewWantFromHome need close enableNotificationDialog`);
      this.enableNotificationDialog?.close();
    }
  }

  /**
   * The function executes after a new instance of the custom component is created and before its build function
   * is executed.
   * Allows state variables to be changed in the aboutToAppear function, and these changes will take effect in
   * subsequent executions of the build function.
   */
  aboutToAppear() {
    hiTraceMeter.startTrace(TraceConstant.TRACE_INDEX_ABORT_TO_APPEAR, TraceConstant.TRACE_INDEX_ABORT_TO_APPEAR_ID);
    HiLog.i(TAG, 'aboutToAppear of index');
    AppStorage.setOrCreate('pageInfos', this.pageInfos);
    this.calculateScreenRatio();
    this.mIndexCtrl.onInit();
    this.mConListCtrl.onInit(this.context);
    AppStorage.setOrCreate('isBackProcess', false);
    AppStorage.setOrCreate('initFlag', true);
    AppStorage.setOrCreate('invokeCamera', false)
    AppStorage.setOrCreate('setTotalSizeFlag', false);
    AppStorage.setOrCreate('comeFromContact', false)
    AppStorage.setOrCreate('downloadListUsing', false);
    this.isSmartOpen = SharedPreferencesUtils.getFromPreferences('isOpenSmart', false) as boolean;
    SharedPreferencesUtils.saveToPreferences('downloadList', [])
    hiTraceMeter.finishTrace(TraceConstant.TRACE_INDEX_ABORT_TO_APPEAR,TraceConstant.TRACE_INDEX_ABORT_TO_APPEAR_ID);
    this.mIndexCtrl.checkNotificationEnabled(this.context, this.checkNotificationEnabledCallback);
  }

  /**
   * Obtains the iPad screen ratio.
   * Changing the landscape/portrait screen ratio of the ipad to the screen is not fixed
   */
  private calculateScreenRatio() {
    this.portraitFunc = this.onScreenChanged.bind(this);
    this.listener.on(common.notificationLocal.NOTIFICATION_LOCAL_SCREEN_CHANGE,
      this.portraitFunc);
    this.refreshLayout();
  }

  /**
   * Function executes before custom component destructor consumption.
   * Changing state variables in the aboutToDisappear function is not allowed, especially changes to the @Link
   * variable may cause unstable application behavior.
   */
  aboutToDisappear() {
    HiLog.i(TAG, 'aboutToDisappear of index');
    this.mConListCtrl.onDestroy();
    this.mIndexCtrl.onDestroy();
    this.listener.off(common.notificationLocal.NOTIFICATION_LOCAL_SCREEN_CHANGE, this.portraitFunc);
    AppStorage.Delete('pageInfos');
    AppStorage.delete('isBackProcess');
    AppStorage.delete('invokeCamera')
    AppStorage.delete('setTotalSizeFlag');
    AppStorage.delete('comeFromContact');
    AppStorage.delete('downloadListUsing');
    this.storagePixelMap.forEach(value => {value?.release()})
    this.mConversationCtrl.releaseConversationPixelMap();
    EnhancedInfoTemporaryDataSource.getInstance().releasePixelMaps();
    this.cactusPixelMap.forEach((v?: string, k?: string) => {
      if (fs.accessSync(v)) {
        fs.unlinkSync(v);
      }
    })
    this.enableNotificationDialog?.close();
  }

  /**
   * Triggers once when this page is displayed. In scenarios such as routing and application access to the foreground
   * and background, only customized components modified by @Entry take effect.
   */
  async onPageShow() {
    HiLog.i(TAG, 'onPageShow...')
    hiTraceMeter.startTrace(TraceConstant.TRACE_INDEX_ON_PAGE_SHOW, TraceConstant.TRACE_INDEX_ON_PAGE_SHOW_ID);
    AppStorage.set('isBackProcess', false)
    AppStorage.set('listIsScrolling', false);
    WantUtil.getWant(this.context, this.pageInfos);
    await MmsPreferences.getInstance().initPreferences();
    this.mIndexCtrl.onShow();
    this.mConListCtrl.onShow(this.context, this.pageInfos);
    emitter.emit(EmitterConstant.EVENT_ON_SHOW_INDEX);

    this.isChatbotOn = SharedPreferencesUtils.getFromPreferences('isUIChatbotOpenRcsHasChanged', false) as boolean ?
      SharedPreferencesUtils.getFromPreferences('isUIChatbotOpenRcs', false) as boolean : this.isOpenRcsState;
    hiTraceMeter.finishTrace(TraceConstant.TRACE_INDEX_ON_PAGE_SHOW, TraceConstant.TRACE_INDEX_ON_PAGE_SHOW_ID);
    this.showChatbotNotice = !(SharedPreferencesUtils.getFromPreferences('notShowChatbotNotice', false) as boolean);
  }

  /**
   * Triggers once when this page disappears. In scenarios such as routing and application access to the foreground
   * and background, only customized components modified by @Entry take effect.
   */
  async onPageHide() {
    HiLog.i(TAG, 'onPageConceal...');
    this.mConversationCtrl.publishData(false, common.int.NUMBER_ZERO);
    AppStorage.set(commonData.STR.IS_BACK_HOMEPAGE, false);
    hiTraceMeter.startTrace(TraceConstant.TRACE_INDEX_ON_PAGE_HIDE, TraceConstant.TRACE_INDEX_ON_PAGE_HIDE_ID);
    AppStorage.setOrCreate('stopAudio', { duration: '', type: -1, path: '', name: '' } as Mms);
    AppStorage.set('isBackProcess', true)
    let audioPlayerService = await import('../service/AudioPlayerService')
    audioPlayerService.AudioPlayerService.getInstance().stopAudio();
    this.mConListCtrl.onHide();
    this.mIndexCtrl.onHide();
    SearchUtil.releaseService();
    // 增加关闭首选项库
    SharedPreferencesUtils.deletePreferencesDelay();
    AppStorage.setOrCreate('stopRecordTime', new Date().getTime());
    hiTraceMeter.finishTrace(TraceConstant.TRACE_INDEX_ON_PAGE_HIDE, TraceConstant.TRACE_INDEX_ON_PAGE_HIDE_ID);
  }

  /**
   * Triggered when a user clicks the back button. Only the customized component modified by @Entry takes effect.
   * If true is returned, the page processes the return logic and does not route the page.
   * If false is returned, the default return logic is used.
   * If no value is returned, the value is treated as false.
   */
  onBackPress(): boolean {
    HiLog.i(TAG, 'onBackPress');

    const isSearch:boolean=AppStorage.get('isSearch')??false
    if (isSearch) {
      AppStorage.set('isSearch',false)
      return true
    } else if (this.mIndexCtrl.showConList) {
      return this.mConListCtrl.onBackPress(this.context);
    }
    return false;
  }

  build() {
    Navigation(this.pageInfos) {
      ConversationList({
        mConListCtrl: $mConListCtrl
      })
        .padding({
          top: 0,
          left: this.fullScreenPadding ? (this.fullScreenPadding.left as number) : 0,
          right: this.fullScreenPadding ? (this.fullScreenPadding.right as number) : 0,
        })
    }
    .mode(this.curBp === common.STR.DEVICE_MOBILE_PHONE ? NavigationMode.Stack : NavigationMode.Auto)
    .navBarWidth(this.screenPercentage)
    .hideTitleBar(true)
    .onNavBarStateChange((isVisible: boolean) => {
        hiTraceMeter.startTrace(TraceConstant.TRACE_INDEX_ON_NAV_BAR_CHANGE,
          TraceConstant.TRACE_INDEX_ON_NAV_BAR_CHANGE_ID);
        let initFlag: boolean = AppStorage.Get('initFlag') as boolean;
        HiLog.i(TAG, 'onNavBarStateChange : ' + isVisible + ' , initFlag : ' + initFlag);
        if (isVisible) {
          // 首次启动应用时，不需要重复调用onPageShow，存在重复刷新问题
          if (initFlag) {
            AppStorage.setOrCreate('initFlag', false);
          } else {
            this.onPageShow();
          }
        }
        hiTraceMeter.finishTrace(TraceConstant.TRACE_INDEX_ON_NAV_BAR_CHANGE,
          TraceConstant.TRACE_INDEX_ON_NAV_BAR_CHANGE_ID);
      })
    .backgroundColor($r('sys.color.ohos_id_color_background'))
    .visibility((EnhancedInfoTemporaryDataSource.getInstance().isHideIndexPage ||
    this.isHideIndexPage) ? Visibility.None : Visibility.Visible)
    .onNavigationModeChange((navigationMode) => {
      HiLog.i(TAG, 'curBp or navigationMode has change. navigationMode：' + navigationMode + 'curBp:' + this.curBp)
      this.curNavMode = navigationMode;
      let pages: string[] = this.pageInfos?.getAllPathName();
      if (pages !== undefined){
        this.mConListCtrl.lastIndex = -1;
        if (navigationMode === common.int.NAVIGATION_MODE_STACK || DeviceUtil.isFloatingScreen()) {
          // 直板机或悬浮窗 移除默认页面
          if (this.isSearching) {
            this.pageInfos?.clear(false);
            setTimeout(() => {
              focusControl.requestFocus('search_bar' + SearchType.FULL);
            }, 50)
          }
          if (this.mConListCtrl.isMultipleSelectState) {
            this.pageInfos.clear(false)
          }
        } else if (navigationMode === common.int.NAVIGATION_MODE_SPLIT && pages.length === 0) {
          // 非直板机 默认展示首条信息
          if (this.isSearching) {
            this.isPageOnFocus = false;
            this.mConListCtrl.showFirstMessage(undefined, true);
            focusControl.requestFocus('search_bar' + SearchType.FULL);
            // 组件提供的临时方案 用于避免折叠到展开时push NavDestination页面过程中抢输入法的焦点
            setTimeout(() => {
              this.isPageOnFocus = true;
            }, 50)
          } else {
            this.mConListCtrl.showFirstMessage(true);
          }
        }
      }
    })
  }
}