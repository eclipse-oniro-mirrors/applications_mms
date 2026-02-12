/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import Ability from '@ohos.app.ability.UIAbility';
import Window from '@ohos.window';
import window from '@ohos.window';
import HiLog from '../utils/HiLog';
import { MmsWindowsManager } from '../utils/WindowsManager';
import MmsPreferences from '../utils/MmsPreferences';
import WorkFactory, { WorkerType } from '../workers/WorkFactory';
import simCardService from '../service/SimCardService';
import WantUtil from '../utils/WantUtil';
import display from '@ohos.display';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import { BusinessError } from '@ohos.base';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import OperatorConfigUtil from '../../cust/utils/OperatorConfigUtil';
import mmsUitlCtr from '../utils/MmsUtil';
import { Configuration } from '@ohos.app.ability.Configuration';
import DataShareHelper from '../model/repository/DataShareHelper';
import { AudioPlayerService } from '../service/AudioPlayerService';
import media from '@ohos.multimedia.media';
import RcsDataPreferences from '../utils/RcsDataPreferences';
import TelephoneUtil from '../utils/TelephoneUtil';
import { taskpool } from '@kit.ArkTS';
import hiTraceMeter from '@ohos.hiTraceMeter';
import TraceConstant from '../data/TraceConstant';
import { common, ConfigurationConstant } from '@kit.AbilityKit';
import BackupRestoreRpc from '../ServiceExtension/AutoBackupRestoreRpc/BackupRestoreRpc';
import lazy { SplitScreenManager } from '../utils/SplitScreenManager'
import { GlobalContextKey } from '../data/commonData';
import DeviceUtil from '../utils/DeviceUtil';
import ConversationListController from '../pages/conversationlist/conversationListController';
import ConversationController from '../pages/conversation/conversationController';
import dotUtil from '../utils/MmsDot/DotUtils';
import { DateUtil } from '../utils/DateUtil';
import Intl from '@ohos.intl';
import { CancelNotificationTimeLock } from '../utils/Locks/TimeLock';
import commonData from '../data/commonData';
import { GlobalContext, pxs2vps } from './GlobalHelper';
import ScreenAdapterUtils from '../utils/ScreenAdapterUtils';
import { EnhancedInfoTemporaryDataSource } from '../model/EnhancedInfoTemporaryDataSource';
import ConversationModel from '../model/ConversationModel';
import { CountryIdUtil } from '../utils/CountryIdUtil';
import AccessibilityUtil from '../utils/AccessibilityUtil';
import myCommon from '../data/commonData';
import { UnLockedNotifyService } from '../utils/UnLockedNotifyService';
import AppStorageKeyConstant from '../data/AppStorageKeyConstant';

const TAG = 'app';
const DELAY_TIME = 6000;

export interface SetOrCreateParams {
  top: number,
  bottom: number,
  left: number,
  right: number
}

/**
 * 冷启动时，获取无效的数据（session，mms_info,rcs_info，part_info）
 */
@Concurrent
async function getInvalidData(context: Context) {
  let urls: string[] = [myCommon.STR.URI_MESSAGE_INVALID_SESSION_COUNT,
    myCommon.STR.URI_MESSAGE_INVALID_INFO_COUNT,
    myCommon.STR.URI_MESSAGE_INVALID_RCS_INFO_COUNT,
    myCommon.STR.URI_MESSAGE_INVALID_RCS_INFO_MSG_COUNT,
    myCommon.STR.URI_MESSAGE_INVALID_PART_INFO_COUNT];
  let conversationModel: ConversationModel = new ConversationModel();
  let counts: number[] = [];
  urls.forEach((urlStr) => {
    conversationModel.getInvalidDataFromDb(context, urlStr, counts);
  })
}

