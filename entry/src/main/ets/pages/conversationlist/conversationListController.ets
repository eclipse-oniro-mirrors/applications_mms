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
import commonEvent from '@ohos.commonEventManager';
import dataShare from '@ohos.data.dataShare';
import ConversationService from '../../service/ConversationService';
import MmsPreferences from '../../utils/MmsPreferences';
import { Mms, DataParameters } from '../../utils/TypesUtils';
import common, { GlobalContextKey, MarkRead } from '../../data/commonData'
import EmitterConstant from '../../data/EmitterConstant'
import lazy { DateUtil } from '../../utils/DateUtil';
import LooseObject from '../../data/LooseObject';
import ConversationListService from '../../service/ConversationListService';
import HiLog from '../../utils/HiLog';
import HashMap from '@ohos.util.HashMap';
import InfoMsgController, { resType } from '../infomsg/InfoMsgController';
import SettingService from '../../service/SettingService'
import commonService from '../../service/CommonService';
import NotificationService, { ISetBadgeContextInfo } from '../../service/NotificationService';
import ConversationListDataSource from '../../model/ConversationListDataSource';
import StringUtil from '../../utils/StringUtil';
import { BusinessError, AsyncCallback } from '@ohos.base';
import ConversationController, { mmsListType, timeDataType } from '../conversation/conversationController';
import commonEventManager from '@ohos.commonEventManager'
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
// import rcs from '@ohos.telephony.rcs';
import data from '@ohos.telephony.data';
import radio from '@ohos.telephony.radio';
import observer from '@ohos.telephony.observer';
import sim from '@ohos.telephony.sim';
import DataService from '../../service/DataService';
import hiTraceMeter from '@ohos.hiTraceMeter';
import TraceConstant from '../../data/TraceConstant';
import Constant from '../../data/Constant';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import { addAirPlaneModeListener, removeAirPlaneModeListener, queryAirPlaneMode } from '../conversation/AirplaneMode';
import settings from '@ohos.settings';
import wifi from '@ohos.wifi';
import emitter from '@ohos.events.emitter';
import dotCommon, { clickAvatarParams, dotNoNeedParmas,
    CPUAndMEMParams,
    longPressDeParams, onlyStateParam,
  stateParam } from '../../utils/MmsDot/DotCommon';
import DotUtil from '../../utils/MmsDot/DotUtils';
import DataShareHelper from '../../model/repository/DataShareHelper';
import ConversationListResponse from '../../model/conversationlist/ConversationListResponse';
import { TimeType, PhotoSizeType, PageFlag, ThreadId } from '../../utils/TypesUtils';
import I18n from '@ohos.i18n';
import ReceiveService from '../../StaticSubscriber/ReceiveService';
import PanGestureUtil from '../../utils/PanGestureUtil';
import { ValuesBucket } from '@kit.ArkData';
import { queryMessagesDataBaseActionData, RcsRegisterOnProp } from './conversationListTool';
import { Queue, taskpool } from '@kit.ArkTS';
import ContactsService from '../../service/ContactsService';
import { CancelNotificationTimeLock } from '../../utils/Locks/TimeLock';
import { SystemMode } from '../../utils/SystemMode';
import { connection } from '@kit.NetworkKit';
import { systemDateTime } from '@kit.BasicServicesKit';
import { ContactInfoModel } from '../../model/ComInfoModel';
import DeviceUtil from '../../utils/DeviceUtil';
import { display } from '@kit.ArkUI';
import { i18n } from '@kit.LocalizationKit';
import BlockedUtil from '../../utils/BlockedUtil';
import ResourceUtils from '../../utils/ResourceUtils';
import ConversationRcsService from '../../service/ConversationRcsService';
import AccessibilityUtil from '../../utils/AccessibilityUtil';
import { ThreadObjectUtils } from '../../model/conversationlist/ThreadObjectUtils';
import TelephoneUtil from '../../utils/TelephoneUtil';
import DistributedUtil from '../../utils/DistributedUtil';
import MMsFileDeleteUtil from '../../utils/MMsFileDeleteUtil';
import FileUtils from '../../utils/FileUtils';
import BackupRestoreRpc from '../../ServiceExtension/AutoBackupRestoreRpc/BackupRestoreRpc';

const TAG = 'ConversationListController';

export class photoFirstNamesType {
  portraitColor: string | Resource  = ''
  firstName: string = ''
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

export class Params {
  public yellowPageId: string = ''
  public hasYellowPageIcon: string = ''
  public icon: string = ''
  strContactsNumber: string = ''
  strContactsNumberFormat: string = ''
  strContactsName: string = ''
  public contactsNameList: string[] = []
  contactsNum: number = -1
  threadId: number = -1
  isDraft: boolean = false
  draftContent: string | Resource = ''
  searchContent: string = ''
  photoFirstNames: photoFirstNamesType[] = []
  rawContactId: string = ''
  smsType: number = 0
  isNewMsgWithDraft: boolean = false
  public isFromInfoMsgView: boolean = false
  public msgId: string = ''
  messageCount: number = 0
  public satelliteList: LooseObject[] = []
  public isFromNewCreatMessage: boolean = false
  public contactId: string | undefined = ''
}

/**
 * 修改此类对象时，请同步修改ThreadObjectUtils的deepCopyThread方法
 */
@Observed
export class messageType {
  @Track public index: number = 0;
  @Track public mmsSource: Array<Mms> = [];
  @Track public isMsm: boolean = false;
  @Track public msgContent: number | string | Resource = 0;
  @Track name: string = ''
  @Track contactsNum: number = 0
  @Track content: string | Resource = ''
  @Track countOfUnread: number = 0
  @Track icon: string = ''
  @Track smsType: number = 0
  @Track isCbChecked: boolean = false
  @Track sendingFailed: boolean = false
  @Track telephone: string = ''
  @Track telephoneFormat: string = ''
  @Track contactName: string = '';
  @Track threadId: number = 0
  @Track timeMillisecond: number | string = 0
  @Track isDraft: boolean = false
  @Track public time: string | Resource = '';
  @Track messageCount: number = 0
  @Track hasMms: boolean = false
  @Track hasAttachment: boolean = false
  @Track public detailTime: string | Resource = '';
  @Track portraitColor: string = ''
  @Track isDelShow: boolean = false
  @Track itemLeft: number = 0
  @Track public yellowPageId: string = '';
  @Track public hasYellowPageIcon: string = '';
  @Track public photoFirstNames: Array<photoFirstNamesType> = [{
    portraitColor: '',
    firstName: ''
  }]
  @Track public contactsNameList: string[] = [];
  @Track public photoSize: PhotoSizeType = {
    width: 0,
    height: 0
  }
  @Track public isFavorite: boolean = false
  @Track public contactId?: string = '';
  @Track public rawContactId?: string = '';
  @Track public isMultipleSelectState: boolean = true;
  @Track public isDisplayDraftText: boolean = false;
  @Track public isReceive: boolean = false;
  @Track public startTime: string = '';
  @Track public groupId: number = 0;
  @Track public id: number | string = 0;
  @Track public msgId: number = 0;
  @Track public mmsPdu: string = ''
  @Track public hasReport: boolean = false;
  @Track public fullDate: timeDataType | Resource | string = {
    id: 0,
    type: 0,
    params: [],
    bundleName: '',
    moduleName: ''
  }
  @Track public timeOfSms: timeDataType | Resource | string = {
    id: 0,
    type: 0,
    params: [],
    bundleName: '',
    moduleName: ''
  }
  @Track public week: timeDataType = {
    id: 0,
    type: 0,
    params: [],
    bundleName: '',
    moduleName: ''
  }
  @Track public fullDateParams: string[] = []
  @Track public timeOfSmsParams: string[] = []
  @Track public contentType: number = 0;
  @Track public isRcs: number = 0;
  @Track public senderNumber: string = '';
  @Track public itemTime: number = 0;
  @Track public msgTitle?: string = '';
  @Track public isChatbotMessage?: boolean = false;
  @Track public chatbotAvatarUri?: string = '';
  @Track public rcsType?: number = 0;
  @Track public blockedType?: number = 0;
  @Track public pinningTime: number = 0;
  @Track public chatbotPageIcon?: string = '';
  @Track public cachedComInfoUri?: string = '';
  @Track public comInfoUri?: string = '';
}

class searchResultListType {
  sessionList: Array<number> = []
  contentList: Array<string> = []
}

export class Result {
  code?: number
  response: Response = new Response()
}

class Response {
  totalListCount: number = 0
  unreadCount: number = 0
  unreadTotalOfInfo: number = 0
}

class Data {
  public event?: string
  public bundleName?: string
  public code?: number
  public data?: string
  public parameters?: MyParameters
}

class MyParameters {
  public content?: string
  public moduleName?: string
  public slotId?: number
  public telephone?: string
}

interface option {
  slotId: number
}
interface PreErr {
  code: number;
  message: string;
}

/**
 * ConversationListController中不需要触发UI刷新的属性需在此类中定义，避免不必要的UI刷性影响性能
 * 此方式是利用了@State装饰器的规则：嵌套属性的赋值观察不到
 */
class NoUiProperty {
  needAgain: boolean = false;
  isRun: boolean = false;
  longPressFingers: number = 0;
  scrollStartIndex: number = 0;
}

class NewMmsData {
  public telephone: string = '';
  public threadId: number = 0;
}

@Concurrent
async function fetchRecentContactsAndBatchUpdateSessionTaskPool(startUpdateTime: string,
  endUpdateTime: string, context: Context): Promise<number[]> {
  let pro = new Promise<number[]>((resolve, reject) => {
    ConversationListService.getInstance()
      .fetchRecentContactsAndBatchUpdateSessionTaskPool(startUpdateTime, endUpdateTime, (results: number[]) => {
        resolve(results);
      }, context);
  })
  return await pro;
}

@Concurrent
async function fetchRecentContactsAndBatchUpdateInfoTaskPool(context: Context): Promise<void> {
  let curVersion = SharedPreferencesUtils.getFromPreferences('updateInfoMsgVersion', 0);
  if (curVersion >= Constant.UPDATE_MSG_VERSION_V2) {
    return;
  }
  let pro = new Promise<void>((resolve, reject) => {
    ConversationListService.getInstance()
      .fetchRecentContactsAndBatchUpdateInfoTaskPool(context, (values: number) => {
        resolve();
      });
  })
  return await pro;
}

@Concurrent
async function fetchRcsInfoAndBatchUpdateSmsMmsInfoTask(context: Context): Promise<number> {
  let curVersion = SharedPreferencesUtils.getFromPreferences('updateInfoMsgVersion', 0);
  if (curVersion >= Constant.UPDATE_MSG_VERSION_V4) {
    return common.int.SUCCESS;
  }
  return await ConversationListService.getInstance().fetchRcsInfoAndBatchUpdateSmsMmsInfoTask(context);
}

@Observed
export default class ConversationListController {
    // Determine whether to perform initialization. (To avoid the onShow time sequence problem immediately after the
    // index is started.)
    public isFirstPageReady :boolean = false;
    public rcsRegisterProp :RcsRegisterOnProp = new RcsRegisterOnProp();
    public noUiProp: NoUiProperty = new NoUiProperty();
    public receiveService = ReceiveService.getInstance();
    isInited: boolean = false;
    commonEventData?: commonEventManager.CommonEventSubscriber
    updateEventData?: commonEventManager.CommonEventSubscriber
    private commonEventDataMms?: commonEventManager.CommonEventSubscriber
    private refreshEventDataMms?: commonEventManager.CommonEventSubscriber
    staticEventData?: commonEventManager.CommonEventSubscriber
    memoryEventData?: commonEventManager.CommonEventSubscriber;
    public timeChangeEventData?: commonEventManager.CommonEventSubscriber;
    public timeTickEventData?: commonEventManager.CommonEventSubscriber;
    public timeTickEventData1?: commonEventManager.CommonEventSubscriber;
    public needRefreshEventData?: commonEventManager.CommonEventSubscriber;
    svgDelete: string = '';
    strMsgDeleteDialogTip?: Resource;
    // Total number of SMs
    total: number = 0;
    // RCS login failure in Wi-Fi state
    private loginFailedCode: number = 35;
    // Total number of notifications.
    totalOfInfo: number = 0;
    // Total number of unread messages.
    unreadTotal: number = 0;
    // Total number of unread notifications
    unreadTotalOfInfo: number = 0;
    /**
     * 首页多选选中个数，此变量为内部变量，变化时需要刷新对应状态变量
     * 改变值需要调用this.refreshConversationListSelectCount(); 需要手动改值
     */
    conversationSelectedNumber: number = 0;
    // Indicates whether the multi-select state is selected.
    isMultipleSelectState: boolean = false;
    // Indicates whether the session list is selected.
    isConversationCheckAll: boolean = false;
    //点击全选状态中，用来计算分页外的选中数。
    public mIsConversationCheckAlling: boolean = false;
    // Value entered in the search box on the information list page
    inputValueOfSearch: string = '';
    inputValueOfSearchTemp: string = '';
    // Mark as read is hidden in the row where the notification is located. When there is unread information,
    // you can swipe left to view this icon.
    markAllAsReadForInfo: boolean = false;
    // Mark as read
    showMarkAllAsRead: boolean = false;
    // Delete. In each individual message line, swipe left on the screen.
    showDelete: boolean = false;
    // Dynamically setting the height of the deleted pop-up window
    dialogHeight: string = '';
    // Data in the notification message
    messageListForInfo: Array<messageType> = [];
    // If the notification integration switch is turned on, the information is not a notification.
    // If the notification integration switch is not turned on, the information is all data.
    messageList: Array<messageType> = [];
    // List of search results
    searchResultList: searchResultListType = {
        sessionList: [],
        contentList: []
    };
    // Search Results Queue
    searchResultListQueue: Array<LooseObject> = [];
    // Search Text Queue
    searchTextQueue: Array<LooseObject> = [];
    // 记录当前查询联系人的时间戳；查询过程中，新的查询请求会覆盖这个值；查询完成后，会进行一次比较，做下一次查询。
    private currentQueryContactTimeStampStr: string = '';
    // Queue start flag bit
    queueFlag: boolean = false;
    // Queue timer start flag bit
    setTimeOutQueueFlag: boolean = false;
    // Number of search results
    countOfSearchResult: number = 0;
    // Indicates whether to perform redirection to avoid repeated redirection.
    isJumping: boolean = false;
    // Index of the last session clicked
    lastIndex: number = -1;
    // Indicates whether to enable the notification integration switch. This switch is in the Settings area.
    hasAggregate: boolean = false;
    // Display contact avatar
    isShowContactHeadIcon: boolean = true;
    // Distributed Scene
    public isOsAccountConstraintEnabled: boolean = false;
    // Indicates whether to display the search return button. By default, the button is not displayed.
    isShowSearchBack: boolean = false;
    isSearchFocusable: boolean = false;
    // The transparent color of the mask is displayed during search.
    isSearchCoverage: boolean = false;
    // Whether to display session search
    isSearchConversation: boolean = false;
    // Show Spacer Lines
    isSearchInterval: boolean = false;
    // Display Single Information Search
    isSearchSms: boolean = false;
    // Show Search Status
    showSearchStatus?: Resource;
    // Indicates whether to display the button for creating an SMS message.
    isNewSms: boolean = true;
    conversationName: string = '';
    // Check whether a common message (non-notification message) exists.
    hasNoOrdinaryMsg: boolean = false;
    //Checking the Session List Data Status:1、before get data ;2、has message 3、no message
    public messageDataStatus: string = common.MSG_DATA_STATUS.DEFAULT
    // Check whether notification information exists.
    hasInfoMsg: boolean = false;
    // Update the UI.
    flushTranslate: boolean = true;
    // Length of the operation button
    operateBtnW: number = 145;
    // Data index of the current touch
    itemTouchedIdx: number = -1;
    // Left margin of notification message
    infoLeft: number = 0;
    // List pagination, quantity
    limit: number = 0;
    reg: RegExp = new RegExp('^[\\u4e00-\\u9fa5_a-zA-Z]+$');
    delItem: number = 0;
    // conversation list adapters
    conversationListDataSource: ConversationListDataSource = new ConversationListDataSource();
    pageInfos: NavPathStack = new NavPathStack();
    isRcsStatus:boolean = false;
    isRcsOpenStatus:boolean = false;
    isCellularOpen: boolean = false;
    // Whether air plane mode.
    isAirPlaneMode: boolean = false;
    isOobeRcs: boolean = false;
    hasCard1: boolean = false;
    hasCard2: boolean = false;
    RCS_ENHANCE_STATUS: string = 'rcs_enhance_status';
    rcsState:boolean = false;
    slotId:number = 0;
    isRcsStateOpen:boolean = false;
    isReadFlag:boolean = false;
    isClosedInterState:boolean = false;
    isConnected:boolean = false
    private canSendStatusbarEvent: boolean = true;
    // app是否在前台
    private isOnForeground: boolean = true;
    private clickStatusBarEventSubscriber: commonEventManager.CommonEventSubscriber | null = null;
    public isToInfoView: boolean = false;
    public page: number = 0;
    public infoTotal: number = 0;
    public isOpenRepairModeDialog: boolean = false;
    public isRepair: boolean = false;
    public isRepairMode: string = '';
    public checkedStatus: Set<number> = new Set<number>();
    //删除全选场景接收到的消息
    public deleteMmsAfterDataSet: Set<NewMmsData> = new Set<NewMmsData>();
    //滑动到第二页不更新数据。
    public scrollTopNeedUpdate: boolean = false;
    //是否有更多数据
    public hasMore: boolean = false;
    //页数
    public pageIndex: number = 0;
    //删除操作进行中
    private deleteIng = false;
    // 是否注册过延迟任务
    private hasRegisterBackupWork: boolean = false;
    private backupWorkTimerId: number = -1;
    private alreadyExecute: boolean = false
    private alreadySyncVcard: boolean = false
    private static mInstance: ConversationListController | undefined = undefined;
    private isEnableRcsAbility: boolean = SystemMode.getInstance().isEnableRcsAbility;
    // 如果是设置模态消失，折叠机刷新列表，不需要选中第一条短信
    public isSettingDismiss: boolean = false;
    private isAdvancedMode: boolean = SharedPreferencesUtils.getFromPreferences('isAdvancedMode', false) as boolean;
    private netConnectionSubscriber: connection.NetConnection | null = null;
    // worker将数据返回后，允许下次查询。防止滑动场景下并发查询。
    private isQueryPageDone: boolean = true;
    public currentConversatonIndex: number = 0;
    // 置顶会话数量
    public pinSessionSize: number = -1;
    // 偏移量是否需要加置顶数量
    public isNeedPinNumberOffset: boolean = true;