export default class MainAbility extends Ability {
  storage: LocalStorage = new LocalStorage();
  private windowObj?: window.Window;
  private wdStage?: window.WindowStage;
  private uiContext?: UIContext;
  private lastColorMode: ConfigurationConstant.ColorMode | undefined = undefined;
  private isPC: boolean = false
  private reportTimer: number | null = null;
  private timerId: number = -1;
  /** 是否已执行增强信息应用的黑名单数据的迁移操作 */
  private alreadyMigrateChatbotBlocklist: boolean = false;
  /** 定时器ID,该定时器用于执行增强信息应用的黑名单数据的迁移操作 */
  private timeoutIdOfMigrateChatbotBlocklist: number | undefined;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hiTraceMeter.startTrace(TraceConstant.TRACE_MAINABILITY_CREATE, TraceConstant.TRACE_MAINABILITY_CREATE_ID);
    HiLog.iw(TAG, 'Ability onCreate com.ohos.mms');
    if (AppStorage.get('receiveSessionArray') === undefined){
      AppStorage.setOrCreate('receiveSessionArray', []);
    }
    if (want.action && want.action !== commonData.STR.LAUNCH_MMS_BY_HOME) {
      // 非桌面拉起短信应用，则默认不能执行取消所有通知操作。
      CancelNotificationTimeLock.getInstance().setLock('onCreate');
    }
    AppStorage.setOrCreate(AppStorageKeyConstant.IS_START_FROM_HOME,
      want?.action === commonData.STR.LAUNCH_MMS_BY_HOME);
    HiLog.w(TAG, `Ability onCreate want.action is: ${want?.action}`);
    this.enableSuggestCache();
    GlobalContext.getContext().setObject('DataWorker', WorkFactory.getWorker(WorkerType.DataWorker));
    // 业务场景需要，冷启动关键数据库为SMS & Contact，优先并行初始化
    try {
      AppStorage.setOrCreate(GlobalContextKey.QUERY_CONTACT_DATA_ON_COLD_START_UP, true)
      DataShareHelper.getInstance().initSilenceContactDataTable(this.context)
        // SMS & Contact初始化
        Promise.resolve(
        DataShareHelper.getInstance().initSmsDB(this.context),
      ).then(async () => {
        // 等待SMS & Contact数据库初始化完成，再初始化其他数据库
        DataShareHelper.getInstance().initYellowPageDB(this.context);
      });
    } catch (error) {
      HiLog.e(TAG, `Database initialization failed: ${error}`);
    }
    RcsDataPreferences.getInstance().loadRcsInfoPreferences(this.context);
    GlobalContext.getContext().setObject('mmsContext', this.context);
    GlobalContext.getContext().setObject('abilityWant', want);
    GlobalContext.getContext().setObject('needToUpdate', true);
    SharedPreferencesUtils.init(this.context);
    MmsPreferences.getInstance().initPreferences();
    AppStorage.setOrCreate<Map<String, media.AVPlayerState>>(
      AudioPlayerService.AUDIO_FILE_PLAY_STATE,
      new Map()
    );
    HiLog.w(TAG, '[onCreate] currentColorMode: ' + this.context?.config?.colorMode);
    AppStorage.setOrCreate('currentColorMode', this.context?.config?.colorMode);
    this.delayOnCreateWorker(want);
    hiTraceMeter.finishTrace(TraceConstant.TRACE_MAINABILITY_CREATE, TraceConstant.TRACE_MAINABILITY_CREATE_ID);
    dotUtil.getInstance().startStatisticReport();
    AccessibilityUtil.getAccessibilitySwitchState();
    clearTimeout(this.reportTimer);
    this.reportTimer = setTimeout(async () => {
      dotUtil.getInstance().switchStatusReport(this.context);
    }, DELAY_TIME);
  }

  //使能温启动,可以快速启动信息应用
  enableSuggestCache() {
    HiLog.i(TAG, 'Application enableSuggestCache')
    let applicationContext = this.context.getApplicationContext();
    try {
      applicationContext.setSupportedProcessCache(true);
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      HiLog.e(TAG, `setSupportedProcessCache fail, code: ${code}, msg: ${message}`);
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    HiLog.i(TAG, 'Application onNewWant');
    if (want.action && want.action !== commonData.STR.LAUNCH_MMS_BY_HOME) {
      //非桌面拉起短信应用，则默认不能执行取消所有通知操作。
      CancelNotificationTimeLock.getInstance().setLock('onNewWant')
    }
    AppStorage.setOrCreate(AppStorageKeyConstant.IS_NEW_WANT_FROM_HOME,
      want?.action === commonData.STR.LAUNCH_MMS_BY_HOME);
    HiLog.w(TAG, `Application onNewWant want.action is: ${want?.action}`);
    GlobalContext.getContext().setObject('abilityWant', want);
    let pageInfos = AppStorage.Get<NavPathStack>('pageInfos');
    if (pageInfos !== undefined) {
      WantUtil.getWant(this.context, pageInfos);
    }
  }

  onWindowStageCreate(windowStage: Window.WindowStage): void {
    HiLog.i(TAG, 'Ability onWindowStageCreate');
    GlobalContext.getContext().setObject('mmsWindowStage', windowStage);
    this.isPC = DeviceUtil.isPC();
    this.adaptiveAging();
    try {
      // 添加一次性定时器，防止可能因为窗口未创建就操作该窗口而导致窗口状态异常(err:1300002)
      setTimeout(() => {
        Window.getLastWindow(this.context, (err, windowObj) => {
          if (err.code) {
            HiLog.e(TAG, 'Window.getLastWindow error: ' + JSON.stringify(err));
            return;
          }
          this.updateWindow(windowObj)
        })
      }, 150)
    } catch (exception) {
      HiLog.e(TAG, 'Window.getLastWindow exception: ' + JSON.stringify(exception));
    }
    // Main window is created, set main page for this ability
    windowStage.loadContent('pages/index', this.storage, (err, data) => {
      if (err.code) {
        HiLog.e(TAG, 'Failed to load the content.');
        return;
      }
      HiLog.i(TAG, 'Succeeded in loading the content. Data: %{public}s');
      windowStage.getMainWindow((err, data: window.Window) => {
        if (err.code) {
          HiLog.e(TAG, 'Failed to obtain the main window.');
          return;
        }
        let windowClass: window.Window = data;
        this.windowObj = data;
        this.uiContext = data?.getUIContext();
        // SmartMmsClient.setUIContext(this.uiContext);
        this.setIsVDEFoldPhoneAndFoldedState();
        this.addDisplayChangeListener();
        this.onWindowSizeChange();
        try {
          if (this.isPC) {
            data.setWindowDecorVisible(false);
            data.setWindowDecorHeight(56);
          }
        } catch (err) {
          HiLog.e(TAG, 'Failed to setWindowDecorVisible.');
        }
        //设置监听键盘变化,用来设置详情页底部输入框避让输入法
        try {
          windowClass.on('keyboardHeightChange', (data) => {
            AppStorage.setOrCreate('keyboardHeight', data);
            HiLog.i(TAG, 'onWindowStageCreate keyboardHeight : ' + AppStorage.get('keyboardHeight'))
          });
        } catch (exception) {
          HiLog.e(TAG, 'Failed to enable the listener for keyboard height changes.');
        }
      });
      try {
        this.reportDrawnEncap();
      } catch (err) {
        let code = (err as BusinessError).code;
        let message = (err as BusinessError).message;
        HiLog.e(TAG, `reportDrawnCompleted failed, code is ${code}, message is ${message}`);
      }
    });

    try {
      windowStage.on('windowStageEvent', (data) => {
        HiLog.i(TAG,'Succeeded in enabling the listener for window stage event changes.');
        AppStorage.setOrCreate('windowStageEventType', data);
      });
    } catch (exception) {
      HiLog.e(TAG,`Failed to enable the listener for window stage event changes. Cause code: ${exception.code},
       message: ${exception.message}`);
    }
    this.wdStage = windowStage;
    // Paf UiWidget 初始化
    // PafUiWidget.init(windowStage, this.context)
  }

  private adaptiveAging() {
    let context = (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);
    let fontSizeScale = context.config.fontSizeScale ?? 1;
    AppStorage.setOrCreate('fontSizeScale', fontSizeScale);
  }

  private reportDrawnEncap() {
    setTimeout(
      () => {
        this.context.reportDrawnCompleted((err) => {
          if (err.code) {
            HiLog.e(TAG, `reportDrawnCompleted failed, code is ${err.code}, message is ${err.message}`);
            return;
          }
          HiLog.i(TAG, 'reportDrawnCompleted succeed');
        });
      }, 700
    )
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    HiLog.w(TAG, '[Ability onConfigurationUpdate] colorMode : ' + newConfig.colorMode);
    AppStorage.setOrCreate('fontSizeScale', newConfig.fontSizeScale ?? 1)
    AppStorage.setOrCreate('currentColorMode', newConfig.colorMode);
    AppStorage.setOrCreate('currentLanguage', newConfig.language);
    // PafUiWidget.configurationUpdate(newConfig);
    DateUtil.updateIntlLocalAndFormatters(new Intl.Locale());
    this.setSystemBarProps(newConfig);
    let lastLan = SharedPreferencesUtils.getFromPreferences('lastLanguage', 'zh-Hans-CN');
    HiLog.w(TAG, 'getCurrentLanguage: ' + newConfig.language + ' value: ' + lastLan);
    if (newConfig.language) {
      let res = newConfig.language.localeCompare(lastLan as string);
      if (res !== 0) {
        HiLog.w(TAG, `lastLanguage changed...`);
        SharedPreferencesUtils.saveToPreferences('lastLanguage', newConfig.language);
        // 语言和上一次有变化 获取国家码
        let countryId: string = CountryIdUtil.getCountryId();
        AppStorage.setOrCreate('country', countryId);
      }
    }
  }

  async updateWindow(windowObj: Window.Window): Promise<void> {
    HiLog.e(TAG, 'Ability async updateWindow');
    try {
      this.updateWindowSize(windowObj);
      this.listeningWindowChanges(windowObj);//执行这个方法会报错
      // register avoidAreaChange
      windowObj.on('avoidAreaChange', (data) => {
        let topRectH: number = -1;
        let bottomRectH: number = -1;
        if (window.AvoidAreaType.TYPE_SYSTEM === data.type) {
          topRectH = data.area.topRect.height;
        } else if (window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR === data.type) {
          bottomRectH = data.area.bottomRect.height;
        }
        let pxs: number[] = [];
        pxs.push(topRectH);
        pxs.push(bottomRectH);
        pxs2vps(pxs).then(
          (vps: number[]) => {
            this.handleAvoidAreaChange(vps[0], vps[1]);
          })
      });
    } catch (exception) {
      console.error(TAG, 'Failed to obtain the area. Cause:' + JSON.stringify(exception));
    }
    // 设置全屏和bar属性
    MmsWindowsManager.getInstance().initForPhone(windowObj, this.context);
  }

  private updateWindowSize(windowObj: Window.Window) {
    let properties: Window.WindowProperties = windowObj.getWindowProperties();
    SplitScreenManager.getInstance().updateScreenSize(properties.windowRect.width, properties.windowRect.height);
    let avoidArea = windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    let navigationArea = windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    AppStorage.setOrCreate('bottomAvoidHeight', navigationArea.bottomRect.height);
    let pxs: number[] = [];
    pxs.push(properties.windowRect.width);
    pxs.push(properties.windowRect.height);
    pxs.push(avoidArea.topRect.height);
    pxs.push(navigationArea.bottomRect.height);
    pxs.push(EnhancedInfoTemporaryDataSource.CHATBOT_CARD_DIVIDER_VP_WIDTH);
    //avoidArea height is as windows status bar height
    pxs2vps(pxs).then(
      (vps: number[]) => {
        // 调整宽度
        this.handleWindowSizeChange(vps[0], windowObj);
        // 调整宽度
        this.updateWindowHeight(vps[1]);
        // 调整上下避让
        this.handleAvoidAreaChange(vps[2], vps[3]);
        EnhancedInfoTemporaryDataSource.ONE_PX_TO_VP = vps[4];
      }
    );
  }

  listeningWindowChanges(windowObj: Window.Window) {
    // 增加窗口变化监听
    windowObj.on('windowSizeChange', (data) => {
      HiLog.i(TAG, 'windowSizeChange..')
      this.onWindowSizeChange();
      let pxs: number[] = [];
      pxs.push(data.width);
      pxs2vps(pxs).then(
        (vps: number[]) => {
          this.handleWindowSizeChange(vps[0], windowObj);
        })
      SplitScreenManager.getInstance().updateScreenSize(data.width, data.height)
      AppStorage.setOrCreate('displayOrientation', display.getDefaultDisplaySync().orientation)
      if (this.isPC) {
        AppStorage.setOrCreate('isWindowSizeChange', data);
      }
    });

    windowObj.on('windowRectChange', (data: window.RectChangeOptions) => {
      SplitScreenManager.getInstance().updateSplitScreenPosition(data.rect);
    });

    windowObj.on('windowRectChange', (data: window.RectChangeOptions) => {
      SplitScreenManager.getInstance().updateSplitScreenPosition(data.rect);
    });

    //绑定窗口模式变化监听
    windowObj.on('windowStatusChange', (windowStatusType) => {
      AppStorage.setOrCreate('windowStatusType', windowStatusType)
      SplitScreenManager.getInstance().updateWindowStatusType(windowStatusType)
      HiLog.i(TAG, 'Succeeded listener for window status changes. Data: ' + JSON.stringify(windowStatusType));
    });
  }

  addDisplayChangeListener() {
    if (!this.uiContext) {
      HiLog.w(TAG, ` addDisplayChangeListener this.uiContext is null.`);
      return;
    }
    try {
      // 由于屏幕密度变化监听可能导致窗口大小更新异常使接短信宽度不更新让短信展示不出来，因此先暂时注释掉 densityUpdate事件
      this.uiContext.getUIObserver().on('densityUpdate', () => {
        try {
          Window.getLastWindow(this.context, (err, windowObj) => {
            if (err.code) {
              HiLog.e(TAG, `addDisplayChangeListener Window.getLastWindow error: ${err?.code}, ${err?.message}`);
              return;
            }
            this.updateWindowSize(windowObj);
          })
        } catch (err) {
          HiLog.e(TAG, `addDisplayChangeListener updateWindowSize err: ${err?.code}, ${err?.message} `);
        }
      });
    } catch (err) {
      HiLog.e(TAG, ` addDisplayChangeListener get error.`);
    }
  }

  private onWindowSizeChange(): void {
    if (this.uiContext) {
      let widthBp: WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
      AppStorage.setOrCreate('currentWidthBreakpoint', widthBp);
      let heightBp: HeightBreakpoint = this.uiContext!.getWindowHeightBreakpoint();
      AppStorage.setOrCreate('currentHeightBreakpoint', heightBp);
      try {
        HiLog.i(TAG, 'onWindowSizeChange FoldStatus is : ' + display.getFoldStatus());
        if (ScreenAdapterUtils.getInstance().isVDESquareScreen() && display.getFoldStatus() == 2) {
          AppStorage.setOrCreate<number>('foldStatus', display.getFoldStatus());
        } else if (display.getFoldStatus() != 2) {
          AppStorage.setOrCreate<number>('foldStatus', display.getFoldStatus());
        }
      } catch (err) {
        HiLog.e(TAG, `Failed to get isFoldableScreenAndFullyUnfolded, Code: ${err.code}, message: ${err.message}`);
      }
    }
  };

  handleAvoidAreaChange(topRectH: number, bottomRectH: number): void {
    let prePadding = this.storage.get<SetOrCreateParams>('fullScreenPadding')
    let setOrCreateParams: SetOrCreateParams = {
      top: topRectH < 0 ? prePadding?.top ?? 0 : topRectH,
      bottom: bottomRectH < 0 ? prePadding?.bottom ?? 0 : bottomRectH,
      left: 0,
      right: 0
    }
    this.storage.setOrCreate('fullScreenPadding', setOrCreateParams);
  }

  handleWindowSizeChange(vp: number, windowObj: Window.Window): void {
    HiLog.e(TAG, 'Ability handleWindowSizeChange');
    // 更新 curbp
    let curBp: string = AppStorage.get('curBp') as string;
    let newBp: string = '';
    if (vp < 600) {
      newBp = 'sm';
    } else if (vp < 840) {
      newBp = 'md';
    } else {
      newBp = 'lg';
    }
    HiLog.i(TAG, 'curBp: ' + curBp);
    if (curBp !== newBp) {
      AppStorage.setOrCreate('curBp', newBp);
    }
    AppStorage.setOrCreate('windowWidth', vp);
    AppStorage.setOrCreate('mmsPadMargin', DeviceUtil.padMargin());
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    HiLog.i(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    HiLog.i(TAG, 'Ability onForeground');
    GlobalContext.getContext().setObject('abilityStatus', 'onForeground');
    simCardService.init(this.context);
    this.setSystemBarProps();
  }

  onBackground(): void {
    //Ability has back to background
    HiLog.i(TAG, 'Ability onBackground');
    GlobalContext.getContext().setObject('abilityStatus', 'onBackground');
    simCardService.deInit();
    AppStorage.delete('notifyUpdateSimSpn');
    AppStorage.delete('simSlotIdIsShowRead');
  }

  onDestroy(): void {
    HiLog.i(TAG, 'Ability onDestroy');
    // 骚扰拦截列表页面是否在前台显示值在ability 销毁时兜底置为false.防止一直为true收不到骚扰拦截信息通知
    SharedPreferencesUtils.saveToPreferences('blockedNotificationIsShow', false);
    GlobalContext.getContext().setObject('abilityStatus', 'onDestroy');
    (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper)?.close();
    GlobalContext.getContext().setObject('DataWorker', null);
    GlobalContext.release()
    this.storage.clear()
    AppStorage.clear()
    OperatorConfigUtil.release();
    ConversationListController.release();
    ConversationController.release();
    SharedPreferencesUtils.release();
    TelephoneUtil.release();
    AppStorage.setOrCreate('keyboardHeight', 0);
    AppStorage.delete('receiveSessionArray');
    AppStorage.delete(AppStorageKeyConstant.IS_START_FROM_HOME);
    AppStorage.delete(AppStorageKeyConstant.IS_NEW_WANT_FROM_HOME);
    AccessibilityUtil.releaseAccessibility();
    HiLog.i(TAG, 'Ability onDestroy finished');
    clearTimeout(this.reportTimer);
    this.clearTimeoutOfMigrateChatbotBlocklist();
  }


  updateWindowHeight(height: number) {
    this.storage.setOrCreate('windowHeight', height);
    AppStorage.setOrCreate('windowHeight', height);
  }

  setSystemBarProps(config?: Configuration) {
    let currentColorMode: ConfigurationConstant.ColorMode | undefined =
      config?.colorMode !== undefined ? config?.colorMode : AppStorage.get('currentColorMode');
    HiLog.w(TAG, '[setSystemBarProps] currentColorMode: ' + currentColorMode);
    if (this.lastColorMode === currentColorMode) {
      HiLog.w(TAG, 'ColorMode has not changed.')
      return;
    }
    let systemBarProperties: window.SystemBarProperties = {
      statusBarContentColor: currentColorMode ? '#ff000000' : '#ffffffff',
    }
    this.windowObj?.setWindowSystemBarProperties(systemBarProperties);
    this.lastColorMode = currentColorMode;
  }

  onBackPressed(): boolean {
    HiLog.i(TAG, 'onBackPresssd start!')
    return true
  }

  /**
   * 清除执行增强信息应用的黑名单数据的迁移操作的定时器
   */
  private clearTimeoutOfMigrateChatbotBlocklist(): void {
    if (this.timeoutIdOfMigrateChatbotBlocklist !== undefined) {
      HiLog.i(TAG, 'clearTimeoutOfMigrateChatbotBlocklist');
      clearTimeout(this.timeoutIdOfMigrateChatbotBlocklist);
      this.timeoutIdOfMigrateChatbotBlocklist = undefined;
    }
  }

  delayOnCreateWorker(wantInfo: Want) {
    //短信冷启动，以下函数可以延迟执行
    HiLog.i(TAG, "[delayOnCreateWorker] begin")
    // let notStartFromHome: boolean = wantInfo?.action !== "action.system.home"
    // if (notStartFromHome) {
      //从通知栏等其他渠道进行立即初始化短信智能卡片
      // HiLog.i(TAG, "[delayOnCreateWorker] SmartMmsClient at once")
      // SmartMmsClient.init(this.context);
      // SmartMmsClient.visitorCheckAgreementStatusAsync(this.wdStage, this.context);
    // } else {
    //   setTimeout(() => {
    //     HiLog.i(TAG, '[delayOnCreateWorker] SmartMmsClient delay');
        // SmartMmsClient.init(this.context);
        // SmartMmsClient.visitorCheckAgreementStatusAsync(this.wdStage, this.context);
      // }, 200)
    // }
    setTimeout(() => {
      DateUtil.updateIntlLocalAndFormatters(new Intl.Locale());
      OperatorConfigUtil.getInstance().initOperatorConfig();
      HiLog.i(TAG, "[delayStartupWorker] end")
    }, 200)

    /**
     * 冷启动时，获取无效的数据（session，mms_info,rcs_info，part_info）延迟4秒，以免影响冷启动
     */
    setTimeout(() => {
      let task: taskpool.Task = new taskpool.Task(getInvalidData, this.context);
      taskpool.execute(task);
    }, 4000)

    let advancedSeMode = mmsUitlCtr.checkAdvancedMode();
    SharedPreferencesUtils.saveToPreferences('isAdvancedMode', advancedSeMode);
    clearTimeout(this.timerId);
    this.timerId = setTimeout(() => {
      UnLockedNotifyService.getInstance().processMessageUserLocked(this.context)
    }, DELAY_TIME)

    this.clearTimeoutOfMigrateChatbotBlocklist();
    this.timeoutIdOfMigrateChatbotBlocklist = setTimeout(() => { //延迟执行，以免影响冷启动
      this.clearTimeoutOfMigrateChatbotBlocklist();
    }, 8000);
  }

  isFoldable(): boolean {
    let ret: boolean = false;
    try {
      ret = display.isFoldable();
    } catch (exception) {
      HiLog.e(TAG, 'Failed to check is foldable or not. exception =' + JSON.stringify(exception));
    }
    if (ret === undefined || !ret) {
      HiLog.d(TAG, 'Failed to check is foldable or not.');
      return false;
    } else {
      HiLog.d(TAG, 'Success to check is foldable or not.');
    }
    return true;
  }

  addFoldStatusListener(): void {
    if (!this.isFoldable()) {
      return;
    }
    try {
      HiLog.i(TAG, 'foldStatusChange display.getFoldStatus()=' + display.getFoldStatus());
      AppStorage.setOrCreate<number>('foldStatus', display.getFoldStatus());
    } catch (err) {
      HiLog.e(TAG, `Failed to getFoldStatus, Code: ${err.code}, message: ${err.message}`);
    }
    try {
      display.on('foldStatusChange', (foldStatus: display.FoldStatus) => {
        HiLog.i(TAG, 'foldStatusChange foldStatus=' + foldStatus);
        AppStorage.setOrCreate<number>('foldStatus', foldStatus);
        this.setIsVDEFoldPhoneAndFoldedState();
      })
    } catch (exception) {
      HiLog.e(TAG, 'foldStatusChange exp=' + JSON.stringify(exception));
    }
  }

  setIsVDEFoldPhoneAndFoldedState() {
    let isVDEFoldPhoneAndFoldedState = ScreenAdapterUtils.getInstance().isVDEFoldPhoneAndFoldedState();
    AppStorage.setOrCreate('isVDEFoldPhoneAndFoldedState', isVDEFoldPhoneAndFoldedState);
    HiLog.i(TAG, "isVDEFoldPhoneAndFoldedState : " + isVDEFoldPhoneAndFoldedState)
  }

}

@Concurrent
function preInit() {
  TelephoneUtil.initPhoneNumberFormat();
}