  // Used for redirecting unread message queues.
  public unReadQueue: Queue<number> = new Queue();
  public unReadListSize: number = 0;
  // 记录会话列表是否有item处于显示标记已读、置顶、删除按钮状态
  public listSwipeActionState:SwipeActionState = SwipeActionState.COLLAPSED;


    static getInstance() {
        if (!ConversationListController.mInstance) {
            ConversationListController.mInstance = new ConversationListController();
        }
        return ConversationListController.mInstance;
    }

    public static release() {
        if (ConversationListController.mInstance) {
            ConversationListController.mInstance.noUiProp.isRun = false
            ConversationListController.mInstance.noUiProp.needAgain = false
            ConversationListController.mInstance = undefined
        }
    }
    onInit(context: Context) {
        HiLog.i(TAG, 'onInit');
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_LIST_CONTROLLER_ON_INIT,TraceConstant.TRACE_CONVERSATION_LIST_CONTROLLER_ON_INIT_ID);
        this.isInited = true;
        this.svgDelete = 'icon/ic_public_delete.svg';
        this.strMsgDeleteDialogTip = $r('app.plural.msg_delete_dialog_tip2', this.conversationSelectedNumber, this.conversationSelectedNumber);
        this.showSearchStatus = $r('app.string.noMessages');
        this.getSettingFlagForConvListPage();
        this.conversationListDataSource.refresh(this.messageList, 'onInit');
        this.delayOnInitWorker(context)
        AppStorage.SetOrCreate('statisticalInitFlag', true);
        SharedPreferencesUtils.saveToPreferences('downloadList', []);
        GlobalContext.getContext().setObject('is24HourTime', I18n.System.is24HourClock());
        hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_LIST_CONTROLLER_ON_INIT,TraceConstant.TRACE_CONVERSATION_LIST_CONTROLLER_ON_INIT_ID);
    }
    async delayOnInitWorker(context: Context) {
        //短信冷启动时延迟150ms，执行以下函数，避免占用CPU
        setTimeout(async() => {
            this.subscribeTimeChangeEvent();
            this.subscribeTimeTickEvent();
            this.subscribeTimeTickEvent1();
            this.subscribeStaticEvent();
            this.subscribeNeedRefreshEvent(context);
            this.acceptFailureEvent();
            this.isOsAccountConstraintEnabled = await DistributedUtil.isOsAccountConstraintEnabled();
        }, 150)
    }

    updateData(context: Context, err: BusinessError, data: commonEventManager.CommonEventData) {
        if (data == null || data.parameters == null) {
            HiLog.w(TAG, 'updateData, data or data.parameters is null, return');
            return;
        }

        this.messageList.forEach(element => {
            if (element.telephone == data.parameters?.telephone) {
                element.countOfUnread --;
            }
        });
        this.conversationListDataSource.refresh(this.messageList, 'updateData');
        HiLog.w(TAG, '[updateData]');
        this.statisticalData(context);
    }

    registerDataChangeObserver(callback: AsyncCallback<dataShare.ChangeInfo>, context: Context) {
        HiLog.i(TAG, 'registerDataChangeObserver');
        let contactDataUri: string = common.STR.URI_ROW_CONTACTS + common.STR.CONTACT_DATA_URI;
        DataShareHelper.getInstance().initContactDB(context).then((dataAbilityHelper) => {
            if (dataAbilityHelper) {
                dataAbilityHelper.on('dataChange',
                    dataShare.SubscriptionType.SUBSCRIPTION_TYPE_EXACT_URI, contactDataUri, callback);
            }
        }).catch((error: BusinessError) => {
            HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
        });
    }

    unregisterDataChangeObserver(callback: AsyncCallback<dataShare.ChangeInfo>, context: Context) {
        let contactDataUri: string = common.STR.URI_ROW_CONTACTS + common.STR.CONTACT_DATA_URI;
        DataShareHelper.getInstance().initContactDB(context).then((dataAbilityHelper) => {
            if (dataAbilityHelper) {
                dataAbilityHelper.off('dataChange',
                    dataShare.SubscriptionType.SUBSCRIPTION_TYPE_EXACT_URI, contactDataUri, callback);
            }
        }).catch((error: BusinessError) => {
            HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
        });
    }

  /**
   * 注册点击状态栏事件，用于返回顶部
   */
  public registerClickStatusBar(): void {
    if (this.clickStatusBarEventSubscriber) {
      HiLog.w(TAG, ` registerClickStatusBar has registed!`);
      return;
    }
    let events = [common.STR.CLICK_STATUSBAR_EVENT];
    let clickStatusBarSubscribeInfo: commonEvent.CommonEventSubscribeInfo = {
      events: events,
    };
    try {
      this.clickStatusBarEventSubscriber = commonEventManager.createSubscriberSync(clickStatusBarSubscribeInfo);
      if (this.clickStatusBarEventSubscriber === null) {
        HiLog.e(TAG, ` registerClickStatusBar failed`);
        return;
      }
      commonEventManager.subscribe(this.clickStatusBarEventSubscriber,
        async (err: BusinessError, data: commonEventManager.CommonEventData) => {
          if (err) {
            HiLog.i(TAG, `registerClickStatusBar err, code: ${err?.code}, message: ${err?.message}`);
            return;
          }
          // 1000ms内不再次触发，保障动效
          if (this.isOnForeground && this.canSendStatusbarEvent) {
            HiLog.i(TAG, ` registerClickStatusBar Publish CLICK_STATUSBAR`);
            emitter.emit(EmitterConstant.EVENT_CLICK_STATUSBAR);
            this.canSendStatusbarEvent = false;
            setTimeout(() => {
              this.canSendStatusbarEvent = true;
            }, 1000);
          }
        });
    } catch (err) {
      HiLog.e(TAG, `registerClickStatusBar failed, code is ${err?.code}, message is ${err?.message}`);
    }
  }

  /**
   * 解注册点击状态栏事件，用于返回顶部
   */
  public unregisterClickStatusBar(): void {
    if (!this.clickStatusBarEventSubscriber) {
      return;
    }
    try {
      commonEvent.unsubscribe(this.clickStatusBarEventSubscriber, (err: BusinessError) => {
        if (err) {
          HiLog.e(TAG, `unregisterClickStatusBar failed, code is ${
          err.code}, message is ${err.message}`);
        } else {
          HiLog.i(TAG, 'unregisterClickStatusBar success');
          this.clickStatusBarEventSubscriber = null;
          emitter.off(EmitterConstant.EVENT_CLICK_STATUSBAR);
        }
      });
    } catch (err) {
      HiLog.e(TAG, `unregisterClickStatusBar failed, code is ${err?.code}, message is ${err?.message}`);
    }
  }

    onRcsStateChange():void {
        HiLog.i(TAG, 'onRcsStateChange Invoking')
        // try {
        //     this.rcsOn(async (message:rcs.RcsEvent) => {
        //         await this.onRcsStateChangeresult(message);
        //     })
        // } catch (err) {
        //     HiLog.e(TAG, 'onRcsStateChange err: ' + err);
        // }
        return;
    }

    // async onRcsStateChangeresult(message:rcs.RcsEvent){
    //     HiLog.i(TAG, 'onRcsStateChange message: ' + JSON.stringify(message));
    //     interface ParamsType {
    //       reason: number
    //     }
    //     if(message.type == 1){
    //         AppStorage.setOrCreate('isOnlineRcs', true);
    //     }else{
    //         if (message.params) {
    //           let params: ParamsType = message.params as ParamsType;
    //           if (params.reason == this.loginFailedCode) {
    //             HiLog.i(TAG, 'onRcsStateChangeResult on message params: ' + params.reason);
    //             SharedPreferencesUtils.saveToPreferences('isOpenRcsError', true);
    //             AppStorage.setOrCreate('isOpenRcsError', true);
    //           }
    //         }
    //         AppStorage.setOrCreate('isOnlineRcs', false);
    //     }
    // }

  public onRcsSendMessageCallBack(context: Context):void {
    HiLog.i(TAG, 'onRcsSendMessageCallBack Invoking')
    try {
      // this.rcsMessageStatusChanged(async (message:rcs.RcsEvent) => {
      //   await this.onRcsSendMessageResult(context, message);
      // })
    } catch (err) {
      HiLog.e(TAG, 'onRcsSendMessageCallBack err: ' + err);
    }
    return;
  }

  // rcsMessageStatusChanged(cb: (message:rcs.RcsEvent) => void): Promise<void> {
  //   return new Promise((resolved, reject:Function) => {
  //       if (this.rcsRegisterProp.rcsMessageStatusChanged) {
  //           HiLog.i(TAG,
  //               '[rcsMessageStatusChanged] [rcsMessageStatusChanged] has been registered, it not need register again ')
  //           resolved();
  //           return;
  //       }
  //     try {
  //       rcs.on('rcsMessageStatusChanged', cb);
  //       this.rcsRegisterProp.rcsMessageStatusChanged = true
  //       HiLog.i(TAG, '[rcsMessageStatusChanged] [rcsMessageStatusChanged] has been registered successfully')
  //     } catch (error) {
  //       HiLog.e(TAG, 'rcsSendMessageCallBack error: ' + JSON.stringify(error));
  //       this.rcsRegisterProp.rcsMessageStatusChanged = false
  //     }
  //     resolved();
  //   });
  // }

  // async onRcsSendMessageResult(context: Context, message:rcs.RcsEvent) {
  //   HiLog.i(TAG, 'onRcsSendMessageResult message: start ');
  //   interface ParamsType {
  //     reason: string
  //   }
  //   if (message.type == 5 && message.params) {
  //     let params: ParamsType = message.params as ParamsType;
  //     let string: string = params.reason;
  //     let dataParameters: DataParameters = JSON.parse(string);
  //     HiLog.i(TAG, 'onRcsSendMessageResult message:  dataParameters');
  //     let dataObj = dataParameters.parameters;
  //     GlobalContext.getContext().setObject('mmsContext', context);
  //     this.receiveService.sendAndReceiveRcsBroadcast(dataParameters, context);
  //     if (dataParameters.event === common.STR.SUBSCRIBER_EVENT) {
  //       this.receiveService.sendRcsSendBroadcast(dataParameters, context);
  //       this.receiveService.sendRcsRecvBroadcast(dataParameters, context);
  //       HiLog.i(TAG, 'onRcsSendMessageResult, SUBSCRIBER_RCS_RECV_EVENT successful');
  //       if (!dataObj.isNotificationFlag) {
  //         HiLog.i(TAG, 'onReceiveEvent: sms message');
  //         this.receiveService.dealSmsReceiveData(dataParameters, context);
  //       }
  //     }
  //   }
  // }

    onShow(context: Context, pageInfos: NavPathStack) {
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_LIST_CONTROLLER_ON_SHOW,TraceConstant.TRACE_CONVERSATION_LIST_CONTROLLER_ON_SHOW_ID);
        this.pageInfos = pageInfos;
        this.isOnForeground = true;
        HiLog.w(TAG, 'ConversationList onShow');
        try {
            if(AppStorage.get('backHasInfoMsg') as boolean) {
                this.hasInfoMsg = false;
                AppStorage.SetOrCreate('hasInfoMsg', false);
                AppStorage.Delete('backHasInfoMsg');
            }
        } catch(error) {
            HiLog.e(TAG,`hasInfoMsg error is: ${JSON.stringify(error)}`)
        }
        if (!this.isInited) {
            HiLog.w(TAG, 'is not init');
            hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_LIST_CONTROLLER_ON_SHOW,TraceConstant.TRACE_CONVERSATION_LIST_CONTROLLER_ON_SHOW_ID);
            return;
        }
        this.isJumping = false;
        this.getSettingFlagForConvListPage();
        //获取会话列表
        if (CancelNotificationTimeLock.getInstance().queryIsUnlocked('ConversationListController->onShow')) {
          HiLog.i(TAG, 'onShow NotificationService.cancelAllNotify()');
          NotificationService.getInstance().cancelAllNotify();
        }
        this.refreshConversationListData(context);
        this.statisticalData(context);
        this.delayOnShowWorker(context)
        this.isToInfoView = false;
        hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_LIST_CONTROLLER_ON_SHOW,TraceConstant.TRACE_CONVERSATION_LIST_CONTROLLER_ON_SHOW_ID);
        this.isRepair = true;
    }

    async delayOnShowWorker(context: Context) {
        //短信冷启动时延迟150ms，执行以下函数，避免占用CPU
        setTimeout(() => {
            this.subscribe(context);
            this.subscribeMms(context);
            MMsFileDeleteUtil.getInstance().delete(context);
            this.initRcs().then(() => {
                HiLog.i(TAG, 'initRcs In')
                this.onShowRcs(context);
            })
        }, 150)
    }
    onShowRcs(context: Context){
        HiLog.i(TAG,'onShowRcs In')
        this.networkStatusChanged();
        this.setRcsInfosResult(context, this.rcsState,this.slotId);
        this.getCellularData(this.slotId);
        this.getSimState();
        this.getAirPlaneMode();
        this.onRcsStateChange();
    }

    async initRcs(): Promise<void> {
        // Obtaining the Card Slot Status
        await this.isHasCard();
        // get rcsInfos
        this.slotId = await DataService.getDefaultCellularDataSlotId();
        // this.rcsState = rcs.isRcsSupported(this.slotId);
        this.isRcsStateOpen = SharedPreferencesUtils.getFromPreferences('isUIOpenRcs', '') as boolean;
        this.isReadFlag = SharedPreferencesUtils.getFromPreferences('readFlag', '') as boolean;
        this.isClosedInterState = SharedPreferencesUtils.getFromPreferences('isClosedInterState', '') as boolean;
        this.isConnected = wifi.isConnected();
        HiLog.i(TAG, 'DataService slotId:' + this.slotId + ',isRcsSupported rcsState:' + this.rcsState + ',isRcsStateOpen :' +
          this.isRcsStateOpen + ',isReadFlag :' + this.isReadFlag + ',isClosedInterState :' +
          this.isClosedInterState + ',isConnected :' + this.isConnected);
    }

    async isHasCard(){
        this.hasCard1 = await sim.hasSimCard(0);
        this.hasCard2 = await sim.hasSimCard(1);
        HiLog.i(TAG, `isHasCard success, promise: hasCard1->${this.hasCard1}`);
        HiLog.i(TAG, `isHasCard success, promise: hasCard1->${this.hasCard2}`);
    };

    refreshConversationListData(context: Context) {
      let inputText:string = AppStorage.get('inputText')??''
      if (inputText && inputText!=='') {
        return
      }
        HiLog.iw(TAG, 'refreshConversationListData, msgList length is :' + this.messageList?.length);
        let needToUpdate: boolean = GlobalContext.getContext().getObject('needToUpdate') as boolean;
        let needToUpdateRecMsg: boolean =
          SharedPreferencesUtils.getFromPreferences('needToUpdateRecMsg', false) as boolean;
        let isFromNotify: boolean = GlobalContext.getContext().getObject('isFromNotify') as boolean;
        let isBackFromConversion: boolean = GlobalContext.getContext().getObject('backFromConversation') as boolean;
        let updateAfterClone: boolean = SharedPreferencesUtils.getFromPreferences('updateAfterClone', false) as boolean;
        HiLog.w(TAG, '[refreshConversationListData] needToUpdate: ' + needToUpdate + ', needToUpdateRecMsg: ' +
            needToUpdateRecMsg + ', isFromNotify: ' + isFromNotify + ', isBackFromConversion: ' + isBackFromConversion +
            ', isRun:' + this.noUiProp.isRun + ', updateAfterClone: ' + updateAfterClone);
        if ((needToUpdate && !this.noUiProp.isRun) || updateAfterClone) {
            this.messageList = [];
            this.saveUpdateAfterClone(updateAfterClone);
            this.requestItem(context);
        } else if (isFromNotify) {
            GlobalContext.getContext().setObject('isFromNotify', false);
            this.messageList = [];
            this.requestItem(context);
        } else if (needToUpdate && isBackFromConversion) {
            GlobalContext.getContext().setObject('backFromConversation', false);
            this.messageList = [];
            this.requestItem(context);
        } else if (needToUpdateRecMsg) {
          SharedPreferencesUtils.saveToPreferences('needToUpdateRecMsg', false);
          this.messageList = [];
          this.requestItem(context);
        } else if (!needToUpdate) {
          HiLog.iw(TAG, 'refreshConversationListData hot start hasAggregate:' + this.hasAggregate +
            ' ,hasInfoMsg:' + this.hasInfoMsg + ' ,hasNoOrdinaryMsg:' + this.hasNoOrdinaryMsg +
            ' ,messageDataStatus:' + this.messageDataStatus)
            GlobalContext.getContext().setObject('backFromConversation', false);
            this.conversationListDataSet();
            this.conversationListDataSource.refresh(this.messageList, 'refreshConversationListData');
        }
    }

    private conversationListDataSet() {
      let is24Change = GlobalContext.getContext().getObject('is24HourTimeChange');
      let isTimeTick = GlobalContext.getContext().getObject('TimeTick');
      let isSysLocaleChanged = AppStorage.get('sysLocaleChanged') as boolean;
      let nationalAntiFraud = BlockedUtil.isNationalAntiFraud(getContext());
      if (is24Change || isTimeTick || isSysLocaleChanged) {
        HiLog.i(TAG, `converDate start`);
        this.messageList.forEach((item: messageType) => {
          DateUtil.convertDateFormatForItem(item);
          if (nationalAntiFraud && item.blockedType === 1) {
            item.name = ResourceUtils.getStringSync($r('app.string.fraud_session'), getContext());
          }
        })
        if (is24Change) {
          GlobalContext.getContext().setObject('is24HourTimeChange', false);
        }
        if (isTimeTick) {
          GlobalContext.getContext().setObject('TimeTick', false);
        }
        if (isSysLocaleChanged) {
          AppStorage.set('sysLocaleChanged', false);
        }
      }
    }

    saveUpdateAfterClone(updateAfterClone: boolean) {
      if (updateAfterClone) {
        SharedPreferencesUtils.saveToPreferences('updateAfterClone', false);
      }
    }

    onDestroy() {
        HiLog.i(TAG, 'onDestroy');
        this.isInited = false;
        // rcs?.off('loginStatusChanged', () => {
        //     HiLog.i(TAG, 'loginStatusChanged off');
        // });
        // rcs?.off('networkStatusChanged', () => {
        //     HiLog.i(TAG, 'networkStatusChanged off');
        // });
        // rcs?.off('rcsMessageStatusChanged', () => {
        //   HiLog.i(TAG, 'rcsMessageStatusChanged off');
        // });
        this.unSubscribeStaticEvent();
        this.unSubscribeMemoryEvent();
        this.unSubscribeTimeChangeEvent();
        this.unSubscribeTimeTickEvent();
        this.unSubscribeTimeTickEvent1();
        this.unsubscribeNeedRefreshEvent();
        this.unsubscribeRefreshEventDataMms();
    }

    onHide() {
      HiLog.i(TAG, 'onHide');
      this.isRepair = false;
      this.isOnForeground = false;
      this.unSubscribe();
    }

    // Touch and hold a list to display the selection and deletion functions.
    conversationLongPress(index : number) {
      if (this.messageList[index]) {
        // Check whether the left slide button exists. If yes, the button cannot be clicked.
        if (this.messageList[index]?.isDelShow != null && this.messageList[index].isDelShow) {
          return;
        }
        // Touch and hold a list to display the selection and deletion functions.
        HiLog.i(TAG, 'conversationLongPress, index: ' + index);
        if (this.isMultipleSelectState) {
          this.messageList[index].isCbChecked = !this.messageList[index].isCbChecked;
        } else {
          this.refreshConversationListSelectCount(1);
          this.checkedStatus.clear();
          this.checkedStatus.add(this.messageList[index].threadId);
          this.messageList[index].isCbChecked = true;
          this.isMultipleSelectState = true;
          PanGestureUtil.addFirstSelect(index, this.messageList[index].isCbChecked, true)
        }
        this.sendSelectedEvent(this.messageList[index].threadId);
      }
    }

    setConversationCheckAll(selectType : number, isClickRow ?: boolean) {
        // Check whether all items are selected.
        if (!this.isMultipleSelectState) {return;}
        if (selectType == common.int.CHECKBOX_SELECT_ALL) {
            this.refreshConversationListSelectCount(this.total);
            this.checkedStatus.clear();
            for (let index = 0; index < this.messageList.length; index++) {
              if (this.messageList[index].isCbChecked) {
                this.checkedStatus.add(this.messageList[index].threadId);
              }
            }
          PanGestureUtil.addFirstSelect(0, true, true, this.messageList.length)
        } else if (selectType == common.int.CHECKBOX_SELECT_NONE) {
            this.refreshConversationListSelectCount(common.int.MESSAGE_CODE_ZERO);
            this.checkedStatus.clear();
        } else {
        }
    }

  refreshConversationListSelectCount(count: number) {
    this.conversationSelectedNumber = count;
    this.isConversationCheckAll = this.conversationSelectedNumber === this.total;
    AppStorage.setOrCreate('conversationListSelectCount', count);
  }

    // Reset touch event, which is used to reset an item that has been moved by sliding left
    // when other buttons are pressed.
    resetTouch() {
        if (this.itemTouchedIdx !== -1) {
            let itemTouched: messageType = this.messageList[this.itemTouchedIdx];
            if (itemTouched == undefined) {return false;}
            if (itemTouched.isDelShow) {
                itemTouched.isDelShow = false;
                this.setListItemTransX(0);
                return true;
            }
        } else if (this.showMarkAllAsRead) {
            this.showMarkAllAsRead = false;
            this.setInfoItemTransX(0);
            return true;
        }
        return false;
    }

    // Touch event for information list
    touchStart(event: GestureEvent, index: number) {
        if (this.isMultipleSelectState) {
            return;
        }
        if (this.showMarkAllAsRead) {
            // If the last touch is a notification item, the notification item will be reset.
                  this.setInfoItemTransX(0);
                  setTimeout(() => {
                    this.showMarkAllAsRead = false;
                  }, 200);
        } else {
            // Check whether the current touch item is the same as that of a touch item.
            // If not, reset the previous touch item.
            if (this.itemTouchedIdx !== -1 && index !== this.itemTouchedIdx) {
                let itemTouched: messageType = this.messageList[this.itemTouchedIdx];
                if (itemTouched != undefined && itemTouched != null && itemTouched.isDelShow) {
                    this.setListItemTransX(0);
                    itemTouched.isDelShow = false;
                }
            }
        }
        this.itemTouchedIdx = index;
        let item: messageType = this.messageList[this.itemTouchedIdx];
        if (item == null || item == undefined) {
            return;
        }
        if (item.countOfUnread > 0) {
            this.operateBtnW = common.int.OPERATE_UNREAD_WIDTH;
        } else {
            this.operateBtnW = common.int.OPERATE_DELETE_WIDTH;
        }
    }

    touchMove(event: GestureEvent, index: number) {
        if (this.isMultipleSelectState) {
            return;
        }
        // offsetX indicates the offset. The value range is [-operateBtnW, 0].
        let offsetX = event.offsetX;
        // If the displacement is less than 2, there is no sliding.
        if (Math.abs(offsetX) <= 2) {
            return;
        }
        let item: messageType = this.messageList[this.itemTouchedIdx];
        let transX = offsetX;
        if (item.isDelShow) {
            if (event.offsetX - this.operateBtnW <= 0) {
                transX = event.offsetX - this.operateBtnW
            } else {
                // Slide right to close
                transX = 0
            }
        } else {
            if (event.offsetX + this.operateBtnW >= 0) {
                transX = event.offsetX
            } else {
                // Slide left to maximum width
                transX = 0 - this.operateBtnW;
            }
        }
        this.setListItemTransX(transX);
    }

    touchEnd(event: GestureEvent, index: number) {
        if (this.isMultipleSelectState) {
            return;
        }
        // offsetX indicates the offset. The value range is [-operateBtnW, 0].
        let offsetX = event.offsetX;
        let item: messageType = this.messageList[this.itemTouchedIdx];
        if (offsetX + (this.operateBtnW / 2) >= 0) {
            this.setListItemTransX(0);
            item.isDelShow = false;
        } else {
            this.setListItemTransX(0 - this.operateBtnW);
            item.isDelShow = true;
        }
    }

    setListItemTransX(transX : number) {
        let item: messageType = this.messageList[this.itemTouchedIdx];
        if (item) {
            if (transX <= 0) {
                item.itemLeft = transX;
            } else {
                item.itemLeft = 0;
            }
        }
        // Used to refresh the interface.
        this.flushTranslate = !this.flushTranslate;
    }

    setInfoItemTransX(disX: number) {
        if (disX >= 0) {
            this.infoLeft = -disX;
        } else {
            this.infoLeft = -this.operateBtnW - disX;
        }
    }

  onLoadingMore(context: Context) {
    HiLog.i(TAG,
      `hasMore: ${this.hasMore}, deleteIng: ${this.deleteIng}, isQueryPageDone: ${this.isQueryPageDone}`);
    if (this.hasMore && !this.deleteIng && this.isQueryPageDone) {
      this.queryAllMessages(context);
      this.isQueryPageDone = false;
    }
  }

  clickConversationCheckAll() {
        // Select All/Deselect All
        if (this.isConversationCheckAll) {
            this.isConversationCheckAll = false;
            this.mIsConversationCheckAlling = false;
            for (let element of this.messageList) {
                element.isCbChecked = false;
            }
            PanGestureUtil.refresh()
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_NONE);
            // 长按-全选/取消全选传参打点
            stateParam.STATE = -1;
            AccessibilityUtil.announceForAccessibility(getContext(this).resourceManager
              .getStringSync($r('app.string.msg_deselect_all_done').id));
        } else {
            this.isConversationCheckAll = true;
            this.mIsConversationCheckAlling = true;
            // Not Select All --> Select All
            for (let element of this.messageList) {
                element.isCbChecked = true;
            }
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_ALL);
            stateParam.STATE = 2;
            AccessibilityUtil.announceForAccessibility(getContext(this).resourceManager
              .getStringSync($r('app.string.msg_select_all_done').id));
        }
        this.sendSelectedEvent(null);
        AppStorage.set('isShowFromCheckAll', true);
    }

    clickConversationDelete() {
        // Button Delete
        if (this.conversationSelectedNumber === common.int.MESSAGE_CODE_ZERO) {
            return;
        }
        // Delete a record.
        if (this.conversationSelectedNumber === common.int.MESSAGE_CODE_ONE) {
            this.strMsgDeleteDialogTip = $r('app.string.msg_delete_dialog_tip1');
            longPressDeParams.STATE = 1;
        } else if (this.conversationSelectedNumber === this.total) {
            // Delete All
            this.strMsgDeleteDialogTip = $r('app.string.msg_delete_dialog_tip3');
            longPressDeParams.STATE = 3;
        } else {
            // Delete multiple records.
            this.strMsgDeleteDialogTip = $r('app.plural.msg_delete_dialog_tip2', this.conversationSelectedNumber, this.conversationSelectedNumber);
            longPressDeParams.STATE = 2;
        }
        // 长按-删除打点
        longPressDeParams.PAGE_STATE = 1;
        DotUtil.getInstance().reportEvent(longPressDeParams, dotCommon.eventName.LONGPRESS_DELETE_MSG);
    }

    onBackPress(context: Context) {
        HiLog.i(TAG, 'onBackPress');
        this.lastIndex = -1;
        // Key returned by the system. The value true indicates interception.
        if (this.isMultipleSelectState) {
            AppStorage.set('isShowFromCheckAll', false);
            HiLog.i(TAG, 'onBackPress isMultipleSelectState');
            for (let element of this.messageList) {
                element.isCbChecked = false;
            }
            this.refreshConversationListSelectCount(common.int.MESSAGE_CODE_ZERO);
            if (this.checkedStatus.size > 0) {
              this.checkedStatus.clear();
              this.sendSelectedEvent(null);
            }
            this.isConversationCheckAll = false;
            this.mIsConversationCheckAlling = false;
            this.isMultipleSelectState = false;
            PanGestureUtil.refresh()
            return true;
        }
      this.listSwipeActionState = AppStorage.get('swipeActionState') ?? SwipeActionState.COLLAPSED
      if (this.listSwipeActionState === SwipeActionState.EXPANDED ) {
        let innerEvent: emitter.InnerEvent = { eventId: EmitterConstant.EVENT_SWIPE_ACTION_CLOSE };
        emitter.emit(innerEvent)
        return true;
      }
        return false;
    }

    resetLastIndexValue() {this.lastIndex = -1;}

    deleteDialogConfirm(context: Context) {
        HiLog.w(TAG, '[deleteSessions] unreadTotal: ' + this.unreadTotal);
        this.deleteIng = true;
        let mmsList: Set<number> = new Set<number>();
        let indexList: number[] = [];
        this.setDelShow();
        let threadIds: Array<number> = [];
        let phoneNumbers: Array<string> = [];
        let listOfGroupSessionId: number[] = [];

        let uncheckedThreadIds: number[] = [];
        let uncheckedPhoneNumbers: string[] = [];
        let uncheckedListOfGroupSessionId: number[] = [];

        this.resetLastIndexValue();

        animateTo({duration: 200}, () => {
            let deletedSessionsUnreadTotal: number = 0;
            for (let index = 0; index < this.messageList.length; index++) {
                let element: messageType = this.messageList[index];
                if (element?.isCbChecked) {
                    deletedSessionsUnreadTotal += element.countOfUnread;
                    threadIds.push(element.threadId);
                    phoneNumbers.push(element.telephone);
                    let tempArray: string[] | undefined = element.telephone?.split?.(',');
                    Boolean(tempArray && tempArray.length > 1) && listOfGroupSessionId.push(element.threadId);
                    mmsList.add(element.threadId);
                    indexList.push(index);
                } else {
                    uncheckedThreadIds.push(element.threadId);
                    uncheckedPhoneNumbers.push(element.telephone);
                    let tempArray: string[] | undefined = element.telephone?.split?.(',');
                    Boolean(tempArray && tempArray.length > 1) && uncheckedListOfGroupSessionId.push(element.threadId);
                }
            }
            HiLog.w(TAG, '[deleteSessions] deleted session count: ' + threadIds.length +
              ', deletedSessionsUnreadTotal: ' + deletedSessionsUnreadTotal);
          this.conversationListDataSource.multiDeleteByThreadId(mmsList);
          this.messageList = this.conversationListDataSource.mmsList;
          this.total -= indexList.length;
          HiLog.i(TAG, 'deleteDialogConfirm first this.messageList length: ' + this.messageList.length);
            this.messageDataStatus = this.messageList.length > 0 ? common.MSG_DATA_STATUS.MSG_NO_EMPTY :
              (this.hasInfoMsg == true ? common.MSG_DATA_STATUS.MSG_NO_EMPTY : common.MSG_DATA_STATUS.MSG_EMPTY)
        })
        this.isMultipleSelectState = false;
        PanGestureUtil.refresh()
        this.checkedStatus.clear();
        this.refreshConversationListSelectCount(0);
        this.messageList = this.conversationListDataSource.mmsList;
        HiLog.i(TAG, 'deleteDialogConfirm second this.messageList length: ' + this.messageList.length);
        let actionData: LooseObject = {};
        if (this.mIsConversationCheckAlling) {
          if (this.deleteMmsAfterDataSet.size > 0) {
            this.deleteMmsAfterDataSet.forEach((item) => {
              uncheckedThreadIds.push(item.threadId);
              uncheckedPhoneNumbers.push(item.telephone);
              let tempArray: string[] | undefined = item.telephone.split?.(',');
              Boolean(tempArray && tempArray.length > 1) && uncheckedListOfGroupSessionId.push(item.threadId);
            })
          }
          actionData = this.setUnActionData(uncheckedThreadIds, uncheckedPhoneNumbers, uncheckedListOfGroupSessionId);
          actionData.deleteMessage = common.deleteMessage.DELETEUNCHECK;
          //如果未选中零条信息，
          if (uncheckedThreadIds.length === 0) {
            actionData.deleteMessage = common.deleteMessage.DELETEALL;
          }
          //并且打开了信息整合。
          if (this.hasAggregate) {
            actionData.smsType = common.sms_type.COMMON;
          }
          NotificationService.getInstance().cancelMessageNotify(context, actionData, () => {});
          ConversationListService.getInstance().deleteSessionByUriPagination(actionData, () => {
            this.statisticalData(context);
            // 防止未加载完分页数据（只刷了首屏），一直删除会话导致页面空白
            if (this.hasMore) {
              this.queryAllMessages(context);
            }
            this.JudgingHasInfoMsg(context);
          }, context);
          this.isConversationCheckAll = false;
          this.mIsConversationCheckAlling = false;
          setTimeout(()=>{
            this.subscriberCallBack(context);
          }, 200)
        } else {
          if (threadIds.length == 0) {
            this.deleteIng = false;
            return;
          }
          setTimeout(()=>{ this.conversationListDataSource.notifyDataReload(); }, 200)
          actionData = this.setActionData(threadIds, phoneNumbers, listOfGroupSessionId);
          actionData.deleteMessage = common.deleteMessage.DELETECHECK;
          NotificationService.getInstance().cancelMessageNotify(context, actionData, () => {
            actionData.hasRead = undefined;
            ConversationListService.getInstance().deleteSessionByUriPagination(actionData, () => {
              this.statisticalData(context);
              // 防止未加载完分页数据（只刷了首屏），一直删除会话导致页面空白
              if (this.hasMore) {
                this.queryAllMessages(context);
              }
              this.JudgingHasInfoMsg(context);
            }, context);
          });
        }
        this.deleteIng = false;
        let curBp: string = AppStorage.get('curBp') as string;
        if (curBp !== common.STR.DEVICE_MOBILE_PHONE) {
          this.deleteChangeDefaultMsg(phoneNumbers)
        }
    }

    private JudgingHasInfoMsg(context: Context) {
      ConversationListService.getInstance()
        .isExistNoticeMessage(context)
        .then((value) => {
          this.hasInfoMsg = value;
          this.messageDataStatus = this.messageList.length > 0 ?
          common.MSG_DATA_STATUS.MSG_NO_EMPTY : (this.hasInfoMsg == true ?
            common.MSG_DATA_STATUS.MSG_NO_EMPTY : common.MSG_DATA_STATUS.MSG_EMPTY);
          AppStorage.setOrCreate('hasInfoMsg', value);
        });
    }

    private setActionData(threadIds: number[], phoneNumbers: string[], sessionIds: number[]): LooseObject {
      let actionData: LooseObject = {};
      actionData.threadIds = threadIds;
      actionData.phoneNumbers = phoneNumbers;
      actionData.listOfGroupSessionId = sessionIds;
      actionData.hasRead = common.is_read.UN_READ;
      return actionData;
    }

    private setUnActionData(threadIds: number[], phoneNumbers: string[], sessionIds: number[]): LooseObject {
      let actionData: LooseObject = {};
      actionData.uncheckedThreadIds = threadIds;
      actionData.uncheckedPhoneNumbers = phoneNumbers;
      actionData.uncheckedListOfGroupSessionId = sessionIds;
      return actionData;
    }

    deleteChangeDefaultMsg(phoneNumbers: Array<string>) {
        let needChangeDefaultMsg = phoneNumbers.some(item => {
            return item == AppStorage.get('selectPhoneNumber')
        })
        HiLog.i(TAG, 'needChangeDefaultMsg:' + JSON.stringify(needChangeDefaultMsg))
        if (this.pageInfos.getAllPathName()[0] === 'Conversation') {
          let strContactsNumber: string =
            (this.pageInfos.getParamByIndex(0) as LooseObject)?.strContactsNumber;
          phoneNumbers.some(item => {
            if (item === strContactsNumber) {
              this.pageInfos.removeByName('Conversation')
            }
          })
        } else if (this.messageList.length === 0) {
          this.pageInfos.pop()
          return;
        }
        HiLog.i(TAG, 'needChangeDefaultMsg:' + JSON.stringify(needChangeDefaultMsg))
        if (needChangeDefaultMsg) {
            this.showFirstMessage()
        }
    }


    deleteDialogCancel() {
        HiLog.i(TAG, 'deleteDialogCancel')
        if (!this.isMultipleSelectState) {
            if (this.messageList[this.delItem] != null) {
                this.messageList[this.delItem].isCbChecked = false;
            }
        }
    }

    setDelShow() {
        if (this.itemTouchedIdx >= 0) {
            let item: messageType = this.messageList[this.itemTouchedIdx];
            this.setListItemTransX(0);
            item.isDelShow = false;
        }
    }

    markInfoMsgAllAsRead() {
        HiLog.w(TAG, '[markInfoMsgAllAsRead] unreadTotal: ' + this.unreadTotal + ', unreadTotalOfInfo: ' + this.unreadTotalOfInfo);
        this.unreadTotal -= this.unreadTotalOfInfo;
        this.unreadTotalOfInfo = 0;
        AppStorage.SetOrCreate('unreadTotalOfInfo', 0);
        InfoMsgController.getInstance().unreadTotalOfInfo = 0;
        this.conversationListDataSource.refresh(this.messageList, 'markInfoMsgAllAsRead');
    }

    clickToMarkAllAsRead(context: Context) {
        HiLog.w(TAG, '[clickToMarkAllAsRead] unreadTotal: ' + this.unreadTotal +
        ', unreadTotalOfInfo: ' + this.unreadTotalOfInfo);
        let threadIds: Array<number> = [];
        for (let mms of this.messageList) {
            if (mms.countOfUnread > common.int.MESSAGE_CODE_ZERO) {
                threadIds.push(mms.threadId);
            }
        }
        let actionData: LooseObject = {};
        actionData.threadIds = threadIds;
        actionData.hasRead = common.is_read.UN_READ;
        actionData.markReadType = MarkRead.all;
        NotificationService.getInstance().cancelMessageNotify(context, actionData, () => {}).then(() => {
          ConversationListService.getInstance().markAllAsRead(context, actionData);
        });
        let badgeContext: ISetBadgeContextInfo = {
          unreadTotal: 0,
          appContext: context,
          updateBadgeEventCode: 'clickToMarkAllAsRead',
          tracedId: systemDateTime.getTime().toString()
        }
        NotificationService.getInstance(context).setBadgeNumberWithContext(badgeContext);
        // 全部已读 设置首选项值为0
        SharedPreferencesUtils.saveToPreferences(common.STR.KEY_OF_UNREAD_TOTAL, 0);
        SharedPreferencesUtils.saveToPreferences(common.STR.KEY_OF_UNREAD_INFO, 0);
        this.unreadTotalOfInfo = 0;
        AppStorage.setOrCreate('unreadTotalOfInfo', 0);
        this.unreadTotal = 0;
      this.unReadQueue = new Queue();
      this.unReadListSize = 0;
        let tempMsgList: Array<messageType> = this.messageList;
        for (let msg of tempMsgList) {
            if (threadIds.indexOf(msg.threadId) != -1) {
                msg.countOfUnread = common.int.MESSAGE_CODE_ZERO;
            }
        }
        this.messageList = tempMsgList;
        HiLog.i(TAG, 'clickToMarkAllAsRead this.messageList length: ' + this.messageList.length);
        this.conversationListDataSource.refresh(this.messageList, 'clickToMarkAllAsRead');
        this.sendUpdateAccessibilityStr();
    }

    jumpToSettingsPage() {
        HiLog.i(TAG, 'jumpToSettingsPage entry');
        let curBp: string = AppStorage.get('curBp') as string;
        if (curBp !== common.STR.DEVICE_MOBILE_PHONE) {
            this.lastIndex = -1
            AppStorage.setOrCreate('selectPhoneNumber', '')
        }
            this.pageInfos.pushPathByName('Settings', {pageFlag: 'settingsDetail'} as PageFlag)
        HiLog.i(TAG, 'jumpToSettingsPage end');
    }

    jumpToFavoritesPage(){
        HiLog.i(TAG, 'jumpToFavoritesPage entry');
        let curBp: string = AppStorage.get('curBp') as string;
        let param: LooseObject = {
            searchContent: this.inputValueOfSearch
        }
        if (curBp !== common.STR.DEVICE_MOBILE_PHONE) {
            this.lastIndex = -1
            AppStorage.setOrCreate('selectPhoneNumber', '')
        }
          this.pageInfos.pushPathByName('Favorites', param)
        HiLog.i(TAG, 'jumpToFavoritesPage end');
    }

    jumpToFeedbackMenu() {
      let context = getContext(this) as myCommon.UIAbilityContext;
      const want: Want = {
        bundleName: "com.ohos.hiviewcare",
        abilityName:"FeedBackAbility",
        parameters: {
          pafAppid: "6051",
          bName: "com.ohos.mms"
        }
      }
      context.startAbility(want);
    }

    subscribeStaticEvent(){
        let events = [common.STR.MMS_SUBSCRIBER_COMMON_EVENT];
        interface commonEventSubscribeInfoType {
            events: string[],
            publisherPermission: string;
        };
        let commonEventSubscribeInfoData: commonEventSubscribeInfoType = {
            events: events,
            publisherPermission: 'ohos.permission.RECEIVE_SMS'
        };
        let commonEventSubscribeInfo = commonEventSubscribeInfoData;
        commonEvent.createSubscriber(commonEventSubscribeInfo, (args1,args2) => {this.createStaticSubscriberCallBack(args1,args2);});
    }
    unSubscribeStaticEvent(){
        if (this.staticEventData != null) {
            commonEvent.unsubscribe(this.staticEventData, () => {
                HiLog.i(TAG, 'unsubscribe staticEventData, success');
            });
        }
    }

    subscribeTimeChangeEvent() {
        let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
            events: [common.STR.COMMON_EVENT_TIME_CHANGED]
        };
        commonEventManager.createSubscriber(subscribeInfo,
            (arg1, arg2) => {this.createTimeChangeSubscriberCallBack(arg1, arg2)})
    }

    unSubscribeTimeChangeEvent() {
        if (this.timeChangeEventData != null) {
            commonEvent.unsubscribe(this.timeChangeEventData, () => {
                HiLog.i(TAG, 'unsubscribe timeChangeEventData, success');
            });
        }
    }

    createTimeChangeSubscriberCallBack(err: BusinessError, data: commonEventManager.CommonEventSubscriber) {
        if (!err) {
            HiLog.i(TAG, `createTimeChangeSubscriber`)
            this.timeChangeEventData = data;
            commonEventManager.subscribe(this.timeChangeEventData, (err, data)=>{
                HiLog.i(TAG, 'createTimeChangeSubscriberCallBack,err : ' + err?.code)
                if (data == null) {
                    HiLog.w(TAG, 'refreshEventData, data or data.data is null, return');
                    return;
                }
                let is24HourTime: boolean = false;
                try {
                    is24HourTime = I18n.System.is24HourClock();
                } catch (error) {
                    let err: BusinessError = error as BusinessError;
                    HiLog.e(TAG, `call System.is24HourClock failed, error code: ${err.code}, message: ${err.message}.`);
                }
                HiLog.i(TAG, `24timeChange: ${JSON.stringify(is24HourTime)}`)
                GlobalContext.getContext().setObject('is24HourTimeChange', true);
                GlobalContext.getContext().setObject('is24HourTime', is24HourTime);
                this.conversationListDataSet();
                this.conversationListDataSource.refresh(this.messageList);
            });
        } else {
            HiLog.e(TAG, `createTimeChangeSubscriber failed, code is ${err.code}, message is ${err.message}`);
        }
    }

    subscribeTimeTickEvent() {
        let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
            events: [common.STR.COMMON_EVENT_TIME_TICK]
        };
        commonEventManager.createSubscriber(subscribeInfo,
            (arg1, arg2) => {this.createTimeTickSubscriberCallBack(arg1, arg2)})
    }

    unSubscribeTimeTickEvent() {
      if (this.timeTickEventData != null) {
        commonEvent.unsubscribe(this.timeTickEventData, () => {
          HiLog.i(TAG, 'unsubscribe timeTickEventData, success');
        });
      }
    }

    createTimeTickSubscriberCallBack(err: BusinessError, data: commonEventManager.CommonEventSubscriber) {
        if (!err) {
            HiLog.i(TAG, `createTimeTickSubscriber`);
            this.timeTickEventData = data;
            commonEventManager.subscribe(this.timeTickEventData, (err, data)=>{
                HiLog.i(TAG, 'createTimeTickSubscriberCallBack,err : ' + err?.code);
                if (data == null) {
                    HiLog.w(TAG, 'refreshEventData, data or data.data is null, return');
                    return;
                }
                HiLog.i(TAG, `TimeTick`);
                GlobalContext.getContext().setObject('TimeTick', true);
            });
        } else {
            HiLog.e(TAG, `createTimeTickSubscriber failed, code is ${err.code}, message is ${err.message}`);
        }
    }

  subscribeTimeTickEvent1() {
    let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: ['event.custom.satellite.ACTION_BEIDOU_SATELLITE_MESSAGE']
    };
    commonEventManager.createSubscriber(subscribeInfo,
      (arg1, arg2) => {this.createTimeTickSubscriberCallBack1(arg1, arg2)})
  }

  unSubscribeTimeTickEvent1() {
    if (this.timeTickEventData1 != null) {
      commonEvent.unsubscribe(this.timeTickEventData1, () => {
        HiLog.i(TAG, 'unsubscribe timeTickEventData, success');
      });
    }
  }

  createTimeTickSubscriberCallBack1(err: BusinessError, data: commonEventManager.CommonEventSubscriber) {
    if (!err) {
      HiLog.i(TAG, `createTimeTickSubscriber1`);
      this.timeTickEventData1 = data;
      commonEventManager.subscribe(this.timeTickEventData1, (err, data)=>{
        HiLog.i(TAG, 'createTimeTickSubscriberCallBack,err : ' + err?.code);
        if (data == null) {
          HiLog.w(TAG, 'refreshEventData, data or data.data is null, return');
          return;
        }
        HiLog.i(TAG, `TimeTick1`);
        let slotId: number = data.parameters?.slotId;
        let summerNumber: number = data.parameters?.simNumber;
        if (slotId === 0 && summerNumber !== undefined) {
          SharedPreferencesUtils.saveToPreferences(common.STR.KEY_OF_SIM_0_NUMBER, summerNumber);
        } else if (slotId === 1 && summerNumber !== undefined) {
          SharedPreferencesUtils.saveToPreferences(common.STR.KEY_OF_SIM_1_NUMBER, summerNumber);
        }
      });
    } else {
      HiLog.e(TAG, `createTimeTickSubscriber failed, code is ${err.code}, message is ${err.message}`);
    }
  }

    // Instruct the application to refresh the session list after the clone is complete.
    subscribeNeedRefreshEvent(context: Context) {
        let subscribeInfoData: commonEvent.CommonEventSubscribeInfo = {
            events: ['refreshConversionList'],
            publisherPermission: 'ohos.permission.READ_MESSAGES'
        };
        commonEventManager.createSubscriber(subscribeInfoData, (err, data) => {
            if (err) {
                HiLog.e(TAG, `create refresh Subscriber failed, code is ${err.code}, message is ${err.message}`);
                return;
            }
            this.needRefreshEventData = data;
            commonEventManager.subscribe(this.needRefreshEventData, (err, data)=>{
                if (data == null) {
                    HiLog.w(TAG, 'needRefreshEventData, data or data.data is null, return');
                    return;
                }
                this.requestItem(context);
            });
        });
    }

    unsubscribeNeedRefreshEvent() {
        if (this.needRefreshEventData == null) {
            return;
        }
        commonEvent.unsubscribe(this.needRefreshEventData, () => {
            HiLog.i(TAG, 'unsubscribe needRefreshEventData, success');
        });
    }

    subscribe(context: Context) {
        let events = [common.STR.RECEIVE_TRANSMIT_EVENT]
        interface  commonEventSubscribeInfoType {
            events: string[],
            publisherPermission: string;
        }
        let commonEventSubscribeInfoData: commonEventSubscribeInfoType = {
            events: events,
            publisherPermission: 'ohos.permission.RECEIVE_SMS'
        };
        let commonEventSubscribeInfo = commonEventSubscribeInfoData;
        commonEvent.createSubscriber(commonEventSubscribeInfo, (args1,args2) => {this.createSubscriberCallBack(context, args1, args2);});

        let eventsUpdate = [common.STR.RECEIVE_UPDATE_EVENT]
        let commonUpdateEventSubscribeInfoData: commonEventSubscribeInfoType = {
            events: eventsUpdate,
            publisherPermission: 'ohos.permission.RECEIVE_SMS'
        };
        let commonUpdateEventSubscribeInfo = commonUpdateEventSubscribeInfoData;
        commonEvent.createSubscriber(commonUpdateEventSubscribeInfo, (args1,args2) => {this.createUpdateSubscriberCallBack(context, args1,args2)});

        let eventsRefresh = [common.STR.MESSAGE_STATUS_CHANGE_NOTIFY]
        let commonRefreshEventSubscribeInfoData: commonEventManager.CommonEventSubscribeInfo = {
            events: eventsRefresh,
        };
        let commonRefreshEventSubscribeInfo = commonRefreshEventSubscribeInfoData;
        commonEvent.createSubscriber(commonRefreshEventSubscribeInfo, (args1, args2) => {
            this.createSubscriberRefreshCallBack(context, args1, args2)
        });
    }

    subscribeMms(context: Context) {
        let events = [common.STR.RECEIVE_TRANSMIT_EVENT]
        interface commonEventSubscribeInfoType {
            events: string[],
            publisherPermission: string;
        }
        let commonEventSubscribeInfoData: commonEventSubscribeInfoType = {
            events: events,
            publisherPermission: 'ohos.permission.RECEIVE_MMS'
        };
        let commonEventSubscribeInfo = commonEventSubscribeInfoData;
        commonEvent.createSubscriber(commonEventSubscribeInfo, (args1, args2) => {
            this.createSubscriberCallBackMms(context, args1, args2);
        });
    }

  subscriberCallBack(context: Context, data?: commonEventManager.CommonEventData) {
    if (this.mIsConversationCheckAlling && data !== null && data !== undefined) {
      if (data.data !== undefined && data.data !== null && data.data.length != 0) {
        this.deleteMmsAfterDataSet.add({
          telephone: JSON.parse(data.data).telephone,
          threadId: JSON.parse(data.data).threadId
        });
      }
    } else if ((this.noUiProp.scrollStartIndex > common.int.SHOW_SESSION_FIRST + this.pinSessionSize) &&
      data !== null && data !== undefined) {
      if (data.data !== undefined && data.data !== null && data.data.length != 0) {
        let telephone: string = JSON.parse(data.data).telephone;
        this.messageList.forEach((item, index) => {
          if (telephone === item.telephone) {
            this.conversationListDataSource.deleteByIndex(index);
          }
        })
        this.scrollTopNeedUpdate = true;
      }
    } else {
      this.scrollTopNeedUpdate = false;
      this.deleteMmsAfterDataSet.clear()
      this.messageList = [];
      this.requestItem(context);
      // Collecting Unread Information
      this.statisticalData(context);
    }
  }

    // Unsubscribe
    unSubscribe() {
        HiLog.i(TAG, 'unSubscribe');
        if (this.commonEventData != null) {
            commonEvent.unsubscribe(this.commonEventData, () => {
                HiLog.i(TAG, 'unSubscribe, success');
            });
            commonEvent.unsubscribe(this.updateEventData, () => {
                HiLog.i(TAG, 'unSubscribe, success');
            });
            commonEvent.unsubscribe(this.commonEventDataMms, () => {
                HiLog.i(TAG, 'commonEventDataMms unSubscribe, success');
            });
            this.commonEventData = undefined;
        }
    }

  createSubscriberCallBack(context: Context, err: BusinessError, data: commonEventManager.CommonEventSubscriber) {
    this.commonEventData = data;
    HiLog.i(TAG, 'commonEventData already get new data');
    // Received subscription
    commonEvent.subscribe(this.commonEventData, (args1, args2) => {
      this.subscriberCallBack(context, args2)
    });
  }
    createUpdateSubscriberCallBack(context: Context, err: BusinessError, data: commonEventManager.CommonEventSubscriber) {
        this.updateEventData = data;
        // Received subscription
        commonEvent.subscribe(this.updateEventData, (args1,args2)=>{
            this.updateData(context, args1, args2)
        });
    }

    createSubscriberCallBackMms(context: Context, err: BusinessError, data: commonEventManager.CommonEventSubscriber) {
        this.commonEventDataMms = data;
        HiLog.i(TAG, 'commonEventDataMms already get new data');
        // Received subscription
        commonEvent.subscribe(this.commonEventDataMms, (args1, args2) => {
            this.subscriberCallBack(context, args2)
            this.lastIndex = -1;
        });
    }

    createSubscriberRefreshCallBack(context: Context, err: BusinessError, data: commonEventManager.CommonEventSubscriber) {
        this.refreshEventDataMms = data;
        commonEvent.subscribe(this.refreshEventDataMms, (err, data) => {
            HiLog.i(TAG, 'createSubscriberRefreshCallBack,err : ' + err?.code)
            GlobalContext.getContext().setObject('needToUpdate', true);
            HiLog.i(TAG, 'createSubscriberRefreshCallBack already get new data');
            if (this.noUiProp.scrollStartIndex > 7) {
                HiLog.i(TAG, 'createSubscriberRefreshCallBack back to the first page and refresh');
                //当前不是分页加载的首页，只改变标示值
                this.scrollTopNeedUpdate = true;
            } else {
                HiLog.i(TAG, 'createSubscriberRefreshCallBack refresh now');
                //当前是分页加载的首页，刷新
                this.messageList = [];
                this.requestItem(context);
            }
        });
    }

    unsubscribeRefreshEventDataMms() {
        if (this.refreshEventDataMms == undefined) {
            return;
        }
        commonEvent.unsubscribe(this.refreshEventDataMms, () => {
            this.refreshEventDataMms = undefined;
            HiLog.i(TAG, 'unsubscribe refreshEventDataMms, success');
        });
    }

    createStaticSubscriberCallBack(err: BusinessError, data: commonEventManager.CommonEventSubscriber) {
        this.staticEventData = data;
        // Received subscription
        commonEvent.subscribe(this.staticEventData, (err, data)=>{
            HiLog.i(TAG,'createStaticSubscriberCallBack,err : '+err?.code)
            if (data == null || data.data == null) {
                HiLog.w(TAG, 'refreshEventData, data or data.data is null, return');
                return;
            }
            let needToUpdate: boolean = JSON.parse(data.data).needToUpdate;
            HiLog.i(TAG,'refreshEventData ,needToUpdate:'+needToUpdate)
            GlobalContext.getContext().setObject('needToUpdate', needToUpdate);
            SharedPreferencesUtils.saveToPreferences('needToUpdateRecMsg', true);
        });
    }

    acceptFailureEvent(){
        let events = [common.STR.RCS_SUBSCRIBER_FAIL_EVENT];
        interface commonEventSubscribeInfoType {
            events: string[],
        };
        let commonEventSubscribeInfoData: commonEventSubscribeInfoType = {
            events: events,
        };
        let commonEventSubscribeInfo = commonEventSubscribeInfoData;
        commonEvent.createSubscriber(commonEventSubscribeInfo, (args1,args2) => {this.createAcceptFailureCallBack(args1,args2);});
    }

    createAcceptFailureCallBack(err: BusinessError, data: commonEventManager.CommonEventSubscriber) {
        this.memoryEventData = data;
        // Received subscription
        commonEvent.subscribe(this.memoryEventData, (err, data)=>{
            if (data == null || data.data == null) {
                HiLog.w(TAG, 'createAcceptFailureCallBack, data or data.data is null, return');
                return;
            }
            let innerEvent: emitter.InnerEvent = { eventId: EmitterConstant.EVENT_CHANGE_RCS_ACCEPT_FAIL };
            let eventData: emitter.EventData = {
                data: {
                    'isShowFailDialog': true,
                }
            }
            emitter.emit(innerEvent, eventData)
        });
    }

    unSubscribeMemoryEvent(){
        if (this.memoryEventData != null) {
            commonEvent.unsubscribe(this.memoryEventData, () => {
                HiLog.i(TAG, 'unsubscribe staticEventData, success');
            });
        }
    }

    // statistical data
  statisticalData(context: Context) {
        ConversationListService.getInstance().statisticalData((result: Result) => {
            if (result.code == common.int.SUCCESS) {
                AppStorage.setOrCreate('unreadTotalOfInfo', this.unreadTotalOfInfo);
            } else {
                HiLog.w(TAG, 'statisticalData, failed');
            }
        }, context);
    }

    // Obtains the switch value for integrating notification information and displaying contact avatars.
    getSettingFlagForConvListPage() {
        let that = this;
        let result = SettingService.getSettingFlagForConvListPage();
        if (result) {
            that.hasAggregate = result.hasAggregate;
            that.isShowContactHeadIcon = result.isShowContactHeadIcon;
            AppStorage.setOrCreate('isShowContactHeadIcon',result.isShowContactHeadIcon);
            if (DeviceUtil.isPC()) {
              AppStorage.setOrCreate('isPCShowMessageBackButton',result.hasAggregate);
            }
        }
    }

  // 30天自动删除通知信息时不会立即刷新角标,需要在删除后获取下未读数触发角标刷新
  requestStatisticalData(context: Context) {
    this.statisticalData(context);
  }

  // Obtaining List Data in Pagination Mode
  requestItem(context: Context) {
    GlobalContext.getContext().setObject('needToUpdate', false)
    let actionData: LooseObject = {};
    if (this.hasAggregate) {
      // 增加首选项存储，优化冷启动打开列表页面通知信息整合栏，加载慢问题 易白屏问题
      let hasInfoMsgBool = SharedPreferencesUtils.getFromPreferences("hasInfoMsgBool", '');
      if (hasInfoMsgBool !== '') {
        this.messageDataStatus = hasInfoMsgBool == true
          ? common.MSG_DATA_STATUS.MSG_NO_EMPTY : this.messageDataStatus;
        this.hasInfoMsg = hasInfoMsgBool as boolean;
      }
      actionData.smsType = common.sms_type.COMMON;
      ConversationListService.getInstance()
        .isExistNoticeMessage(context)
        .then((value) => {
          this.hasInfoMsg = value;
          SharedPreferencesUtils.saveToPreferences("hasInfoMsgBool", value);
          this.messageDataStatus = this.hasInfoMsg == true
            ? common.MSG_DATA_STATUS.MSG_NO_EMPTY : this.messageDataStatus;
          AppStorage.SetOrCreate('hasInfoMsg', value);
        })
    }
    HiLog.i(TAG, 'requestItem need query, :' + actionData.smsType);
    // 1、查询第一批数据。
    this.queryCurPageAndRefresh(context, () => {
      // 普通消息会话列表查询结束后，触发未读数据清理
      // 会触发短信的全量查询，严重影响性能，当前版本暂不需要清理，后续需要再开启
      // 暂保留实现，删除入口
      this.tryUpdateSessionContactInfo(context);
      //升级检查
      this.upgradeCheck(context);
      this.isNeedPinNumberOffset = true;
      if (this.pinSessionSize === -1) {
        this.queryPinSessionSize(context);
      }
      // 页面刷新后，注册延迟任务
      if (!this.hasRegisterBackupWork) {
        clearTimeout(this.backupWorkTimerId);
        this.backupWorkTimerId = setTimeout(()=>{
          BackupRestoreRpc.getInstance().connect();
        }, common.int.BACKUP_WORK_DELAY_TIME);
        this.hasRegisterBackupWork = true;
      }
    });

    ConversationListService.getInstance()
      .getSessionListSize(actionData, context)
      .then((sessionSize) => {
        this.total = sessionSize;
        this.hasNoOrdinaryMsg = this.total == 0 ? true : false;
      })
  }

  private upgradeCheck(context: Context) {
    let curVersion = SharedPreferencesUtils.getFromPreferences('updateInfoMsgVersion', 0);
    HiLog.i(TAG, `updateInfoMsgVersion: ${curVersion}` + `alreadyExecute: ${this.alreadyExecute}`);
    if (curVersion >= Constant.UPDATE_MSG_VERSION_V4) {
      return;
    }

    let taskQueue: taskpool.SequenceRunner = new taskpool.SequenceRunner();
    if (curVersion < Constant.UPDATE_MSG_VERSION_V2 && !this.alreadyExecute) {
      taskQueue.execute(new taskpool.Task(fetchRecentContactsAndBatchUpdateInfoTaskPool, context))
        .then(() => {
          HiLog.i(TAG, 'fetchRecentContactsAndBatchUpdateInfoTaskPool exec success');
          this.alreadyExecute = true;
          this.statisticalData(context);
          this.requestItem(context);
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'fetchRecentContactsAndBatchUpdateInfoTaskPool error ' + JSON.stringify(error));
          SharedPreferencesUtils.saveToPreferences('updateInfoMsgVersion',
            Constant.NO_UPDATE_INFO_MSG_VERSION);
        })
    }
    if (curVersion < Constant.UPDATE_MSG_VERSION_V4 && !this.alreadySyncVcard) {
      this.alreadySyncVcard = true;
      taskQueue.execute(new taskpool.Task(fetchRcsInfoAndBatchUpdateSmsMmsInfoTask, context))
        .then((res: ESObject) => {
          HiLog.i(TAG, 'fetchRcsInfoAndBatchUpdateSmsMmsInfoTask exec success, res:' + res);
          if (res === common.int.SUCCESS) {
            SharedPreferencesUtils.saveToPreferencesTaskPool('updateInfoMsgVersion', Constant.UPDATE_MSG_VERSION_V4);
          }
        })
        .catch((error: BusinessError) => {
          HiLog.e(TAG, 'fetchRcsInfoAndBatchUpdateSmsMmsInfoTask error ' + JSON.stringify(error));
        })
    }
  }

  async queryPinSessionSize(context: Context) {
    let data: LooseObject = {};
    if (this.hasAggregate) {
      data.smsType = common.sms_type.COMMON;
    }
    data.queryPinSessionSize = true;
    try {
      await ConversationListService.getInstance().queryPinSessionSize(data, context).then((pinSize) => {
        HiLog.i(TAG, 'queryPinSessionSize pinSize: ' + pinSize);
        this.isNeedPinNumberOffset = false;
        this.pinSessionSize = pinSize;
      })
    } catch (error) {
      HiLog.e(TAG, 'queryPinSessionSize fail error : ' + JSON.stringify(error));
    }
  }


  // The notification page is displayed.
  clickToSummerPalace() {
    if (this.resetTouch()) {
      HiLog.i(TAG, `[clickToSummerPalace] this.resetTouch()`)
      return;
    }
    if (this.isMultipleSelectState) {
      HiLog.i(TAG, `[clickToSummerPalace] this.isMultipleSelectState`)
      return;
    }
    HiLog.i(TAG, 'clickToSummerPalace')
    this.resetLastIndexValue();
    let pages: string[] = this.pageInfos?.getAllPathName();
    if (pages[pages.length - 1] === 'SmcConversation') {
      HiLog.i(TAG, `[clickToSummerPalace] this.isJumping`)
      return;
    }
    this.isToInfoView = true;
    let curBp: string = AppStorage.get('curBp') as string;
    if (curBp !== common.STR.DEVICE_MOBILE_PHONE) {
      this.pageInfos?.clear();
      AppStorage.set('selectPhoneNumber','')
    }
    SharedPreferencesUtils.init(getContext());
    let hasShowWelcomeBeiDou =
      SharedPreferencesUtils.getFromPreferencesTaskPool('has_show_welcome_bei_dou', false) as boolean;
    if (curBp === common.STR.DEVICE_MOBILE_PHONE) {
      HiLog.i(TAG, 'pushPathByName START')
      if (hasShowWelcomeBeiDou) {
        this.pageInfos.pushPathByName('SmcConversation', {} as LooseObject)
      } else {
        this.pageInfos.pushPathByName('SmcUsageGuide', {} as LooseObject)
      }
      HiLog.i(TAG, 'pushPathByName END')
    } else {
      this.pageInfos.replacePathByName('SmcConversation', {} as LooseObject)
    }
  }

    // The notification page is displayed.
    clickToInfoMessages() {
        if (this.resetTouch()) {
            HiLog.i(TAG, `[clickToInfoMessages] this.resetTouch()`)
            return;
        }
        if (this.isMultipleSelectState) {
            HiLog.i(TAG, `[clickToInfoMessages] this.isMultipleSelectState`)
            return;
        }
        HiLog.i(TAG, 'clickToInfoMessages')
        this.resetLastIndexValue();
        let pages: string[] = this.pageInfos?.getAllPathName();
        if (pages[pages.length - 1] === 'InfoMsg') {
            HiLog.i(TAG, `[clickToInfoMessages] this.isJumping`)
            return;
        }
        this.isToInfoView = true;
        AppStorage.set('isSelectAppMsg', false)
        let curBp: string = AppStorage.get('curBp') as string;
        if (curBp !== common.STR.DEVICE_MOBILE_PHONE) {
            this.pageInfos?.clear();
            AppStorage.set('selectPhoneNumber','')
        }
      InfoMsgController.getInstance().unreadTotalOfInfo = this.unreadTotalOfInfo;
      if (curBp === common.STR.DEVICE_MOBILE_PHONE) {
        HiLog.i(TAG, 'pushPathByName START')
        this.pageInfos.pushPathByName('InfoMsg', {} as LooseObject)
        HiLog.i(TAG, 'pushPathByName END')
      } else {
        this.pageInfos.replacePathByName('InfoMsg', {} as LooseObject)
      }
    }

    // Tap the avatar to go to the contact details page or recipient list page.
    clickToGroupDetail(context: Context, index: number) {
        if (this.isJumping) {
            return;
        }
        this.isJumping = true;
        // Determine whether to redirect to the contact details page or to the list page of multiple recipients.
        let contactsNum: number = this.messageList[index]?.contactsNum;
        let telephone = this.messageList[index]?.telephone;
      if (contactsNum > common.int.MESSAGE_CODE_ONE) {
        let threadId: number = this.messageList[index]?.threadId;
        this.jumpToGroupContactList(threadId);
        // 点击群组头像打点
        clickAvatarParams.AVATAR_NUMBER = 2;
        DotUtil.getInstance().reportEvent(clickAvatarParams, dotCommon.eventName.CLICK_AVATAR_EVENT);
      } else {
        let actionData: ActionData = {
          phoneNumber: telephone,
          pageFlag: common.contactPage.PAGE_FLAG_CONTACT_DETAILS,
          contactId:this.messageList[index].contactId,
        };
        this.jumpToContact(context, actionData);
        // 列表-点击单人头像打点
        clickAvatarParams.AVATAR_NUMBER = 1;
        DotUtil.getInstance().reportEvent(clickAvatarParams, dotCommon.eventName.CLICK_AVATAR_EVENT);
      }
    }

    // Switching to the Contacts app
    jumpToContact(context: Context, actionData: ActionData) {
        let str = commonService.commonContactParam(actionData);
      (context as myCommon.UIAbilityContext).startAbility(str).then((data) => {
            HiLog.i(TAG, 'jumpToContact, startAbility success');
        }).catch((error: BusinessError) => {
            HiLog.e(TAG, 'jumpToContact, failed Cause: ' + JSON.stringify(error.message));
                if (error.code == 16200001) {
                    this.againJumpToContact(context, actionData);
                }
        })
        this.isJumping = false;
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

    // Go to the multi-faceted portrait list page.
    jumpToGroupContactList(threadId: number) {
        HiLog.i(TAG, 'jumpToGroupContactList entry');
        try {
          if ((DeviceUtil.isTabletOrPC() || (DeviceUtil.isFoldable() &&
            display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED)) &&
            (this.pageInfos.getIndexByName('groupContactList').length > 0)) {
            this.pageInfos.replacePathByName('groupContactList', {
              threadId: threadId
            } as ThreadId);
          } else {
            this.pageInfos.pushPathByName('groupContactList', {
              threadId: threadId
            } as ThreadId);
          }
          this.isJumping = false;
          HiLog.i(TAG, 'jumpToGroupContactList entry');
        } catch (err) {
          HiLog.e(TAG, `Failed to getFoldStatus, Code: ${err.code}, message: ${err.message}`);
        }
    }

  queryAllMessages(context: Context) {
    this.pageIndex++;
    HiLog.i(TAG, 'queryAllMessages pageQuery: ' + this.pageIndex);
    this.queryPageMessages(context, this.pageIndex, StringUtil.getLimitForSession(this.pageIndex));
  }

  private doProcessTimeForIndexSessionListItem(indexSessionList: messageType[], context: Context) {
    for (let session of indexSessionList) {
      DateUtil.convertDateFormatForItem(session);
      //当列表处于多选情况下，新来信息导致列表isCbChecked初始化，需重新刷新isCbChecked对应的值
      session.isCbChecked = this.checkedStatus.has(session.threadId);
      if (FileUtils.isHasLocationImage(context, session.telephoneFormat)) {
        session.cachedComInfoUri = FileUtils.getSandboxPath(context, session.telephoneFormat);
      }
    }
  }

  /**
   * 刷新当前已查出的数据
   * @param context 上下文
   * @param callback 回调
   */
  queryCurPageAndRefresh(context: Context, callback: () => void) {
    HiLog.i(TAG, 'start queryCurPageAndRefresh');
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_LIST_QUERY_FIRST_PAGE,
      TraceConstant.TRACE_CONVERSATION_LIST_QUERY_FIRST_PAGE_ID);
    let curPageSize = this.conversationListDataSource.totalCount();
    HiLog.i(TAG, ` queryCurPageAndRefresh:${curPageSize}`);
    let actionData: LooseObject = {};
    actionData = queryMessagesDataBaseActionData(actionData, this.hasAggregate,
      Math.max(curPageSize, Constant.FIRST_PAGE_SIZE));
    actionData.sqlMethodQuery = true;
    actionData.queryOffset = 0;

    if (AppStorage.get(GlobalContextKey.QUERY_CONTACT_DATA_ON_COLD_START_UP)) {
      actionData.useWorker = false;
    }
    ConversationListService.getInstance().getSessionListResultNew(actionData, context).then((data) => {
      this.isFirstPageReady = true;
      this.messageList = [];
      if (data && data.response) {
        let responseList: messageType[] = ThreadObjectUtils.jsonToObjArray(data.response as messageType[]);
        this.doProcessTimeForIndexSessionListItem(responseList, context);
        // getSessionListResultNew 接口待整改，数据库没有数据时，返回的列表应该是空的才对。当前修改牵涉接口多，待后续修改。
        if (responseList.length == 1 && responseList[0].threadId <= 0) {
          HiLog.i(TAG, 'db has no session,but return one empty session,do not need handle.');
        } else {
          this.messageList = responseList;
        }
      } else {
        this.messageList = [];
      }
      this.conversationListDataSource.refresh(this.messageList, 'queryCurPageAndRefresh');
      this.sendUpdateAccessibilityStr();
      this.messageList = this.conversationListDataSource.mmsList;
      this.setUnReadQueue(this.messageList);
      this.pageIndex = 0;
      this.hasMore = this.messageList.length >= Constant.FIRST_PAGE_SIZE;
      this.messageDataStatus = this.messageList.length > 0
        ? common.MSG_DATA_STATUS.MSG_NO_EMPTY : (this.hasInfoMsg == true
          ? common.MSG_DATA_STATUS.MSG_NO_EMPTY : common.MSG_DATA_STATUS.MSG_EMPTY)
      HiLog.i(TAG, 'end queryCurPageAndRefresh ,messageList.length : ' + this.messageList.length);
      hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_LIST_QUERY_FIRST_PAGE,
        TraceConstant.TRACE_CONVERSATION_LIST_QUERY_FIRST_PAGE_ID);
      if (!(this.pageInfos?.size() > 0)) {
        this.showFirstMessage()
      }
      if (AppStorage.get('curBp') !== common.STR.DEVICE_MOBILE_PHONE) {
        for (let i = 0; i < this.messageList.length; i++) {
          if (this.messageList[i].telephone === AppStorage.get('selectPhoneNumber') &&
            this.messageList[i].countOfUnread > common.int.MESSAGE_CODE_ZERO) {
            this.messageList[i].countOfUnread = common.int.MESSAGE_CODE_ZERO;
            break;
          }
        }
        this.resetLastIndexValue();
      }
      callback();
    })
  }
    showFirstMessage(isUnfolding?: boolean, isFromIndexByIsSearching?: boolean) {
        let mmsNavMode: number = AppStorage.get('mmsNavMode') as number;
        if (mmsNavMode === common.int.NAVIGATION_MODE_SPLIT && this.messageList.length > 0) {
            if (this.isSettingDismiss && !isUnfolding) {
               this.isSettingDismiss = false;
               return;
            }
            // 折叠屏在搜索状态展开，显示详情页，跳转到折叠前的
          if (isFromIndexByIsSearching && this.currentConversatonIndex != 0
            && this.messageList[this.currentConversatonIndex]) {
            this.clickInfoToConversation(this.currentConversatonIndex, isUnfolding);
          } else {
            for (let index = 0; index < this.messageList.length; index++) {
              this.clickInfoToConversation(index, isUnfolding);
              break;
            }
          }
        }
    }

  queryPageMessages(context: Context, page: number, limit: number) {
    let actionData: LooseObject = {};
    HiLog.i(TAG, 'queryPageMessages, page:' + page + ',limit:' + limit);
    if (this.hasAggregate) {
      actionData.smsType = common.sms_type.COMMON;
    }
    actionData.page = page;
    actionData.limit = limit;
    actionData.orderByTimeDesc = true;
    actionData.sqlMethodQuery = true;
    let curPageSize = this.conversationListDataSource.totalCount();
    actionData.queryOffset = curPageSize;
    HiLog.iw(TAG, ` queryPageMessages actionData.queryOffset:${actionData.queryOffset}`);
    hiTraceMeter.startTrace(TraceConstant.TRACE_QUERY_CONVERSION_LIST, TraceConstant.TRACE_QUERY_CONVERSION_LIST_ID)
    ConversationListService.getInstance().getSessionListResultNew(actionData, context).then((data) => {
      // 二次校验如果数据已经加载，不重复加载
      if (this.conversationListDataSource.totalCount() !== actionData.queryOffset) {
        HiLog.w(TAG, 'queryPageMessages Data Source Mismatch');
        this.isQueryPageDone = true;
        return;
      }
      // getSessionListResultNew 接口待整改，数据库没有数据时，返回的列表应该是空的才对。当前修改牵涉接口多，待后续修改。
      if (data.response.length == 1 && data.response[0].threadId <= 0) {
        this.hasMore = false;
        this.isQueryPageDone = true;
        return
      }
      if (data.response.length > 0) {
        let responseList: messageType[] = data.response;
        responseList.forEach((item: messageType, index: number) => {
          DateUtil.convertDateFormatForItem(item);
          if (this.mIsConversationCheckAlling) {
            item.isCbChecked = true;
            this.checkedStatus.add(item.threadId);
          }
        })
      }
      let responseList: messageType[] = ThreadObjectUtils.jsonToObjArray(data.response as messageType[]);
      this.conversationListDataSource.refreshIndexPage(responseList, page, actionData.queryOffset);
      this.messageList = this.conversationListDataSource.mmsList;
      this.setUnReadQueue(this.messageList);
      HiLog.iw(TAG, 'queryPageMessages, this.messageList.length: ' + this.messageList.length +
        ', this.total: ' + this.total + ', page:' + page);
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_CONVERSION_LIST, TraceConstant.TRACE_QUERY_CONVERSION_LIST_ID);
      this.hasMore = this.messageList.length < this.total;
      this.isQueryPageDone = true;
    })
  }

    dealMmsListContent(item: messageType) {
        HiLog.i(TAG, 'messageType is ' + item.isDraft)
        if (item.hasMms && item.hasAttachment) {
            if (item.content == common.STR.EMPTY_STR) {
                item.content = $r('app.string.attachment_no_subject');
            } else {
                item.content = $r('app.string.attachment', item.content);
            }
        }
        if (item.hasMms && !item.hasAttachment && item.content == common.STR.EMPTY_STR) {
            item.content = $r('app.string.no_subject');
        }
    }

   sendSelectedEvent(id: number | null) {
      let innerEvent: emitter.InnerEvent = {
        eventId: EmitterConstant.EVENT_CONVERSATION_LIST_SELECT_STATUES_CHANGE,
      };
      let eventData: emitter.EventData = {
        data: { 'id': id }
      };
      emitter.emit(innerEvent, eventData);
    }

    sendUpdateAccessibilityStr() {
      let innerEvent: emitter.InnerEvent = {
        eventId: EmitterConstant.EVENT_CONVERSATION_LIST_ACCESSIBILITY_TEXT_CHANGE,
      };
      emitter.emit(innerEvent);
    }

    // The SM details page is displayed.
    clickInfoToConversation(index: number, isUnfolding?: boolean) {
        isUnfolding === undefined ? false : isUnfolding;
        if (this.resetTouch()) {
          HiLog.i(TAG, 'clickInfoToConversation resetTouch is true')
            return;
        }

      let isSearchResultEmpty:boolean=AppStorage.get('isSearchResultEmpty')??true
      if (!isSearchResultEmpty) {
        this.messageList = this.conversationListDataSource.mmsList;
      }
        if (this.messageList[index] == undefined) {
            HiLog.i(TAG, 'Message list is null!')
            this.messageList = this.conversationListDataSource.mmsList;
            HiLog.i(TAG, 'clickInfoToConversation this.messageList length: ' + this.messageList.length);
        }
        // If multiple options are selected, the system responds to CheckBox.
        if (this.isMultipleSelectState && !isUnfolding) {
            this.messageList[index].isCbChecked = !this.messageList[index].isCbChecked;
            PanGestureUtil.addFirstSelect(index, this.messageList[index].isCbChecked, true)
            if (this.messageList[index].isCbChecked) {
              this.checkedStatus.add(this.messageList[index].threadId);
            } else {
              this.checkedStatus.delete(this.messageList[index].threadId);
            }
            if (this.mIsConversationCheckAlling) {
              this.refreshConversationListSelectCount(this.total - (this.messageList.length - this.checkedStatus.size));
            } else {
              this.refreshConversationListSelectCount(this.checkedStatus.size);
            }
            this.sendSelectedEvent(this.messageList[index].threadId);
            return;
        }
       if (this.lastIndex == index){
            HiLog.i(TAG, `clickInfoToConversation index is: ${index}`)
            return;
       }
        this.lastIndex = index;
        this.isJumping = false;
        this.isToInfoView = false;
      this.refreshTimeForClickItem(AppStorage.get('curBp') as string);
      this.jumpToConversationPage(this.messageList[index]);
      // 查看信息-通知详情打点
      onlyStateParam.STATE = 1;
      DotUtil.getInstance().reportEvent(onlyStateParam, dotCommon.eventName.CLICK_TO_VIEW_SMS_EVENT);
    }

  /**
   * 点击会话列表进入详情刷新列表时间显示
   *
   * @param curBp 当前设备形态
   */
  public refreshTimeForClickItem(curBp: string) {
    if (curBp === common.STR.DEVICE_MOBILE_PHONE || StringUtil.isEmpty(curBp)) {
      return;
    }
    // 分栏设备点击进入详情页需刷新列表页显示时间（时间显示为X分钟之前的列需与详情页最新消息时间保持一致）
    HiLog.w(TAG, `clickInfoToConversation refreshTimeForClickItem`);
    let isNeedDataReload = false;
    this.conversationListDataSource.mmsList.forEach((item: messageType) => {
      if (DateUtil.isDateDiffOneHour(item)) {
        isNeedDataReload = true;
        DateUtil.convertDateFormatForItem(item);
      }
    });
    HiLog.w(TAG, `clickInfoToConversation refreshTimeForClickItem isNeedDataReload :${isNeedDataReload}`);
    if (!isNeedDataReload) {
      return;
    }
    setTimeout(() => {
      this.conversationListDataSource.notifyDataReload();
    }, 200);
  }

  /**
   * 滑动多选多选框状态
   */
  public gesTureListCheckBox(index: number, startCbChecked: boolean) {
    this.messageList[index].isCbChecked = startCbChecked;
    if (this.messageList[index].isCbChecked) {
      this.checkedStatus.add(this.messageList[index].threadId);
    } else {
      this.checkedStatus.delete(this.messageList[index].threadId);
    }
    if (this.mIsConversationCheckAlling) {
      this.refreshConversationListSelectCount(this.total - (this.messageList.length - this.checkedStatus.size));
    } else {
      this.refreshConversationListSelectCount(this.checkedStatus.size);
    }
    this.sendSelectedEvent(this.messageList[index].threadId);
  }

  // The SM click checkBox.
  clickCheckBox(index: number, value: boolean) {
    this.clickInfoToConversation(index);
  }

    // The session details page is displayed.
    jumpToConversationPage(item: messageType, msgId: string = '', fromInfoView?: boolean) {
      HiLog.i(TAG, `jumpToConversationPage entry ${item?.threadId}`);
      if (item) {
        let params: Params = {
          yellowPageId: item.yellowPageId,
          hasYellowPageIcon: item.hasYellowPageIcon,
          icon: item.icon,
          strContactsNumber: item.telephone,
          strContactsNumberFormat: item.telephoneFormat,
          strContactsName: ((!StringUtil.isEmpty(item.contactName) && StringUtil.isEmpty(item.contactId) &&
              !StringUtil.isContain(item.contactName, item.telephone))) ?
          item.contactName : item.name,
          contactsNameList: item.contactsNameList,
          contactsNum: item.contactsNum,
          threadId: item.threadId,
          isDraft: item.isDraft,
          draftContent: item.content,
          searchContent: this.inputValueOfSearch,
          msgId: msgId,
          photoFirstNames: item?.photoFirstNames,
          rawContactId: item?.rawContactId as string,
          smsType: item?.smsType,
          isNewMsgWithDraft: item?.messageCount == 0 && item?.isDraft,
          isFromInfoMsgView: fromInfoView ? fromInfoView : false,
          messageCount: item.messageCount as number,
          satelliteList: [],
          isFromNewCreatMessage: false,
          contactId:item.contactId,
        }
        let curBp: string = AppStorage.get('curBp') as string;

        if (curBp === common.STR.DEVICE_MOBILE_PHONE) {
          if (item.isDraft && item?.messageCount == 0 && !(item.telephone?.startsWith('sip:') &&
          item.telephone?.includes('botplatform'))) {
            this.pageInfos.pushPathByName('CreateNewConversation', params)
          } else {
            this.pageInfos.pushPathByName('Conversation', params)
            if ((item.telephone?.startsWith('sip:') && item.telephone?.includes('botplatform'))) {
              DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.CLICK_CHATBOT);
            }
          }
        } else {
          AppStorage.setOrCreate('needToSaveDraft', !AppStorage.get('needToSaveDraft'))
          this.pageInfos.clear();
          if (item.isDraft && item?.messageCount == 0) {
            this.pageInfos.replacePathByName('CreateNewConversation', params, false);
          } else {
            this.pageInfos.replacePathByName('Conversation', params, false);
          }
        }
        HiLog.i(TAG, 'jumpToConversationPage end');
      } else {
        HiLog.e(TAG, 'jumpToConversationPage failed,item is null!')
      }
    }

    markAsReadByThread(context: Context, item: messageType, telephone: string) {
      HiLog.i(TAG, 'markAsReadByThread')
      // rcs?.sendReadReceipt(telephone, () => {});
      this.handleMarkAllAsRead(context, item.threadId);
      item.countOfUnread = common.int.MESSAGE_CODE_ZERO;
      this.setUnReadQueue(this.messageList);
      HiLog.i(TAG, 'markAsReadByThread this.messageList length: ' + this.messageList.length);
      this.setListItemTransX(0);
    }

    handleMarkAllAsRead(context: Context, threadId: number, isFromConversation?: boolean) {
        let actionData: LooseObject = {};
        actionData.threadId = threadId;
        actionData.hasRead = common.is_read.UN_READ;
        HiLog.w(TAG, 'handleMarkAllAsRead  NotificationService.cancelMessageNotify');
      let markStartTime = new Date().getTime();
      ConversationListService.getInstance().markAllToRead(context, actionData, (response:ConversationListResponse) => {
        HiLog.iw(TAG, 'markAllToRead get response');
        if (response&&response.code === common.int.SUCCESS) {
          this.refreshListForHandleMarkAllAsRead(markStartTime, threadId, isFromConversation ?? false);
          HiLog.i(TAG, 'markAllToRead success and current thread has unread msg.start statisticalData')
          HiLog.w(TAG, '[markAllToRead] statisticalData');
          this.statisticalData(context);
        }
      });
        NotificationService.getInstance().cancelAllNotify();
        setTimeout(()=>{
            // 触发会话列表刷新，更新会话头像上的未读数
            let tempMsgList: Array<messageType> = this.messageList;
            for (let msg of tempMsgList) {
                if (msg.threadId == threadId) {
                    // 刷新会话头像上的未读数
                    msg.countOfUnread = common.int.MESSAGE_CODE_ZERO;
                }
            }
            this.messageList = tempMsgList;
           this.setUnReadQueue(this.messageList);
            HiLog.i(TAG, ' handleMarkAllAsRead this.messageList length: ' + this.messageList.length);
        }, 64)
    }

  /**
   * 单条会话标记已读更新数据库后刷新列表
   *
   * @param markStartTime 标记已读开始时间
   * @param threadId 会话Id
   * @param isFromConversation 是否是会话详情页onShown触发
   */
  public refreshListForHandleMarkAllAsRead(markStartTime: number, threadId: number, isFromConversation: boolean) {
    if (!isFromConversation) {
      HiLog.w(TAG, 'refreshListForHandleMarkAllAsRead params invalid');
      return;
    }
    let markTime = new Date().getTime() - markStartTime;
    HiLog.w(TAG,
    `refreshListForHandleMarkAllAsRead cost time: ${markTime},this.messageList length: ${this.messageList?.length}`);
    // 因时序问题会话标记已读完成之时。首页数据查询还未返回，此时this.messageList为空需延迟后刷新
    let timeOut: number = (this.messageList?.length === 0) ? 200 : 0;
    let needToReload = false;
    setTimeout(() => {
      for (let msg of this.messageList) {
        if (msg.threadId === threadId) {
          // 会话头像上未读数
          needToReload = msg.countOfUnread > 0;
          msg.countOfUnread = needToReload ? common.int.MESSAGE_CODE_ZERO : msg.countOfUnread;
          break;
        }
      }
      HiLog.w(TAG,
        `handleRefreshList needToReload: ${needToReload},this.messageList length: ${this.messageList?.length}`);
      if (needToReload && markTime <= common.int.MARK_ALL_TO_READ_MAX_COST_TIME) {
        HiLog.w(TAG, 'refreshListForHandleMarkAllAsRead success needToReload');
        this.conversationListDataSource.notifyDataReload();
      }
    }, timeOut);
  }

    handUpdateMsgList(threadId: number, index: number) {
      // 触发会话列表刷新，更新会话头像上的未读数
      let tempMsgList: Array<messageType> = this.messageList;
      for (let msg of tempMsgList) {
        if (msg.threadId == threadId) {
          // 刷新会话头像上的未读数
          msg.countOfUnread = common.int.MESSAGE_CODE_ONE;
          HiLog.i(TAG, 'handUpdateMsgList break threadId: ' + threadId);
          break;
        }
      }
      this.messageList = tempMsgList;
      HiLog.i(TAG, ' handUpdateMsgList this.messageList index: ' + index);
      this.conversationListDataSource.notifyDataChange(index);
    }

  handleMarkAsUnReadByIndex(context: Context, item: messageType) {
    let threadId: number = item?.threadId;
    this.handleMarkAsUnRead(context, threadId, item);
    this.setListItemTransX(0);
  }

  handleMarkAsUnRead(context: Context, threadId: number, threadItem: messageType) {
    let actionData: LooseObject = {};
    actionData.sessionId = threadId;
    HiLog.w(TAG, 'handleMarkAsUnRead  threadId:' + threadId);
    ConversationService.getInstance().queryMmsInfoLastReadCondition(context, actionData, async (res: resType) => {
      if (res.code == common.int.FAILURE || res.abilityResult.length == 0) {
        HiLog.w(TAG, 'handleMarkAsUnRead: query sms_mms_info fail, return!');
        return;
      }
        HiLog.i(TAG, 'handleMarkAsUnRead get response');
      let item = res.abilityResult[res.abilityResult.length -1];
          if (item.rcsId > 0) {
            await ConversationRcsService.getInstance().updateRcsInfoMessageToReadStateByCondition(context, item.rcsId, common.int.MESSAGE_UNREAD);
            HiLog.i(TAG, 'handleMarkAsUnRead rcs success');
            ConversationListService.getInstance().updateSessionRead(context, threadId);
            this.statisticalData(context);
            threadItem.countOfUnread = common.int.MESSAGE_CODE_ONE;
          } else {
            let mmsActionData: Record<string, number> = {
              'msgId': item.msgId
            }
            let valueBucket: Record<string, number> = {
              'is_read': common.int.MESSAGE_UNREAD
            }
            ConversationService.getInstance().updateSmsMmsInfoByCondition(context, mmsActionData,
              valueBucket, (res:LooseObject) => {
                if (res.code == common.int.SUCCESS) {
                  HiLog.i(TAG, 'handleMarkAsUnRead sms success');
                } else {
                  HiLog.i(TAG, 'handleMarkAsUnRead failed, resultcode: ' + res.code);
                }
                ConversationListService.getInstance().updateSessionRead(context, threadId);
                this.statisticalData(context);
              });
            threadItem.countOfUnread = common.int.MESSAGE_CODE_ONE;
          }
          this.messageList = this.conversationListDataSource.mmsList;
    });
  }

    deleteAction(idx: number) {
        this.delItem = idx;
        let element: messageType = this.messageList[idx] != null ? this.messageList[idx] : new messageType();
        AppStorage.setOrCreate('deleteSessionThreadId', element.threadId)
        this.strMsgDeleteDialogTip = $r('app.string.msg_delete_dialog_tip1');
        element.isCbChecked = true;
        this.messageDataStatus = this.messageList?.length > 0
          ? common.MSG_DATA_STATUS.MSG_NO_EMPTY : (this.hasInfoMsg == true
            ? common.MSG_DATA_STATUS.MSG_NO_EMPTY : common.MSG_DATA_STATUS.MSG_EMPTY)
    }

    checkHasCommonMessage() {
        return this.messageList.length > 0;
    }

    showMultipleSelectView() {
        this.resetTouch();
        if (this.checkHasCommonMessage()) {
            this.isMultipleSelectState = true;
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN)
        }
    }

    closeItemEnd() {
        HiLog.i(TAG,'closeItemEnd Start')
        this.messageList.forEach( (item: messageType) => {
            item.isMultipleSelectState = false;
        })
    }

    updateJumpStatus(status: boolean) {
        this.isJumping = status;
    }

    public simStateChangeStatusResult(slotId:number){
        HiLog.i(TAG,'simStateChangeStatusResult In')
        // let rcsState: boolean = rcs.isRcsSupported(slotId);
        // HiLog.i(TAG, 'simStateChangeStatus rcsState:'+rcsState)
        // The RCS capability is supported.
        // if (rcsState) {
        //     this.isRcsStatus = true;
        //     AppStorage.setOrCreate('rcsStatus', this.isRcsStatus)
        //     let isFirstInMms = SharedPreferencesUtils.getFromPreferences('isFirstMms', '');
        //     HiLog.i(TAG, `simStateChangeStatus isFirstMms success, data:->${JSON.stringify(isFirstInMms)}`);
        //     if (isFirstInMms) {
        //         this.isRcsOpenStatus = true;
        //     } else {
        //         this.isRcsOpenStatus = false;
        //     }
        //     if(this.isAirPlaneMode) {
        //         this.isRcsOpenStatus = true;
        //     }
        //     HiLog.i(TAG,'simStateChangeStatusResult In'+this.isRcsOpenStatus)
        //     AppStorage.setOrCreate('isOpenRcsStatus', this.isRcsOpenStatus)
        // } else {
        //     this.isRcsStatus = false;
        //     this.isRcsOpenStatus = true;
        //     AppStorage.setOrCreate('rcsStatus', this.isRcsStatus)
        //     AppStorage.setOrCreate('isOpenRcsStatus', this.isRcsOpenStatus)
        // }

    }

    public simStateChangeStatusNoHaveSimCard(){
        this.isRcsStatus = false;
        this.isRcsOpenStatus = true;
        AppStorage.setOrCreate('rcsStatus', this.isRcsStatus)
        AppStorage.setOrCreate('isOpenRcsStatus', this.isRcsOpenStatus)
    }

    public async getDefaultDataSlotId() {
        HiLog.i(TAG, 'getDefaultDataSlotId In');
        await this.isHasCard();
        HiLog.i(TAG, 'hasCard1 :'+this.hasCard1+'hasCard2 :'+this.hasCard2);
        if (!this.hasCard1 && !this.hasCard2) {
            HiLog.i(TAG, 'sim out');
            this.simStateChangeStatusNoHaveSimCard()
            // sim out
            this.isCellularOpen = true;
            HiLog.i(TAG, 'cellularDataGet:'+this.isCellularOpen);
            AppStorage.setOrCreate('cellularDataGet', this.isCellularOpen);
            AppStorage.setOrCreate('simOut',true);
        } else {
            HiLog.i(TAG, 'sim in');
            this.getPrimarySlotId().then((res) => {
                HiLog.i(TAG, 'getPrimarySlotId: then: ' + JSON.stringify(res));
                this.simStateChangeStatusResult(res);
                this.getCellularData(res);
            }).catch((err: BusinessError) => {
                HiLog.e(TAG, `getPrimarySlotId err = ${JSON.stringify(err)}`);
            });
            AppStorage.setOrCreate('simOut',false);
        };
    }


    getPrimarySlotId() {
        return new Promise((resolve: (value: number) => void, reject: (reason?: BusinessError) => void) => {
            try {
                radio.getPrimarySlotId((error, value) => {
                    if (error) {
                        HiLog.i(TAG, 'getPrimarySlotId error:' + JSON.stringify(error));
                        reject(error);
                    } else {
                        HiLog.i(TAG, 'getPrimarySlotId data:' + JSON.stringify(value));
                        resolve(value);
                    }
                });
            } catch (error) {
                HiLog.i(TAG, 'getPrimarySlotId catch:' + JSON.stringify(error));
                reject(error);
            }
        });
    }

    public  simStateChangeInfo():void{
        HiLog.i(TAG, `simStateChangeInfo In`);
        observer.on('iccAccountInfoChange',  datasValue => {
            HiLog.i(TAG,'on iccAccountInfoChange, data:' + JSON.stringify(datasValue));
            ConversationController.getInstance().getHasSimCard();
            this.getDefaultDataSlotId();
        });
    }

    public async getSimState():Promise<void> {
        if (!this.hasCard1 && !this.hasCard2) {
            AppStorage.setOrCreate('isGetSim', false);
        }
        return;
    }

    // rcsOn(cb: (message:rcs.RcsEvent) => void): Promise<void> {
    //     return new Promise((resolved, reject:Function) => {
    //         if (this.rcsRegisterProp.loginStatusChanged) {
    //             /* 已经注册成功不需要再次注册
    //              * */
    //             HiLog.i(TAG, '[rcsOn] [loginStatusChanged] has been registered, it not need register again ')
    //             resolved();
    //             return
    //         }
    //         try {
    //             rcs.on('loginStatusChanged', cb);
    //             this.rcsRegisterProp.loginStatusChanged = true
    //             HiLog.i(TAG, '[rcsOn] [loginStatusChanged] has been registered successfully ')
    //         } catch (error) {
    //             HiLog.e(TAG, 'loginStatusChanged error: ' + JSON.stringify(error));
    //             this.rcsRegisterProp.loginStatusChanged = false
    //         }
    //         resolved();
    //     });
    // }

    // networkStatusChangedOn(cb: (message: rcs.RcsEvent) => void): Promise<void> {
    //     return new Promise((resolved, reject: Function) => {
    //         if (this.rcsRegisterProp.networkStatusChanged) {
    //             /* 已经注册成功不需要再次注册
    //              * */
    //             HiLog.i(TAG,
    //                 '[networkStatusChangedOn] [networkStatusChanged] has been registered, it not need register again ')
    //             resolved();
    //             return;
    //         }
    //         try {
    //             rcs.on('networkStatusChanged', cb);
    //             this.rcsRegisterProp.networkStatusChanged = true
    //             HiLog.i(TAG, '[networkStatusChangedOn] [networkStatusChanged] has been registered successfully ')
    //         } catch (error) {
    //             HiLog.e(TAG, 'networkStateChanged error: ' + JSON.stringify(error));
    //             this.rcsRegisterProp.networkStatusChanged = false
    //         }
    //         resolved();
    //     });
    // }

    public async setRcsInfos(context: Context, rcsState:boolean,slotId:number):Promise<void> {
        try {
            HiLog.i(TAG, 'ConversationList setRcsInfos in')
            if (this.hasCard1 || this.hasCard2) {
                this.setRcsInfosResult(context, rcsState, slotId);
            }
        } catch (error) {
            HiLog.e(TAG, 'setRcsInfos error: ' + JSON.stringify(error));
        }
        return;
    }

    public async setRcsInfosResult(context: Context, rcsState:boolean,slotId:number){
        if (rcsState) {
            this.isRcsStatus = true;
        } else {
            this.isRcsStatus = false;
            // rcs.stopRcs(async (err: PreErr, data: void) => {
            //     HiLog.i(TAG, 'stopRcs:' + 'err:' + JSON.stringify(err) + 'data:' + JSON.stringify(data));
            //     AppStorage.setOrCreate('isOnlineRcs', false);
            // })
        }
        AppStorage.setOrCreate('rcsStatus', this.isRcsStatus)

        if (rcsState) {
            // 增强信息的开关，打开的时候才请求 rcs service 打开服务，否则不请求
            this.isRcsStateOpen = SharedPreferencesUtils.getFromPreferences('isUIOpenRcs', '') as boolean;
            HiLog.i(TAG, 'set RcsInfos, isRcsStateOpen :' + this.isRcsStateOpen);
            if (this.isRcsStateOpen && this.isEnableRcsAbility) {
                this.setRcsInfosResultOpenRcs(context, slotId,this.isReadFlag);
            } else {
                this.setRcsInfosResultNotOpenRcs();
            }
        }
    }

    public async networkStatusChanged(){
       // this.networkStatusChangedOn(async (message: rcs.RcsEvent) => {
       //     HiLog.i(TAG, 'on message networkStatusChangedOn: ' + JSON.stringify(message))
       //     if (message.type == 1) {
       //         this.isCellularOpen = true;
       //         AppStorage.setOrCreate('cellularDataGet', this.isCellularOpen);
       //     } else if (message.type == 0 ) {
       //         let isClosedInterState = SharedPreferencesUtils.getFromPreferences('isClosedInterState','');
       //         HiLog.i(TAG, 'isClosedInterState: ' + isClosedInterState);
       //         if(isClosedInterState){
       //             this.isCellularOpen = true;
       //         }else{
       //             this.isCellularOpen = false;
       //         }
       //         await this.isHasCard();
       //         if (!this.hasCard1 && !this.hasCard2) {
       //             AppStorage.setOrCreate('cellularDataGet', true);
       //         }else{
       //             if(!this.isAirPlaneMode) {
       //                 HiLog.i(TAG, '!this.isAirPlaneMode this.isCellularOpen: '+this.isCellularOpen);
       //                 AppStorage.setOrCreate('cellularDataGet', this.isCellularOpen);
       //             }else {
       //                 AppStorage.setOrCreate('cellularDataGet', false);
       //             }
       //         }
       //         AppStorage.setOrCreate('isOnlineRcs', false);
       //     }
       // });
    }

    public async setRcsInfosResultOpenRcs(context: Context, slotId:number, isReadFlag:boolean){
        HiLog.i(TAG, 'setRcsInfos isRcsStateOpen In True:' + isReadFlag);

        HiLog.i(TAG, 'rcs start isAdvancedMode is :' + this.isAdvancedMode);
        if (this.isAdvancedMode) {
          return;
        }
        // this.rcsOn(async (message: rcs.RcsEvent) => {
        //     HiLog.i(TAG, 'on message setRcsInfosResultOpenRcs: ' + JSON.stringify(message))
        //     if (message.type == 1) {
        //         AppStorage.setOrCreate('isOnlineRcs', true);
        //     } else if (message.type == 0) {
        //         AppStorage.setOrCreate('isOnlineRcs', false);
        //     }
        // });
        this.onRcsSendMessageCallBack(context);
        // rcs.startRcs({
        //     slotId, readReceiptEnabled: isReadFlag
        // }, () => {
        // })
        // })
        this.isRcsOpenStatus = true;
        HiLog.i(TAG, 'setRcsInfos isRcsOpenStatus :' + this.isRcsOpenStatus);
        AppStorage.setOrCreate('isOpenRcsStatus', this.isRcsOpenStatus)
    }

    public async setRcsInfosResultNotOpenRcs() {
        HiLog.i(TAG, 'setRcsInfos isRcsStateOpen In False:');
        let isFirstInMms = SharedPreferencesUtils.getFromPreferences('isFirstMms', '');
        HiLog.i(TAG, `setRcsInfos isFirstMms success, data:->${JSON.stringify(isFirstInMms)}`);
        this.isRcsOpenStatus = !!isFirstInMms;
        HiLog.i(TAG, 'setRcsInfosResultNotOpenRcs In' + this.isRcsOpenStatus)
        AppStorage.setOrCreate('isOpenRcsStatus', this.isRcsOpenStatus)
        let innerEvent: emitter.InnerEvent = { eventId: EmitterConstant.EVENT_CHANGE_RCS_SETTING_STATUS }
        let eventData: emitter.EventData = {
            data: {
                'isOpenRcsStatus': this.isRcsOpenStatus
            }
        }
        emitter.emit(innerEvent, eventData)
    }

    public async isFirstInMmsGet():Promise<boolean>{
        HiLog.i(TAG, `isFirstInMmsGet -> In`);
        let isFirstInMms = SharedPreferencesUtils.getFromPreferences('isOpenRcs', '');
        this.isCellularOpen = isFirstInMms as boolean;
        return this.isCellularOpen;
    }

    public async getCellularData(slotId?:number): Promise<void>{
        if (this.hasCard1 || this.hasCard2) {
            if(slotId!==undefined) {
                this.cellularDataInfo();
            }else{
                let slotId = await DataService.getDefaultCellularDataSlotId()
                HiLog.i(TAG, `setRcsInfos success, promise: slotId->${slotId}`);
                this.cellularDataInfo();
            }
        }
        return;
    }

    public cellularDataInfo(){
        if(!this.rcsState){
            this.isCellularOpen = true;
            HiLog.i(TAG, 'this.isCellularOpen'+this.isCellularOpen);
            AppStorage.setOrCreate('cellularDataGet', this.isCellularOpen)
        }else{
            this.getCellularDataResult();
        }
    }

    public getCellularDataResult(){
        if (this.isClosedInterState||this.isConnected) {
            this.isCellularOpen = true;
            AppStorage.setOrCreate('cellularDataGet', this.isCellularOpen)
        } else {
            HiLog.i(TAG, `changeCellularData data.isCellularDataEnabled In`);
            let promise = data.isCellularDataEnabled();
            promise.then((value: boolean) => {
                this.isCellularOpen = value;
                HiLog.i(TAG, 'this.isCellularOpen'+this.isCellularOpen);
                AppStorage.setOrCreate('cellularDataGet', this.isCellularOpen)
            }).catch((err: Object) => {
                this.isCellularOpen = false;
                HiLog.i(TAG, 'this.isCellularOpen'+this.isCellularOpen);
                AppStorage.setOrCreate('cellularDataGet', this.isCellularOpen)
            });
        }
    }
    initAirPlaneMode(context: Context):void {
        addAirPlaneModeListener((data: number) => {
            this.initAirPlaneModeResult(context, data);
        }, context);
        return;
    }

    public initAirPlaneModeResult(context: Context, data:number){
        HiLog.i(TAG, 'addAirPlaneModeListener'+data);
        this.isAirPlaneMode = data == 1 ? true : false;
        HiLog.i(TAG, 'isEnableRcs callback'+this.isAirPlaneMode);
        AppStorage.setOrCreate('isEnableRcs', this.isAirPlaneMode)
        if(this.isAirPlaneMode){
            this.isRcsOpenStatus=true;
            AppStorage.setOrCreate('isOpenRcsStatus', true)
        }
    }
    getAirPlaneMode():void {
        HiLog.i(TAG, 'getAirPlaneMode');
        queryAirPlaneMode((data: number) => {
           this.getAirPlaneModeResult(data);
        });
        return;
    }
    public getAirPlaneModeResult(data:number){
        this.isAirPlaneMode = data == 1 ? true : false;
        HiLog.i(TAG, 'isEnableRcs callback'+this.isAirPlaneMode);
        AppStorage.setOrCreate('isEnableRcs', this.isAirPlaneMode)
        if(this.isAirPlaneMode){
            this.isRcsOpenStatus = true;
            AppStorage.setOrCreate('isOpenRcsStatus', true)
        }else{
        }
    }
    removeAirPlaneMode():void {
        HiLog.i(TAG, 'removeAirPlaneMode');
        removeAirPlaneModeListener();
        return;
    }

  /**
   * Try update contact info.
   */
  public async tryUpdateSessionContactInfo(context: Context, refreshItem: boolean = false) {
    HiLog.i(TAG, 'updateSessionContactInfo, currentQuery:' + this.currentQueryContactTimeStampStr +
      ', refreshItem:' + refreshItem);
    let lastUpdateTime: string = SharedPreferencesUtils
      .getFromPreferences(common.STR.KEY_OF_LAST_CONTACT_UPDATE_TIME, '0') as string;
    let currentTime: string = String(Date.now());
    if (lastUpdateTime > currentTime) {
      SharedPreferencesUtils.saveToPreferences(common.STR.KEY_OF_LAST_CONTACT_UPDATE_TIME, currentTime);
      HiLog.i(TAG, 'updateSessionContactInfo skip.');
      SharedPreferencesUtils.saveToPreferences(common.STR.KEY_OF_LAST_CONTACT_UPDATE_TIME, currentTime);
      return;
    }
    if (this.currentQueryContactTimeStampStr == '') { // 代表当前没有查询的事件
      this.currentQueryContactTimeStampStr = currentTime; // 先进行一次赋值
      taskpool.execute(fetchRecentContactsAndBatchUpdateSessionTaskPool,
        lastUpdateTime, currentTime, context).then((results: Object) => {
        this.fetchRecentContactsDone(context, results as number[], currentTime, refreshItem);
      })

    } else {
      HiLog.i(TAG, 'updateSessionContactInfo wait for next search.');
      this.currentQueryContactTimeStampStr = currentTime;
    }
  }

  public fetchRecentContactsDone(context: Context, results: number[], currentTime: string, refreshItem: boolean) {
    HiLog.i(TAG, 'updateSessionContactInfo end. results length: ' + results?.length + ', ' +
      'current time:' + this.currentQueryContactTimeStampStr);
    if (results?.length > 3000) {
      // 增加短信应用被杀无法监听联系人变化，短信启动时会根据联系人变化更新session，如果联系人变动过大会造成CPU超基线，打点豁免
      let cpuHighParams: CPUAndMEMParams = new CPUAndMEMParams()
      DotUtil.getInstance().reportCpuEvent(cpuHighParams)
    }
    if (this.currentQueryContactTimeStampStr != currentTime) { // 如果后续有下次查询
      HiLog.i(TAG, 'updateSessionContactInfo start next search:' + this.currentQueryContactTimeStampStr);
      this.currentQueryContactTimeStampStr = ''; // 一定要置为空串，代表重新查询
      this.tryUpdateSessionContactInfo(context);
    } else {
      this.currentQueryContactTimeStampStr = '';
      if (refreshItem && results?.length > 0) { // 查询到的结果如果>0，则进行列表刷新，否则不刷新
        HiLog.i(TAG, 'updateSessionContactInfo end this time, try to request item.');
        if (this.messageList.length > 5500) {
          /* 1.当联系人更新时,短信在后台，会造成数据库CPU负载高;
             2.经过多次测试会话数无论联系人多少，当前会话数超过(70%)5500条时会出现超基线的情况；
          * */
          let cpuHighParams: CPUAndMEMParams = new CPUAndMEMParams()
          DotUtil.getInstance().reportCpuEvent(cpuHighParams)
        }
        this.messageList = [];
        this.requestItem(context);
      } else {
        HiLog.i(TAG, 'updateSessionContactInfo end this time, no refresh this time.');
      }
    }
  }

  /**
   * 保存当前会话的短信总数
   */
  async saveSessionTotalMsgCount(context: Context, sessionId: number, messageCount: number, callback: Function) {
    HiLog.i(TAG, 'saveSessionTotalMsgCount, messageCount: ' + messageCount);
    let valueBucket: ValuesBucket = {
      'message_count': messageCount
    }
    let actionData: LooseObject = {
      threadId: sessionId
    }
    ConversationListService.getInstance().updateSessionByCondition(context, actionData, valueBucket, callback);
  }

  //刷新单独某一行
  refreshListWithUpdateIdStr(context: Context, updateIdMap: Map<string, string>) {
    HiLog.i(TAG, 'refreshList row start updateIdStr :' + updateIdMap);
    if (this.messageList.length == 0) {
      return;
    }
    /* 2.新增的情况下，根据联系人id获取联系人信息，并根据电话号码和短信对比，相同做修改
     * updateIdStr为空，则为删除联系人(单独删除和批量删除)，重新请求
     */
    if (updateIdMap.size === 0) {
      this.messageList = [];
      this.requestItem(context);
    } else {
      let actionData: LooseObject = {};
      HiLog.i(TAG, 'refreshList row telephone ');
      let keys: string[] = [];
      for (let key of updateIdMap.keys()) {
        keys.push(key)
      }
      actionData.contactIds = keys;
      HiLog.i(TAG, 'refreshList updateIdS : ' + JSON.stringify(keys));
      let contactResultMap: Map<string, ContactInfoModel> = new Map<string, ContactInfoModel>();
      ContactsService.getInstance().queryContactDataByCondition(actionData, (objc: LooseObject) => {
        HiLog.i(TAG, 'refreshList row rawContqueryContactDataByCondition');
        if (objc !== undefined && objc.abilityResult !== undefined && objc.abilityResult.length > 0) {
          for (let index = 0; index < objc.abilityResult.length; index++) {
            const contactInfo: ContactInfoModel = objc.abilityResult[index] as ContactInfoModel;
            if (contactInfo !== undefined) {
              contactResultMap.set(contactInfo.contactId, contactInfo);
            }
          }
          this.upDataMessageListContactInfo(context, contactResultMap, keys.length === 1 ? true : false);
        }
      }, context)
    }
  }

  //更新信息中联系人信息
  upDataMessageListContactInfo(context: Context, contactResultMap: Map<string, ContactInfoModel>,
    isUpdataSeesionData: boolean) {
    for (let i = 0; i < this.messageList.length; i++) {
      let contactId: string = this.messageList[i].contactId as string;
      let contactModel: ContactInfoModel | undefined = contactResultMap.get(contactId);
      if (contactModel !== undefined) {
        HiLog.i(TAG, 'refreshList row has contactInfo ');
        let contactFormatPhoneNumber: string = TelephoneUtil.formatDisplayPhoneNumE164(contactModel.detailInfo);
        let sessionFormatPhoneNumber: string = TelephoneUtil.formatDisplayPhoneNumE164(this.messageList[i].telephone);
        if (sessionFormatPhoneNumber === contactFormatPhoneNumber) {
          this.messageList[i].name = contactModel.displayName;
        } else {
          HiLog.i(TAG, 'refreshList row user change telephone ');
          //如果同一个contact id，联系人和短信的手机号码不一致，说明联系人修改过手机号码
          this.messageList[i].contactId = '';
          this.messageList[i].rawContactId = '';
          // 如果当前只修改了一个联系人时，再去更新session表，以免引起性能问题
          if (isUpdataSeesionData) {
            HiLog.i(TAG, 'refreshList row user only change one telephone ');
            let actionInfo: LooseObject = {
              'telephone': this.messageList[i].telephone,
            }
            let valueBucket: ValuesBucket = {
              'contact_name': '',
              'contact_id': '',
            }
            ConversationListService.getInstance()
              .updateSessionByCondition(context, actionInfo, valueBucket, null, true);
          }
        }
        this.conversationListDataSource.notifyDataChange(i);
      }
    }
  }

  refreshMessageStatus(item: mmsListType) {
    let changeIndex: number = -1;
    for (let index = 0; index < this.messageList.length; index++) {
      if (this.messageList[index].threadId === item.threadId) {
        changeIndex = index;
        this.messageList[index].sendingFailed = true;
      }
    }
    this.conversationListDataSource.notifyDataChange(changeIndex);
  }

  public getAppPreferredLanguage(): string {
    let res: string = '';
    try {
      res = i18n.System.getAppPreferredLanguage();
      if (res.includes('en')) {
        res = 'en';
      }else if (res.includes('bo')){
        res = 'bo';
      }
      return res;
    } catch (error) {
      HiLog.e(TAG, `getAppPreferredLanguage error: ${error?.code} ${error?.message}`);
      return res;
    }
  }

  updateConversationListMsg(context: Context, index: number, isUnPin: boolean) {
    HiLog.i(TAG, 'start updateConversationListMsg index: ' + index);
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_LIST_QUERY_FIRST_PAGE,
      TraceConstant.TRACE_CONVERSATION_LIST_QUERY_FIRST_PAGE_ID);
    let actionData: LooseObject = {};
    actionData.page = Constant.REFRESH_INDEX_INIT_NUM;
    actionData.limit = this.messageList.length;
    actionData.orderByTimeDesc = true;
    actionData.isNeedMessageSort = true;
    if (this.hasAggregate) {
      actionData.smsType = common.sms_type.COMMON;
    }
    ConversationListService.getInstance().getSessionListResultNew(actionData, context).then((data) => {
      if (data && data.response <= 0) {
        HiLog.i(TAG, 'updateConversationListMsg get session fail');
        return;
      }
      let responseList: messageType[] = ThreadObjectUtils.jsonToObjArray(data.response as messageType[]);
      this.doProcessTimeForIndexSessionListItem(responseList, context);
      if (responseList.length == 1 && responseList[0].threadId <= 0) {
        HiLog.i(TAG, 'updateConversationListMsg db has no session,but return one empty session,do not need handle.');
        return;
      }
      this.messageList = responseList;
      if (isUnPin) {
        this.hasMore = this.messageList.length < this.total;
        this.isQueryPageDone = true;
      }
      HiLog.i(TAG, 'updateConversationListMsg responseList: ' + responseList.length + ' messageList: ' +
        this.messageList.length);
      this.conversationListDataSource.refresh(this.messageList, 'updateConversationListMsg');
      this.sendUpdateAccessibilityStr();
      this.setUnReadQueue(this.messageList);
      setTimeout(() => {
        let accessContent = 'Conversation' + index;
        AccessibilityUtil.requestFocusForAccessibilityNotInterrupt(accessContent);
      }, 50);
      hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_LIST_QUERY_FIRST_PAGE,
        TraceConstant.TRACE_CONVERSATION_LIST_QUERY_FIRST_PAGE_ID);
    })
  }

  private async setUnReadQueue(response: LooseObject[]) {
    this.unReadQueue = new Queue();
    this.unReadListSize = 0;
    for (let i = 0; i < response.length; i++) {
      if (response[i].countOfUnread && response[i].countOfUnread > 0) {
        HiLog.i(TAG, 'unReadListSize: ' + this.unReadListSize);
        this.unReadQueue.add(this.unReadListSize + i);
      }
    }
    this.unReadListSize += response.length;
  }
}
