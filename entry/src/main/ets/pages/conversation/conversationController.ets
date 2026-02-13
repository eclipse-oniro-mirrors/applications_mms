/**
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
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
// import rcs from '@ohos.telephony.rcs';
import Prompt from '@ohos.promptAction';
import promptAction from '@ohos.promptAction';
import emitter from '@ohos.events.emitter';
import lazy fs from '@ohos.file.fs';
import HiLog from '../../utils/HiLog';
import common from '../../data/commonData';
import commonData from '../../data/commonData';
import EmitterConstant from '../../data/EmitterConstant';
import commonEvent from '@ohos.commonEventManager';
import commonEventManager from '@ohos.commonEventManager';
import ContactsService from '../../service/ContactsService';
import ConversationService from '../../service/ConversationService';
import ConversationRcsService from '../../service/ConversationRcsService';
import ConversationListService from '../../service/ConversationListService';
import LooseObject from '../../data/LooseObject';
import commonService from '../../service/CommonService';
import settingService from '../../service/SettingService';
import { commonPasteboard } from '../../data/Pasteboard';
import TelephoneUtil from '../../utils/TelephoneUtil';
import sendMsgService from '../../service/SendMsgService';
import MmsPreferences from '../../utils/MmsPreferences';
import lazy { DateUtil } from '../../utils/DateUtil';
import NotificationService, { IBadgeContextInfo } from '../../service/NotificationService';
import commonCtrl, { IQueryNoReceiverDraftResult } from './common';
import AvatarColor from '../../model/common/AvatarColor';
import ConversationDataSource from '../../model/ConversationDataSource';
import { addAirPlaneModeListener, queryAirPlaneMode, removeAirPlaneModeListener } from './AirplaneMode';
import { CallService } from '../../service/CallService';
import ConversationListController from '../conversationlist/conversationListController';
import ConListController, { photoFirstNamesType } from '../conversationlist/conversationListController';
import { AsyncCallback, BusinessError } from '@ohos.base';
import CheckUtil from '../../utils/CheckUtil';
import { SelectDialogBuilder } from '../../views/MultiSimCardCallDialog';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import MMAttachmentAreaController from '../../views/AttachmentArea/MMAttachmentAreaController';
import { dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import lazy MmsUtil, {
  getMmsMapTextSource,
  SUPPORT_MMS_TRANSFORM_FORMAT,
  KEEP_MESSAGE_TYPE_WHEN_MMS_TO_RCS,
  KEEP_MESSAGE_TYPE_WHEN_RCS_TO_MMS
} from '../../utils/MmsUtil';
import FileUtil, { ENHANCED_INFO_SUPPORT_FORWARD_FILE_TYPES,
    formatFileSize,
    transmitUriInfo } from '../../utils/FileUtil';
import { AddressInfo,
    Contact,
    ContactType,
    LocationType,
    Mms,
    mmsInfo,
    mmsInfoData,
  NewConversationSendData,
  PageJumpType,
    RcsSendLoc,
    SessionContentTypeOfRcs
} from '../../utils/TypesUtils';
import ConversationListModel from '../../model/ConversationListModel';
import hiTraceMeter from '@ohos.hiTraceMeter';
import TraceConstant from '../../data/TraceConstant';
import SmilFile from '../../utils/SmilFile';
import MMPictureController from '../../views/AttachmentArea/MMPictureController';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import { mmsReceive } from '../../views/MmsReceive/mmsReceiveMain';
import tabTextList from './emoji'
import lazy { Emoji } from './emoji'
import AdvancedSettingsController from '../settings/advancedSettings/advancedSettingsController';
import MessageUtil from '../../../cust/utils/MessageUtil';
import StringUtil, { isObjectJSONString } from '../../utils/StringUtil';
import ObjectUtil from '../../utils/ObjectUtil';
import sim from '@ohos.telephony.sim';
import fileUri from '@ohos.file.fileuri';

import lazy utd from '@ohos.data.uniformTypeDescriptor';
import lazy statvfs from '@ohos.file.statvfs';
import DotUtil from '../../utils/MmsDot/DotUtils';
import dotCommon, {
    dotNoNeedParmas,
    editWordSizeParams,
    dotSendParmas,
    otherEntranceParmas,
    sendMmsParams,
    rcsSendMsgParams,
    sendRcsParams,
    onlyStateParam,
    MsgServiceNumberParams
} from '../../utils/MmsDot/DotCommon';
import ImageUtil from '../../utils/ImageUtil';
import image from '@ohos.multimedia.image';
import curves from '@ohos.curves';
import {
    IQueryMessageDetailAll,
    IQueryMessageDetailInfo,
    IQueryMsgDetailSizeInfo
} from '../../model/type/ConversationParams';
import ConversationRcsModel from '../../model/ConversationRcsModel';
import InfoMsgController from '../infomsg/InfoMsgController';
import DataShareHelper from '../../model/repository/DataShareHelper';
import SsmUtils from '../../utils/SsmUtils';
import { EnhancedInfoTemporaryDataSource } from '../../model/EnhancedInfoTemporaryDataSource';
import YellowPageService from '../../service/yellowPageService';
import { call } from '@kit.TelephonyKit';
import I18n from '@ohos.i18n';
import { HashMap } from '@kit.ArkTS';
import ConversationModel from '../../model/ConversationModel';
import PanGestureUtil from '../../utils/PanGestureUtil';
import { Interval, LoadDataOrderModel } from '../../model/LoadDataOrderModel';
import { settings, systemDateTime } from '@kit.BasicServicesKit';
import { ContactTypeForUI } from '../../views/AttachmentArea/MMMoreDialog';
import lazy { VCardUtil } from '../../utils/VCardUtil';
import ReportSpamMessageManager from '../../report/ReportSpamMessageManager';
import { GlobalContextKey } from '../../data/commonData';
import { i18n, intl } from '@kit.LocalizationKit';
import OperatorConfigUtil from '../../../cust/utils/OperatorConfigUtil';
import lazy { AudioPlayerService } from '../../service/AudioPlayerService';
import lazy { MessageTimeout } from './ConversationMessageTimeout';
import { LengthMetrics } from '@kit.ArkUI';
import DeviceUtil from '../../utils/DeviceUtil';
import { dataShare } from '@kit.ArkData';
//import { mapCommon, map } from '@kit.MapKit';
import Constant from '../../data/Constant';
import { ActionData as Action, DraftModel, DraftUtils } from '../../utils/DraftUtils';
import { StorageMessageTimeout } from './StorageMessageTimeout';
import lazy { isSameTel } from '../../utils/TelephoneUtilEnhancde';
import { Context } from '@kit.AbilityKit';
import lazy { BotMessage, ClientMessage, Postback, Reply, Response } from '../../chatbot/utils/ChatbotEntitys';
import DataService from '../../service/DataService';
import lazy { OBLIQUE } from '../../chatbot/utils/ChatbotFileUtils';
import lazy { getTime } from '../../utils/SystemDateTimeUtil';
import { ChatbotUtils } from '../../chatbot/utils/ChatbotUtils';
import { addAIFaceChangeModeListener, queryFaceChangeDetectMode,
    removeAIFaceChangeModeListener } from './AIFaceChangeMode';
import { AiFaceChangeUtils } from '../../utils/AiFaceChangeUtils';
import { RcsLoginUtil } from '../../utils/RcsLoginUtil';
import { connection } from '@kit.NetworkKit';
import SimSlotIdUtils from '../../utils/SimSlotIdUtils';
import LocationUtil from '../../utils/LocationUtil';
import { SystemMode } from '../../utils/SystemMode';
import AppStorageKeyConstant from '../../data/AppStorageKeyConstant';
import AccessibilityUtil from '../../utils/AccessibilityUtil';

const TAG = 'ConversationController';
const COMMON_FILE_SIZE_STRING = '/300KB';
const MAXIMUM_LENGTH_OF_CHARACTERS = 670;
const DOUBLE: number = 60;
const DEGREE: string = '°';
const MINUTE: string = '\'';
const SECOND: string = '\"';
const TASK_SECOND: number = 1000;
const TASK_MAX_TIMES: number = 14;
const TASK_PROGRESS: number = 7;
const TASK_MAX: number = 92;
const ONE_HOUR_IN_MILLISECOND = 3600000;

// ListHeight is updated only once within the timeout period
const LIST_HEIGHT_INSENSITIVE_TIMEOUT: number = 30;

const SINGLE_CONTACT: number = 1;
const SERVICE_KIND = 8;
let dataShareHelper: dataShare.DataShareHelper

export interface InitData {
    id: number
    telephone: string
}

export interface InsertResult {
    rowId: number
    initDatas: InitData[]
    groupId: number
}

export class selectContactType {
    telephone: string = ''
    telephoneFormat: string = ''
    contactName: string = ''
    rawContactId?: string
    contactId?: string
}

export class itemType {
    contactName: string = ''
    telephone: string = ''
    telephoneFormat: string = ''
    headImage: string = ''
    select: boolean = false
    rawContactId?: string
    public yellowPageId?: string = ''
    public hasYellowPageIcon?: string = ''
    public photoPath?: string
}

export interface BaseItemType {
    contactValue: string
    selectContacts: itemType[]
    hasBlur: boolean
}

class transformType {
    scale: string = ''
}

export class timeDataType {
    id: number = 0
    type: number = 0
    params: Array<number | string> = []
    bundleName: string = ''
    moduleName: string = ''
}

export interface TransmitInfoType {
    isRcs: number
    content: string
    contactsName: ResourceStr
    isMsm: boolean
    msgShowType: number
    msgUriPath: string
    contentInfo: string
    contentType: number
    info: string
    mms: Array<Mms>
    msgTitleTransmit?: string,
    smilStr?: string,
    fullMmsSource?: Array<Mms>
}

export interface TransmitSourceType {
    threadId: number
    strContactsName: string
    strContactsNumber: string
    strContactsNumberFormat: string
    transmitSource: TransmitInfoType[]
    isContainerOriginSource: boolean
    transmitContent: string
    transmitContentDetail: string
    isFromTransmitView: boolean
    mmsStatus: number
}

export interface MmsSourceType {
    type: number
    uriPath: string
    time: string
    fileSize: number
}

export interface pictureListFromGalleryType {
    checkedValue: boolean
    path: string
}

export class mmsEditListTempType {
    type: number = 0;
    uriPath: string = '';
}

export class ActionDataType {
    slotId: number = -1
    destinationHost: string = ''
    content: string = ''
    isEditMms: boolean = false
    contactId?: string;
    contactName?: string;
    hosts?: string[];
    isReSend?: boolean = false;
    id?: string = '';
    isRcs?: number = 0;
    resendStateIsRcs?: boolean = undefined;
    threadId?: number = -1;
    public groupId?: number;
    msgTitle?: string = '';
    basePath?: string = '';
    isChatbot?: boolean = false;
    data?: string;
    trafficType?: string;
    contributionId?: string;
}

export interface BaseAbilityResult {
    detailInfo: string
    displayName: string
    id: number
    rawContactId?: string
    contactId?: string
}

interface AbilityResult {
    code: number
    abilityResult: BaseAbilityResult[]
}
export class cardMmsListType {
    name: string =  ''
    content: string = ''
    public timeRange: string = ''
}
@Observed
export class mmsListType {
    index: number = 0;
    receiverNumber: string = '';
    startTime: string = '';
    msgTitle: string = '';
    isSender: number = 0;
    sessionType: number = 0;

    id: number|string = 0;
    public msgItemIndex: number | string = 0;
    content: number | string | Resource = 0;
    public ct: string = '';
    public detectResContent: string = '';
    failReceiveContext: number | string | Resource = 0;
    isRcs: number = 0;
    // 标记是否ip消息，默认非ip消息，控制是否走智能信息渲染
    isIpMsg: boolean = false;
    // 标记是否普通的ip消息（固定文本、参数文本），控制item长按菜单及多选时底部按钮的展示
    isSimpleIpMsg: boolean = false;
    // ip消息结构化数据源
    ownerAddr: string = '';
    // 区分单双IP消息
    serviceCenter: string = '';
    showTitle: boolean | string = false;
    is_collect: boolean = false;
    msgType: number = 0;
    isFullScreenImg: boolean = true;
    // 0: 未识别过，-1: 非验证码（收到消失时识别），-3：非验证码（智能信息下挂识别），其他: 验证码的值
    public msgCode: number = 0;
    // 验证码：用于智能信息关闭时app实现复制功能
    public msgCodeStr: string = '';
    read: number = 0;
    sendStatus: number = 0;
    //slot_id
    subId: number = -1;
    timeMillisecond: number | string = -1;
    isMsm: boolean = false;
    isCbChecked: boolean = false;
    isDraft: boolean = false;
    groupId: number = 0;
    isReceive: boolean = false;
    date: timeDataType | string | null = null;
    time: timeDataType | string | null | Resource = null;
    completeNumber: number = 0;
    failuresNumber: number = 0;
    telephone: string = '';
    hasReport: boolean = false;
    isShowMsgLongMenu: boolean = false;
    msgShowType: number = 0;
    public fullDate: timeDataType | string | Resource = {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: ''
    }
    public timeOfSms: timeDataType | Resource | string = {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: ''
    }
    week: timeDataType = {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: ''
    }
    dateShow: boolean = true
    public dateString: string = ''
    detailTime: string | Resource | null = null
    threadId: number = 0
    pduId: number = 0
    audioTime: string = ''
    msgUriPath: string = ''
    mmsEditListTemp: LooseObject = {}
    doubleClickStatus?: boolean = false;
    mmsSource: Array<Mms> = [];
    contactsNum: number = 0
    isDelShow: boolean = false
    itemLeft: number = 0
    photoFirstName: string = ''
    name: string = ''
    portraitColor: string|Resource = ''
    hasMms: boolean = false
    hasAttachment: boolean = false
    fullDateParams: string[] = []
    timeOfSmsParams: string[] = []
    success: number = -1
    contentType: number = 0;
    operatorServiceNumber?: string = '';
    rcsId?:number = 0;
    isAdvancedSecurity: boolean = false;
    senderNumber: string = '';
    isReport?: number = 0;
    public expiresTime: string = '';
    public mmsPdu: string = '';
    public position: string = '';
    public latitudeAndLongitude: string = '';
    public progressValue:number = -1;
    public showProgress: boolean = false;
    public clurSize?: number = 0;
    public totalSize?: number = 0;
    public yellowPageId: string = '';
    public hasYellowPageIcon: string = '';
    public icon: string = '';
    public rcsType: number = 0;
    public endTime: mmsInfoData = new mmsInfoData();
    public msgState: number = -1;
    public slotId: number = -1;
    public receiveState: number = 0;
    public riskUrlBody: string = '';
    public proxy?: UIExtensionProxy;
    public smsType: number = 0;
    public msgContent?: string;
}

export class groupIdsInfos{
    groupId:number|string = 0 ;
    isRcs:number|string = 0;
    public msgId:number | string = '';
    public rcsId?:number | undefined = 0;
    /**
     * 是否需要删除资源文件（重发/草稿等场景只删除数据库mms_part表记录，不删除沙箱文件）
     */
    public isNeedDeleteSourceFile?: boolean = true;
    /**
     * 信息是否已被收藏
     */
    public isCollect?: boolean = false;
    /**
     * 是否为媒体信息
     */
    public isMms?: boolean = false;
}
class vCardType {}

export interface ActionData {
    contents: string[]
    mmsSource: Array<Mms>
}

export interface mmsSourceItem {
    content: string,
    mms: Mms[],
    msgTitleTransmit?: string,
    contentType?: number,
    smilStr?: string,
    fullMmsSource?: Mms[],
    mmsListIndex?: number,
    basePath?: string
}

export interface SendMsgIndexes {
    copySourceIndex: number
    mmsListIndex: number
}

export interface rcsFileInfo {
    name: string,
    filePath: string,
    sandBoxPath: string,
    size: number
    isAMRAudioFile?: boolean
}
/**
 * @param rcsType {@link common.ENHANCED_INFO_ITEM_TYPE}
 * @returns fileType {@link common.ENHANCED_INFO_RICH_MEDIA_TYPE_IN_RCS_SERVICE}
 */
export const convertRcsTypeToFileType = (rcsType: number) => {
    let rcsTypes = Object.entries(common.ENHANCED_INFO_ITEM_TYPE) as [string, number][];
    let fileTypes = Object.entries(common.ENHANCED_INFO_RICH_MEDIA_TYPE_IN_RCS_SERVICE) as [string, number][];
    let mapNumber2RcsType = new Map<number, string>();
    let mapFileType2Number = new Map<string, number>(fileTypes);
    for (let i = 0; i < rcsTypes.length; i++) {
        mapNumber2RcsType.set(rcsTypes[i][1], rcsTypes[i][0]);
    }
    let fileTypeStr = mapNumber2RcsType.get(rcsType);
    if (fileTypeStr) {
        return mapFileType2Number.get(fileTypeStr);
    } else {
        return;
    }
}


export default class ConversationController {

    private static sInstance: ConversationController | undefined = undefined;
    public isSelectEVENT: emitter.InnerEvent = {
        eventId: EmitterConstant.EVENT_CONVERSION_IS_SELECT,
        priority: emitter.EventPriority.HIGH
    };
    public isPC: boolean = DeviceUtil.isPC()
    isRcsMms: boolean = false;
    simSlotId: number = 0;
    haveTwoCards: boolean = false;
    lastMsg: LooseObject = {};
    commonEventData?: commonEventManager.CommonEventSubscriber;
    public processEventSubscriber: commonEventManager.CommonEventSubscriber | null = null;
    public receiveOkEventSubscriber: commonEventManager.CommonEventSubscriber | null = null;
    private rcsSendCanceledEventSubscriber: commonEventManager.CommonEventSubscriber | null = null;
    private chatbotReceivedSuggestionsEventSubscriber: commonEventManager.CommonEventSubscriber | null = null;
    private chatbotCardDownloadOriginEventSubscriber: commonEventManager.CommonEventSubscriber | null = null;
    public failEventData: commonEventManager.CommonEventSubscriber | null = null;
    private receiveCancelEventSubscriber: commonEventManager.CommonEventSubscriber | null = null;
    private conversationListCtr: ConversationListController = ConversationListController.getInstance();
    commonCtrl = commonCtrl.getInstance();
    // Message deletion prompt
    strMsgDeleteDialogTip?: Resource;
    // Message report prompt
    strMsgReportDialogTip?: Resource;
    // Click Status
    isClickStatus: boolean = false;
    // Select Status
    isSelectStatus: boolean = false;
    // More Actions
    isShowMoreOperation: boolean = false;
    // The default value is false for determining whether the current day is the same.
    isLessOneDay: boolean = false;
    // Check whether full-screen conditions are met.
    isShowFullScreen: boolean = false;
    // Check whether all the options are selected.
    isMessageCheckAll: boolean = false;
    // Is it just a recording?
    isOnlyAudio: boolean = false;
    // Deleted Count
    selectDeleteMsgCount: number = 0;
    // Text entered in the text box, which is also the content of the SMS message to be sent.
    textValue: string = '';
    // Recording Animation Tasks
    drawRecordingTaskId: number = 0;
    // Tab option page. 0: Take a photo; 1: Take a picture; 2: Record a record; 3: More
    tabIndex: number = 1;
    // Text content of the tab option page
    tabTextList: Array<Resource> = [];
    // Recording Status
    isRecordingStatus: boolean = true;
    // Current recording time
    curRecordingTime: string = '00:00';
    // Size of the current recording file (KB)
    curSize: number = 0;
    // Recording Start Time
    startRecordTime: number = 0;
    // Airplane mode
    isFlightMode: boolean = false;
    // Information Attachment Size Tips
    msgSendTip: string = '';
    // Whether SMS messages can be sent.
    canSendMessage: boolean = false;
    // Whether air plane mode.
    isAirPlaneMode: boolean = false;
    // Whether the currently edited message is an MMS message
    isEditMms: boolean = false;
    // Size of the MM attachment to be edited.
    curEdtFileSize: number = 0;
    // Obtains the time display of a single selection.
    mmsTime: string = '';
    // SMS and MMS
    isMmsType?: Resource;
    // Recipient
    isSendRecipient: boolean = false;
    // Contact First Name
    strContactsName: string = '';
    // Stores the contact information that needs to be saved to the database.
    sessionContactsInfo: SessionContactInfoForDB[] = [];
    // Contact Phone Number
    strContactsNumber: string = '';
    // Contact Phone Number Formatting
    strContactsNumberFormat: string = '';
    // The attachment type is business card.
    isVCard: boolean = false;
    // Indicates whether the information is created.
    isNewMsg: boolean = false;
    // If open from home after enter from notification
    isBackHome = false;
    // Create a new message from the '+' on the ConversationList.
    isConversationNewMsg: boolean = false;
    // Number of Contacts
    contactsNum: number = 0;
    // Original Contacts Names List
    public contactsNameList: string[] = [];
    // business card
    vCard: vCardType = {};
    // MM Edit List
    mmsEditList: Array<MmsSourceType> = [];
    // Information List
    mmsList: Array<mmsListType> = [];
    // Index of the selected information
    mmsIndex: number = 0;
    // Index of the slide information
    slideMmsIndex: number = -1;
    currentMmsItem: mmsListType | undefined = undefined;
    // yOffset
    yOffset: number = -1;
    // slide yOffset
    slideYOffset: number = -1;
    // Initial x-position
    rawX: string = '';
    // Initial y-position
    rawY: string = '';
    // Thumbnails in Gallery
    pictureListFromGallery: Array<pictureListFromGalleryType> = [];
    // Tab Title
    tabTitleText?: Resource;
    // Send Toolbar Distance from Bottom Position
    sendBarMarginBottom: number = 0;
    // Tab Height
    tabHeight: number = common.int.TAB_HEIGHT;
    // Restoration task ID.
    restoreTimeoutId: number = 0;
    // Whether the animation is actually executed
    isTabHeightAnimation: boolean = false;
    // 0: default; 1: slide; 2: full screen
    tabSlideStatus: number = 0;
    // Sliding distance
    slideDistance: number = 0;
    // Start point coordinate of the slide
    slideStartPoint: Record<string, number> = {
        'x': 0,
        'y': 0
    };
    // Whether to slide up
    isTabSlideUp: number = 0;
    // Contact list, which is obtained from the contact app and used as an attachment for sending MMS messages.
    // contactListFromContactApp: Array<any> = [];
    // Card slot
    slotId: number = 0;
    // Selected Contacts
    selectContacts: Array<selectContactType> = [];
    // 记录SessionId和SelectContacts的对应关系
    public selectContactsMap: Map<number, Array<selectContactType>> = new Map();
    // Content in the recipient text box
    receiveContactValue: string = '';
    // Controls the display and hiding of the last div.
    isSendStatus: boolean = false;
    // ID of the session list.
    threadId: number = 0;
    // Indicates whether the page is a details page.
    isDetail: boolean = true;
    // Subscript to be resent
    resendIndex: number = 0;
    // Whether the replication option is visible
    showText: boolean = true;
    // Search for the value passed
    searchKey: string = '';
    // Is it grass?
    isDraft: boolean = false;
    // Contents of the draft
    draftContent: string = '';
    draftGroupId: number = 0;
    // Dynamic change sign from bottom
    distanceBottomFlag: boolean = false;
    // Deleting a Details Page
    hasDetailDelete: boolean = false;
    pattern: string = '';
    // 0: normal; 1: notification
    public smsType: number = 0;
    isPicCheckboxClicked: boolean = false;
    // Whether to support sending reports
    hasReport: boolean = false;
    textareaDatasource: Array<LooseObject> = [];
    pptTotalCount: number = 0;
    selectedTextareaIdx: number = -1;
    hasImage: boolean = false;
    hasContent: boolean = false;
    hasVcard: boolean = false;
    mmsAddType: number = 0;
    picItemSelectedIndex: number = -1;
    slideDuration: number = 5;
    searchContent: string = '';
    isNewMsgWithDraft: boolean = false;
    // Time
    // mmsDateSet: Set<any> = new Set();
    photoFirstName: string = common.STR.WHITE_SPACE;
    portraitColor: string|Resource = common.STR.EMPTY_STR;
    public rawContactId: string = '';
    public contactId: string = '';
    reg: RegExp = new RegExp('[\\u4e00-\\u9fa5_a-zA-Z]');
    numberReg: RegExp = new RegExp('^[0-9]+$');
    allChinese: RegExp = new RegExp('^[\\u3400-\\u4db5_\\u4e00-\\u9fa5]+$');
    hasChinese: RegExp = new RegExp('[\\u3400-\\u4db5_\\u4e00-\\u9fa5]');
    hasEnglish: RegExp = new RegExp('[a-zA-Z]');
    page: number = 1;
    total: number = 0;
    scroller: Scroller = new Scroller();
    private dataParameters: LooseObject = {};
    private dataParametersPhone: string = '';
    private searchMsgId: string = '';
    private searchMsgIndex: number = -1;
    private loadDataOrderModel: LoadDataOrderModel = new LoadDataOrderModel();
    isBackToIndex: boolean = true;
    pageInfos: NavPathStack = AppStorage.get("PathStack") as NavPathStack;
    conListCtrl: ConListController = ConListController.getInstance();
    //The 660 is only the default value. The initialization will assign a value.
    public listHeight: number = 660;
    mAttachAreaCtrl: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
    pictureCtrl: MMPictureController = MMPictureController.getInstance();
    audioStatus: number = common.MMS_AUDIO_STATUS.NO_AUDIO;
    public richMediaCards: number = common.MMS_AUDIO_STATUS.NO_AUDIO;
    // Temporarily store 'insensitive' ListHeight
    private insensitiveListHeight: number = this.listHeight;
    // Byte array of all emojis
    private allEmojiValues: number[][] | undefined = undefined;
    // The emoji strings
    private emojiStrArray: string[] | undefined = undefined;
    // The max length of emoji codes
    private emojiCodesMaxLen: number = 0;
    copySource: Array<Mms> = [];
    /**  Event subscriber that receives read reports of rcs messages */
    public staticEventData?: commonEventManager.CommonEventSubscriber | null = null;
    private conversationRcsModel: ConversationRcsModel = new ConversationRcsModel();
    mAdvancedSettingsCtrl: AdvancedSettingsController = AdvancedSettingsController.getInstance();
    isChangeInputPlaceholder: boolean = false;
    setMMsFlag: boolean = false;
    isSendPicture:boolean = false;
    persistenceData:Array<mmsListType> = [];
    formatStrContactsNumberFormat: string = '';
    formatStrContactsName: string = '';
    contactsNameIsNotEqualToContactsNumberFormat :boolean = false;
    sendReportable: boolean = false;
    mmsCount: number = 0;
    // Are both SIM cards not activated
    public isNoCardActive: boolean = false;
    // Activate both SIM cards
    public isAllCardActive: boolean = false;
    public isAllCardReady: boolean = false;
    public isAllCardCanSend: boolean = false;
    private covLatitude: string = '';
    private covLongitude: string = ''
    public progressValue:number = 0;
    private progressTask:number = -1;
    public yellowPageId: string = '';
    public hasYellowPageIcon: string = '';
    public icon: string = '';
    public cbSelectedOnlyOneMsmItemOfMmsList: mmsListType | undefined;
    public callingSlotId: number = -1;
    private dsdsMode: sim.DsdsMode = 0;
    public queryTerminate = new Map<number, number>();
    private isShow: boolean = false;
    public currentQueryTimeID: number = 0;
    public static reportScreenPadding: number = 0;
    private conversationPixelMap: HashMap<string, PixelMap> = new HashMap();
    public vCardJumpBack : boolean = false;
    public caretPosition: number = 0;
    public isEmoChange: boolean = false;
    public messageCount: number = 0;
    public isNewSend: boolean = false;
    public maxSizeOfMms: number = OperatorConfigUtil.getInstance().getCustMMSSize(commonData.int.MMS_FILE_MAX_SIZE) ||
      307200;
    public isMoreMenuDelete: boolean = false;
    private messageTimeout: MessageTimeout = new MessageTimeout();
    public draftModel: DraftModel | null = null
    private timeoutID: number = -1
    public isTextAsMms: boolean = false;
    public hasAttachment: boolean = false;
    public newEmojiLength: number = 0;
    public isPageHide: boolean = false;
    private creatNewConversationMessageId: number = 0;
    private creatNewConversationCompleteNumber: number = 0;
    private creatNewConversationFailuresNumber: number = 0;
    private creatNewConversationSuccess: number = 0;
    private storageMessageTimeout: StorageMessageTimeout = StorageMessageTimeout.getInstance();
    public isFromBackground: boolean = false;
    public chatbotPageIcon?: string = '';
    public callbackPhoneNumber: string = '';
    public hasRcsFileNotDownload: boolean = false;
    public isFromNotication: boolean = false;
    public isRcsMsgSourceFileDownloaded: boolean = false;
    public rcsMsgId: number = 0;
    private cactusUrl: string = '';
    public chatbotMmsNumber: string = '';
    private lastSelectedRow: number = -1;
    private isInInit: boolean = false;
    private clickStatusbarCallback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      if (!AppStorage.get('isAtMsgListTop')) {
        HiLog.i(TAG, `clickStatusbarCallback back to up.`);
        AppStorage.setOrCreate(AppStorageKeyConstant.CONVERSATION_BACK_TO_UP, true);
        this.scroller.scrollToIndex(Math.max(Math.min(1, this.messageCount), 0));
        this.scroller.scrollToIndex(0, true);
        AppStorage.setOrCreate(AppStorageKeyConstant.CONVERSATION_BACK_TO_UP, false);
      }
    }

  public resetIsInitParam() {
    this.isInInit = true;
    setTimeout(() => {
      this.isInInit = false;
    }, 2000);
  }

    get canSendMmsMessage() {
        return this.isRcsMms ? true :
            (((GlobalContext.getContext().getObject('fileTotalSize') as number) || 0) <= this.maxSizeOfMms);
    }

    changeVCardJumpBack() {
        this.vCardJumpBack = true;
    }

    changeVCardJumpBackNeedFresh() {
        this.vCardJumpBack = false;
    }

    getIsNew() {
        return this.isNewMsg;
    }
    static getInstance() {
        if (!ConversationController.sInstance) {
            ConversationController.sInstance = new ConversationController();
        }
        return ConversationController.sInstance;
    }

    public static release() {
        if (ConversationController.sInstance) {
            ConversationController.sInstance.mmsList = []
            ConversationController.sInstance = undefined
        }
    }

    static getTestInstance() {
        return new ConversationController();
    }

    handleSendReportable() {
        const deliveryReportSwitch = MmsPreferences.getInstance().getValueOfDeliveryReportSwitch();
        this.sendReportable = deliveryReportSwitch == common.DELIVERY_REPORTS.MMS
            || deliveryReportSwitch == common.DELIVERY_REPORTS.SMS_AND_MMS;
    }

    onInit(context: Context, pageInfos: NavPathStack) {
        HiLog.i(TAG, 'onInit');
        this.cactusUrl = context.resourceManager.getStringSync($r('app.string.map_url'));
        // 给原始草稿赋值
        this.draftModel = new DraftModel()
        this.handleSendReportable();
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_INIT, TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_INIT_ID);
        if (AppStorage.get('comeFromContact')) {
            this.resetMmsArea();
            // 新建信息-三方应用拉起打点
            otherEntranceParmas.OTHER_PNAMEID = 'com.ohos.contacts';
            DotUtil.getInstance().reportEvent(otherEntranceParmas, dotCommon.eventName.OTHER_APP_PULL);
        }
        this.resetData();
        this.pageInfos = pageInfos;
        this.initData();
        this.initRouterData(context);
        this.initSearchIndex(context);
        this.initYellowPageData(context);
        this.initNewPageContacts();
        this.rcsLoggedIn();
        this.rcsStateChange();
        // rcs 的事件监听
        this.appearSubscribe(context);
        this.getHasSimCard();
        this.mAdvancedSettingsCtrl.getAdvancedPageSwitchValue(); // use 3ms
        AppStorage.setOrCreate('isConversationNeedChange', true);
        this.initCurrentQueryTimeID();
        this.isShow = false;
        // Obtains the actual data. You do not need to query the data when creating new data.
        this.obtainSessionInformation(context); // 加载详情数据源
        EnhancedInfoTemporaryDataSource.getInstance().clearMapImageMsgIdToData();
        hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_INIT, TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_INIT_ID);
    }

    initCurrentQueryTimeID() {
        // 进入页面 or threadId 重新生成情况，需要重新生成对应 currentQueryTimeID
        this.currentQueryTimeID = new Date().getTime();
        HiLog.i(TAG, `initCurrentQueryTimeID currentQueryTimeID: ${this.currentQueryTimeID}, threadId: ${this.threadId}`);
        if (this.threadId != undefined && this.threadId != null) {
            this.queryTerminate.set(this.threadId, this.currentQueryTimeID);
        }
    }

    setIsShow() {
        this.isShow = true;
    }

    async initYellowPageData(context: Context) {
        if ((StringUtil.isEmpty(this.rawContactId) && StringUtil.isEmpty(this.yellowPageId)) ||
            (!StringUtil.isEmpty(this.yellowPageId) && StringUtil.isEmpty(this.formatStrContactsName))) {
            let res = await YellowPageService.getInstance()
                .judgeYellowPageByTelephone(this.strContactsNumber, context);
            this.yellowPageId = res.yellowPageId;
            if (this.yellowPageId) {
                this.strContactsName = res.name;
                this.smsType = 1;
                this.formatStrContactsName = res.name;
                this.contactsNameIsNotEqualToContactsNumberFormat = true;
            }
        }
    }
    obtainSessionInformation(context: Context): void {
        HiLog.iw(TAG, 'obtainSessionInformation: this.isNewMsg: ' + this.isNewMsg);
        if (!this.isNewMsg) {
            this.queryMessageDetail(context,
                {
                    isDraft:this.isDraft,
                    currentPage:1,
                    threadId:this.threadId,
                    contactsNum:this.contactsNum,
                    queryTimeID:this.currentQueryTimeID,
                    startIndex: 0,
                    isCallOnInitRequestMessageList: true
                }
                , () => {
                this.lastMsg = this.mmsList[this.mmsList.length - 1];
                this.getHasSimCard().then(() => {
                    if (this.haveTwoCards) {
                        this.twoCardsJudging(context);
                    }
                }).catch((error: BusinessError) => {
                    HiLog.e(TAG, error.message);
                });
                if (this.draftModel !== null && !this.draftModel?.needDeleteSession.isLoaded) {
                    this.draftModel.needDeleteSession.isLoaded = true
                }
            });
            HiLog.iw(TAG, 'conversation queryMessageDetail');
        } else {
            if (this.contactsNum == 0) {
                HiLog.iw(TAG, '[queryNoReceiverDraft]')
                DraftUtils.getInstance().queryNoReceiverDraft(context,
                    (result: IQueryNoReceiverDraftResult) => {
                    if (result.code == common.int.SUCCESS) {
                        this.dealMessageDetailTime(context, {
                            'response': result.response
                        });
                        if (result.response?.length > 0) {
                            this.isDraft = true;
                            this.setDraft();
                        }
                        /*
                         * 有多个没有联系人的草稿，表示出现脏数据，需要清理脏数据；
                         * 跑稳定性发现，特殊情况下会存在多个匿名草稿的问题，会造成其他应用拉去短信时的草稿内容异常。
                         * */
                        if (result.response?.length > 1) {
                            this.clearDirtyNoReceiverDraft(context, result.response);
                        }
                    }
                })
            }
            ConversationDataSource.getInstance().refresh(this.mmsList);
            let subId: number = MmsPreferences.getInstance().getSendMessageSlotId();
            this.updateSimSlotId(subId);
        }
        this.initDraftFlag(context);
    }

    /**
     * 刷新日期
     *
     * @param context 上下文
     * @param isNeedRefreshHour 是否仅刷新一小时之内消息的日期
     */
    refreshConversationDate(context: Context, isNeedRefreshHour?: boolean) {
        this.dealMessageDetailTime(context, {
            'response': this.mmsList
        }, false, false, isNeedRefreshHour);
    }

    private clearDirtyNoReceiverDraft(context: Context, draftItemList: mmsListType[]): number {
        /**
         * 已知复现路径
         * 1. 新建信息，填入联系人和草稿，回退主页面。每次都是使用不同的联系人和草稿内容；
         * 2. 再次新建信息，选择草稿信息，然后删除联系人返回到列表；
         * 3. 直接新建信息，然后删除草稿内容再退回，可以发现草稿信息的填充值不为空。
         */
        HiLog.e(TAG, 'clear dirty draft message in [clearDirtyNoReceiverDraft]');
        let needDeleteGroupIds: number[] = [];
        for (let item of draftItemList) {
            if (item.sendStatus == common.int.SEND_DRAFT) {
                needDeleteGroupIds.push(item.groupId);
            }
        }
        if (needDeleteGroupIds.length > 0) {
            HiLog.e(TAG, 'dirty draft message num is :' + needDeleteGroupIds.length);
            DraftUtils.getInstance().deleteMessageByGroupIds(needDeleteGroupIds, context, () =>{});
        }
        return needDeleteGroupIds.length;
    }

    twoCardsJudging(context: Context) {
        if (this.lastMsg?.isRcs === common.MESSAGE_TYPE.RCS) {
            setTimeout(() => {
                this.queryRcsMmsInfoSlotIdByCondition(context, (result: LooseObject) => {
                    let subId: number = SimSlotIdUtils.getAvailableSlotId(result.abilityResult);
                    HiLog.w(TAG,
                        `queryRcsMmsInfoSlotIdByCondition abilityResult:${result.abilityResult}, slotId:${subId}`);
                    this.updateSimSlotId(subId);
                })
            }, 50)
        } else {
            setTimeout(() => {
                this.querySmsMmsInfoSlotIdByCondition(context, (result: LooseObject) => {
                    let subId: number = SimSlotIdUtils.getAvailableSlotId(result.abilityResult);
                    HiLog.w(TAG,
                        `querySmsMmsInfoSlotIdByCondition abilityResult:${result.abilityResult}, slotId:${subId}`);
                    this.updateSimSlotId(subId);
                })
            }, 50)
        }
    }

    resetMmsArea(){
        let source: Mms[] = this.mAttachAreaCtrl.mmDisplaySource;
        this.resetMmsSource();
        this.release();
    }


    shouldEnableSendButtonForSlot(slotId: number): boolean {
        //DSDS_MODE_V2 = 0,DSDS_MODE_V3 = 1,DSDS_MODE_V5_TDM = 2,DSDS_MODE_V5_DSDA = 3,
        if (this.haveTwoCards) {
            return !call.hasCallSync() || this.callingSlotId == slotId || this.dsdsMode > 1;
        } else {
            return true;
        }
    }

    isCall(): boolean {
        let hasCall: boolean = call.hasCallSync();
        return hasCall;
    }

    setMessageTimeoutContent(context: Context): void {
        this.messageTimeout.context = context;
    }

    onShow(context: Context) {
        try {
            call.on('callDetailsChange', (data: call.CallAttributeOptions) => {
                this.callingSlotId = data.accountId
            })
        } catch (err) {
            HiLog.e(TAG, `onShow call.on error: ${err}`);
        }
        sim.getDsdsMode().then((data: sim.DsdsMode) => {
            this.dsdsMode = data;
        })
        HiLog.i(TAG, 'onShow');
        AppStorage.setOrCreate('currentSessionId', this.threadId);
        GlobalContext.getContext().setObject(GlobalContextKey.IS_JUMP_TO_PREVIEW, false);
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_SHOW,TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_SHOW_ID);
        // Check whether the Send button can be clicked.
        this.judgeSendBtnCanClicked();
        // Subscribe to airPlane mode
        this.initAirPlaneMode(context);
        this.initSatelliteMode(context);
        hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_SHOW,TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_SHOW_ID);
    }

    queryFaceChangeSwitch(context: Context) {
        queryFaceChangeDetectMode((switchStatus: number) => {
            HiLog.i(TAG, `shike face change switch status: ` + switchStatus);
            SharedPreferencesUtils.saveToPreferences('spamshield_message_live_detection', switchStatus);
        })
    }
    changeIsRcsMms(isRcsMms: boolean, isSlotIdChange: boolean){
        this.isRcsMms = isRcsMms;
        if (!isSlotIdChange) {
            this.resetValuesSwitchBetweenMmsAndRcs(!isRcsMms);
        }
        HiLog.iw(TAG, `changeIsRcsMms this.isRcsMms: ${this.isRcsMms}, isSlotIdChange: ${isSlotIdChange}`);
    }

    async getHasSimCard() {
        HiLog.i(TAG, 'getHasSimCard: ' + this.haveTwoCards);
        HiLog.i(TAG, 'isNoCardActive start: ' + this.isNoCardActive);
        let hasCard1: boolean = await sim.hasSimCard(common.int.SIM_ONE);
        let hasCard2: boolean = await sim.hasSimCard(common.int.SIM_TWO);
        this.haveTwoCards = hasCard1 && hasCard2;
        let isCardActive1: boolean = await sim.isSimActive(common.int.SIM_ONE);
        let isCardActive2: boolean = await sim.isSimActive(common.int.SIM_TWO);
        this.isAllCardActive = isCardActive1 && isCardActive2;
        this.isNoCardActive = (!isCardActive1) && (!isCardActive2);
        let isCardReady1: sim.SimState = sim.getSimStateSync(common.int.SIM_ONE);
        let isCardReady2: sim.SimState = sim.getSimStateSync(common.int.SIM_TWO);
        this.isAllCardReady = ((isCardReady1 == sim.SimState.SIM_STATE_READY ||
            isCardReady1 == sim.SimState.SIM_STATE_LOADED) && (isCardReady2 == sim.SimState.SIM_STATE_READY ||
            isCardReady2 == sim.SimState.SIM_STATE_LOADED));
        this.isAllCardCanSend = this.isAllCardReady && this.isAllCardActive;
        this.updateIsAllCardActive()
        HiLog.i(TAG, `isCardActive1: ${JSON.stringify(isCardActive1)}`);
        HiLog.i(TAG, `isCardActive2: ${JSON.stringify(isCardActive2)}`);
        HiLog.i(TAG, `isCardReady1: ${JSON.stringify(isCardReady1)}, isCardReady2: ${JSON.stringify(isCardReady2)}`);
        HiLog.i(TAG, `isNoCardActive: ${JSON.stringify(this.isNoCardActive)}`);
        HiLog.i(TAG, `haveTwoCards: ${JSON.stringify(this.haveTwoCards)}`);
        if (!this.haveTwoCards) {
            return;
        }
        if (isCardActive1 || isCardActive2) {
            if (!isCardActive1) {
                this.slotId = 1;
                return;
            }
        }
        HiLog.i(TAG, 'isNoCardActive end.');
    }

    updateIsAllCardActive() {
        let innerEvent: emitter.InnerEvent = { eventId: EmitterConstant.EVENT_CHANGE_ALL_ACTIVE }
        this.canSendMessage = MmsPreferences.getInstance().haveSimCardReady();
        if (this.isNewMsg) {
            this.setCanSendMsgStatus();
        } else if (this.canSendMessage) {
            if (this.textValue === '' &&
                this.mAttachAreaCtrl.mmDisplaySource.length <= 0) {
                this.canSendMessage = false
            }
        }
        let eventData: emitter.EventData = {
            data: {
                'isAllCardCanSend': this.isAllCardCanSend
            }
        }
        emitter.emit(innerEvent, eventData)
    }

    updateSimSlotId(subId: number){
        this.simSlotId = subId;
        AppStorage.setOrCreate('simSlotId',subId);
        let innerEvent: emitter.InnerEvent = { eventId: EmitterConstant.EVENT_CHANGE_SUBID_STATUS }
        let eventData: emitter.EventData = {
            data: {
                'subId': subId
            }
        }
        emitter.emit(innerEvent, eventData)
        HiLog.i(TAG, `updateSimSlotId, set KEY_OF_SELECTED_SLOTID: ${JSON.stringify(subId)}`);
        MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SELECTED_SLOTID, subId);
    }

    /**
     * 在新建会话点击发送消息后，跳转到conversation页面来实际地发送消息
     * @param context
     */
    fromNewConversationSend(context: Context) {
        if (GlobalContext.getContext().getObject('isFromNewCreatMessage')) {
            HiLog.i(TAG,'fromNewConversationSend start')
            let routerParams: LooseObject = this.pageInfos.getParamByIndex(this.pageInfos.size() - 1) as LooseObject;
            this.isNewMsg = routerParams?.isNewMsg;
            this.isConversationNewMsg = routerParams?.isConversationNewMsg;
            this.threadId = StringUtil.isEmpty(routerParams.threadId) ? 0 : routerParams.threadId;
            this.slotId = routerParams?.slotId;

            this.receiveContactValue = routerParams?.receiveContactValue;
            this.selectContacts = routerParams?.selectContacts
            this.setSelectContacts(this.selectContacts)
            this.isEditMms = routerParams.isMsm;
            this.mAttachAreaCtrl.mmDisplaySource = routerParams.mmsSource;
            this.mAttachAreaCtrl.rcsDisplaySource = routerParams.rcsDisplaySource;
            this.textValue = routerParams.inputText;
            this.vCardJumpBack =  routerParams.vCardJumpBack;
            this.isTextAsMms = routerParams.isTextAsMms;
            let isNeedSend: boolean = routerParams.isNeedSend;
            let isNeedsendAudio: boolean = routerParams.isNeedsendAudio;
            let isRCS: boolean = routerParams.isRCS;
            this.changeIsRcsMms(isRCS, false);
            if (isNeedSend) {
                this.canSendMessage = true;
                const newConversationSendData: NewConversationSendData = {
                    isEditMms: routerParams.isMsm,
                    attachmentDataList: routerParams.mmsSource
                };
                if (isRCS) {
                    //从新建会话跳转历史会话发送消息的场景,由于发送逻辑是异步的,期间会有地方更改this.isEditMms和
                    // this.mAttachAreaCtrl.mmDisplaySource,导致发送异常。所以使用路由传入的数据来发送。
                    this.sendOfEnhancedInfo(context, newConversationSendData);
                } else {
                    //从新建会话跳转历史会话发送消息的场景,由于发送逻辑是异步的,期间会有地方更改this.isEditMms和
                    // this.mAttachAreaCtrl.mmDisplaySource,导致发送异常。所以使用路由传入的数据来发送。
                    this.send(context, newConversationSendData);
                }
            }
            if (isNeedsendAudio) {
                this.canSendMessage = true;
                this.sendAudio(context);
            }
            GlobalContext.getContext().setObject('isFromNewCreatMessage', false)
        }

    }

    initTransmit(context: Context) {
        if (this.draftModel !== null) {
            this.draftModel.isForwardingDraftModel = true
        }
        // Initialize the forwarded data
        this.initTransmitMeg();
        // Forwarding and sending
        this.transmitSend(context);
        // get Forwarding draft
        this.getDraftTextData(context)
    }

    getDraftTextData(context: Context, isSetTextValue: boolean = true) {
        DraftUtils.getInstance().getDraftTextData(context, this.threadId, (result: string[]) => {
            if (result.length < 2) {
                HiLog.e(TAG, 'invalid length');
                return;
            }
            if (isSetTextValue) {
                this.isEditMms = result[0] === '1';
                this.textValue = result[1];
                this.isDraft = true
            }
            if (this.draftModel != null && !this.draftModel.isHasSetValueForInitialDraftText) {
                this.draftModel.initialDraftText = result[1];
                this.draftModel.isHasSetValueForInitialDraftText = true
            }
        })
    }

    checkIfNeedRefresh(context: Context) {
        let receiveSessionArray: string[] = AppStorage.get('receiveSessionArray') ?? [];
        let hasNewMsg: boolean = false;
        let strTheadID = this.threadId.toString();
        for (let i = 0; i < receiveSessionArray.length; i++) {
            let receiveId = receiveSessionArray[i];
            if (receiveId !== undefined && receiveId.toString() === strTheadID) {
                hasNewMsg = true;
                HiLog.w(TAG, 'receiveSessionArray has new')
                break;
            }
        }
        HiLog.i(TAG, 'hasNewMsg: ' + hasNewMsg + ', this.isBackHome: ' + this.isBackHome)
        // 后台期间此会话有新消息
        if (hasNewMsg || this.isBackHome || SharedPreferencesUtils.getFromPreferences('restoreBlocked', false)) {
            // 执行查库操作
            this.isBackHome = false;
            this.refreshConversationData(context);
        } else {
            // 只更新页面会话时间信息
            HiLog.i(TAG, 'only need update time')
            this.onlyRefreshTime();
        }
        // 清空后台期间收到新消息的临时数据
        AppStorage.setOrCreate('receiveSessionArray', []);
    }

    onlyRefreshTime() {
        let now = new Date();
        let currentMillisecond: number = now.getTime();
        let oneDayMilliseconds: number = 24 * 60 * 60 * 1000;
        let twoDaysMilliseconds: number = 48 * 60 * 60 * 1000;
        let yesterday = new Date(currentMillisecond - oneDayMilliseconds);

        let yearOfNow = now.getFullYear();
        let monthOfNow = now.getMonth() + 1;
        let dayOfNow = now.getDate();
        let yesterdayMonth = yesterday.getMonth() + 1;
        let yesterdayDay = yesterday.getDate();

        let sysLocaleChanged = AppStorage.get('sysLocaleChanged') as boolean;
        for (let i = this.mmsList.length - 1; i >= 0; i--) {
            let msgMillisecond: number = Number.parseInt(this.mmsList[i].timeMillisecond as string);
            let diff: number = currentMillisecond - msgMillisecond;
            if (diff > twoDaysMilliseconds && !sysLocaleChanged) {
                break;
            }
            DateUtil.onlyUpdateSmsItemTime(this.mmsList[i], yearOfNow, monthOfNow, dayOfNow, yesterdayMonth, yesterdayDay, diff);
        }
        if (this.mmsList.length > 0) {
            ConversationDataSource.getInstance().refresh(this.mmsList);
        }
    }

    initDraftFlag(context: Context) {
        if (this.isDraft && this.textValue.length == 0) {
            HiLog.i(TAG, 'enter getDraftTextData');
            this.getDraftTextData(context);
        } else {
            if (this.draftModel != null && !this.draftModel.isHasSetValueForInitialDraftText) {
                this.draftModel.isHasSetValueForInitialDraftText = true;
            }
        }
    }

    refreshConversationData(context: Context) {
        HiLog.i(TAG, 'refreshConversationData Start!')
        let restoreBlocked: boolean = SharedPreferencesUtils.getFromPreferences('restoreBlocked', false) as boolean;
        if (GlobalContext.getContext().getObject('conversationNeedToUpdate') || restoreBlocked) {
            this.queryMessageDetail(context, {
                isDraft:this.isDraft,
                currentPage:1,
                threadId:this.threadId,
                contactsNum:this.contactsNum,
                queryTimeID:this.currentQueryTimeID,
                startIndex: 0
            },() => {});
            GlobalContext.getContext().setObject('conversationNeedToUpdate', false);
            SharedPreferencesUtils.saveToPreferences('restoreBlocked', false);
        }
        this.initDraftFlag(context);
    }

    onHide() {
        HiLog.i(TAG, 'onHide');
        this.isPageHide = true;
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_HIDE,TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_HIDE_ID);
        this.isFromBackground = true;
        AppStorage.setOrCreate('receiveSessionArray', [])
        this.unSubscribeDetail();
        this.unsubscribeChatbotReceivedSuggestionsEvent();
        this.unsubscribeChatbotCardDownloadOriginFileEvent();
        this.messageTimeout.clearSubscribeAndTimer();
        if (this.isShow) {
            this.currentQueryTimeID = new Date().getTime();
            this.queryTerminate.clear();
            this.queryTerminate.set(this.threadId, this.currentQueryTimeID);
            this.isShow = false;
        }
        if (this.isPC && GlobalContext.getContext().getObject('transmitFlag') === true) {
            GlobalContext.getContext().setObject('transmitFlag', true)
        } else {
            GlobalContext.getContext().setObject('transmitFlag', false)
        }
        hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_HIDE,TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_HIDE_ID);
    }
    /**
     * 订阅"增强信息发送消息发送成功"公共事件
     */
    public sendOKReceiveEvent = (sendSendOKEventSubscriber: (data: commonEvent.CommonEventSubscriber) => void) => {
        HiLog.iw(TAG, 'sendOKReceiveEvent');
        let events = [common.STR.RCS_SUBSCRIBER_SEND_OK_EVENT];
        let commonEventSubscribeInfoData: commonEvent.CommonEventSubscribeInfo = {
            events: events,
            publisherBundleName: common.STR.BUNDLE_NAME, // 这里校验包名即可，短信包名不能被卸载仿冒
        };

        let subscriber: commonEvent.CommonEventSubscriber;
        try {
            subscriber = commonEvent.createSubscriberSync(commonEventSubscribeInfoData);
            sendSendOKEventSubscriber(subscriber);
            commonEvent.subscribe(subscriber, (err, data) => {
                HiLog.iw(TAG, 'sendOKReceiveEvent callback');
                if (err) {
                    HiLog.e(TAG, `sendOKReceiveEvent subscribe failed, code is ${err.code}, message is ${err.message}`);
                    return;
                }
                if (!data || !data.data) {
                    HiLog.e(TAG, 'sendOKReceiveEvent subscribe failed, data or data.data is null');
                    return;
                }
                this.updateMmsListItemStatusOfRcs(data.data, common.int.RCS_SEND_OK);
            })
        } catch (error) {
            let err: BusinessError = error as BusinessError;
            HiLog.e(TAG,
                `sendOKReceiveEvent createSubscriberSync failed, code is ${err?.code}, message is ${err?.message}`);
        }
    }
    subscribeRcsSendCanceledEvent() {
        HiLog.iw(TAG, 'subscribeRcsSendCanceledEvent');
        let events = [common.STR.RCS_SUBSCRIBER_FILE_SEND_CANCELED_EVENT];
        let commonEventSubscribeInfoData: commonEvent.CommonEventSubscribeInfo = {
            events: events,
            publisherBundleName: common.STR.BUNDLE_NAME, // 这里校验包名即可，短信包名不能被卸载仿冒
        };
        let subscriber: commonEvent.CommonEventSubscriber;
        try {
            subscriber = commonEvent.createSubscriberSync(commonEventSubscribeInfoData);
            this.rcsSendCanceledEventSubscriber = subscriber;
            commonEvent.subscribe(this.rcsSendCanceledEventSubscriber, (err, data) => {
                HiLog.iw(TAG, 'RcsSendCanceledEvent callback');
                if (err) {
                    HiLog.e(TAG, `subscribeRcsSendCanceledEvent subscribe failed, code is ${err.code}, message is ${err.message}`);
                    return;
                }
                if (!data || !data.data) {
                    HiLog.e(TAG, 'subscribeRcsSendCanceledEvent subscribe failed, data or data.data is empty');
                    return;
                }
                this.updateMmsListItemStatusOfRcs(data.data, common.int.RCS_SEND_CANCELED);
            })
        } catch (error) {
            let err: BusinessError = error as BusinessError;
            HiLog.e(TAG, `subscribeRcsSendCanceledEvent createSubscriberSync failed, code is ${err?.code}, message is ${err?.message}`);
        }
    }

    unsubscribeRcsSendCanceledEvent() {
        if (!this.rcsSendCanceledEventSubscriber) {
            return;
        }
        try {
            commonEvent.unsubscribe(this.rcsSendCanceledEventSubscriber, (err: BusinessError) => {
                if (err) {
                    HiLog.e(TAG,
                        `unsubscribeRcsSendCanceledEvent failed, code is ${err.code}, message is ${err.message}`);
                } else {
                    HiLog.i(TAG, 'unsubscribeRcsSendCanceledEvent success');
                    this.rcsSendCanceledEventSubscriber = null;
                }
            });
        } catch (error) {
            let err: BusinessError = error as BusinessError;
            HiLog.e(TAG, `unsubscribeRcsSendCanceledEvent failed, code is ${err.code}, message is ${err.message}`);
        }
    }

  public subscribeChatbotCardDownloadOriginFile(callback: (msgId: string, serviceId: string,
    mmsSourceList: Mms[]) => void) {
    HiLog.i(TAG, 'subscribeChatbotCardDownloadOriginFile');
    const commonEventSubscribeInfoData: commonEvent.CommonEventSubscribeInfo = {
      events: [common.STR.RCS_SUBSCRIBER_CHATBOT_CARD_DOWNLOAD_ORIGIN_FILE_DONE],
      publisherBundleName: common.STR.BUNDLE_NAME, // 这里校验包名即可，短信包名不能被卸载仿冒
    };
    let subscriber: commonEvent.CommonEventSubscriber;
    try {
      subscriber = commonEvent.createSubscriberSync(commonEventSubscribeInfoData);
      this.chatbotCardDownloadOriginEventSubscriber = subscriber;
      commonEvent.subscribe(this.chatbotCardDownloadOriginEventSubscriber, (err, data) => {
        HiLog.i(TAG, 'subscribeChatbotCardDownloadOriginFile callback');
        if (err) {
          HiLog.e(TAG, `subscribeChatbotCardDownloadOriginFile subscribe failed, code is ${
          err.code}, message is ${err.message}`);
          return;
        }
        if (!data?.data || !data.parameters?.serviceId || !data.parameters.mmsSourceList) {
          HiLog.e(TAG, 'subscribeChatbotCardDownloadOriginFile subscribe error, datas is empty');
          return;
        }
        callback(data.data, data.parameters.serviceId, data.parameters.mmsSourceList);
      })
    } catch (e) {
      HiLog.e(TAG, `subscribeChatbotCardDownloadOriginFile createSubscriberSync error: ${JSON.stringify(e)}`);
    }
  }

  public unsubscribeChatbotCardDownloadOriginFileEvent() {
    if (!this.chatbotCardDownloadOriginEventSubscriber) {
      return;
    }
    try {
      commonEvent.unsubscribe(this.chatbotCardDownloadOriginEventSubscriber, (err: BusinessError) => {
        if (err) {
          HiLog.e(TAG, `unsubscribeChatbotCardDownloadOriginFileEvent failed, code is ${
          err.code}, message is ${err.message}`);
        } else {
          HiLog.i(TAG, 'unsubscribeChatbotCardDownloadOriginFileEvent success');
          this.chatbotCardDownloadOriginEventSubscriber = null;
        }
      });
    } catch (e) {
      HiLog.e(TAG, `unsubscribeChatbotCardDownloadOriginFileEvent error: ${JSON.stringify(e)}`);
    }
  }

  subscribeChatbotReceivedSuggestionsEvent(callback: (serviceId: string, botMessage: BotMessage) => void) {
    HiLog.i(TAG, 'subscribeChatbotReceivedSuggestionsEvent');
    const commonEventSubscribeInfoData: commonEvent.CommonEventSubscribeInfo = {
      events: [common.STR.RCS_SUBSCRIBER_CHATBOT_RECEIVED_SUGGESTIONS_EVENT],
    };
    let subscriber: commonEvent.CommonEventSubscriber;
    try {
      subscriber = commonEvent.createSubscriberSync(commonEventSubscribeInfoData);
      this.chatbotReceivedSuggestionsEventSubscriber = subscriber;
      commonEvent.subscribe(this.chatbotReceivedSuggestionsEventSubscriber, (err, data) => {
        if (err) {
          HiLog.e(TAG, `subscribeChatbotReceivedSuggestionsEvent subscribe failed, code is ${
          err.code}, message is ${err.message}`);
          return;
        }
        if (!data || !data.data) {
          HiLog.e(TAG, 'subscribeChatbotReceivedSuggestionsEvent subscribe failed, data or data.data is empty');
          return;
        }
        if (data.parameters) {
          callback(data.parameters.serviceId, data.parameters.botMessage);
        }
      })
    } catch (e) {
      HiLog.e(TAG, `subscribeChatbotReceivedSuggestionsEvent createSubscriberSync error: ${JSON.stringify(e)}`);
    }
  }

  unsubscribeChatbotReceivedSuggestionsEvent() {
    if (!this.chatbotReceivedSuggestionsEventSubscriber) {
      return;
    }
    try {
      commonEvent.unsubscribe(this.chatbotReceivedSuggestionsEventSubscriber, (err: BusinessError) => {
        if (err) {
          HiLog.e(TAG, `unsubscribeChatbotReceivedSuggestionsEvent failed, code is ${
          err.code}, message is ${err.message}`);
        } else {
          HiLog.i(TAG, 'unsubscribeChatbotReceivedSuggestionsEvent success');
          this.chatbotReceivedSuggestionsEventSubscriber = null;
        }
      });
    } catch (e) {
      HiLog.e(TAG, `unsubscribeChatbotReceivedSuggestionsEvent error: ${JSON.stringify(e)}`);
    }
  }

    getDataParameters(){

        return this.dataParameters;
    }

    getDataParametersPhone(){

        return this.dataParametersPhone;
    }
    subscribeStaticEvent(context: Context) {
        const commonEventSubscribeInfoData: commonEvent.CommonEventSubscribeInfo = {
          events: [common.STR.RCS_SUBSCRIBER_COMMON_EVENT],
          publisherBundleName: common.STR.BUNDLE_NAME, // 这里校验包名即可，短信包名不能被卸载仿冒
        };
        commonEvent.createSubscriber(commonEventSubscribeInfoData, (args1, args2) => {
            this.createStaticSubscriberCallBack(context, args1, args2);
        });
    }

    createStaticSubscriberCallBack(context: Context, err: BusinessError, data: commonEventManager.CommonEventSubscriber) {
        this.staticEventData = data;
        // Received subscription
        commonEvent.subscribe(this.staticEventData, (err, data) => {
            HiLog.i(TAG, 'createStaticSubscriberCallBack, err : ' + err?.code)
            if (data == null || data.data == null) {
                HiLog.w(TAG, 'refreshEventData, data or data.data is null, return');
                return;
            }
            let readFlag: boolean = SharedPreferencesUtils.getFromPreferences('readFlag', false) as boolean;
            HiLog.i(TAG, 'queryRcsMmsInfoReadByMsgId readFlag: ' + readFlag);
            if (readFlag) {
                this.updateMmsListItemStatusOfRcs(data.data, common.int.SEND_MESSAGE_READ);
            }
        });
    }

    // disAppear 的时候 取消事件监听
    disAppearUnsubscribe() {
        this.unSubscribeStaticEvent();
        this.unsubscribeProcessEventSubscriber();
        this.unsubscribeReceiveOkEventSubscriber();
        this.unsubscribeReceiveCancelEventSubscriber();
        this.unsubscribeFailEventSubscriber();
        this.unsubscribeRcsSendCanceledEvent();
    }

    // appear 的时候 增加事件监听
    appearSubscribe(context: Context) {
        this.subscribeStaticEvent(context);
        this.receiveOkReceiveEvent();
        this.receiveCancelReceiveEvent();
        this.failReceiveEvent();
        // 在此单例类中，仅注册，不销毁，重新注册不会重复返回，销毁点在发送处
        emitter.on(EmitterConstant.EVENT_CLICK_STATUSBAR, this.clickStatusbarCallback);
        // 在转发rcs视频场景下，订阅进度事件和取消订阅进度事件会因并发问题导致时序不可控，进而导致订阅失效，这里进行延迟100ms订阅，
        // 保证转发场景下，取消订阅和订阅按序进行，订阅取消发送事件和发送成功事件同理。
        setTimeout(() => {
            this.processReceiveEvent();
            this.subscribeRcsSendCanceledEvent();
        }, 100);
    }

    unSubscribeStaticEvent() {
        if (this.staticEventData != null) {
            commonEvent.unsubscribe(this.staticEventData, () => {
                HiLog.i(TAG, 'unsubscribe staticEventData, success');
            });
            this.staticEventData = null;
        }
    }

    initData() {
        this.strMsgDeleteDialogTip = $r('app.plural.msg_delete_dialog_con_tip2',
            this.selectDeleteMsgCount, this.selectDeleteMsgCount
        );
        this.tabTextList = [];

        this.textValue = '';
        this.receiveContactValue = '';
        this.isDraft = false;
        this.mmsList = [];
        this.newEmojiLength = 0;
        this.setSelectStatus(false);
        this.selectDeleteMsgCount = 0;
        ConversationDataSource.getInstance().selectList = []
        AppStorage.setOrCreate('selectLength', 0)
        this.isMessageCheckAll = false;
    }

    initAirPlaneMode(context: Context) {
        addAirPlaneModeListener((data: number) => {
            this.isAirPlaneMode = data == 1 ? true : false;
            AppStorage.setOrCreate('isAirPlaneMode',data == 1 ? true : false)
        }, context);
    }

    getAirPlaneMode() {
        HiLog.i(TAG, 'getAirPlaneMode');
        queryAirPlaneMode((data: number) => {
            HiLog.i(TAG, 'getAirPlaneMode callback');
            this.isAirPlaneMode = data == 1 ? true : false;
        });
    }

    removeAirPlaneMode() {
        HiLog.i(TAG, 'removeAirPlaneMode');
        removeAirPlaneModeListener();
    }

    initSatelliteMode(context: Context) {
        addAIFaceChangeModeListener(() => {
            this.queryFaceChangeSwitch(context);
        }, context)
    }

    removeSatelliteMode() {
        removeAIFaceChangeModeListener();
    }

    release() {
        this.textValue = '';
        this.receiveContactValue = '';
        this.isDraft = false;
        this.mmsList = [];
    }

    /**
     * 订阅"增强信息发送消息已送达"公共事件
     */
    public deliveryEvent = (setDeliveryEventData: (data: commonEvent.CommonEventSubscriber | null) => void) => {
        HiLog.iw(TAG, 'deliveryEvent');
        const commonEventSubscribeInfoData: commonEvent.CommonEventSubscribeInfo = {
            events: [common.STR.RCS_SUBSCRIBER_DELIVERY_EVENT],
            publisherBundleName: common.STR.BUNDLE_NAME, // 这里校验包名即可，短信包名不能被卸载仿冒
        };
        try {
            commonEvent.createSubscriber(commonEventSubscribeInfoData, (args1, args2) => {
                HiLog.iw(TAG, 'createDeliveryEventCallBack start');
                setDeliveryEventData(args2);
                this.createDeliveryEventCallBack(args1, args2);
            });
        } catch (e) {
            HiLog.e(TAG, `deliveryEvent error: ${e?.code} ${e?.message}`);
        }
    }

    failReceiveEvent() {
        const commonEventSubscribeInfoData: commonEvent.CommonEventSubscribeInfo = {
            events: [common.STR.RCS_SUBSCRIBER_FAIL_RECEIVE_EVENT],
            publisherBundleName: common.STR.BUNDLE_NAME, // 这里校验包名即可，短信包名不能被卸载仿冒
        };
        commonEvent.createSubscriber(commonEventSubscribeInfoData, (args1, args2) => {
            HiLog.iw(TAG, 'failReceiveEvent: createSubscriber success');
            this.createFailReceiveEventCallBack(args1, args2);
        });
    }

    private createDeliveryEventCallBack = (err: BusinessError, data: commonEventManager.CommonEventSubscriber) => {
        // Received subscription
        try {
            commonEvent.subscribe(data, (err, data) => {
                if (data == null || data.data == null) {
                    HiLog.w(TAG, 'createDeliveryEventCallBack, data or data.data is null, return');
                    return;
                }
                HiLog.iw(TAG, 'createDeliveryEventCallBack');
                this.updateMmsListItemStatusOfRcs(data.data, common.int.SEND_MESSAGE_SUCCESS);
            });
        } catch (e) {
            HiLog.e(TAG, `createDeliveryEventCallBack error: ${e?.code} ${e?.message}`);
        }
    }

    createFailReceiveEventCallBack(err: BusinessError, data: commonEventManager.CommonEventSubscriber) {
        this.failEventData = data;
        // Received subscription
        commonEvent.subscribe(this.failEventData, (err, data) => {
            if (data == null || data.data == null) {
                HiLog.w(TAG, 'createFailReceiveEventCallBack, data or data.data is null, return');
                return;
            }
            HiLog.iw(TAG, 'createFailReceiveEventCallBack');
            this.updateMmsListItemStatusOfRcs(data.data, common.int.SEND_MESSAGE_FAILED);
        });
    }

    /**
     * 取消订阅"增强信息发送消息已送达"公共事件
     */
    public unSubscribeDeliveryEvent = (deliveryEventData: commonEvent.CommonEventSubscriber | null,
        setDeliveryEventData: (data: commonEvent.CommonEventSubscriber | null) => void) => {
        if (deliveryEventData) {
            try {
                commonEvent.unsubscribe(deliveryEventData, () => {
                    HiLog.i(TAG, 'unsubscribe deliveryEventData, success');
                });
                setDeliveryEventData(null);
            } catch (e) {
                HiLog.e(TAG, `unSubscribeDeliveryEvent error: ${e?.code} ${e?.message}`);
            }
        }
    }

    private dealWithOneContact(transmitContacts: Array<itemType>) {
        let item: itemType = new itemType();
        item.contactName = this.strContactsName;
        item.telephone = this.strContactsNumber;
        item.rawContactId = this.rawContactId;
        if (this.strContactsName == common.STR.EMPTY_STR && this.strContactsNumberFormat == common.STR.EMPTY_STR) {
            item.telephoneFormat = this.strContactsNumber;
        } else {
            item.telephoneFormat = this.strContactsNumberFormat;
        }
        item.headImage = common.STR.EMPTY_STR;
        item.select = false;
        transmitContacts.push(item);
    }

    private dealWithMultiContacts(transmitContacts: Array<itemType>) {
        let splitStr = this.strContactsName.includes(common.STR.CONTACT_NAME_SPLIT) ? common.STR.CONTACT_NAME_SPLIT :
        common.STR.COMMA;
        let contactsNames = this.strContactsName.split(splitStr);
        let telephones = this.strContactsNumber.split(',');
        let telephoneFormat = this.strContactsNumberFormat.split(',');
        let rawContactId = this.rawContactId.split(',');
        let isNameWithComma = (contactsNames.length != this.contactsNum);
        let length = isNameWithComma ? this.contactsNameList.length : contactsNames.length;
        for (let index = 0; index < length; ++index) {
            let item: itemType = new itemType();
            item.contactName = isNameWithComma ? this.contactsNameList[index] : contactsNames[index];
            item.telephone = telephones[index];
            item.rawContactId = rawContactId[index];
            if (contactsNames[index] == common.STR.EMPTY_STR &&
                telephoneFormat[index] == common.STR.EMPTY_STR) {
                item.telephoneFormat = telephones[index];
            } else {
                item.telephoneFormat = telephoneFormat[index];
            }
            item.headImage = common.STR.EMPTY_STR;
            item.select = false;
            transmitContacts.push(item);
        }
    }

    initNewPageContacts() {
        let transmitContacts: Array<itemType> = [];
        if (this.strContactsNumber) {
            if (this.contactsNum == SINGLE_CONTACT) {
                this.dealWithOneContact(transmitContacts);
            } else {
                this.dealWithMultiContacts(transmitContacts);
            }
        }
        this.commonCtrl.paramContact.transmitContacts = transmitContacts;
        this.commonCtrl.paramContact.isSelectContact = false;
    }

    initRouterData(context: Context) {
        // {'pathArray':[{'name':'Conversation','param':{'isNewMsg':true}}],'changeFlag':1,'type':'NavPathStack'}
        let routerParams: LooseObject = this.pageInfos.getParamByIndex(this.pageInfos.size() - 1) as LooseObject;
        if (!routerParams) {
            HiLog.w(TAG, "initRouterData routerParams is null！")
            return;
        }
        this.strContactsName =
            StringUtil.isEmpty(routerParams.strContactsName) ? '' : routerParams.strContactsName;
        this.strContactsNumber =
            StringUtil.isEmpty(routerParams.strContactsNumber) ? '' : routerParams.strContactsNumber;
        this.strContactsNumberFormat =
            StringUtil.isEmpty(routerParams.strContactsNumberFormat) ? '' : routerParams.strContactsNumberFormat;
        this.contactsNum = StringUtil.isEmpty(routerParams.contactsNum) ? 0 : routerParams.contactsNum;
        this.contactsNameList = StringUtil.isEmpty(routerParams.contactsNameList) ? [] : routerParams.contactsNameList;
        //The quantity is subject to strContactsNumber.
        let length: number = StringUtil.isEmpty(this.strContactsNumber) ? 0 : this.strContactsNumber.split(',').length;
        this.contactsNum = length == this.contactsNum ? this.contactsNum : length;
        this.threadId = StringUtil.isEmpty(routerParams.threadId) ? 0 : routerParams.threadId;
        this.isDraft = StringUtil.isEmpty(routerParams.isDraft)? false : routerParams.isDraft;
        this.draftContent = StringUtil.isEmpty(routerParams.draftContent) ? '' : routerParams.draftContent;
        this.searchContent = StringUtil.isEmpty(routerParams.searchContent)? '' : routerParams.searchContent;
        this.isNewMsg = StringUtil.isEmpty(routerParams.isNewMsg)? false : routerParams.isNewMsg;
        this.isConversationNewMsg = StringUtil.isEmpty(routerParams.isConversationNewMsg) ? false : routerParams.isConversationNewMsg;
        let photoFirstNames: Array<photoFirstNamesType> = StringUtil.isEmpty(routerParams.photoFirstNames) ? [] : routerParams.photoFirstNames;
        this.photoFirstNameDeal(this.strContactsName, photoFirstNames);
        this.searchMsgId = StringUtil.isEmpty(routerParams.msgId) ? '' : routerParams.msgId;
        this.isBackToIndex = routerParams?.isFromInfoMsgView ? false : true;
        this.textValue = StringUtil.isEmpty(routerParams.content) ? '' : routerParams.content;
        this.rawContactId =  StringUtil.isEmpty(routerParams.rawContactId) ? '' :routerParams.rawContactId;
        this.contactId =  StringUtil.isEmpty(routerParams.contactId) ? '' :routerParams.contactId;
        this.isFromNotication = routerParams?.isFromNotice ? true : false;
        this.yellowPageId = StringUtil.isEmpty(routerParams.yellowPageId) ? '' : routerParams.yellowPageId;
        this.hasYellowPageIcon = StringUtil.isEmpty(routerParams.hasYellowPageIcon) ? '' : routerParams.hasYellowPageIcon;
        this.icon = StringUtil.isEmpty(routerParams.icon) ? '' : routerParams.icon;
        this.smsType = StringUtil.isEmpty(routerParams.smsType) ? 0 : routerParams.smsType;
        this.portraitColor = AvatarColor.background.Color[Number(this.rawContactId.split(',')[0] || '0') % 6];
        this.isNewMsgWithDraft =StringUtil.isEmpty(routerParams.isNewMsgWithDraft) ? false : routerParams.isNewMsgWithDraft;
        this.messageCount = Number.isNaN(routerParams.messageCount) ? 0 : routerParams.messageCount;
        if (this.chatbotPageIcon === '') {
            this.chatbotPageIcon = StringUtil.isEmpty(routerParams?.chatbotPageIcon) ? '' : routerParams?.chatbotPageIcon;
        }
        HiLog.i(TAG,'isNewMsg : '+this.isNewMsg)
        HiLog.i(TAG,
            `initRouterData, isFromNotication: ${this.isFromNotication},contactsNum: ${this.contactsNum},threadId is: ${this.threadId}`)
        if (routerParams.isFromNewCreatMessage === true) {
            this.getDraftTextData(context)
        }
        if(!StringUtil.isEmpty(this.yellowPageId) && StringUtil.isEmpty(this.hasYellowPageIcon)){
            let actionData: LooseObject = {};
            actionData.telephones = [this.strContactsNumber];
            YellowPageService.getInstance().queryYellowPageListInfoByCondition(actionData, (res: LooseObject) => {
                if (res.code == commonData.int.FAILURE || res.abilityResult.length == 0) {
                    HiLog.w(TAG, 'telephonesForSearchYellowPage, has no YellowPage');
                } else {
                    if (res.abilityResult[0].photo) {
                        this.hasYellowPageIcon = res.abilityResult[0].photo
                    }
                }
            }, context);

        }
        this.formatDisplayPhoneNum();
    }

    formatDisplayPhoneNum() {
        if (this.contactsNum > SINGLE_CONTACT) {
            let splitStr = this.strContactsName.includes(common.STR.CONTACT_NAME_SPLIT) ? common.STR.CONTACT_NAME_SPLIT :
            common.STR.COMMA;
            let strContactNameArr = this.strContactsName.split(splitStr);
            let strNumberArr = this.strContactsNumber.split(common.STR.COMMA);
            let contactsName = common.STR.EMPTY_STR;
            let formatNum = common.STR.EMPTY_STR;
            for (let index = 0; index < strNumberArr.length; ++index) {
                if (strNumberArr[index] != null && strContactNameArr[index] != null &&
                    strNumberArr[index].replace(/\s*/g, '') == strContactNameArr[index].replace(/\s*/g, '')) {
                    formatNum = TelephoneUtil.countryCodeFormatPhone(strNumberArr[index]);
                    contactsName += (formatNum + common.STR.CONTACT_NAME_SPLIT);
                } else {
                    contactsName += (strContactNameArr[index] + common.STR.CONTACT_NAME_SPLIT);
                }
            }
            this.strContactsName = contactsName.substring(0, contactsName.length - 2);
        }
        this.formatStrContactsNumberFormat = this.contactsNum > 1 ? this.strContactsName :
            TelephoneUtil.countryCodeFormatPhone(this.strContactsNumberFormat);
        HiLog.w(TAG, 'formatDisplayPhoneNum end');
        this.formatStrContactsName = this.strContactsName;
        if (this.formatStrContactsNumberFormat.startsWith('sip:') &&
        this.formatStrContactsNumberFormat.includes('botplatform')) {
            this.contactsNameIsNotEqualToContactsNumberFormat = false;
            // 号码比较是否相同时去除空格
        } else if (this.formatStrContactsName === this.formatStrContactsNumberFormat.replace(/\s*/g, '')) {
            this.contactsNameIsNotEqualToContactsNumberFormat = false;
            this.formatStrContactsName = this.formatStrContactsNumberFormat;
        } else {
            // 最后统一格式化后进行比较电话号码是否相同，如带区号和不带区号的进行比较，号码相等时应该相等
            let formattedContactName = TelephoneUtil.formatDisplayPhoneNum(this.formatStrContactsName);
            let formattedContactNumber = TelephoneUtil.formatDisplayPhoneNum(this.formatStrContactsNumberFormat);
            this.contactsNameIsNotEqualToContactsNumberFormat = (formattedContactName !== formattedContactNumber);
        }
    }

    public getNetConnectType(): string {
        try {
            const netCapabilities = connection.getNetCapabilitiesSync(connection.getDefaultNetSync());
            if (!netCapabilities || !netCapabilities.bearerTypes || !netCapabilities.networkCap) {
                return 'noNet';
            }
            if (netCapabilities.networkCap.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
                if (netCapabilities.bearerTypes.includes(connection.NetBearType.BEARER_WIFI)) {
                    return 'wifiNet';
                } else if (netCapabilities.bearerTypes.includes(connection.NetBearType.BEARER_CELLULAR)) {
                    return 'cellularNet';
                } else {
                    return 'otherNet';
                }
            } else {
                return 'noNet';
            }
        } catch (e) {
            HiLog.e(TAG, `getNetCapabilities: failed, error: ${JSON.stringify(e.message)}`);
            return 'noNet';
        }
    }

    rcsLoggedIn(): void {
        HiLog.i(TAG, 'onRcsStateChange Invoking');
        //设置中RCS开关是否打开
        let isRcsSetting: boolean = SharedPreferencesUtils.getFromPreferences('isUIOpenRcs', '') as boolean;
        RcsLoginUtil.getInstance().getRcsLoggedInTaskPool(isRcsSetting, (res: LooseObject) => {
            if (this.getNetConnectType() === 'noNet') {
                HiLog.i(TAG, 'isOnlineRcs is no onlineAble isRcsOpen: ' + res);
                AppStorage.setOrCreate('isOnlineRcs', false);
                return;
            }
            HiLog.i(TAG, 'isOnlineRcs isRcsOpen: ' + res);
            AppStorage.setOrCreate('isOnlineRcs', res);
        })
    }
    // rcsOn(cb: (message:rcs.RcsEvent) => void): Promise<void> {
    //     return new Promise((resolved, reject:Function) => {
    //         try {
    //             rcs.on('loginStatusChanged', cb);
    //         }catch (error) {
    //             HiLog.e(TAG, 'loginStatusChanged error: ' + JSON.stringify(error));
    //         }
    //         resolved();
    //     });
    // }

  async updateUIRcs(msgId: string, isSendOk:boolean, sendStatus: number,
                updateItemCallBack?: (item: mmsListType) => Promise<void>): Promise<void> {
        HiLog.iw(TAG, 'updateUIRcs: updateUIRead' + 'isSendOk:' + isSendOk)
        if (this.mmsList == undefined) {
            HiLog.e(TAG, 'updateUIRcs Error, mmsList:' + JSON.stringify(this.mmsList));
            return;
        }
        try {
            let length: number = this.mmsList.length;
            if (length > 0) {
                let index = -1;
                for (let i = length - 1; i >= 0; i--) {
                    if (this.mmsList[i]?.id === msgId) {
                        index = i
                        break;
                    }
                }
                let rcsItem: mmsListType = this.mmsList[(index !== -1) ? index : (length - 1)];
                this.mmsList.forEach(item => {
                    this.updateUIStateRcs(item, msgId, isSendOk, rcsItem, sendStatus)
                })
                if (updateItemCallBack) {
                    await updateItemCallBack(rcsItem);
                }
                this.resetItem(rcsItem);
                ConversationDataSource.getInstance().refresh(this.mmsList);
            }
        } catch (error) {
            HiLog.e(TAG, `updateUIRcs: ` + JSON.stringify(error));
        }
    }

  receiveOkEventSubscribeCallback(err: BusinessError, data: commonEvent.CommonEventData) {
    if (err) {
      HiLog.e(TAG, `receiveOkReceiveEvent subscribe failed, code is ${err.code}, message is ${err.message}`);
      return;
    }
    if (!data || !data.data) {
      HiLog.e(TAG, 'receiveOkReceiveEvent subscribe failed, data or data.data is null');
      return;
    }

    this.updateUIRcs(data.data, true, common.int.SEND_MESSAGE_SUCCESS, async (item: mmsListType) => {
      if (!item?.mmsSource || item.mmsSource.length === 0) {
        return;
      }

      if (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE) {
        const context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
        this.checkRcsImageFaceDetect(item.id as string, context);
        const temp = item.mmsSource.find((v) => (v.type === commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE));
        if (temp?.path) {
          const mapKeyToPixelMap = EnhancedInfoTemporaryDataSource.getInstance()?.mapKeyToPixelMap;
          const oldPixelMap = mapKeyToPixelMap?.get(temp.path);
          if (oldPixelMap) {
            oldPixelMap.release();
            mapKeyToPixelMap.delete(temp.path);
          }
        }
      } else if (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
        let thumbnailItem: Mms | undefined = undefined;
        let originItem: Mms | undefined = undefined;
        for (let value of item.mmsSource) {
          if (value.type === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO_THUMBNAIL) {
            thumbnailItem = value;
          } else if (value.type === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
            originItem = value;
          }
        }

        const isExistOriginVideoFile = Boolean(originItem?.path && fs.accessSync(originItem.path));
        HiLog.i(TAG, 'receiveOkEventSubscribeCallback: isExistOriginVideoFile: ' + isExistOriginVideoFile);
        if (thumbnailItem?.path && isExistOriginVideoFile) {
          await this.generateLocalThumbnailForDisplay((originItem as Mms).path, thumbnailItem.path);
        }
      }
    });
  }

    private async checkRcsImageFaceDetect(msgId: string, context: Context) {
        let faceDetectStatus = SharedPreferencesUtils.getFromPreferences('spamshield_message_live_detection', 0) as number;
        if (faceDetectStatus == 0) {
            return;
        }
        // 查询rcs_info获取rcs_id
        ConversationRcsService.getInstance().queryRcsIdByMsgId(msgId, (result: LooseObject) => {
            if (result && result.length > 0) {
                for (let i = 0; i < result.length; i++) {
                    let actionData: LooseObject = {};
                    actionData.rcsId = result[i].rcsId;
                    ConversationService.getInstance().queryMmsPartInfo(actionData, async (partResult: LooseObject) => {
                        if (partResult && partResult.length > 0) {
                            for (let j = 0; j < partResult.length; j ++) {
                                let locationPath = partResult[i].locationPath as string;
                                    await AiFaceChangeUtils.getInstance().startAiFaceChange(locationPath, partResult[i].mmsPartId, (fraudResult, fileId)=> {
                                        let isFraud = AiFaceChangeUtils.getInstance().getDetectionResult(fraudResult);
                                        HiLog.i(TAG, 'shike isFraud no temp: ' + isFraud +'fileId: ' + fileId);
                                        if (isFraud) {
                                            ConversationService.getInstance().updateMmsPartById(fileId, 1, () => {}, context);
                                            this.mmsList[this.mmsList.length - 1].mmsSource[0].isFraud = 1;
                                            ConversationDataSource.getInstance().refresh(this.mmsList);
                                        }
                                    })
                            }
                            AiFaceChangeUtils.getInstance().finalizeModel();
                        }
                    }, context)
                }
            }
        }, context);
    }

    receiveOkReceiveEvent() {
        HiLog.iw(TAG, 'receiveOkReceiveEvent');
        const commonEventSubscribeInfoData: commonEvent.CommonEventSubscribeInfo = {
            events: [common.STR.RCS_RECEIVE_FILE_OK],
            publisherBundleName: common.STR.BUNDLE_NAME, // 这里校验包名即可，短信包名不能被卸载仿冒
        };
        let subscriber: commonEvent.CommonEventSubscriber;
        try {
            subscriber = commonEvent.createSubscriberSync(commonEventSubscribeInfoData);
            HiLog.iw(TAG, 'receiveCancelReceiveEvent: createSubscriberSync success');
            this.receiveOkEventSubscriber = subscriber;
            commonEvent.subscribe(this.receiveOkEventSubscriber, (err, data) => {
              this.receiveOkEventSubscribeCallback(err, data);
            })
        } catch (error) {
            let err: BusinessError = error as BusinessError;
            HiLog.e(TAG, `receiveOkReceiveEvent createSubscriberSync failed, code is ${err?.code}, message is ${err?.message}`);
        }
    }

    receiveCancelReceiveEvent() {
        HiLog.iw(TAG, 'receiveCancelReceiveEvent');
        const commonEventSubscribeInfoData: commonEvent.CommonEventSubscribeInfo = {
            events: [common.STR.RCS_RECEIVE_FILE_CANCEL],
            publisherBundleName: common.STR.BUNDLE_NAME, // 这里校验包名即可，短信包名不能被卸载仿冒
        };
        let subscriber: commonEvent.CommonEventSubscriber;
        try {
            subscriber = commonEvent.createSubscriberSync(commonEventSubscribeInfoData);
            this.receiveCancelEventSubscriber = subscriber;
            commonEvent.subscribe(this.receiveCancelEventSubscriber, (err, data) => {
                if (err) {
                    HiLog.e(TAG, `receiveCancelReceiveEvent subscribe failed, code is ${err.code}, message is ${err.message}`);
                    return;
                }
                if (!data || !data.data) {
                    HiLog.e(TAG, 'receiveCancelReceiveEvent subscribe failed, data or data.data is null');
                    return;
                }
                HiLog.iw(TAG, 'receiveCancelReceiveEvent subscribe callback data');
                this.updateMmsListItemStatusOfRcs(data.data, common.int.RCS_RECEIVING_CANCEL, data.parameters?.cancelValue);
                ConversationDataSource.getInstance().refresh(this.mmsList);
            })
        } catch (error) {
            let err: BusinessError = error as BusinessError;
            HiLog.e(TAG, `receiveCancelReceiveEvent createSubscriberSync failed, code is ${err?.code}, message is ${err?.message}`);
        }
    }

    processReceiveEvent() {
        HiLog.iw(TAG, 'processReceiveEvent');
        const commonEventSubscribeInfoData: commonEvent.CommonEventSubscribeInfo = {
            events: [common.STR.RCS_SUBSCRIBER_FILE_PROGRESS_EVENT],
            publisherBundleName: common.STR.BUNDLE_NAME, // 这里校验包名即可，短信包名不能被卸载仿冒
        };
        let subscriber: commonEvent.CommonEventSubscriber;
        try {
            subscriber = commonEvent.createSubscriberSync(commonEventSubscribeInfoData);
            HiLog.iw(TAG, 'processReceiveEvent: createSubscriberSync success');
            this.processEventSubscriber = subscriber;
            this.processReceiveEventPart();
        } catch (error) {
            let err: BusinessError = error as BusinessError;
            HiLog.e(TAG, `processReceiveEvent createSubscriberSync failed, code is ${err?.code}, message is ${err?.message}`);
        }
    }

    private processReceiveEventPart() {
        commonEvent.subscribe(this.processEventSubscriber, (err, data) => {
            HiLog.iw(TAG, `processReceiveEventPart: listen to the event release.`);
            if (err) {
                HiLog.e(TAG, `processReceiveEvent subscribe failed, code is ${err.code}, message is ${err.message}`);
                return;
            }
            if (!data || !data.data) {
                HiLog.e(TAG, 'processReceiveEvent subscribe failed, data or data.data is null');
                return;
            }
            let isExistInfoInRcsInfoWithMsgId = Boolean(data.parameters?.isExistInfoInRcsInfoWithMsgId);
            this.processReceiveEventPartNext(isExistInfoInRcsInfoWithMsgId, data.data,
                data.parameters?.type, data.parameters?.clurSize, data.parameters?.totalSize);
            EnhancedInfoTemporaryDataSource.getInstance().mapImageMsgIdToData.set(data.data as string, {
                clurSize: data.parameters?.clurSize || 0,
                totalSize: data.parameters?.totalSize || 0,
                isExistInfoInRcsInfoWithMsgId: isExistInfoInRcsInfoWithMsgId
            });
        });
    }

    public processReceiveEventPartNext(isExistInfoInRcsInfoWithMsgId: boolean, dataData: string,
        dataType?: string, clurSize?: number, totalSize?: number) {
        if (!isExistInfoInRcsInfoWithMsgId) {
            return
        }

        let msgId: string = dataData;
        let sendStatus: number = dataType === 'receive' ? common.int.RCS_RECEIVING : common.int.SEND_MESSAGE_SENDING;
        let mmsList = this.mmsList;
        let mmsListLength: number = mmsList.length;
        if (!mmsList || mmsListLength === 0) {
            HiLog.e(TAG, 'processReceiveEventPartNext error, mmsList is empty');
            return;
        }
        let num = mmsList.filter(item => {
            return item.id === msgId
        }).length
        let index = 0
        if (num === 2) { //判断是否是发送跟接收，接收时msgId一样的有两个，num为2
           index = mmsList.findIndex((item) => {
                return (item && item.id === msgId && item.isReceive);
            })
        } else {
            index = mmsList.findIndex((item) => {
                return (item && item.id === msgId);
            })
        }

        if (index === -1) {
            return;
        }
        let rcsItem: mmsListType = this.mmsList[index];
        rcsItem.sendStatus = sendStatus;
        rcsItem.clurSize = clurSize || 0;
        rcsItem.totalSize = totalSize || 0;
        if (dataType === 'receive') {
            this.resetItem(rcsItem, true);
        }
    }

  updateMmsListItemStatusOfRcs(msgId: string, messageStatus: number, cancelValue?: boolean) {
    let mmsListItem: mmsListType | undefined = this.findMmsListItemByMsgIdOfRcs(msgId, cancelValue);
    if (!mmsListItem) {
      return;
    }
    mmsListItem.sendStatus = messageStatus;
    this.resetItem(mmsListItem);
  }

  findMmsListItemByMsgIdOfRcs(msgId: string, cancelValue?: boolean): mmsListType | undefined {
    let mmsList = this.mmsList;
    let mmsListLength: number = mmsList.length;
    if (!mmsList || mmsListLength === 0) {
      HiLog.w(TAG, 'findMmsListItemOfRcs: mmsList is empty');
      return;
    }
    let newListArr: mmsListType[] = [];
    for (let index = 0; index < mmsList.length; index++) {
        if (mmsList[index].id === msgId) {
            newListArr.push(mmsList[index]);
        }
    }
      let index = newListArr.findIndex((item) => {
          if (newListArr.length === 1) {
              return (item && item.id === msgId);
          } else {
              if (cancelValue) {
                  return (item && item.id === msgId && item.isReceive);
              } else {
                  return (item && item.id === msgId && !item.isReceive);
              }
          }
      })
      if (index === -1) {
          return;
      }
    return newListArr[index];
  }

  findMmsListItemByRcsIdOfRcs(rcsId: number | undefined): mmsListType | undefined {
    if (!rcsId) {
      return
    }
    let mmsList = this.mmsList;
    let mmsListLength: number = mmsList.length;
    if (!mmsList || mmsListLength === 0) {
      HiLog.w(TAG, 'findMmsListItemOfRcs: mmsList is empty');
      return;
    }
    let index = mmsList.findIndex((item) => {
      return (item && item.rcsId === rcsId);
    })
    if (index === -1) {
      return;
    }
    return mmsList[index];
  }

  unsubscribeProcessEventSubscriber() {
        if (!this.processEventSubscriber) {
            return;
        }
        try {
            commonEvent.unsubscribe(this.processEventSubscriber, (err: BusinessError) => {
                if (err) {
                    HiLog.e(TAG,
                        `unsubscribeProcessEventSubscriber failed, code is ${err.code}, message is ${err.message}`);
                } else {
                    HiLog.i(TAG, 'unsubscribeProcessEventSubscriber success');
                    this.processEventSubscriber = null;
                }
            });
        } catch (error) {
            let err: BusinessError = error as BusinessError;
            HiLog.e(TAG,
                `unsubscribeProcessEventSubscriber failed, code is ${err.code}, message is ${err.message}`);
        }
  }
    /**
     * 取消订阅"增强信息发送消息发送成功"公共事件
     */
    public unsubscribeSendOKEventSubscriber = (sendOKEventSubscriber: commonEvent.CommonEventSubscriber | null,
        setSendOKEventSubscriber: (data: commonEvent.CommonEventSubscriber | null) => void) => {
        if (!sendOKEventSubscriber) {
            HiLog.e(TAG, 'unsubscribeSendOKEventSubscriber: sendOKEventSubscriber empty');
            return;
        }
        try {
            commonEvent.unsubscribe(sendOKEventSubscriber, (err: BusinessError) => {
                if (err) {
                    HiLog.e(TAG,
                        `unsubscribeSendOKEventSubscriber failed, code is ${err.code}, message is ${err.message}`);
                } else {
                    HiLog.i(TAG, 'unsubscribeSendOKEventSubscriber success');
                    setSendOKEventSubscriber(null);
                }
            });
        } catch (error) {
            let err: BusinessError = error as BusinessError;
            HiLog.e(TAG,
                `unsubscribeSendOKEventSubscriber failed, code is ${err.code}, message is ${err.message}`);
        }
    }

    unsubscribeReceiveOkEventSubscriber() {
        if (this.receiveOkEventSubscriber === null) {
            return;
        }
        try {
            commonEvent.unsubscribe(this.receiveOkEventSubscriber, (err: BusinessError) => {
                if (err) {
                    HiLog.e(TAG,
                        `unsubscribereceiveOkEventSubscriber failed, code is ${err.code}, message is ${err.message}`);
                } else {
                    HiLog.i(TAG, 'unsubscribereceiveOkEventSubscriber success');
                    this.receiveOkEventSubscriber = null;
                }
            });
        } catch (error) {
            let err: BusinessError = error as BusinessError;
            HiLog.e(TAG,
                `unsubscribereceiveOkEventSubscriber failed, code is ${err.code}, message is ${err.message}`);
        }
    }

    unsubscribeReceiveCancelEventSubscriber() {
        if (this.receiveCancelEventSubscriber === null) {
            return
        }
        try {
            commonEvent.unsubscribe(this.receiveCancelEventSubscriber, (err: BusinessError) => {
                if (err) {
                    HiLog.e(TAG,
                        `unsubscribeReceiveCancelEventSubscriber failed, code is ${err.code}, message is ${err.message}`);
                } else {
                    HiLog.i(TAG, 'unsubscribeReceiveCancelEventSubscriber success');
                    this.receiveCancelEventSubscriber = null;
                }
            });
        } catch (error) {
            let err: BusinessError = error as BusinessError;
            HiLog.e(TAG,
                `unsubscribeReceiveCancelEventSubscriber failed, code is ${err.code}, message is ${err.message}`);
        }
    }
    unsubscribeFailEventSubscriber() {
        if (!this.failEventData) {
            return
        }
        try {
            commonEvent.unsubscribe(this.failEventData, (err: BusinessError) => {
                if (err) {
                    HiLog.e(TAG,
                        `unsubscribeFailEventSubscriber failed, code is ${err.code}, message is ${err.message}`);
                } else {
                    HiLog.i(TAG, 'unsubscribeFailEventSubscriber success');
                    this.failEventData = null;
                }
            });
        } catch (error) {
            let err: BusinessError = error as BusinessError;
            HiLog.e(TAG,
                `unsubscribeFailEventSubscriber failed, code is ${err.code}, message is ${err.message}`);
        }
    }

    cancelRcsFile(context: Context, msgId: string): void {
        HiLog.i(TAG, 'cancelFileRcs msgId: ' + msgId)
        if (!msgId) {
            HiLog.w(TAG, 'cancelRcsFile msgId is empty');
            return;
        }
        // let params: rcs.RcsFileOptions = {
        //     'msgId': msgId,
        //     'dstFileName': '',
        //     'srcFileName': '',
        //     'fileType': ''
        // };
        // try {
        //     rcs.cancelFile(params);
        // } catch (e) {
        //     HiLog.e(TAG, 'cancelRcsFile rcs.cancelFile fail, error: ' + JSON.stringify(e));
        //     return;
        // }
    }
    checkMmsListCbSelectedItem(mmsList: mmsListType[]) {
        let cbSelectedItemOfMmsList = mmsList?.filter(v => {
            return v.isCbChecked === true;
        });
        //check Only one selected
        if (!cbSelectedItemOfMmsList || cbSelectedItemOfMmsList.length !== 1) {
            return;
        }
        //check item is Msm
        if (cbSelectedItemOfMmsList[0].isMsm === false) {
            return;
        }
        return cbSelectedItemOfMmsList[0];
    }
    updateUIStateRcs(item :mmsListType, msgId: string, isSendOk:boolean, rcsItem:mmsListType, sendStatus: number) {
        if (item.id == msgId) {
            if (isSendOk) {
                if (sendStatus === common.int.SEND_MESSAGE_READ) {
                    item.sendStatus = common.int.SEND_MESSAGE_READ;
                } else if (sendStatus === common.int.RCS_SEND_OK) {
                    item.sendStatus = sendStatus;
                } else if (sendStatus === common.int.RCS_RECEIVING_CANCEL) {
                    item.sendStatus = sendStatus;
                } else {
                    item.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
                }
                rcsItem = item;
            } else {
                item.sendStatus = sendStatus;
                rcsItem = item;
            }
        }
    }


    // networkStatusChangedOn(cb: (message:rcs.RcsEvent) => void): Promise<void> {
    //     return new Promise((resolved, reject:Function) => {
    //         // try {
    //         //     rcs.on('networkStatusChanged', cb);
    //         // }catch (error) {
    //         //     HiLog.e(TAG, 'networkStateChanged error: ' + JSON.stringify(error));
    //         // }
    //         resolved();
    //     });
    // }

    networkStateChange(): void{
        try {
            // this.networkStatusChangedOn(async (message: rcs.RcsEvent) => {
            //     HiLog.i(TAG, 'on message networkStateChange: ' + JSON.stringify(message))
            //     if(message.type == 0 ){
            //         AppStorage.setOrCreate('isOnlineRcs', false);
            //     }
            // });
        }catch(err) {
            HiLog.e(TAG, 'rcsStateChange err: ' + err);
        }
        return;
    }

    rcsStateChange(): void{
        try {
            // this.rcsOn(async (message: rcs.RcsEvent) => {
            //     HiLog.i(TAG, 'on message rcsStateChange: ' + JSON.stringify(message))
            //     if(message.type == 1){
            //         AppStorage.setOrCreate('isOnlineRcs', true);
            //     }else if(message.type == 0){
            //         AppStorage.setOrCreate('isOnlineRcs', false);
            //     }
            // });
        }catch(err) {
            HiLog.e(TAG, 'rcsStateChange err: ' + err);
        }
        return;
    }

    photoFirstNameDeal(strContactsName: string, photoFirstNames?: Array<photoFirstNamesType>,callBack?:Function) {
        // Get first initials
        if (strContactsName !== common.STR.EMPTY_STR && strContactsName.indexOf(',') > -1) {
            this.photoFirstName = common.FIRST_NAME_TYPE.GROUP_SMS;
        } else {
            if(strContactsName !== common.STR.EMPTY_STR && this.reg.test(strContactsName)) {
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
                    this.photoFirstName = common.STR.WHITE_SPACE;
                 }
            } else {
                this.photoFirstName = common.STR.WHITE_SPACE;
            }
            if (photoFirstNames && photoFirstNames.length > 0) {
                let photoObj: photoFirstNamesType = photoFirstNames[0];
                this.portraitColor = photoObj.portraitColor ? photoObj.portraitColor : this.portraitColor;
            }
        }
        if (callBack) {
            callBack(this.photoFirstName,this.portraitColor)
        }
    }

    // Handle invalid phone numbers that contain #, *, and dots in redirection from other applications.
    // Replace them with spaces.
    dealSpecialPhoneNumber() {
        if (!TelephoneUtil.isPhoneNumber(this.strContactsNumber)) {
            this.strContactsNumber = this.replaceCode(this.strContactsNumber);
            this.strContactsNumberFormat = this.replaceCode(this.strContactsNumberFormat);
            if (this.strContactsName != common.STR.EMPTY_STR) {
                this.strContactsName = common.STR.EMPTY_STR;
            }
        }
    }

    replaceCode(str: string) {
        if (str != null && str.length != 0) {
            return str.replace(new RegExp('e|-|#|\\*|\\.', 'g'), common.STR.EMPTY_STR);
        } else {
            return common.STR.EMPTY_STR;
        }
    }

    titleBarCancel() {
        // Cancel button
        this.cancelCheckedAll();
        ConversationDataSource.getInstance().refresh(this.mmsList)
        this.resetSelectData();
    }

    private resetStatus() {
        //重置isJumping，从短信群发会话点击头像进入，防止重复点击
        this.conListCtrl.isJumping = true;
        //重置index
        this.conListCtrl.lastIndex = -1;
        //返回首页，是否需要刷新数据标识位
        GlobalContext.getContext().setObject('backFromConversation', true);
    }

    private resetStatusTwo() {
        //后台期间此会话有新消息时会刷新
        this.isBackHome = true;
        GlobalContext.getContext().setObject('conversationNeedToUpdate', true);
    }

    onBackPress(context: Context, isChatbotConversation: boolean, isDeeplink: boolean) {
        HiLog.iw(TAG, 'onBackPress');
        ConversationListController.getInstance()
            .refreshListForHandleMarkAllAsRead(new Date().getTime(), this.threadId, true);
        //是否从全搜/通知中心进入短信详情的场景的短信标识位
      if (AppStorage.get(commonData.STR.IS_BACK_HOMEPAGE) && !this.isSelectStatus) {
          AppStorage.set(commonData.STR.IS_BACK_HOMEPAGE, false);
          //获取短信标识位，区分全搜/从通知中心进入短信详情的场景
          let clickFromNotification: boolean =
              AppStorage.get('isFromNotificationUseByBackPressOnly') ?? false as boolean;
          //从通知中心进入短信详情的场景
        if (clickFromNotification) {
          //恢复从通知中心进入短信详情的场景的短信标识位
          AppStorage.set('isFromNotificationUseByBackPressOnly', false);
          this.resetStatus();
          this.resetStatusTwo();
          HiLog.iw(TAG, '[onBackPress] clickFromNotification start!');
          return false;
        } else {
            //是否是来自联系人，如果来自联系人，直接返回联系人
            if (AppStorage.get('comeFromContact')) {
                AppStorage.set('comeFromContact', false);
                HiLog.iw(TAG, 'onBackPress isFromContacts!')
            } else {
                //全搜进入短信详情的场景
                HiLog.iw(TAG, '[onBackPress] moveAbilityToBackground start!');
            }
            (context as myCommon.UIAbilityContext).moveAbilityToBackground();
            this.resetStatusTwo();
            return true;
        }
      }

        this.resetStatus();
        HiLog.iw(TAG,
            `onBackPress isSelectStatus: ${this.isSelectStatus}, richMediaCards: ${this.richMediaCards}, audioStatus: ${this.audioStatus}`);
        if (this.isSelectStatus) {
            // Multi-choice status
            this.resetSelectData();
            this.resetMmsCount();
            this.cancelCheckedAll();
            ConversationDataSource.getInstance().refresh(this.mmsList)
            if (this.yOffset != -1) {
                HiLog.i(TAG, 'this.yOffset is :' + this.yOffset)
                let mun: LengthMetrics = new LengthMetrics(-this.yOffset);
                this.scroller.scrollToIndex(this.mmsIndex, false, ScrollAlign.START, {
                    extraOffset:mun
                });
            }
            return true;
        }
        // 保存草稿
        this.saveDraft(context, true, isChatbotConversation, isDeeplink);
        if (isChatbotConversation) {
            if (this.pageInfos && this.pageInfos.getIndexByName('RcsChatbotSearchBarActivity').length > 0) {
                this.pageInfos.popToName('RcsChatbotSearchBarActivity');
                return true
            }
            if (this.pageInfos && this.pageInfos.getIndexByName('RcsHomePageChatbotActivity').length > 0) {
                this.pageInfos.popToName('RcsHomePageChatbotActivity');
            } else if (this.pageInfos && this.pageInfos.getIndexByName('InfoMsg').length > 0) {
                this.pageInfos.popToName('InfoMsg')
            } else {
                this.pageInfos?.clear()
                return false;
            }
        }
        if (AppStorage.get('curBp') as string !== common.STR.DEVICE_MOBILE_PHONE) {
            return false;
        }
        AppStorage.set('selectPhoneNumber', '')
        if (!this.pageInfos) {
            HiLog.iw(TAG, 'this.pageInfos is null');
            return false;
        }
        return true;
    }

    saveDraft(context: Context, state: boolean = true, isChatbotConversation: boolean, isDeeplink: boolean,
        isNeedToSetNull: boolean = true) {
        this.setDraftModel(() => {
            let isRcs = this.isRcsMms ? commonData.WEBVIEW_MENU_ID.REPORT_ID : commonData.WEBVIEW_MENU_ID.SHARE_ID;
            DraftUtils.getInstance().setIsRcsMms(isRcs);
            DraftUtils.getInstance().saveDraft(context, undefined, false, false, true);
            if (state && (!isChatbotConversation || isDeeplink)) {
                this.navPageChange()
            }
            this.pictureCtrl.pictureList.forEach(item => {
                item.pixelMap?.release()
            });
            this.pictureCtrl.pictureList = []
            this.pictureCtrl.pictureDataSource.refresh(this.pictureCtrl.pictureList)
        }, isNeedToSetNull)
    }

    navPageChange() {
        if (this.isBackToIndex) {
            HiLog.i(TAG, 'onBackPress isBackToIndex');
            //router.back({url: 'pages/index'});
            this.pageInfos?.clear();
        } else {
            HiLog.i(TAG, 'pop to infoMsg');
            if (this.pageInfos?.getParamByName('InfoMsg')?.length > 0) {
                // router.back({url: 'pages/infomsg/InfoMsg'});
                HiLog.i(TAG, `pagesInfos has InfoMsg, now pop to infoMsg!`);
                this.pageInfos?.popToName('InfoMsg');
            } else {
                // 对pathInfos可能没有InfoMsg的情况加保护
                HiLog.w(TAG, 'no InfoMsg in pageInfos! ' +
                    ' this.pageInfos:' +
                JSON.stringify(this.pageInfos))
                this.pageInfos?.pushPathByName('InfoMsg', {} as LooseObject)
            }
        }
    }

    removeEmitter(curBp: string) {
        emitter.off(EmitterConstant.EVENT_IN_BLOCKED_LIST);
        emitter.off(EmitterConstant.EVENT_CHANGE_BUBBLE_MODE);
        emitter.off(EmitterConstant.EVENT_SIM_STATE_CHANGE);
        emitter.off(EmitterConstant.EVENT_SLOTID_CHANGE);
        emitter.off(EmitterConstant.EVENT_CHANGE_RCS_ACCEPT_FAIL);
        emitter.off(EmitterConstant.EVENT_RECEIVE_ADD_CONTACT);
        emitter.off(EmitterConstant.EVENT_RECEIVE_IN_CONTACT);
        emitter.off(EmitterConstant.EVENT_CHANGE_MESSAGE_STATUS);
        emitter.off(EmitterConstant.EVENT_CHANGE_ALL_ACTIVE)
        if (curBp === common.STR.DEVICE_MOBILE_PHONE) {
            emitter.off(EmitterConstant.EVENT_CHANGE_NEW_INPUT_STATUS);
        }
        emitter.off(EmitterConstant.EVENT_CONVERSION_IS_SELECT);
    }

    setDraftModel(callback: Function, isNeedToSetNull: boolean = true) {
        if (this.timeoutID >= 0) {
            clearInterval(this.timeoutID)
            this.timeoutID = -1
        }
        if (this.draftModel === null) {
            HiLog.e(TAG, 'draftModel is null')
            callback(true)
            return
        }
        let source: Mms[] = this.mAttachAreaCtrl.mmDisplaySource
        let actionData: Action = this.getDraftActionData(source)
        actionData.isNewMsg = this.isNewMsg
        actionData.telephone = this.strContactsNumber
        actionData.selectContacts = this.getSelectContacts()
        actionData.receiveContactValue = this.receiveContactValue
        this.draftModel.actionData = actionData
        let mmsListLength = this.mmsList.length
        if (mmsListLength > 0) {
            this.draftModel.mmsList = [this.mmsList[mmsListLength - 1]]
        }
        this.draftModel.needDeleteSession.isNeedDelete = mmsListLength === 0 ? true : false
        DraftUtils.getInstance().draftModelArray.push(JSON.parse(JSON.stringify(this.draftModel)))
        if (isNeedToSetNull) {
            this.draftModel = null
            this.resetMmsSource();
            this.release()
        }
        callback(false)
    }

    resetSelectData() {
        this.setSelectStatus(false);
        this.selectDeleteMsgCount = 0;
        PanGestureUtil.refresh()
    }

    getDraftActionData(source: Mms[]): Action {
        let actionData: Action = new Action();
        actionData.slotId = this.slotId;
        actionData.threadId = this.threadId;
        actionData.receiveContactValue = common.STR.EMPTY_STR;
        actionData.selectContacts = [];
        actionData.content = this.textValue;
        actionData.isReceive = false;
        actionData.ownNumber = common.STR.EMPTY_STR;
        actionData.isSender = common.is_sender.NO;
        actionData.hasDraft = common.has_draft.HAVE;
        actionData.hasReport = settingService.judgeIsDeliveryReport(this.isEditMms);
        actionData.isMms = source?.length > 0 || this.isTextAsMms ? true : false;
        actionData.mmsSource = source;
        actionData.groupId = this.draftGroupId;
        actionData.hasAttachment = this.isEditMms ? true : false;
        actionData.isDraft = this.isDraft;
        return actionData;
    }

    private getSelectContactsLength(): number {
        if (this.selectContactsMap.has(this.threadId)) {
            let retVal = this.selectContactsMap.get(this.threadId) as Array<selectContactType>;
            return retVal != null ? retVal.length : 0;
        }
        return 0;
    }

    public getSelectContacts(): Array<selectContactType> {
        let retVal: selectContactType[] = [];
        if (this.selectContactsMap.has(this.threadId)) {
            retVal = this.selectContactsMap.get(this.threadId) as Array<selectContactType>;
        } else {
            retVal = [];
        }
        return retVal;
    }

    public setSelectContacts(selectContacts: Array<selectContactType>) {
        this.selectContactsMap.set(this.threadId, selectContacts);
    }

    public clearSelectContacts(isCalledByAboutToDisappear: boolean = false) {
        if (isCalledByAboutToDisappear) {
            if (this.threadId == 0) {
                this.selectContactsMap.set(this.threadId, []);
            }
        } else {
            this.selectContactsMap.set(this.threadId, []);
        }
    }

    cancelCheckedAll() {
        for (let element of this.mmsList) {
            element.isCbChecked = false;
        }
    }

    clickGroupCheckAll() {
        for (let element of this.mmsList) {
            element.isCbChecked = !this.isMessageCheckAll;
        }
        ConversationDataSource.getInstance().refreshList(this.mmsList);
        PanGestureUtil.addFirstSelect(0, true, true, this.mmsList.length)
        if (this.isMessageCheckAll) {
            this.setMessageCheckAll(common.int.CHECKBOX_SELECT_NONE);
        } else {
            this.setMessageCheckAll(common.int.CHECKBOX_SELECT_ALL);
            HiLog.i('clickGroupCheckAll Num', JSON.stringify(this.mmsList.length))
        }
        HiLog.i('clickGroupCheckAll', JSON.stringify(this.isMessageCheckAll))
    }

    mmsFavorite(context: Context) {
        this.mmsList.forEach(item=>{
            if (item.isCbChecked) {
                if (item?.isRcs === common.MESSAGE_TYPE.RCS) {
                    let valueBucket: ValuesBucket = {
                        'is_collect': common.is_collect.FAVORITE,
                    }
                    let actionData: LooseObject = {
                        'rcsId': item.rcsId,
                    }
                    ConversationRcsService.getInstance()
                        .updateRcsReceivedMmsInfoByRcsId(context, actionData, valueBucket, null);
                    let conversationModel = new ConversationModel();
                    let valueBucketMms: ValuesBucket = {
                        'is_collect': common.is_collect.FAVORITE,
                    }
                    let actionDataMms: LooseObject = {
                        'rcsId': item.rcsId,
                    }
                    conversationModel.updateSmsMmsInfoByRcsID(actionDataMms, valueBucketMms, null, context);
                    if (item.is_collect == false) {
                        ConversationService.getInstance().updateMmsPartByCondition(context, actionData, null);
                        let pathItem: LooseObject | null = null;
                        ConversationService.getInstance()
                            .queryMmsInfoByFavoriteCondition(context, actionDataMms, (result: LooseObject) => {
                                if (result.code === common.int.SUCCESS && result.abilityResult != null) {
                                    // let vCard: number = result.abilityResult.findIndex(data  => data.type === common.MM_ATTACHMENT_TYPE.VCARD);
                                    // if (vCard !== -1) {
                                    //     result.abilityResult.forEach((item) => {
                                    //         if (item.type && item.type === common.MM_ATTACHMENT_TYPE.VCARD) {
                                    //             pathItem = item; // type = 4,vCard卡片正确显示
                                    //         }
                                    //     })
                                    // } else {
                                    //     pathItem = result.abilityResult[result.abilityResult.length -1]
                                    // }
                                } else {
                                    HiLog.e(TAG, '[mmsFavorite] queryMmsInfoByFavoriteCondition fail');
                                }
                                this.handleQueryAndInsertRcsFavorite(context, actionData, pathItem, item);
                            })
                    } else {
                        promptAction.showToast({
                            message: $r('app.string.info_has_been_stared'),
                            duration: 2000
                        })
                    }
                }
                else {
                    let valueBucket: ValuesBucket = {
                        'is_collect': common.is_collect.FAVORITE,
                    }
                    let actionData: LooseObject = {
                        'msgId': item.id,
                    }
                    ConversationService.getInstance().updateSmsMmsInfoByCondition(context, actionData, valueBucket, null);
                    if (item.is_collect == false) {
                        ConversationService.getInstance().updateMmsPartByCondition(context, actionData, null);
                        let msgItem1: LooseObject | null = null
                        ConversationService.getInstance()
                            .queryMmsInfoByFavoriteCondition(context, actionData, (result: LooseObject) => {
                                if (result.code === common.int.SUCCESS && result.abilityResult != null) {
                                    // let vCard: number = result.abilityResult.findIndex(data => data.type === common.MM_ATTACHMENT_TYPE.VCARD);
                                    // if (vCard !== -1) {
                                    //     result.abilityResult.forEach((item) =>{
                                    //         if (item.type && item.type === common.MM_ATTACHMENT_TYPE.VCARD) {
                                    //             msgItem1 = item; // type = 4,vCard卡片正确显示
                                    //         }
                                    //     })
                                    // } else {
                                    //     msgItem1 = result.abilityResult[1];
                                    // }
                                } else {
                                    HiLog.e(TAG, '[mmsFavorite] queryMmsInfoByFavoriteCondition fail');
                                }
                                ConversationService.getInstance()
                                    .querySmsMmsInfoByCondition(context, actionData, (result: LooseObject) => {
                                        if (result.code === common.int.SUCCESS && result.abilityResult != null) {
                                            let msgItem: LooseObject = result.abilityResult[0];
                                            // item中的msgtype与数据库中的会偶发性的不一致，导致在查询收藏表的时候会查询失败
                                            let now: Date = new Date();
                                            let valueBucket: ValuesBucket = {
                                                'msg_id': msgItem.msgId,
                                                'receiver_number': msgItem.receiverNumber,
                                                'sender_number': msgItem.senderNumber,
                                                'keep_time': String(now.getTime()), //收藏时间
                                                'start_time': msgItem.startTime, //信息时间
                                                'msg_type': msgItem.msgType,
                                                'sms_type': msgItem.smsType,
                                                'msg_title': msgItem.msgTitle,
                                                'msg_content': msgItem.msgContent,
                                                'session_type': msgItem.sessionType,
                                                'group_id': msgItem.groupId,
                                                'part_type': msgItem1 ? msgItem1.type : '',
                                                'part_location_path': msgItem1 ? msgItem1.locationPath : '',
                                                'recording_time': msgItem1 ? msgItem1.recordingTime : '',
                                                'session_id': msgItem.sessionId,
                                                'is_sender': msgItem.isSender,
                                                'rcs_id': msgItem.rcsId ?? 0,
                                                'detect_res_content': msgItem.detectResContent
                                            }
                                            this.insertMsgFavorite(valueBucket, item, context);
                                        } else {
                                            HiLog.e(TAG, '[mmsFavorite] querySmsMmsInfoByCondition fail');
                                        }
                                    });
                            });
                    } else {
                        promptAction.showToast({
                            message: $r('app.string.info_has_been_stared'),
                            duration: 2000
                        })
                    }
                }
            }
        })
        if (AppStorage.get('isScreenReaderOpen') && this.lastSelectedRow <= this.mmsList.length - 1 &&
            this.lastSelectedRow !== -1) {
            let indexAccessId = this.mmsList[this.lastSelectedRow].id.toString();
            setTimeout(() => {
                AccessibilityUtil.requestFocusForAccessibility(indexAccessId);
            }, 50);
        }
    }

    private handleQueryAndInsertRcsFavorite(context: Context, actionData: LooseObject, pathItem: LooseObject | null,
        item: mmsListType) {
        ConversationService.getInstance()
            .querySmsMmsInfoByCondition(context, actionData, (result: LooseObject) => {
                if (result.code === common.int.SUCCESS && result.abilityResult?.length > 0) {
                    let mmsItem: LooseObject = result.abilityResult[0];
                    ConversationRcsService.getInstance()
                        .queryRcsInfoByCondition(actionData, (rcsResult: LooseObject) => {
                            if (rcsResult.code === common.int.SUCCESS) {
                                let rcsItem: LooseObject = rcsResult.abilityResult[0];
                                let now: Date = new Date();
                                let valueBucket: ValuesBucket = {
                                    'msg_id': mmsItem.msgId,
                                    'receiver_number': rcsItem.receiverNumber,
                                    'sender_number': rcsItem.senderNumber,
                                    'keep_time': String(now.getTime()),
                                    'start_time': mmsItem.startTime,
                                    'msg_type': mmsItem.msgType,
                                    'sms_type': mmsItem.smsType,
                                    'msg_title': rcsItem.msgTitle,
                                    'msg_content': rcsItem.msgContent,
                                    'session_id': mmsItem.sessionId,
                                    'session_type': mmsItem.sessionType,
                                    'group_id': rcsItem.groupId,
                                    'part_type': rcsItem.rcsType,
                                    'part_location_path': pathItem ? pathItem.locationPath : '',
                                    'part_size': pathItem ? pathItem.partSize : '',
                                    'recording_time': pathItem ? pathItem.recordingTime : '',
                                    'is_sender': rcsItem.isSender,
                                    'rcs_id': rcsItem.rcsId,
                                    'detect_res_content': rcsItem.detectResContent
                                };
                                this.insertMsgFavorite(valueBucket, item, context);
                            } else {
                                HiLog.e(TAG, '[mmsFavorite] queryRcsInfoByCondition fail');
                            }
                        }, context);
                } else {
                    HiLog.e(TAG, '[mmsFavorite] querySmsMmsInfoByCondition fail');
                }
            });
    }

    private insertMsgFavorite(valueBucket: ValuesBucket, item: mmsListType, context: Context) {
        let conversationModel: ConversationModel = new ConversationModel();
        conversationModel.insertMsgFavorite(valueBucket, () => {
            item.is_collect = true;
            updateFavorite(this.searchContent);
            promptAction.showToast({
                message: $r('app.string.info_is_stared'),
                duration: 2000
            });
        }, context);
    }

    /**
     * 保存短信的文本识别信息
     */
    saveMmsDetect(context: Context, id: number, detectResContent: string, isRcs: number) {
        let valueBucket: ValuesBucket = {
            'detect_res_content': detectResContent,
        }
        if (isRcs == 0) {
            let actionData: LooseObject = {
                'msgId': id,
            }
            ConversationService.getInstance().updateSmsMmsInfoByCondition(context, actionData, valueBucket, null);
        } else {
            let actionData: LooseObject = {
                'rcsId': id,
            }
            ConversationRcsService.getInstance().updateRcsReceivedMmsInfoByRcsId(context, actionData, valueBucket, null);
        }
    }

    setMessageCheckAll(type: number) {
        HiLog.i(TAG, 'setMessageCheckAll, isSelectStatus=' + this.isSelectStatus);
        if (!this.isSelectStatus) {
            return;
        }
        if (type == common.int.CHECKBOX_SELECT_ALL) {
            HiLog.i(TAG, 'setMessageCheckAll, CHECKBOX_SELECT_ALL');
            this.selectDeleteMsgCount = this.mmsList.length;
            this.isMessageCheckAll = true;
            this.hasReport = false;
            this.judgeOnlyAudio();
            this.judgeRcsFileNotDownload();
            ConversationDataSource.getInstance().selectData(0, true, this.mmsList.length)
        } else if (type == common.int.CHECKBOX_SELECT_NONE) {
            HiLog.i(TAG, 'setMessageCheckAll, CHECKBOX_SELECT_NONE');
            this.selectDeleteMsgCount = 0;
            this.isMessageCheckAll = false;
            this.hasReport = false;
            ConversationDataSource.getInstance().selectList = []
            AppStorage.setOrCreate('conversationSelectNumber', 0)
        } else {
            // The default value is CHECKBOX_SELECT_UNKNOWN. Check whether there is any unselected item.
            HiLog.i(TAG, 'setMessageCheckAll, else');
            this.checkBoxSelectUnknow();
        }
    }

    /**
     * 滑动多选设置全选与单选更多按钮内容
     */
    gesTureListCheckBox(selectDeleteMsgCount: number) {
        if (selectDeleteMsgCount === this.mmsList.length) {
            this.isMessageCheckAll = true
            this.hasReport = false;
        } else if (this.isMessageCheckAll) {
            this.isMessageCheckAll = false
        }
        if (selectDeleteMsgCount == 1) {
            let item: mmsListType = new mmsListType();
            for (let i = 0; i < this.mmsList.length; i++) {
                if (this.mmsList[i].isCbChecked) {
                    item = this.mmsList[i];
                    this.mmsIndex = i;
                    break;
                }
            }
            if (item != null) {
                this.setGroupMoreMenu(item);
            }
        }
    }

    checkBoxSelectUnknow() {
        HiLog.i(TAG, 'checkBoxSelectUnknow, start');
        // The default value is CHECKBOX_SELECT_UNKNOWN. Check whether there is any unselected item.
        this.isMessageCheckAll = true;
        this.selectDeleteMsgCount = 0;
        let countReport = 0;
        for (let element of this.mmsList) {
            if (element.isCbChecked) {
                this.selectDeleteMsgCount++;
                HiLog.i(TAG, 'checkBoxSelectUnknow, isCbChecked:' + this.selectDeleteMsgCount);
            } else if (this.isMessageCheckAll) {
                this.isMessageCheckAll = false;
            }
            if (element.isCbChecked && element.hasReport) {
                countReport++;
                HiLog.i(TAG, 'checkBoxSelectUnknow, countReport:' + countReport);
            }
        }
        if (countReport == 1) {
            this.hasReport = true;
        } else {
            this.hasReport = false;
        }
    }

    listCheckBoxChange(index: number, e: boolean) {
        if (e) {
            this.lastSelectedRow = index;
        }
        // When API 7 is used, the isOn type is not boolean but is of the number type. If the isOn type is displayed,
        // an error may occur.
        let isCheck: string = e === true ? '1' : '0';
        //    this.messageList[index].isCbChecked = isCheck == '1' ? true : false;
        let item: mmsListType = this.mmsList[index];
        item.isCbChecked = isCheck == '1' ? true : false;
        ConversationDataSource.getInstance().selectData(index, item.isCbChecked)
        PanGestureUtil.addFirstSelect(index, item.isCbChecked, true)
        HiLog.iw(TAG, `listCheckBoxChange, isCbChecked=${item.isCbChecked}, index=${index}, mmsIndex=${this.mmsIndex}`);
        this.cbSelectedOnlyOneMsmItemOfMmsList = this.checkMmsListCbSelectedItem(this.mmsList);
        this.hasReport = item.hasReport;
        this.setMessageCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
        if (this.selectDeleteMsgCount == 1) {
            let item: mmsListType = new mmsListType();
            for (let i = 0; i < this.mmsList.length; i++) {
                if (this.mmsList[i].isCbChecked) {
                    item = this.mmsList[i];
                    this.mmsIndex = i;
                    break;
                }
            }
            if (item != null) {
                this.setGroupMoreMenu(item);
            }
        }
        ConversationDataSource.getInstance().refreshList(this.mmsList);
        this.judgeOnlyAudio();
        this.judgeRcsFileNotDownload();
    }

    // Number of selected multimedia messages and enhanced messages
    multiSelectMmsMsg(index: number) {
        if (this.mmsList[index].isCbChecked) {
            if (this.mmsList[index].isMsm) {
                this.mmsCount--;
            }
        } else {
            if (this.mmsList[index].isMsm) {
                this.mmsCount++;
            }
        }
    }

    resetMmsCount() {
        this.mmsCount = 0;
    }

    judgeOnlyAudio() {
        HiLog.i(TAG, 'judgeOnlyAudio');
        this.audioStatus = common.MMS_AUDIO_STATUS.NO_AUDIO;
        this.richMediaCards = common.MMS_AUDIO_STATUS.NO_AUDIO;
        let selectedArr: mmsListType[] = [];
        this.mmsList.forEach((item) => {
            if (item.isCbChecked) {
                selectedArr.push(item);
            }
        });

        let hasAudio: boolean = false;
        let hasOther: boolean = false;
        for (let i = 0; i < selectedArr.length; i++) {
            let item: mmsListType = selectedArr[i];
            if (!item.mmsSource || item.mmsSource.length === 0) {
                hasOther = true;
            } else {
                for (let j = 0; j < item?.mmsSource?.length; j++) {
                    let mms: Mms = item.mmsSource[j];
                  if (mms.type === common.MM_ATTACHMENT_TYPE.AUDIO ||
                    mms.type === common.ENHANCED_INFO_ITEM_TYPE.AUDIO) {
                        if (item.content !== '') {
                            hasOther = true;
                        }
                        hasAudio = true;
                    } else if (mms.type !== common.MM_ATTACHMENT_TYPE.AUDIO &&
                        mms.type !== common.MM_ATTACHMENT_TYPE.SMIL) {
                        hasOther = true;
                    }
                }
            }
            if (hasOther && hasAudio) {
                this.audioStatus = common.MMS_AUDIO_STATUS.HAS_AUDIO;
            } else if (hasOther && !hasAudio) {
                this.audioStatus = common.MMS_AUDIO_STATUS.NO_AUDIO;
                if (item.rcsType === common.ENHANCED_INFO_ITEM_TYPE.CHATBOT_CARD) {
                    this.richMediaCards = common.MMS_AUDIO_STATUS.ONLY_AUDIO;
                }
                HiLog.i(TAG, `judgeOnlyAudio item.rcsType: ${item.rcsType}`);
            } else if (!hasOther) {
                this.audioStatus = common.MMS_AUDIO_STATUS.ONLY_AUDIO;
            }
            HiLog.i(TAG,
                `judgeOnlyAudio hasOther: ${hasOther}, hasAudio: ${hasAudio}, richMediaCards: ${this.richMediaCards}`);
        }
    }

  /**
   * Judge whether the rich media message of Rcs has an original file.
   * The message types processed by this method include FILE, AUDIO_FILE, AUDIO, and VIDEO.
   *
   * @param mmsItem
   */
  judgeTheRcsMsgSourceFileDownloaded(mmsItem: mmsListType) {
    HiLog.i(TAG, 'judgeTheRcsMsgSourceFileDownloaded');
    this.isRcsMsgSourceFileDownloaded = false;
    if (!mmsItem || !mmsItem.isRcs || !mmsItem.mmsSource) {
      return;
    }

    switch (mmsItem.rcsType) {
      case commonData.ENHANCED_INFO_ITEM_TYPE.FILE:
      case commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE:
        if (mmsItem.sendStatus !== commonData.int.RCS_FIRST_RECEIVING &&
          mmsItem.sendStatus !== commonData.int.RCS_RECEIVING) {
          this.isRcsMsgSourceFileDownloaded = true;
        }
        return;
      case commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO:
        this.isRcsMsgSourceFileDownloaded = true;
        return;
      case commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO: {
        try {
          const originItem = mmsItem.mmsSource.find(v => (v.type === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO));
          this.isRcsMsgSourceFileDownloaded = Boolean(originItem?.path && fs.accessSync(originItem.path));
        } catch (e) {
          HiLog.e(TAG, 'judgeTheRcsMsgSourceFileDownloaded VIDEO error: ' + JSON.stringify(e));
          this.isRcsMsgSourceFileDownloaded = false;
        }
        return;
      }
    }
  }

    judgeRcsFileNotDownload() {
        this.hasRcsFileNotDownload = false;
        HiLog.i(TAG, 'judgeRcsFileNotDownload enter');
        let selectedArr: mmsListType[] = [];
        this.mmsList.forEach((item) => {
            if (item.isCbChecked && item.mmsSource && item.mmsSource.length > 0) {
                selectedArr.push(item);
            }
        });
        HiLog.i(TAG, 'judgeRcsFileNotDownload selectedArr length is ' + selectedArr.length);
        for (let i = 0; i < selectedArr.length; i++) {
            let item: mmsListType = selectedArr[i];
            if (!item) {
                continue;
            }
            // let sendStatus = selectedArr[i].sendStatus;
            if (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.FILE ||
                item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE) {
                if (item.sendStatus === commonData.int.RCS_FIRST_RECEIVING ||
                    item.sendStatus === commonData.int.RCS_RECEIVING) {
                    this.hasRcsFileNotDownload = true;
                    break;
                }
            } else if (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
                try {
                    const originItem = item.mmsSource?.find(v => (v.type === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO));
                    this.hasRcsFileNotDownload = !(originItem?.path && fs.accessSync(originItem.path));
                } catch (e) {
                    HiLog.e(TAG, 'judgeTheRcsMsgSourceFileDownloaded VIDEO error: ' + JSON.stringify(e));
                    this.hasRcsFileNotDownload = false;
                }
            }
            if (this.hasRcsFileNotDownload) {
                break;
            }
        }
    }

    setGroupMoreMenu(item: mmsListType) {
        HiLog.i(TAG, 'setGroupMoreMenu');
        if (!item.isMsm) {
            this.hasContent = true;
        } else {
            this.judgeOnlyAudio();
            this.judgeRcsFileNotDownload();
        }
    }

    longPressSelected(context: Context, index: number, jumpPageAfterAnimationEffect?: (type: PageJumpType,
        pageName: string, param: Record<string, number | boolean | string | LooseObject[]>,
        pageInfos: NavPathStack) => void, selectText?: string) {
        switch (index) {
          case 0:
          // duplicating
            this.copyText(selectText);
            break;
          case 1:
          // Forwarding
            this.transmitMsg(context, this.mmsIndex, jumpPageAfterAnimationEffect);
            break;
          case 2:
          // Delete
            this.deleteDialogShow();
            break;
          case 3:
          // Select Text
            this.gotoTextSelect(this.mmsIndex);
            break;
          case 4:
          // more
            this.more();
            break;
          case 5:
          // Save
            this.saveImage(context);
            break;
          case 6:
          // report
            this.reportDialogShow();
            break;
          default:
            break;
        }
    }

    // Initializing Forwarding Data
    initTransmitMeg() {
            if (GlobalContext.getContext().getObject('transmitFlag')) {
            let routerParams: LooseObject = this.pageInfos.getParamByIndex(this.pageInfos.size() - 1) as LooseObject;
            this.threadId = StringUtil.isEmpty(routerParams.threadId) ? 0 : routerParams.threadId;
            this.initCurrentQueryTimeID();
            this.slotId = MmsPreferences.getInstance().getSendMessageSlotId();
            this.strContactsName = routerParams?.strContactsName;
            this.strContactsNumber = routerParams?.strContactsNumber;
            this.strContactsNumberFormat = routerParams?.strContactsNumberFormat;
            this.rawContactId = routerParams?.rawContactId || '';
            this.contactId = routerParams?.contactId || '';
            if (routerParams?.isFromTransmitView) {
                this.isBackToIndex = true;
            }
            this.initNewPageContacts();
        }
    }

    resetData() {
        this.release();
        this.resetSelectData();
        this.isMessageCheckAll = false;
    }

    // Forwarding and sending
    async transmitSend(context: Context) {
        this.resetData();
        if (GlobalContext.getContext().getObject('transmitFlag')) {
            let params: TransmitSourceType = this.pageInfos.getParamByIndex(this.pageInfos.size() - 1) as TransmitSourceType;
            params = this.deleteRcsTypeIfNoSupport(params);
            if (params?.mmsStatus !== common.TRANSMIT_MSG_STATUS.NO_MMS &&
                params?.mmsStatus !== common.TRANSMIT_MSG_STATUS.SHARE_SMS) {
                HiLog.iw(TAG, 'transmit mms-isRcsMms: ' + this.isRcsMms + ';transmit mms-mmsStatus: ' + params?.mmsStatus);
                if (params?.mmsStatus !== common.TRANSMIT_MSG_STATUS.SHARE_MMS) {
                    this.generalTransmitMmsSend(context, params);
                    return
                }
                let mms = params.transmitSource[0].mms
                if (mms[0].type == commonData.MM_ATTACHMENT_TYPE.AUDIO) {
                    let duration = await AudioPlayerService.getInstance().getAudioDuration(mms[0].path);
                    duration = this.formateDuration(duration)
                    mms[0].duration = duration
                }
                params.transmitSource[0].mms = mms
                if (this.isRcsMms) {
                    this.generalTransmitMmsSend(context, params);
                    return
                }
                FileUtil.packingSize(params.transmitSource[0].mms[0].path).then(res => {
                    if (res.size > OperatorConfigUtil.getInstance().getCustMMSSize(commonData.int.MMS_FILE_MAX_SIZE)) {
                        let maxSize: number = OperatorConfigUtil.getInstance().getCustMMSSize(
                            commonData.int.MMS_FILE_MAX_SIZE) / commonData.int.BYTE_CONVERSION_UNIT;
                        let countryId = i18n.System.getSystemRegion();
                        let numberFormat = new intl.NumberFormat(countryId, { style: 'unit', unit: 'kilobyte' });
                        let masxSiseStr = numberFormat.format(maxSize);
                        let msg: Resource = $r('app.string.attachment_failed', masxSiseStr);
                        MmsUtil.showToast({
                            message: msg,
                            duration: 2000
                        });
                        return
                    }
                    this.generalTransmitMmsSend(context, params);
                })
            } else {
                HiLog.iw(TAG, 'transmit sms');
                this.generalTransmitSend(context, params);
            }
        }
    }

    //如果当前卡不支持rcs消息，则从转发的消息里删除rcs类型的消息（只包括文件-FILE、联系人-VCARD、地图-MAP）
    deleteRcsTypeIfNoSupport(params: TransmitSourceType): TransmitSourceType {
        HiLog.i(TAG,'delete not supported message from transmit')
        let isOnlineRcs: boolean = AppStorage.Get('isOnlineRcs') as boolean;
        let mmsList: TransmitInfoType[] = [];
        for (let i = 0; i < params.transmitSource.length; i++) {
            let transmitContent: TransmitInfoType = params.transmitSource[i];
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
                if (this.slotId === this.simSlotId && isOnlineRcs) {
                    mmsList.push(transmitContent)
                } else {
                    HiLog.i(TAG,'has not supported message in transmit content')
                }
            } else {
                mmsList.push(transmitContent)
            }

        }
        if (mmsList.length < params.transmitSource.length) {
            let msg: Resource = $r('app.string.audio_play_error');
            this.showToastRcs({
                message: msg,
                duration: 3000
            });
        }
        params.transmitSource = mmsList;
        return params;
    }

    /*
   * toast 提示
    */
    showToastRcs(options: promptAction.ShowToastOptions) {
        try {
            promptAction.showToast(options);
        } catch (err) {
            HiLog.e(TAG, `showToast error: ${err}`);
        }
    }

    formateDuration (time: string) {
        let duration = Number(time)
        let seconds: string | number = Math.floor((duration / 1000) % 60)
        let minutes: string | number = Math.floor((duration / (1000 * 60)) % 60)
        let hours: string | number = Math.floor((duration / (1000 * 60 * 60)) % 24);
        hours = (hours < 10) ? "0" + hours : hours;
        minutes = (minutes < 10) ? "0" + minutes : minutes;
        seconds = (seconds < 10) ? "0" + seconds : seconds;
        if (duration >= ONE_HOUR_IN_MILLISECOND) {
            return hours + ":" + minutes + ":" + seconds
        } else {
            return minutes + ":" + seconds
        }
    }

    generalTransmitSend(context: Context, params: TransmitSourceType) {
        let transmitSource: TransmitInfoType[] = params?.transmitSource;
        let isSource: boolean = params?.isContainerOriginSource;
        let transmitContent: string = params?.transmitContent;
        this.canSendMessage = false;
        let content: string = common.STR.EMPTY_STR;
        let contents: Array<string> = [];
        if (isSource) {
            let contentLength: number = 0;
            transmitSource.forEach((element: TransmitInfoType, index: number) => {
                contentLength = contentLength + element.content.length;
                if (contentLength > MAXIMUM_LENGTH_OF_CHARACTERS) {
                    content = common.STR.EMPTY_STR;
                }
                if (isSource && element?.info) {
                    content = content + element.info + '\n' + element.content;
                } else {
                    content = content + element.content;
                }
                if (index !== transmitSource.length - 1) {
                    content = content + '\n' + ' ' + '\n';
                }
                if (contents.length === 0 || contentLength > MAXIMUM_LENGTH_OF_CHARACTERS) {
                    contentLength = contentLength > MAXIMUM_LENGTH_OF_CHARACTERS ? element.content.length : contentLength;
                    if (contents.length === 0) {
                        content = transmitContent + '\n' + content;
                    }
                    contents.push(content);
                } else {
                    contents[contents.length - 1] = content;
                }
            });
        } else {
            content = params?.transmitContentDetail;
            contents.push(content);
        }

        let actionData: ActionData = {
            contents: contents,
            mmsSource: []
        };
        this.delayTransmitSend(context, actionData, false);
    }

    delayTransmitSend(context: Context, element: ActionData, isMms: boolean) {
        if (element.contents.length === 0) {
            HiLog.i(TAG, 'delayTransmitSend error');
            return;
        }
        this.queryMessageDetail(context, {
                    isDraft:this.isDraft,
                    currentPage:1,
                    threadId:this.threadId,
                    contactsNum:this.contactsNum,
                    queryTimeID:this.currentQueryTimeID,
                    startIndex: 0
                }, async () => {
            HiLog.i(TAG, 'delayTransmitSend element');
            let firstContent: string = element.contents[0]?.trim();
            if (element.contents.length === 1) {
                HiLog.i(TAG, 'delayTransmitSend contents length is 1');
                await this.sendSms(context, firstContent, isMms, element.mmsSource, false);
            } else {
                // One segment is sent first to prevent a new session.
                // No session ID is generated. Cyclic sending may cause different session IDs in multiple segments.
                HiLog.i(TAG, 'delayTransmitSend segment multiple pieces of information');
                this.sendSms(context, firstContent, isMms, element.mmsSource, false, () => {
                    let lastContents = element.contents.slice(1);
                    lastContents.forEach(content => {
                        this.sendSms(context, content?.trim(), isMms, element.mmsSource, false);
                    })
                });
            }
        });
    }

    generalTransmitMmsSend(context: Context, params: TransmitSourceType) {
        HiLog.i(TAG, 'generalTransmitMmsSend');
        // 获取转发的原消息是rcs还是普通短彩信
        let isOriginalMms: boolean = params?.transmitSource[0].isRcs == 0;
        HiLog.i(TAG, 'original msg is mms: ' + isOriginalMms);
        let transmitSource: TransmitInfoType[] = params?.transmitSource;
        let isSource: boolean = params?.isContainerOriginSource;
        let transmitContent: string = params?.transmitContent;
        let transmitContentDetail: string = params?.transmitContentDetail;
        this.canSendMessage = false;
        let content: string = common.STR.EMPTY_STR;
        let mmsSource: mmsSourceItem[] = [];
        let hasMsg = false;
        transmitSource.forEach((element, index: number) => {
            if (element instanceof Array) {
                if (isSource) {
                    element.forEach((subEle: TransmitInfoType, idx) => {
                        if (subEle?.info) {
                            content = content + subEle.info + '\n' + subEle.content;
                        } else {
                            content = content + subEle.content;
                        }
                        if (idx !== element.length - 1) {
                            content = content + '\n' + ' ' + '\n';
                        }
                        if (!hasMsg) {
                            content = transmitContent + '\n' + content;
                            hasMsg = true;
                        }
                    });
                } else {
                    content = transmitContentDetail[index];
                }
                mmsSource.push({
                    content: content,
                    mms: []
                });
                hasMsg = true;
            } else {
                if (element.content !== common.STR.EMPTY_STR) {
                    mmsSource.push({
                        content: element.content,
                        mms: element.mms,
                        fullMmsSource: element.fullMmsSource,
                        msgTitleTransmit: element?.msgTitleTransmit || '',
                        contentType: element.contentType,
                        smilStr: element.smilStr || ''
                    });
                } else {
                    mmsSource.push({
                        content: '',
                        mms: element.mms,
                        fullMmsSource: element.fullMmsSource,
                        msgTitleTransmit: element?.msgTitleTransmit || '',
                        contentType: element.contentType,
                        smilStr: element.smilStr || ''
                    });
                }
            }
        });
        mmsSource = this.createNewSourcePath(context, mmsSource, isSource, transmitContent, isOriginalMms);
        this.delayTransmitMmsSend(context, mmsSource, isOriginalMms);
    }

    createNewSourcePath(context: Context, mmsSource: mmsSourceItem[], isSource: boolean, transmitContent: string, isOriginalMms?: boolean) {
        mmsSource.forEach((ele, index) => {
            const contentType: number = typeof ele.contentType === 'undefined' ? -1 : ele.contentType;
            let isSlideMms: boolean = MmsUtil.isSlideType(contentType);
            let basePath = '';
            if (isSlideMms) {
                basePath = FileUtil.getSandboxPath(context) + '/' + Date.now() + '_' + index;
                fs.mkdirSync(basePath);
            }
            ele.basePath = basePath;
            if (ele.fullMmsSource?.length) {
                ele.fullMmsSource.forEach(item => {
                    let originName = item.name;
                    if (item.type == commonData.MM_ATTACHMENT_TYPE.IMAGE ||
                        item.type == commonData.MM_ATTACHMENT_TYPE.AUDIO ||
                        item.type == commonData.MM_ATTACHMENT_TYPE.VIDEO ||
                        item.type === commonData.MM_ATTACHMENT_TYPE.VCARD ||
                    ENHANCED_INFO_SUPPORT_FORWARD_FILE_TYPES.has(item.type)) {
                        let uriInfo: transmitUriInfo = {
                            imageUri: item.path,
                            basePath
                        }
                        let path =
                            FileUtil.writeMediaToSandBox(context,
                                (isSlideMms && MmsUtil.isSlideAttach(item.type)) ? uriInfo : item.path,
                                item.type, false, false, true);
                        item.path = path;
                        item.name = FileUtil.getFileName(path)
                    } else if (item.type == commonData.ENHANCED_INFO_ITEM_TYPE.MAP) {
                        let path = FileUtil.writeMediaToSandBox(context, item.path, item.type, false, false, true);
                        item.path = path;
                        item.name = FileUtil.getFileName(path);
                        let accuracy: number = 0;
                        if (item.address) {
                            let arrLocInfo: string = item.address?.name + ';' + item.address?.address;
                            let arrAddressInfo: [LooseObject] = [{
                                'body': arrLocInfo,
                                'longitude': item.address?.longitude.toString(),
                                'latitude': item.address?.latitude.toString(),
                                'accuracy': accuracy.toString(),
                            }];
                            let addressJson: string = JSON.stringify(arrAddressInfo);
                            addressJson = addressJson.slice(1, -1);
                            item.content = addressJson;
                        }
                    } else {
                        this.readFileContent(context, item, basePath, isSource, transmitContent);
                    }

                    if (ele.smilStr) {
                        ele.smilStr = ele.smilStr.replace(originName, item.name)
                    }
                })
            } else if (isOriginalMms) {
                ele.mms.forEach(item => {
                    if (SUPPORT_MMS_TRANSFORM_FORMAT.includes(item.type)) {
                        let path = FileUtil.writeMediaToSandBox(context, item.path, item.type, false, true, true);
                        item.path = path;
                        item.name = FileUtil.getFileName(path)
                    } else {
                        this.readFileContent(context, item);
                    }
                })
            }
        })
        return mmsSource;
    }
    async queryMessageDetailCallBack(context: Context, mmsSource: mmsSourceItem[], isOriginalMms: boolean) {
        let firstContent: mmsSourceItem = mmsSource[0];
        let mms = firstContent.mms as Array<Mms>;
        let msgTitleTransmit = firstContent.msgTitleTransmit || '';
        let isMms = mms.length > 0 || !!msgTitleTransmit;
        if (mmsSource.length === 1) {
            HiLog.i(TAG, 'queryMessageDetailCallBack contents length is 1');
            this.sendSms(context, mmsSource[0], isMms, mms, isOriginalMms);
        } else {
            // One segment is sent first to prevent a new session.
            // No session ID is generated. Cyclic sending may cause different session IDs in multiple segments.
            HiLog.i(TAG, 'queryMessageDetailCallBack segment multiple pieces of information');
            let maxGroupId: null | number = await this.getMaxGroupIdInMmsInfoTable(context);
            let isMaxGroupIdEffective: boolean = (typeof maxGroupId === 'number' && !isNaN(maxGroupId));
            let newGroupIds: number[] = []
            if (isMaxGroupIdEffective) {
                newGroupIds = mmsSource.map((v, i) => ((maxGroupId as number) + i + 1));
            }

            let executionTimes = 0
            this.sendSms(context, mmsSource[0], isMms, mms, isOriginalMms, () => {
                if (executionTimes > 0) {
                    return
                }
                for (let i = 1; i < mmsSource.length; i++) {
                    let mms = mmsSource[i].mms;
                    let msgTitleTransmit = mmsSource[i].msgTitleTransmit || '';
                    let isMms = mms.length > 0 || !!msgTitleTransmit;
                    // 转发多条信息每次调用发送延迟50ms，保证每条消息的插入顺序
                    setTimeout(() => {
                        HiLog.i(TAG, 'multi forward sendMms:' + i);
                        this.sendSms(context, mmsSource[i], isMms, mms, isOriginalMms, undefined, newGroupIds[i]);
                    }, 50 * i)
                }
                executionTimes++
            }, newGroupIds[0]);
        }
    }
    readFileContent(context: Context, item: Mms, basePath?: string, isSource?: boolean, transmitContent?: string) {
        try {
            let str = fs.readTextSync(item.path);
            let result: Record<string, string> = FileUtil.writeTextToSandBox(context, str,
                item.type == commonData.MM_ATTACHMENT_TYPE.SMIL, basePath, isSource, transmitContent);
            item.path = result.path;
            item.name = result.name;
        } catch (e) {
            HiLog.e(TAG, 'readFileContent error');
        }
    }

    delayTransmitMmsSend(context: Context, mmsSource: mmsSourceItem[], isOriginalMms: boolean) {
        if (mmsSource.length === 0) {
            HiLog.i(TAG, 'delayTransmitMmsSend error');
            return;
        }
        this.queryMessageDetail(context, {
                    isDraft:this.isDraft,
                    currentPage:1,
                    threadId:this.threadId,
                    contactsNum:this.contactsNum,
                    queryTimeID:this.currentQueryTimeID,
                    startIndex: 0
        }, () => {
            this.queryMessageDetailCallBack(context, mmsSource, isOriginalMms);
        });
    }

    /**
     * 在转发消息或分享消息给信息应用的场景中发送消息
     * @param context
     * @param contentObj 原始数据源
     * @param isMms
     * @param mmsSource
     * @param isOriginalMms
     * @param callback
     * @param groupId
     * @returns
     */
    async sendSms(context: Context, contentObj: string | mmsSourceItem, isMms: boolean,
                  mmsSource: Array<Mms>, isOriginalMms: boolean,
        callback?: Function, groupId?: number | null): Promise<void> {
        // Sending an SMS Message on a Full-Screen Page
        this.isSendStatus = true;
        let msgTitle = '';
        let basePath = '';
        let content: string = typeof contentObj === 'string' ? contentObj : contentObj.content;
        content = MessageUtil.replaceForLossy7Bit(this.slotId, content, 0, content.length);
        let isMmsMapMessage: boolean = false;
        if (typeof contentObj === 'object') {
            let mmsMapSource = contentObj.mms?.find(v => (v && v.type === commonData.MM_ATTACHMENT_TYPE.MAP));
            if (contentObj.mms.length === 2 && mmsMapSource) { //彩信位置消息，此时彩信位置消息有位置图片和消息文本txt两个附件
                isMmsMapMessage = true;
                contentObj.content = mmsMapSource.content ?? '';
                //若此时彩信位置消息的address为空，可从text属性使用JSON解析出来
                if (!mmsMapSource.address && isObjectJSONString(mmsMapSource.text)) {
                    mmsMapSource.address = JSON.parse(mmsMapSource.text as string);
                }
            } else {
                contentObj.content = content;
            }
            msgTitle = contentObj.msgTitleTransmit || '';
            basePath = contentObj?.basePath || '';
        }
        // Initialize the data to be sent.
        await this.initSendSms(context, contentObj, isMms, mmsSource, isOriginalMms, isMmsMapMessage);
        let actionData: ActionDataType = new ActionDataType();
        actionData.slotId = this.slotId;
        actionData.destinationHost = this.strContactsNumber;
        actionData.contactName = this.strContactsName;
        actionData.content = this.getSendText(context, content, false);
        actionData.isEditMms = isMms;
        actionData.msgTitle = msgTitle;
        actionData.basePath = basePath;
        if (typeof groupId === 'number' && !isNaN(groupId)) {
            actionData.groupId = groupId;
        }
        // 同时转发多条消息时 需要使用sendMsgIndex中mmsListIndex确定此次发送的是列表中那一条，避免取到最后一条
        let sendMsgIndex: SendMsgIndexes = {
            copySourceIndex: -1,
            mmsListIndex: (typeof contentObj === 'object') ? (contentObj.mmsListIndex ?? 0) : (this.mmsList.length - 1)
        }
        HiLog.iw(TAG, `sendSms sendMsgIndex.mmsListIndex is: ${sendMsgIndex.mmsListIndex}`);
        this.sendInterval(context, actionData, this.mmsList, callback, sendMsgIndex);
        HiLog.iw(TAG, 'sendSms send end');
        if (this.isEditMms) {
            this.isEditMms = false;
        }
    }

    shareMmsMessage(target: mmsListType) {
        HiLog.i(TAG, 'shareMmsMessage');
        // let data: systemShare.SharedData | undefined = undefined;
        // let type: number = -1;
        // let path: string = '';
        // let duration: string = '';
        // for (let i = 0; i < target.mmsSource?.length; i++) {
        //     if (target.mmsSource[i].type != 0) {
        //         type = target.mmsSource[i].type;
        //         path = target.mmsSource[i].path;
        //         duration = target.mmsSource[i].duration;
        //         break;
        //     }
        // }
        // if (path == '' || type == -1) {
        //     HiLog.i(TAG, 'shareMmsMessage error');
        //     return;
        // }
        // let uri: string = fileUri.getUriFromPath(path);
        // if (MmsUtil.isAudio(type)) {
        //     HiLog.i(TAG, 'shareMessage type Audio');
        //     data = new systemShare.SharedData({
        //         utd: MmsUtil.getFileUTD(path),
        //         uri: uri,
        //         content: duration
        //     });
        // } else if (MmsUtil.isImage(type)) {
        //     HiLog.i(TAG, 'shareMessage type Image');
        //     data = new systemShare.SharedData({
        //         utd: MmsUtil.getFileUTD(path),
        //         uri: uri
        //     });
        // } else if (MmsUtil.isVideo(type)) {
        //     HiLog.i(TAG, 'shareMessage type video');
        //     data = new systemShare.SharedData({
        //         utd: MmsUtil.getFileUTD(path),
        //         uri:uri
        //     });
        // }
        // return data;
    }

    async shareMessage(context: Context) {
        let  target : mmsListType | undefined = this.mmsList.find((item:mmsListType) => item.isCbChecked === true);
        HiLog.i(TAG, 'shareMessage start share');
        if (target == undefined) {
            HiLog.e(TAG, 'shareMessage error');
            return;
        }
        try {
            // let data: systemShare.SharedData | undefined= undefined;
            // if (target.isMsm) {
            //     data = this.shareMmsMessage(target);
            // } else {
            //     let length = (target.content as string).length;
            //     let desc = context.resourceManager.
            //     getPluralStringValueSync($r('app.plural.share_description').id, length);
            //     data = new systemShare.SharedData({
            //         utd: utd.UniformDataType.PLAIN_TEXT,
            //         content: target.content as string,
            //         description: desc
            //     });
            // }
            // if(data != null) {
            //     HiLog.i(TAG, 'shareMessage add data');
            //     let controller: systemShare.ShareController = new systemShare.ShareController(data);
            //     controller.show(context as myCommon.UIAbilityContext, {
            //         previewMode: systemShare.SharePreviewMode.DETAIL,
            //         selectionMode: systemShare.SelectionMode.SINGLE
            //     });
            // }
        } catch (err) {
            HiLog.i(TAG, `message share` + JSON.stringify(err));
        }
    }

    /**
     *
     * @param context
     * @param contentObj
     * @param isMms
     * @param mmsSource
     * @param isOriginalMms
     * @param isMmsMapMessage 是否是彩信位置消息
     * @returns
     */
    async initSendSms(context: Context, contentObj: string | mmsSourceItem, isMms: boolean, mmsSource: Array<Mms>,
        isOriginalMms: boolean, isMmsMapMessage: boolean):Promise<void> {
        // Obtain the day of the week.
        let content = '';
        let msgTitle = '';
        let contentType: number = -1;
        if (typeof contentObj === 'object') {
            msgTitle = contentObj.msgTitleTransmit || '';
            content = contentObj.content;
            contentType = typeof contentObj.contentType === 'undefined' ? -1 : contentObj.contentType;
        } else {
            content = contentObj as string;
        }
        if (isMms) {
            let smilSource = this.getSmilSource(context, contentObj, mmsSource)
            mmsSource.unshift(smilSource)
        }
        let item: mmsListType = new mmsListType();
        item.date = common.STR.EMPTY_STR;
        item.detailTime = $r('app.string.just');
        item.timeMillisecond = new Date().getTime();
        DateUtil.convertTimeStampToDateWeek(item, false);
        DateUtil.fullDate(item);
        item.content = this.getSendText(context, content, true);
        item.isFullScreenImg = false;
        item.isCbChecked = false;
        item.is_collect = false;
        item.isReceive = false;
        item.sendStatus = this.getMessageSendStatus();
        item.subId = this.slotId;
        item.isMsm = isMms;
        item.isRcs = isOriginalMms? common.MESSAGE_TYPE.SMS_OR_MMS : common.MESSAGE_TYPE.RCS;
        if (item.isRcs) {
            if (isMms) {
              item.rcsType = mmsSource[1].type;
              if (item.rcsType === common.ENHANCED_INFO_ITEM_TYPE.VIDEO_THUMBNAIL) {
                item.rcsType = common.ENHANCED_INFO_ITEM_TYPE.VIDEO;
              }
            } else {
                item.rcsType = common.ENHANCED_INFO_ITEM_TYPE.TEXT;
            }
        }
        this.contactsNum = this.strContactsNumber.split(',').length;
        item.contactsNum = this.contactsNum;
        if (this.contactsNum > 1) {
            item.completeNumber = 0;
            item.failuresNumber = 0;
        }
        item.hasReport = settingService.judgeIsDeliveryReport(item.isMsm);
        item.mmsSource = mmsSource;
        item.contentType = contentType > -1 ? contentType : MmsUtil.getMmsContentType(mmsSource, msgTitle);
        item.msgTitle = msgTitle || '';
        if (isMmsMapMessage) { //彩信位置消息
            item.msgShowType = common.MESSAGE_SHOW_TYPE.MAP;
        }
        HiLog.i(TAG, `initSendSms push item`);
        // 如果没有开rcs并且转发的是普通短信，需要判断一下转发的长度有没有超长，是否需要转彩信
        let canSendMessage = MmsPreferences.getInstance().haveSimCardReady();
        if (!this.isRcsMms && !item.isMsm && canSendMessage) {
            HiLog.i(TAG, 'rcs off and transmit sms, need to check content length');
            let needChangeToMms: boolean = await MessageUtil.isMmsText(item.content);
            if (needChangeToMms) {
                item.isRcs = 0;
                item.isMsm = true;
                item.contentType = 2;
                // 添加txt附件
                let textSource: Mms = {
                    duration: '',
                    type: common.MM_ATTACHMENT_TYPE.TEXT,
                    ct: '',
                    path: '',
                    name: '',
                    content: ''
                }
                let textObj: Record<string, string> = FileUtil.writeTextToSandBox(context, item.content, false);
                textSource.path = textObj.path;
                textSource.name = textObj.name;
                item.mmsSource.push(textSource);
                //添加smil
                let smilSource: Mms = MmsUtil.setSmilSource(context, item.content, item.mmsSource);
                item.mmsSource.unshift(smilSource);
            }
        }
        // 收发成功率打点-开始发送 转发、分享(因转发分享的消息类型此处才可以确认且之前步骤均为页面跳转&参数传递)
        // 转发信息时，用原信息中的isrcs判断使用哪种方式发送，而不是根据当前页面的rcs开关,如果原消息为rcs，当前没开rcs，以普通短彩信发送
        if ((this.isRcsMms && item?.isRcs)) {
            DotUtil.getInstance().reportSuccessRateForSendStart(dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_RCS);
        } else {
            DotUtil.getInstance().reportSuccessRateForSendStart(item?.isMsm ?
                dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_MMS :
                dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_SMS);
        }
        this.setDateShow(item, this.mmsList, -1);
        this.setShowTitle(item, this.mmsList);
        this.mmsList.push(item);
        // 同时转发多条消息时 需要确定此次发送的是列表中那一条，避免发送时在sendInterval()取到最后一条
        if (typeof contentObj === 'object') {
            let index = 0;
            for (let i = this.mmsList.length - 1; i >= 0; i--) {
                if (!this.mmsList[i].isReceive) {
                    index = i;
                    break;
                }
            }
            contentObj.mmsListIndex = index;
        }
        ConversationDataSource.getInstance().refresh(this.mmsList);
    }

    isNeedTransmitTip(): boolean {
        let onlyAudioMms: mmsListType | undefined = this.mmsList.find((mms:mmsListType) => {
            if (mms.isMsm && mms.isCbChecked) {
                let mmsArr: Array<Mms> = mms.mmsSource;
                if (mms.mmsSource.length >= 3) {
                    return false
                }
                let audioResource: Mms | undefined = mmsArr.find((source:Mms) => source.type === common.MM_ATTACHMENT_TYPE.AUDIO);
                return audioResource !== undefined
            }
            return false
        });
        return onlyAudioMms !== undefined
    }

    transmitMsg(context: Context, index?: number, jumpPageAfterAnimationEffect?: (type: PageJumpType, pageName: string,
        params: Record<string, number | boolean | string | LooseObject[]>, pageInfos: NavPathStack) => void) {
        let transmitContentList: Array<LooseObject> = [];
        let transmitContentStr: string = '';
        let transmitContentDetail: string = '';
        let selectedArr: mmsListType[] = this.buildSelectedArr(index);
        let mmsNumber: number = 0;
        for (let index = 0; index < selectedArr.length; index++) {
            const element = selectedArr[index];
            if (element.mmsSource?.length > 0) {
                HiLog.i(TAG,
                  'source mms part in db is out of order, resort to ensure smil is at the front and text at the back');
                element.mmsSource.sort((a, b) => { //附件数据重新排序以确保SMIL位于前面，文本位于后面。
                    if (a.type === commonData.MM_ATTACHMENT_TYPE.TEXT) {
                        return 1
                    } else if (b.type === commonData.MM_ATTACHMENT_TYPE.TEXT) {
                        return -1
                    } else {
                        return a.type - b.type
                    }
                });
            }
            if (!element) {
                continue;
            }
            let title: string | Resource = common.STR.EMPTY_STR;
            if (this.strContactsName && this.strContactsName != common.STR.EMPTY_STR) {
                title = this.strContactsName;
            } else {
                title = this.strContactsNumberFormat;
            }
            let transmitContent: Resource | null = null;
            if (selectedArr.length === 1) {
                transmitContent = element.isReceive ? $r('app.string.transmitContentReceive', title) : $r('app.string.transmitContent');
                if (element.isReceive) {
                    transmitContentStr = context.resourceManager.getStringSync(transmitContent, title);
                } else {
                    transmitContentStr = context.resourceManager.getStringSync(transmitContent);
                }
            } else {
                transmitContent = $r('app.string.transmitContentMulti', title);
                transmitContentStr = context.resourceManager.getStringSync(transmitContent, title);
            }
            if (index === 0) {
                transmitContentDetail = element.content as string;
            } else {
                transmitContentDetail = transmitContentDetail + '\n' + ' ' + '\n' + element.content;
            }
            let transmitObj: LooseObject = this.buildTransmitObj(context, selectedArr, element, title, transmitContent);
            transmitContentList.push(transmitObj);
            mmsNumber = this.mmsNumberPlus(element, transmitObj, mmsNumber);
        }
        let mmsStatus: number = 0;
        if (mmsNumber > 0) {
            // mmsNumber === selectedArr.length mean All MMS messages, otherwise Some of them are MMS messages
            mmsNumber === selectedArr.length ?
                mmsStatus = common.TRANSMIT_MSG_STATUS.ALL_MMS : mmsStatus = common.TRANSMIT_MSG_STATUS.HAS_MMS_SMS;
        }
        this.jumpTransmitMsg(transmitContentStr, transmitContentDetail, transmitContentList, mmsStatus,
            jumpPageAfterAnimationEffect);
    }

    private buildTransmitObj(context: Context, selectedArr: mmsListType[], element: mmsListType, title: string,
        transmitContent: Resource) {
        let transmitObj: LooseObject = {};
        if (selectedArr.length > 1) {
            transmitObj.info = this.getTransmitInfo(context, element, title);
        }
        transmitObj.isRcs = element.isRcs;
        transmitObj.content = element.content;
        transmitObj.contactsName = transmitContent;
        transmitObj.isMsm = element.isMsm;
        transmitObj.mms = this.getTransmitSource(element.mmsSource);
        transmitObj.contentInfo = common.STR.EMPTY_STR;
        transmitObj.contentType = element.contentType;
        try {
            if (MmsUtil.isSlideType(element.contentType) && element.mmsSource?.length) {
                const fullMmsSource = MmsUtil.getSmilMmsSourceDelEmptyPar(element.mmsSource);
                const slideData = MmsUtil.generateSlidePreviewData(element.mmsSource);
                transmitObj.msgTitleTransmit = element.msgTitle;
                transmitObj.slideFirstItemTransmit = slideData[0];
                transmitObj.fullMmsSource = fullMmsSource;
                transmitObj.smilStr = fs.readTextSync(element.mmsSource[0].path)
            }
        } catch (e) {
            HiLog.e(TAG, 'readFileContent error');
        }
        return transmitObj;
    }

    buildSelectedArr(index?: number): Array<mmsListType> {
        let selectedArr: mmsListType[] = [];
        if (index != undefined && index >= 0 && this.mmsList.length > index) {
            selectedArr.push(this.mmsList[index]);
        } else {
            this.mmsList.forEach((item) => {
                if (item.isCbChecked) {
                    if (this.audioStatus === common.MMS_AUDIO_STATUS.HAS_AUDIO && item.isMsm) {
                        let mmsArr: Mms[] = item.mmsSource;
                        // If the number of attachments is greater than 3, the attachments can be forwarded.
                        if (mmsArr.length >= 3) {
                            selectedArr.push(item);
                        } else {
                            // only attachment & smil
                            let hasAudio = false;
                            mmsArr.forEach((mms) => {
                                if (mms.type === common.MM_ATTACHMENT_TYPE.AUDIO) {
                                    hasAudio = true;
                                }
                            });
                            if (!hasAudio) {
                                selectedArr.push(item);
                            }
                        }
                    } else {
                        selectedArr.push(item);
                    }
                }
            });
        }
        return selectedArr;
    }

    private mmsNumberPlus(element: mmsListType, transmitObj: LooseObject, mmsNumber: number) {
        if (element.isMsm || (element.isRcs && element.rcsType)) {
            mmsNumber = mmsNumber + 1;
        }
        return mmsNumber;
    }

    getTransmitSource(mmsSource: Array<Mms>) {
        if (!mmsSource || mmsSource.length === 0) {
            return [];
        }
        let source: Array<Mms> = [];
        mmsSource.forEach((item) => {
            if (item.type !== common.MM_ATTACHMENT_TYPE.SMIL) {
                source.push(item);
            }
        });
        return source;
    }

    getTransmitInfo(context: Context, item: mmsListType, title: string) {
        let info: string = '';
        DateUtil.fullDate(item, true);
        let fullDateStr: string = item.fullDate as string;
        let timeOfSmsStr: string = item.timeOfSms as string;
        let timeStr: string = fullDateStr + ' ' + timeOfSmsStr.replace(new RegExp('s', 'ig'),'');
        if (item.isReceive) {
            info = timeStr + ' ' + title + ':';
        } else {
            let me: string = context.resourceManager.getStringSync($r('app.string.me'));
            info = timeStr + ' ' + me + ':';
        }
        return info;
    }

    jumpTransmitMsg(transmitContent: string, transmitContentDetail: string, transmitContentList: LooseObject[],
        mmsStatus: number, jumpPageAfterAnimationEffect?: (type: PageJumpType, pageName: string,
            params: Record<string, number | boolean | string | LooseObject[]>, pageInfos: NavPathStack) => void) {
        HiLog.i(TAG, 'jumpTransmitMsg entry');
        let param: Record<string, number | boolean | string | LooseObject[]> = {
            'threadId': this.threadId,
            'doubleCard': false,
            'transmitContent': transmitContent,
            'transmitContentList': transmitContentList,
            'isMulti': true,
            'mmsStatus': mmsStatus,
            'isMyStartPage': false,
            'transmitContentDetail': transmitContentDetail,
            'isRcs': this.isRcsMms
        }
        if (this.isPC) {
            AppStorage.setOrCreate('isTransmitShow', true);
            AppStorage.setOrCreate('isTransmitSearch', false);
            AppStorage.setOrCreate('transmitParam', param);
        } else {
            if (jumpPageAfterAnimationEffect) {
                jumpPageAfterAnimationEffect(PageJumpType.PUSH_PATH_BY_NAME, 'TransmitMsg', param, this.pageInfos);
            } else {
                this.pageInfos.pushPathByName('TransmitMsg', param);
            }
        }
        HiLog.i(TAG, 'jumpTransmitMsg end');
    }

    // report a dialog box.
    reportDialogShow() {
        this.strMsgReportDialogTip = $r('app.string.msg_report_dialog_con_tip1');
        let item = this.mmsList[this.mmsIndex];
        item.isShowMsgLongMenu = false
        HiLog.i(TAG, 'reportDialogShow, isShowMsgLongMenu=' + item.isShowMsgLongMenu);
        if (!item.isMsm) {
            this.hasContent = true;
            return;
        }
    }

    // Delete a dialog box.
    deleteDialogShow() {
        this.strMsgDeleteDialogTip = $r('app.string.msg_delete_dialog_con_tip1');
        let item = this.mmsList[this.mmsIndex] != null ? this.mmsList[this.mmsIndex] : new mmsListType();
        item.isShowMsgLongMenu = false
        HiLog.i(TAG, 'deleteDialogShow, isShowMsgLongMenu=' + item.isShowMsgLongMenu);
        if (!item.isMsm) {
            this.hasContent = true;
            return;
        }
    }

    favorite(){
        for (let element of this.mmsList) {
            element.isCbChecked = false;
        }
    }

    // more
    more() {
        ConversationDataSource.getInstance().selectList = [] // 每次点击多选，清除已选择列表
        AppStorage.set('VDEisInMore', true);
        this.setTabOperationStatus(false);
        this.distanceBottomFlag = false;
        let item = this.mmsList[this.mmsIndex];
        this.lastSelectedRow = this.mmsIndex;
        // 点击多选后默认勾选
        item.isCbChecked = true;
        this.cbSelectedOnlyOneMsmItemOfMmsList = this.checkMmsListCbSelectedItem(this.mmsList);
        if (item.isCbChecked) {
            if (item.isMsm) {
                this.mmsCount++;
            }
        }

        item.isShowMsgLongMenu = false;
        HiLog.i(TAG, 'more, isShowMsgLongMenu=' + item.isShowMsgLongMenu);
        if (this.mmsList != null) {
            ConversationDataSource.getInstance().refresh(this.mmsList);
        }
        ConversationDataSource.getInstance().selectData(this.mmsIndex, true)
        this.setSelectStatus(true);
        PanGestureUtil.addFirstSelect(this.mmsIndex, item.isCbChecked, true)
        this.hasDetailDelete = false;
        this.setMessageCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
        this.hasReport = item.hasReport;
        this.setGroupMoreMenu(item);
    }

    setTabOperationStatus(flag: boolean) {
        this.isShowMoreOperation = flag;
        // Value type. The HTML page is refreshed only when the value type is numeric.
        if (flag) {
            this.sendBarMarginBottom = common.int.TAB_HEIGHT;
        } else {
            this.sendBarMarginBottom = 0;
        }
    }

    setSelectStatus(isSelect: boolean) {
        this.isSelectStatus = isSelect;
      // 如果是非多选状态下重置richMediaCards为默认状态
      if (!isSelect){
        this.richMediaCards = common.MMS_AUDIO_STATUS.NO_AUDIO;
      }
        // 增加监听，防止初始化时默认contactNum为0误在多收件人时展现“加入黑名单”按钮
        let eventData: emitter.EventData = {
            data: {
                isSelect: isSelect
            }
        }
        HiLog.i(TAG, 'setSelectStatus emit isSelect: ' + isSelect);
        emitter.emit(this.isSelectEVENT, eventData);
    }

    // Event of pressing and holding an SMS message
    mmsListLongPress(index: number, mmsItem?: mmsListType | undefined) {
        for (let i = 0; i < this.mmsList.length; i++) {
            if (index == i) {
                this.mmsList[index].isShowMsgLongMenu = true;
            } else {
                this.mmsList[i].isShowMsgLongMenu = false;
            }
        }
        this.mmsIndex = index;
        if (mmsItem) {
            this.currentMmsItem = mmsItem
        } else {
            this.currentMmsItem = this.mmsList[index]
        }
        HiLog.i(TAG, 'listIndexId: ' + this.mmsList[index]?.id);
        HiLog.i(TAG, 'currentMmsItemId: ' + this.currentMmsItem?.id);
        if (this.isSelectStatus) {
            this.mmsList[index].isCbChecked = !this.mmsList[index].isCbChecked;
            this.setMessageCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
            return;
        }
        this.hasContent = false;
        this.hasImage = false;
        let item = this.mmsList[index];
        let menuId = common.STR.EMPTY_STR;
        if (item?.isMsm) {
            this.setGroupMoreMenu(item);
        } else {
            this.audioStatus = common.MMS_AUDIO_STATUS.NO_AUDIO;
        }
    }

    setNewMessageStatus() {
        if (this.mmsList && this.mmsList.length === 0) {
            this.isNewMsg = true;
            this.rawContactId = '';
            this.contactId = ''
            this.initNewPageContacts();
            this.changeReceiveInputStatus();
        }
    }

    deleteMessageByMsgId(context: Context, id:string,mmsItem?: LooseObject) {
        let actionData: LooseObject = {};
        if(mmsItem?.groupId!=undefined) {
            if(mmsItem?.isRcs===common.MESSAGE_TYPE.RCS) {
                actionData.groupIdRcs = mmsItem?.groupId;
            }
            actionData.groupId = mmsItem?.groupId;
        }
        // Invoke the database deletion method.
        ConversationService.getInstance().deleteSmsMmsInfoByCondition(context, actionData, () => {});
    }

    deleteDialogConfirm(context: Context) {
        hiTraceMeter.startTrace(TraceConstant.TRACE_DEL_MSG, TraceConstant.TRACE_DEL_MSG_ID)
        let groupIds: number[] = [];
        let groupInfos: Array<groupIdsInfos> = [];
        HiLog.i(TAG, 'deleteDialogConfirm, isSelectStatus=' + this.isSelectStatus);
        let lastIndex = ConversationListController.getInstance().lastIndex
        let sum = 1;
        ConversationListController.getInstance().resetLastIndexValue();
        let lastMsgGroupId: number = 0;
        if (this.mmsList && this.mmsList.length > 0) {
            lastMsgGroupId = this.mmsList[this.mmsList.length - 1].groupId;
        }
        this.selectStatusOnDeleteMsg(groupIds, groupInfos, sum);
        hiTraceMeter.finishTrace(TraceConstant.TRACE_DEL_MSG,TraceConstant.TRACE_DEL_MSG_ID)
        this.cancelCheckedAll();
        //只有从搜索进来，记录是否删除了数据
        if (!StringUtil.isEmpty(this.searchContent)) {
            AppStorage.setOrCreate(Constant.IS_DELETE_MESSAGE, true);
        }
        if (groupIds.length > 0) {
            let isFoldNeedRefresh: boolean = groupIds.includes(lastMsgGroupId)
            DraftUtils.getInstance().deleteMessageByGroupIds(groupIds, context, ()=>{},
                groupInfos, undefined, (this.contactsNum > 1));
            // 用setTimeout不让以下逻辑阻塞送显
            setTimeout(() => {
                // 删除完所有会话并且没有文本草稿和彩信草稿时，删除当前会话返回列表
                if (this.mmsList.length === 0 && this.textValue === common.STR.EMPTY_STR &&
                    this.mAttachAreaCtrl.mmDisplaySource.length === 0) {
                    this.updateConversationListAfterDeleteMessageDetail(context, lastIndex, this.threadId);
                } else {
                    // 删除某条会话后需要刷新session列表预览内容（1.非草稿需要更新 2.历史会话删除完有草稿也需要更新）
                    if (!this.isDraft || this.mmsList.length === 0) {
                        this.updateLastItemContent(context, isFoldNeedRefresh);
                    }
                    this.mmsIndex = 0;
                }
            }, 20);
            GlobalContext.getContext().setObject('needToUpdate', true);
        }
        let tempRcsId: number = -1;
        let tempSatellite: number = -1;
        for (let item of this.mmsList) {
            item.showTitle = tempRcsId !== item.isRcs;
            tempRcsId = item.isRcs as number;
        }
    }

    async updateConversationListAfterDeleteMessageDetail(context: Context, lastIndex: number, threadId: number) {
      ConversationListController.getInstance().deleteAction(lastIndex);
      ConversationListController.getInstance().deleteDialogConfirm(context);
      this.deleteMessageById(context, threadId, () => {
          // 从详情返回的刷新延时一会儿，以确保会话删除好了再刷新
          setTimeout(() => {
              this.pageNeedChange();
          }, 200)
      });
    }

    showReportToast(msg: ResourceStr, reportScreenPadding: number) {
        let option: promptAction.ShowToastOptions = {
            message: msg,
            duration: 2000,
            bottom: 80 + reportScreenPadding
        }
        MmsUtil.showToast(option);
    }

    selectStatusOnDeleteMsg(groupIds: number[], groupInfos: Array<groupIdsInfos>, sum: number) {
        let mmsListCopy: mmsListType[] = [];
        if (this.isSelectStatus) {
            // Delete the selected item through the filter.
            let executionTimes = 0
            let mmsListLen = this.mmsList.length
            for (let index = 0; index < this.mmsList.length; index++) {
                let element = this.mmsList[index];
                this.mmsList[index].msgItemIndex = index;
                if (!element.isCbChecked) {
                    this.setDateShow(element, mmsListCopy, -1);
                    mmsListCopy.push(element);
                } else {
                    groupInfos.push({
                        groupId: element.groupId,
                        isRcs: element.isRcs,
                        msgId: element.id,
                        rcsId: element.rcsId,
                        isNeedDeleteSourceFile: true,
                        isCollect: element.is_collect,
                        isMms: element.isMsm
                    });
                    groupIds.push(element.groupId);
                    animateTo({ duration: 100 }, () => {
                        ConversationDataSource.getInstance().deleteByIndex(index);
                    })
                    index--;
                    sum++;
                }
                executionTimes++
                if (executionTimes == mmsListLen) {
                    break
                }
            }
            // Set to non-multi-choice status
            this.resetSelectData();
            this.mmsList = mmsListCopy;
            this.mmsIndex = 0;
        } else if (this.mmsList[this.mmsIndex] != undefined) {
            let item = this.mmsList[this.mmsIndex];
            for (let i = 0; i < this.mmsList.length; i++) {
                this.mmsList[i].msgItemIndex = i;
                if (this.mmsIndex == i) {
                    continue;
                } else {
                    this.setDateShow(this.mmsList[i], mmsListCopy, -1);
                    mmsListCopy.push(this.mmsList[i]);
                }
            }
            this.mmsList = mmsListCopy;
            HiLog.i(TAG, 'selectStatusOnDeleteMsg deleteDialogConfirm, mmsList.length=' + this.mmsList.length);
            groupIds.push(item.groupId);
            groupInfos.push({
                groupId: item.groupId,
                isRcs: item.isRcs,
                msgId: item.id,
                rcsId: item.rcsId,
                isNeedDeleteSourceFile: true,
                isMms: item.isMsm,
                isCollect: item.is_collect
            })
            animateTo({ duration: 200 }, () => {
                ConversationDataSource.getInstance().deleteByIndex(this.mmsIndex);
                //如果在当前会话的短信加载完之前删除，会导致最后少查2个
                this.messageCount--;
                sum++;
            })
        } else {
            HiLog.e(TAG, '[selectStatusOnDeleteMsg] can not handle scene: mmsList.length= ' +
            this.mmsList.length + ' this.mmsIndex = ' + this.mmsIndex);
        }
        setTimeout(()=>{
            ConversationDataSource.getInstance().notifyDataReload();
        }, 100)
    }

    pageNeedChange() {
        let curBp: string = AppStorage.get('curBp') as string;
        GlobalContext.getContext().setObject('backFromConversation', true);
        if (curBp !== common.STR.DEVICE_MOBILE_PHONE) {
            this.resetMmsSource();
            this.draftModel = null;
            if (InfoMsgController.getInstance().total >= 0 || this.isBackToIndex) {
                ConversationListController.getInstance().lastIndex = -1;
                this.pageInfos.pop(false)
                AppStorage.setOrCreate('indexNeedShow', !(AppStorage.get('indexNeedShow') as boolean))
            }
        } else {
            this.pageInfos?.pop();
        }
    }

    async updateLastItemContent(context: Context, isFoldNeedRefresh: boolean = false) {
        let actionData: Record<string, number | number[] | string[] | mmsListType[]> = {
            'mmsList': this.mmsList,
            'threadId': this.threadId
        };
        ConversationListService.getInstance().updateLastItemContent(actionData, () => {
            if (AppStorage.get('curBp') !== common.STR.DEVICE_MOBILE_PHONE && isFoldNeedRefresh) {
                this.conversationListCtr.refreshConversationListData(context)
            }
        }, context);
    }

    deleteMessageById(context: Context, threadId: number, callback?: Function) {
        HiLog.i(TAG, 'deleteMessageById: threadId is ' + threadId);
        let threadIds: number[] = [threadId];
        // Deleting Database Data
        let actionData: Record<string, number[]> = {
            'threadIds': threadIds,
        };
        ConversationListService.getInstance().deleteMessageById(actionData, () => {}, context);
        if (callback) {
            callback();
        }
    }

    clickGroupDelete(selectNumber?: number) {
        if (!selectNumber || selectNumber == 0) {
            return;
        }
        if (selectNumber == 1) {
            this.strMsgDeleteDialogTip = $r('app.string.msg_delete_dialog_con_tip1');
        } else if (selectNumber == this.mmsList.length) {
            this.strMsgDeleteDialogTip = $r('app.string.msg_delete_dialog_con_tip3');
        } else {
            this.strMsgDeleteDialogTip = $r('app.plural.msg_delete_dialog_con_tip2', selectNumber, selectNumber);
        }
    }

    onContactDataChangeObserver(context: Context) {
        if (this.strContactsNumber == undefined || this.strContactsNumber == '') {
            return;
        }
        let actionData: LooseObject = {};
        actionData.telephones = this.strContactsNumber.split(common.STR.COMMA);
        actionData.hasDelete = '0';

        ContactsService.getInstance().queryContactDataByCondition(actionData, (res: AbilityResult) => {
            HiLog.i(TAG, 'onContactDataChangeObserver, callback');
            if (res.code == common.int.FAILURE) {
                return;
            }
            let contacts: Contact[] = res.abilityResult;
            let sessionLists: Array<LooseObject> = [];
            let session: LooseObject = {};
            session.telephone = this.strContactsNumber;
            session.name = this.strContactsName;
            session.contactsNum = this.contactsNum;
            session.telephoneFormat = this.strContactsNumberFormat;
            sessionLists.push(session);

            let conversationListModel =  new ConversationListModel();
            conversationListModel.buildSessionNames(contacts, sessionLists, context);
            const lastContact = sessionLists.pop();
            this.strContactsName = lastContact?.name;
            this.formatStrContactsName = lastContact?.name;
            if (DeviceUtil.isPC()) {
                AppStorage.setOrCreate('isPCPageRefresh', !AppStorage.get('isPCPageRefresh'));
            }
            this.rawContactId = lastContact?.rawContactId;
            this.contactId = lastContact?.contactId;
            this.photoFirstNameDeal(this.strContactsName);
        }, context);
    }

    public querySmsMmsInfoSlotIdByCondition(context: Context, callBack: Function): void {
        let phoneNumber: string = this.strContactsNumber;
        ConversationService.getInstance().querySmsMmsInfoSlotIdByCondition(context, phoneNumber, (res: LooseObject) => {
            callBack(res);
        });
    }
    public queryRcsMmsInfoSlotIdByCondition(context: Context, callBack: Function): void {
        let phoneNumber: string = this.strContactsNumber;
        ConversationRcsService.getInstance().queryRcsInfoSlotIdByCondition(phoneNumber, (res: LooseObject) => {
            callBack(res);
        }, context);
    }

    reReceivedRcsSmsSetTimeOut(context: Context, tmp: number[]) {
        setTimeout(() => {
            this.queryMessageDetail(context, {
                isDraft:this.isDraft,
                currentPage:1,
                threadId:this.threadId,
                contactsNum:this.contactsNum,
                queryTimeID:this.currentQueryTimeID,
                startIndex: 0
            }, () => {
                for (let index = 0; index < tmp.length; index++) {
                    this.mmsList[tmp[index]].isCbChecked = true;
                }
                this.emiterSlotid(this.mmsList[this.mmsList.length - 1].subId);
                ConversationDataSource.getInstance().refresh(this.mmsList);
                this.scroller.scrollEdge(Edge.End);
            });
            if (this.isMessageCheckAll) {
                this.isMessageCheckAll = false;
            }
            let actionData: LooseObject = {};
            actionData.threadId = this.threadId;
            actionData.hasRead = common.is_read.UN_READ;
            HiLog.w(TAG, 'reReceivedRcsSms NotificationService.cancelMessageNotify');
            if (!this.isPageHide) {
                NotificationService.getInstance().cancelMessageNotify(context, actionData, () => {
                    ConversationListService.getInstance().markAllToRead(context, actionData, () => {
                        let badgeContext:IBadgeContextInfo={
                            appContext:context,
                            updateBadgeEventCode:'reReceivedRcsSmsSetTimeOut',
                            tracedId: systemDateTime.getTime().toString(),
                        }
                        NotificationService.getInstance(badgeContext.appContext).updateBadgeNumberWithContext(badgeContext);
                    });
                });
            }
        }, 500);
    }

    public async reReceivedRcsSms(context: Context, reReceivedIndex: number, msgId: string){
        let path = context.filesDir;
        let remainingSpace: number = 0;
        remainingSpace = await statvfs.getFreeSize(path) / common.int.BYTE_CONVERSION_UNIT;
        if (!this.judgmentRemainingSpace(remainingSpace)) {
            return;
        }
        let deleteItem = this.mmsList[reReceivedIndex];
        this.mmsList.splice(reReceivedIndex, 1);
        this.executingDeleteMessageByGroupIds(context, deleteItem);
        let actionData: LooseObject = this.setActionData(deleteItem, msgId);
        ConversationService.getInstance().insertSessionAndDetail(actionData, ((res: LooseObject) => {
            GlobalContext.getContext().setObject('needToUpdate', true)
            let tmp: number[] = [];
            for (let index: number = 0; index < this.mmsList.length; index++) {
                if (this.mmsList[index].isCbChecked) {
                    tmp.push(index);
                }
            }
            // Receiving RCS Updates
            this.reReceivedRcsSmsSetTimeOut(context, tmp);
        }), context);
    }

    private setActionData(deleteItem: mmsListType, msgId: string): LooseObject {
        let actionData: LooseObject = {};
        let sendResults: Array<LooseObject> = [];
        let sendResult: LooseObject = {};
        sendResult.telephone = this.strContactsNumber;
        sendResult.content = deleteItem.failReceiveContext;
        sendResult.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
        sendResults.push(sendResult);
        let hasAttachment: boolean = commonService.judgeIsAttachment(deleteItem.mmsSource);
        actionData.sendResults = sendResults;
        actionData.isReceive = true;
        actionData.ownNumber = common.STR.EMPTY_STR;
        actionData.isSender = true;
        actionData.mmsSource = deleteItem.mmsSource;
        actionData.hasAttachment = hasAttachment;
        actionData.type = commonData.RCS_TYPE.RCS;
        actionData.isSender = 1;
        actionData.msgId = msgId;
        actionData.starttime = new Date().getTime();
        return actionData;
    }

    public executingDeleteMessageByGroupIds(context: Context, deleteItem: mmsListType): void {
        let groupIds = [deleteItem.groupId];
        let groupInfos: Array<groupIdsInfos> = [];
        groupInfos.push({
            groupId: deleteItem.groupId,
            isRcs: deleteItem.isRcs,
            msgId: deleteItem.id,
            rcsId: deleteItem.rcsId,
            // 重新接收RCS消息，
            isNeedDeleteSourceFile: false,
            isMms: deleteItem.isMsm,
            isCollect: deleteItem.is_collect
        });
        DraftUtils.getInstance().deleteMessageByGroupIds(groupIds, context, () =>{}, groupInfos);
    }

    private judgmentRemainingSpace(remainingSpace: number): boolean {
        try{
            HiLog.i(TAG, 'handleRcsReceive remainingSpace: ' + remainingSpace);
            if (remainingSpace < common.int.MMS_ATTACHMENT_UPPER_LIMIT) {
                let innerEvent: emitter.InnerEvent = { eventId: EmitterConstant.EVENT_CHANGE_RCS_ACCEPT_FAIL };
                let eventData: emitter.EventData = {
                    data: {
                        'isShowFailDialog': true,
                    }
                }
                emitter.emit(innerEvent, eventData);
                return false;
            }
        }catch(err) {
            HiLog.e(TAG, 'getFreeSize error: ' + JSON.stringify(err));
            return true;
        };
        return true;
    }

    /*
    * 目的:
    * 本函数对于分页查询位置的数据状态进行修复
    * 背景:
    * 1.分页查询,每页数据的merge时，状态(例如是否显示时间,实现显示彩信还是rcs)可能会出错
    * 2.第一页数据[A,B,C] A默认会显示日期，信息类型:短信/彩信 增强信息
    * 3.第二页数据[F,E,D] F默认会显示日期，彩信类型:短信/彩信 增强信息
    * 4.数据合并[F,E,D,A,B,C]后，需要重新确认A是否需要显示【日期】或者【彩信类型】
    * 核心逻辑：下标从1开始
    * 1.查询完第x页，数据总长度为m
    * 2.第x+1页，数据新增长度为n，数据的总长度为:n+m
    * 3.需要对比第n个数据和n+1个数据的日志和类型是否一样。
    * */
    private dataCorrectionForPagingQuery(mergeIndex: number) {
        if (mergeIndex < 0 || mergeIndex + 1 >= this.mmsList.length) {
            return
        }
        // 是否是同一天的信息
        this.mmsList[mergeIndex + 1].dateShow =
            DateUtil.isNotSameDay(this.mmsList[mergeIndex + 1].timeMillisecond,
                this.mmsList[mergeIndex].timeMillisecond)
        // 是否是同一类型信息：增信信息 短信/彩信 卫星消息 智能信息
        this.mmsList[mergeIndex + 1].showTitle =
            (this.mmsList[mergeIndex + 1].isIpMsg !== this.mmsList[mergeIndex].isIpMsg) ||
            (this.mmsList[mergeIndex + 1].isRcs !== this.mmsList[mergeIndex].isRcs)
    }

  /**
   * Obtain information details.
   *
   * @param callback
   */
  public async queryMessageDetail(context: Context, queryInfoObj: IQueryMessageDetailInfo, callback?: Function,
    isConversation?: boolean): Promise<void> {
    GlobalContext.getContext().setObject('is24HourTime', I18n.System.is24HourClock());
    HiLog.w(TAG, 'start queryMessageDetail , threadId:' + this.threadId + ', queryInfoObj.threadId: ' +
    queryInfoObj.threadId + ',queryInfoObj.queryTimeID: ' + queryInfoObj.queryTimeID);
    if (this.queryTerminate.get(queryInfoObj.threadId) != queryInfoObj.queryTimeID || this.vCardJumpBack) {
      HiLog.i(TAG, `DqueryMessageDetail return queryTerminate: ${queryInfoObj.queryTimeID}`);
      this.vCardJumpBack = false;
      return;
    }
    let actionData: IQueryMsgDetailSizeInfo = { threadId: this.threadId, needDistinct: false };
    /**
     * 如果当前记录的信息总数为空，查询当前会话的信息总数，并写入到session表中
     * queryInfoObj.isDraft,true:当前会话有草稿，false:当前会话无草稿
     * this.messageCount 在页面跳转时就会赋值，暂时未找到进入此条件的场景
     */
    if ((this.messageCount == 0 && !queryInfoObj.isDraft)) {
      HiLog.i(TAG, 'current session msgCount = 0');
      hiTraceMeter.startTrace(TraceConstant.TRACE_QUERY_ALL_INFO_SIZE,
        TraceConstant.TRACE_QUERY_ALL_INFO_SIZE_ID);
      this.messageCount =
        await ConversationService.getInstance().queryAllInfoSizeByCondition(context, actionData);
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_ALL_INFO_SIZE,
        TraceConstant.TRACE_QUERY_ALL_INFO_SIZE_ID);
      this.conListCtrl.saveSessionTotalMsgCount(context, this.threadId, this.messageCount, (res: LooseObject) => {
        if (res.code == common.int.SUCCESS) {
          HiLog.i(TAG, `updateSessionMsgCount success, messageCount: ${this.messageCount}`);
        } else {
          HiLog.w(TAG, 'updateSessionMsgCount fail!');
        }
      });
    }
    queryInfoObj.resultTotal = this.messageCount;
    /**
     * 如果上一次查询的size为空，即第一次查询，会查询当前会话的信息总数
     */
    if (!queryInfoObj.lastListSize) {
      if (this.contactsNum == 1) {
        actionData.contactsNum = 1;
        queryInfoObj.needInitMmsList = true;
        this.messageCount =
          await ConversationService.getInstance().queryAllInfoSizeByCondition(context, actionData);
        if (this.messageCount === 0) {
          onlyStateParam.INFO_PAGE_STATE = 0;
        } else {
          onlyStateParam.INFO_PAGE_STATE = 1;
        }
        DotUtil.getInstance().reportEvent(onlyStateParam, dotCommon.eventName.CLICK_TO_VIEW_SMS_EVENT);
        // 存在草稿时，数据库查询会多一条，在这里减掉此数目
        queryInfoObj.resultTotal = queryInfoObj.isDraft ? --this.messageCount : this.messageCount;
      }
      queryInfoObj.lastListSize = -1;
      queryInfoObj.startIndex = queryInfoObj.resultTotal;
    }
    if (this.contactsNum === 1 && queryInfoObj.needInitMmsList) {
      // 第一次加载时先给list填充空数组
      this.mmsList = new Array(queryInfoObj.resultTotal).fill(new mmsListType());
      this.loadDataOrderModel.initParam(this.searchMsgIndex, queryInfoObj.resultTotal);
      queryInfoObj.needInitMmsList = false;
    }
    let nextInterval: Interval = this.loadDataOrderModel.getNextLoadDataInterval();
    if (this.contactsNum === 1 && nextInterval.start === 0 && nextInterval.start === nextInterval.end) {
      HiLog.e(TAG, ` loadData end.`);
      return;
    }
    let customLimit = nextInterval.end - nextInterval.start;
    // 因为查询会查出草稿，而页面不展示草稿，所以对数据做了偏移，最后一页需要多查一条来补充
    if (nextInterval.end === queryInfoObj.resultTotal && queryInfoObj.isDraft) {
      customLimit++;
    }
    let queryActionData: IQueryMessageDetailAll = {
      actionDataName: Constant.ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL,
      threadId: queryInfoObj.threadId,
      page: queryInfoObj.currentPage,
      contactsNum: queryInfoObj.contactsNum,
      limit: customLimit,
      offset: nextInterval.start,
      isCustomSearch: (this.contactsNum === 1) ? true : false
    };
    (this.contactsNum == 1) ?
    this.queryMessageDetailPreFillItem(context, queryInfoObj, queryActionData, callback, isConversation)
      :
    this.queryMessageDetailWithoutPreFillItem(context, queryInfoObj, queryActionData, callback, isConversation);
  }

    private isSmartQueryFlag(): boolean {
        if (this.contactsNum == 1 && (TelephoneUtil.judgeIsInfoMsg(this.strContactsNumber) ||
        ChatbotUtils.isChatbotNumber(this.strContactsNumber))) {
            return true;
        }
        return false;
    }

    public  queryMessageDetailWithoutPreFillItem(context: Context, queryInfoObj: IQueryMessageDetailInfo, queryActionData: IQueryMessageDetailAll,
        callback?: Function, isConversation?: boolean) {
        HiLog.i(TAG,'[queryMessageDetailWithoutPreFillItem] start')
        ConversationService.getInstance().queryMessageDetailAll(context, queryActionData, (result: LooseObject) => {
            if (result.code == common.int.SUCCESS) {
                if (queryInfoObj.threadId != this.threadId) {
                    HiLog.i(TAG, `not need refresh threadId: ${queryInfoObj.threadId}, this.threadId: ${this.threadId}`);
                    return;
                }
                result = this.dealMessageDetailTime(context, result, isConversation);
                let newMmsListLength = (result as mmsListType[]).length
                if (queryInfoObj.currentPage === 1 && newMmsListLength > 0) {
                    this.mmsList = result as mmsListType[];
                    this.messageTimeout.messageTimeoutProcessing(this.mmsList, this.isDraft, this.threadId, true);
                } else {
                    let newQueryMmsList: mmsListType[] = result as mmsListType[];
                    let mergeIndex: number = newQueryMmsList.length - 1;
                    this.mmsList = newQueryMmsList.concat(this.mmsList);
                    this.dataCorrectionForPagingQuery(mergeIndex);
                }
                HiLog.i(TAG, `1 Detail, this.mmsList.length: ${this.mmsList.length} , total: ${queryInfoObj.resultTotal},
                    this.page: ${queryInfoObj.currentPage}`);
                let lastMsg: mmsListType = this.mmsList[this.mmsList.length - 1];
                AppStorage.setOrCreate('lastMsg', lastMsg);
                ConversationDataSource.getInstance().refresh(this.mmsList);
                if (this.searchMsgId !== common.STR.EMPTY_STR) {
                    this.jumpToIndex(context);
                } else {
                    this.scroller.scrollEdge(Edge.End);
                }
                if (queryInfoObj.lastListSize && queryInfoObj.lastListSize < this.mmsList.length &&
                    newMmsListLength * (queryInfoObj.contactsNum == 0 ? 1 : queryInfoObj.contactsNum) ==
                        StringUtil.getLimitForSmsMmsInfo(queryInfoObj.currentPage, queryInfoObj.contactsNum)) {
                    queryInfoObj.lastListSize = this.mmsList.length;
                    if (newMmsListLength > 0) {
                        queryInfoObj.currentPage++;
                    }
                    setTimeout(() => {
                        this.queryMessageDetail(context, queryInfoObj, callback);
                    }, 200);
                    return;
                }
                this.messageTimeout.messageTimeoutProcessing(this.mmsList, this.isDraft, this.threadId);
                this.page = 1;
                if (this.mmsList.length == 0 && queryInfoObj.isDraft) {
                    HiLog.i(TAG, 'queryMessageDetail, isNewMsg = true');
                    this.isNewMsg = true;
                }
            } else {
                HiLog.w(TAG, 'queryMessageDetail fail! actionData: ' + JSON.stringify(queryActionData));
            }
            if (queryInfoObj.isDraft && !this.draftModel?.isHasSetValueForInitialDraftText) {
                this.setDraft();
            }
            if (callback) {
                callback();
            }
        }, 0);
    }

  private queryMessageDetailPreFillItem(context: Context, queryInfoObj: IQueryMessageDetailInfo,
    queryActionData: IQueryMessageDetailAll,
    callback?: Function, isConversation?: boolean) {
    HiLog.i(TAG, '[queryMessageDetailPreFillItem] start');
    ConversationService.getInstance().queryMessageDetailAll(context, queryActionData, (result: LooseObject) => {
      if (result.code == common.int.SUCCESS) {
        if (queryInfoObj.threadId != this.threadId) {
          HiLog.i(TAG,
            `queryMessageDetailPreFillItem not need refresh threadId: ${queryInfoObj.threadId}, this.threadId: ${this.threadId}`);
          return;
        }
        // 从通知跳转到短信的会话详情页，会执行两次onshow()和一次aboutToAppear(), 会有两次查询，丢弃前一次的。
        if (this.queryTerminate.get(queryInfoObj.threadId) != queryInfoObj.queryTimeID) {
            HiLog.i(TAG, `DqueryMessageDetailPreFillItem return queryTerminate: ${queryInfoObj.queryTimeID},
            queryInfoObj.isDraft: ${queryInfoObj.isDraft}`);
            return;
        }
        result = this.dealMessageDetailTime(context, result, isConversation,
        queryInfoObj.isCallOnInitRequestMessageList);
        let newQueryMmsList: mmsListType[] = result as mmsListType[];
        let totalSize = this.mmsList.length;
        HiLog.i(TAG,
          `queryMessageDetailPreFillItem newLen:${newQueryMmsList.length}, mmsList.len:${this.mmsList.length}`);
        HiLog.i(TAG,
          `queryMessageDetailPreFillItem totalSize:${totalSize}, offset:${queryActionData.offset}, limit:${queryActionData.limit}`);
        // 草稿情况单独处理，整体向前偏移一位
        let start = Math.max(0, (totalSize - (queryActionData?.offset ?? 0) - (queryActionData?.limit ?? 0) +
          (queryInfoObj.isDraft ? 1 : 0)));
        let end = Math.min(totalSize, start + newQueryMmsList.length) - 1;
        HiLog.i(TAG, `queryMessageDetailPreFillItem, start:${start}, end:${end}`);
        this.mmsList.splice(start, newQueryMmsList.length, ...newQueryMmsList);
        this.messageTimeout.messageTimeoutProcessing(this.mmsList, this.isDraft, this.threadId, true);
        // 页查询位置的数据状态进行修复--查询后插入的的start&&end + 1 的位置
        // 考虑到加载机制会首先加载顶部一次及首次进入可能为搜索等不是最新消息开始查询的场景，这里首尾都需要修复
        if (newQueryMmsList?.length > 0) {
            this.dataCorrectionForPagingQuery(start - 1);
            this.dataCorrectionForPagingQuery(end);
        }
        if (queryInfoObj.currentPage <= 1) {
          if (this.searchMsgIndex >= 0) {
            // 搜索跳转场景下进行一次跳转位置校准
            let searchCalibrationIndex = this.mmsList.findIndex((info) => {
              return info && info.id?.toString() === this.searchMsgId;
            });
            let actualSearchMsgIndex = searchCalibrationIndex > -1 ? searchCalibrationIndex : this.searchMsgIndex;
            HiLog.w(TAG,
                `queryMessageDetailPreFillItem searchMsgIndex:${this.searchMsgIndex},actualSearchMsgIndex:${actualSearchMsgIndex},scrollTo searchMsgId:${this.mmsList[actualSearchMsgIndex]?.id},searchMsgId:${this.searchMsgId}`);
            this.scroller.scrollToIndex(actualSearchMsgIndex);
          } else if (!queryInfoObj.notNeedScrollToEnd) {
            HiLog.i(TAG, `queryMessageDetailPreFillItem scrollEdge`);
            this.scroller.scrollEdge(Edge.End);
          } else {
            HiLog.w(TAG, `queryMessageDetailPreFillItem no scroll.`);
          }
        }
        let lastMsg: object = this.mmsList[this.mmsList.length - 1];
        AppStorage.setOrCreate('lastMsg', lastMsg);
        ConversationDataSource.getInstance().refreshPartial(this.mmsList, start, end);
        if (this.loadDataOrderModel.isLoadFinished()) {
          HiLog.w(TAG, ` loadData end.`);
        } else {
          queryInfoObj.lastListSize = this.mmsList.length - start;
          queryInfoObj.startIndex = start;
          if (newQueryMmsList.length > 0) {
            queryInfoObj.currentPage++;
          }
          this.queryMessageDetailAllSmartQuery(context, queryInfoObj, callback);
          return;
        }
        this.page = 1;
        if (this.mmsList.length == 0 && queryInfoObj.isDraft) {
          HiLog.i(TAG, 'queryMessageDetail, isNewMsg = true');
          this.isNewMsg = true;
        }
      } else {
        HiLog.w(TAG, 'queryMessageDetail fail! actionData: ' + JSON.stringify(queryActionData));
      }
      if (queryInfoObj.isDraft && !this.draftModel?.isHasSetValueForInitialDraftText) {
        this.setDraft();
      }
      if (callback) {
        callback();
      }
    }, 0);
  }

  private queryMessageDetailAllSmartQuery(context: Context, queryInfoObj: IQueryMessageDetailInfo,
    callback?: Function) {
    let page: number = queryInfoObj.currentPage ?? 1;
    HiLog.i(TAG, ` queryMessageDetailAllSmartQuery page:${page}`);
    // 前3个批次需要快速展示，后面批次间隔200ms
    setTimeout(() => {
      this.queryMessageDetail(context, queryInfoObj, callback)
    }, (page <= 3 ? 20 : 200));
  }

    private dealMessageDetailTime(context: Context, result: Record<string,mmsListType[]>, isConversation?: boolean,
      isCallOnInitRequestMessageList?: boolean, isNeedRefreshHour?: boolean): Array<LooseObject> {
        let resultList: Array<mmsListType> = [];
        if (result.response && result.response.length > 0) {
            for (let entry of result.response.entries()) {
                let item = entry[1];
                item.timeMillisecond = Number.parseInt(item.timeMillisecond as string);
                // 判断是否仅需要刷新一小时之内的消息
                if (isNeedRefreshHour && !DateUtil.isDateDiffOneHour(item)) {
                    continue;
                }
                DateUtil.fullDate(item);
                DateUtil.convertTimeStampToDateWeek(item, false);
                this.setDateShow(item, resultList, -1);
                DateUtil.convertDateFormatForItem(item);
                if (item.sendStatus == common.int.SEND_DRAFT) {
                    if (!isConversation) {
                        this.dealDraftData(context, item, isCallOnInitRequestMessageList);
                    }
                } else {
                    resultList.push(item);
                }
            }
        }
        return resultList;
    }

    deleteDraftData(context: Context) {
        if (this.isDraft && this.draftGroupId > 0) {
            let groupIds = [this.draftGroupId];
            DraftUtils.getInstance().deleteMessageByGroupIds(groupIds, context, () =>{});
            this.draftGroupId = 0;
        }
        else {
            HiLog.i(TAG, 'this.isDraft:' + JSON.stringify(this.isDraft) + 'this.draftGroupId' + JSON.stringify(this.draftGroupId))
        }
    }

    async deleteDraftDataByThread(context: Context) {
        HiLog.i(TAG, 'deleteDraftDataByThread: threadId is:' + this.threadId);
        let threadIds: number[] = [this.threadId];
        let actionData: Record<string, number | number[]> = {
            'threadIds': threadIds,
            'msgState': commonData.int.SEND_DRAFT,
        };
        ConversationService.getInstance().deleteSmsInfoByCondition(context, actionData, () => {});
    }

    dealDraftData(context: Context, item: mmsListType, isCallOnInitRequestMessageList?: boolean) {
        this.draftContent = item.content as string;
        this.draftGroupId = item.groupId;
        if (item.isMsm) {
            this.isEditMms = true;
            this.hasAttachment = item.mmsSource.length > 0;
            HiLog.i(TAG, 'dealDraftData hasAttachment = ' + this.hasAttachment);
            if (!this.setMMsFlag) {
                this.setMMsFlag = true;
                setTimeout(() => {
                    this.setMmsDataSource(context, item.mmsSource, isCallOnInitRequestMessageList);
                }, 10)
            }
        } else {
            this.isEditMms = false;
        }
    }
    // Set Draft Content
    setDraft() {
        HiLog.i(TAG, 'setDraft, start!');
        // If the content is a draft, the draft content needs to be displayed.
        if (this.isDraft) {
            if (this.draftContent == null || this.draftContent == common.STR.EMPTY_STR) {
                HiLog.i(TAG, 'textValue: ' + this.textValue);
                return;
            }
            if (this.textValue == null || this.textValue == common.STR.EMPTY_STR) {
                this.textValue = this.draftContent;
            }
            this.canSendMessage = MmsPreferences.getInstance().haveSimCardReady();
        }
    }

    updateDetail(context: Context, threadId: number, sendResult: Record<string, string | number | string[]>, sendNumbersLength: number, msgId: string,resendStateIsRcs?:boolean) {
        let actionData: LooseObject = {};
        let sendResults : Array<Object> = [];
        sendResults.push(sendResult);
        actionData.sendResults = sendResults;
        actionData.threadId = threadId;
        let isRcsMmsType :boolean = false;
        if(sendResult.isRcs === common.MESSAGE_TYPE.RCS){
            isRcsMmsType = true;
        }else{
            isRcsMmsType = false;
        }
        ConversationService.getInstance().updateSessionAndDetail(context, isRcsMmsType,actionData, sendNumbersLength, msgId, resendStateIsRcs);
        let sendStatus: number = sendResult.sendStatus as number;
        let deliveryReportSwitch: string = MmsPreferences.getInstance().getValueOfDeliveryReportSwitch();
        HiLog.i(TAG, 'updateDetail, sendStatus=' + sendStatus + ', deliveryReportSwitch=' + deliveryReportSwitch);
        if ((deliveryReportSwitch == common.DELIVERY_REPORTS.SMS_AND_MMS ||
        deliveryReportSwitch == common.DELIVERY_REPORTS.SMS) && sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
            let msg: string = '';
            let phoneNumber: string = sendResult.telephone as string;
            if(sendResult.contactName === common.STR.EMPTY_STR){
                msg = TelephoneUtil.formatDisplayPhoneNum(sendResult.telephone as string) + '';
            } else if (phoneNumber.startsWith('sip')) {
                msg = sendResult.contactName as string;
            } else {
                msg = sendResult.contactName + '<' + TelephoneUtil.formatDisplayPhoneNum(sendResult.telephone as string) + '>'
            }
            let receivedResource: Resource = $r('app.string.message_received', msg)
            let receivedMsg: string = context.resourceManager.getStringSync(receivedResource, msg);
            this.showToast(receivedMsg)
        }
        let tempRcsId: number = -1;
        let tempSatellite: number = -1;
        for (let item of this.mmsList) {
            item.showTitle = (tempRcsId !== item.isRcs);
            tempRcsId = item.isRcs as number;
        }
        if (this.mmsList.length > 0) {
            ConversationDataSource.getInstance().refresh(this.mmsList);
        }
    }

    showToast(msg: ResourceStr) {
        Prompt.showToast({
            message: msg,
            duration: 2000,
        });
    }

    // Setting the Sending Status
    setCanSendMsgStatus() {
        if ((this.receiveContactValue == common.STR.EMPTY_STR && this.getSelectContactsLength() == 0) ||
        (this.textValue == common.STR.EMPTY_STR && !this.isEditMms)) {
            this.canSendMessage = false;
        }
    }

    // Obtains the size of the current MMS file.
    getCurEdtFileSize() {
        this.curEdtFileSize = 0;
        if (!this.isEditMms || this.mmsEditList.length == 0) {
            return;
        }
        for (let element of this.mmsEditList) {
            this.curEdtFileSize += element.fileSize;
        }
    }

    dealSmsSendResult(context: Context, params: LooseObject, item: mmsListType, sendResult: Record<string, string | number | string[]>,
        sendNumbersLength: number, callback?: Function) {
        HiLog.w(TAG, `dealSmsSendResult slotId:${params.slotId}`)
        try {
            HiLog.w(TAG, 'dealSmsSendResult start');
            HiLog.w(TAG, 'dealSmsSendResult resendStateIsRcs not In')
            params.id = item.id;
            sendMsgService.sendMessage(params, (sendStatus: number) => {
                let now: number = new Date().getTime();
                dotSendParmas.NUMBER_STATUS = sendNumbersLength;

                this.updateUI(context, sendStatus, sendNumbersLength, item, sendResult, '', params?.resendStateIsRcs)
                // sms 消息发送成功打点
                if (sendStatus === common.int.SEND_MESSAGE_SUCCESS && sendNumbersLength === item?.success) {
                    DotUtil.getInstance()
                        .reportSuccessRateForSendFinished(dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_SMS);
                }
                if (callback) {
                    callback();
                }
            });
            this.isFoldSend(context, this.strContactsNumber);
            HiLog.w(TAG, 'dealSmsSendResult start');
        }catch (error) {
            HiLog.e(TAG, 'dealSmsSendResult error: ' + JSON.stringify(error));
        } finally {
            // 如果是转发消息，发送完后草稿被置为空，需要将初始草稿清空，用户返回或者切换会重新保存草稿
            if (this.draftModel !== null && this.draftModel?.isForwardingDraftModel) {
                this.draftModel.initialDraftText = commonData.STR.EMPTY_STR
                this.draftModel.initialDraftAttachments = []
            }
        }
    }

    updateUI(context: Context, sendStatus: number, sendNumbersLength: number, item: mmsListType, sendResult: Record<string, string | number | string[]>, msgId: string,resendStateIsRcs?:boolean) :void{
        if (sendStatus === common.int.SEND_MESSAGE_FAILED) {
            // 群发会话失败数量不能大于群发的联系人数量兜底
            item.failuresNumber =
                sendNumbersLength > item.failuresNumber ? (item.failuresNumber + 1) : sendNumbersLength;
        } else if (sendStatus === common.int.SEND_MESSAGE_SUCCESS) {
            // 群发会话成功数量不能大于群发的联系人数量兜底
            item.success = sendNumbersLength > item.success ? (item.success + 1) : sendNumbersLength;
        }
        if (this.contactsNum > item.completeNumber) {
            item.completeNumber = item.completeNumber + 1;
        }
            if (sendNumbersLength === item.completeNumber || sendNumbersLength === 1) {
                if (item.failuresNumber !== 0) {
                    item.sendStatus = common.int.SEND_MESSAGE_FAILED;
                } else if (item.success === sendNumbersLength) {
                    item.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
                } else {
                    item.sendStatus = common.int.SEND_MESSAGE_SENDING;
                }
            } else {
                item.sendStatus = common.int.SEND_MESSAGE_SENDING;
            }
        if(sendStatus === common.int.RCS_SEND_OK){
            item.sendStatus = common.int.RCS_SEND_OK;
        }
        if ((msgId !== undefined && msgId !== '' && msgId !== null) && (item.isRcs == common.MESSAGE_TYPE.RCS)) {
                item.id = msgId;
        }
        if(resendStateIsRcs===false){
            item.isRcs=common.MESSAGE_TYPE.SMS_OR_MMS;
        }else if (resendStateIsRcs===true){
            item.isRcs=common.MESSAGE_TYPE.RCS;
        }
        item.showProgress = false;
        clearInterval(this.progressTask);
        this.progressValue = 0;
        this.addProgressSize(item, msgId);
        this.resetItem(item);
        sendResult.sendStatus = sendStatus;
        sendResult.isRcs = item.isRcs;
        // sendResult中更新群组会话发送状态，此时会话中最新消息的发送状态为多个联系人发送状态的综合结果
        sendResult.groupSendStatus = item.sendStatus;
        HiLog.iw(TAG, 'updateUI, updateUI sendResult.sendStatus: ' + sendResult.sendStatus);
        if (sendResult.sendStatus === common.int.SEND_MESSAGE_FAILED) {
            this.conversationListCtr.refreshMessageStatus(item);
        }
        // Update sending status
        this.refreshDetail(context, item, sendResult, sendNumbersLength, msgId, resendStateIsRcs);
        return;
    }

    addProgressSize(item: mmsListType, msgId: string) {
        let mapImageMsgIdToData = EnhancedInfoTemporaryDataSource.getInstance().mapImageMsgIdToData;
        if (msgId && mapImageMsgIdToData?.get(msgId)?.isExistInfoInRcsInfoWithMsgId === false) {
            let clurSize = EnhancedInfoTemporaryDataSource.getInstance().mapImageMsgIdToData.get(msgId)?.clurSize || 0;
            let totalSize =
                EnhancedInfoTemporaryDataSource.getInstance().mapImageMsgIdToData.get(msgId)?.totalSize || 0;
            item.clurSize = clurSize;
            item.totalSize = totalSize;
        }
    }

    refreshDetail(context: Context, item: mmsListType, sendResult: Record<string, string | number | string[]>, sendNumbersLength: number,
                  msgId: string, resendStateIsRcs?: boolean) {
        this.updateDetail(context, item.threadId, sendResult, sendNumbersLength, msgId, resendStateIsRcs);
        GlobalContext.getContext().setObject('transmitFlag', false);
        this.scroller.scrollEdge(Edge.End);
        if (GlobalContext.getContext().getObject('transmitFlag')) {
            GlobalContext.getContext().setObject('transmitFlag', false)
            this.queryMessageDetail(context, {
                isDraft:this.isDraft,
                currentPage:1,
                threadId:item.threadId,
                contactsNum:this.contactsNum,
                queryTimeID:this.currentQueryTimeID,
                startIndex: 0
            }, () => {
                this.scroller.scrollEdge(Edge.End);
            });
        }
    }
    resetItem(item: mmsListType, isNotNotifyDataChangeToMmsList?: boolean) {
        for (let index = 0; index < this.mmsList.length; index++) {
            const element = this.mmsList[index];
            if (element.id == item.id) {
                this.mmsList.splice(index, 1, item);
                break;
            }
            if(element.isRcs === common.MESSAGE_TYPE.RCS){
                if (element.rcsId == item.rcsId) {
                    this.mmsList.splice(index, 1, item);
                    if (!isNotNotifyDataChangeToMmsList) {
                        ConversationDataSource.getInstance().setIsSendingRCSAnimate(index)
                    }
                    break;
                }
            }
            else {
                if (element.id == item.id) {
                    this.mmsList.splice(index, 1, item);
                    break;
                }
            }
        }
    }

    getSendMessageId(initDatas: InitData[], telephone: string): number {
        for (let initData of initDatas) {
            if (initData.telephone == telephone) {
                return initData.id;
            }
        }
        return -1;
    }

    convertingSms() {
        // Convert to SMS
        this.isEditMms = false;
        this.showToast($r('app.string.converting_sms'));
    }

    dealSendResult(context: Context, actionData: ActionDataType, item: mmsListType, initDatas: InitData[], callback?: Function) {
        HiLog.w(TAG, 'dealSendResult start');
        this.isDraft = MmsUtil.isRcsMap(item?.msgType) ? true : false;
        item.completeNumber = 0;
        item.failuresNumber = 0;
        item.success = 0;
        // Add sending information to the list.
        let sendNumbers: string[] = actionData.hosts as string[];
        let sendNumbersLength: number = sendNumbers.length;
        let content: string = actionData.content;
        let contactNames: string[] = actionData.contactName?.split(',') as string[];
        let rcsMsgType: number = 0;
        for (let i = 0; i < sendNumbers.length; i++) {
            HiLog.w(TAG, 'dealSendResult normal message');
            let params: Record<string, number | number[] | string | boolean> =
                this.initSendParams(actionData, sendNumbers[i], content, rcsMsgType);
            let sendResult: Record<string, number | string[] | string> =
                this.initSendResult(initDatas, sendNumbers[i], contactNames[i], content, actionData);
            this.initAndSend(context, item, params, sendResult, sendNumbersLength, callback);
        }
        HiLog.w(TAG, 'dealSendResult end');
    }

    initSendParams(actionData: ActionDataType, sendNumber:string, bodyText:string, rcsMsgType: number) {
        let params: Record<string, number | number[] | string | boolean> = {
            'slotId': actionData.slotId,
            'destinationHost': sendNumber,
            'content': bodyText,
            'isReSend': actionData?.isReSend as boolean,
            'id': actionData?.id as string,
            'resendStateIsRcs': actionData?.resendStateIsRcs as boolean,
            'rcsMsgType': rcsMsgType
        };
        return params;
    }
    initSendResult(initDatas: InitData[], sendNumber: string, contactName: string, content: string,
        actionData: ActionDataType) {
        sendNumber = actionData.isChatbot ? actionData.destinationHost : sendNumber;
        let id: number = this.getSendMessageId(initDatas, sendNumber);
        let sendResult: Record<string, number | string[] | string> = {
            'id': id,
            'telephone': actionData.isChatbot ? actionData.destinationHost : sendNumber,
            'content': content,
            'contactName': contactName
        }
        return sendResult;
    }

    initAndSend(context: Context, item: mmsListType, params: Record<string, number | number[] | string | boolean>,
        sendResult: Record<string, number | string[] | string>, sendNumbersLength: number, callback?: Function) {
        if (!item.isMsm) {
            this.dealSmsSendResult(context, params, item, sendResult, sendNumbersLength, callback);
        }else {
            HiLog.w(TAG, 'initAndSend item isMsm');
        }
    }

    insertInitData(context: Context, actionData: ActionDataType, item: mmsListType, callback: Function): void {
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_INSERT_INIT_DATA,
            TraceConstant.TRACE_CONVERSATION_INSERT_INIT_DATA_ID);
        let sendNumbers: string[] = actionData.hosts as string[];
        let insertSendResults: LooseObject[] = [];
        for (let i = 0; i < sendNumbers.length; i++) {
            let sendResult: Record<string, number | string[] | number | string> = {
                'slotId': actionData.slotId,
                'telephone': sendNumbers[i],
                'content': actionData.content,
                'msgTitle': actionData.msgTitle || '',
                'sendStatus': item?.sendStatus ?? common.int.SEND_MESSAGE_SENDING
            }
            insertSendResults.push(sendResult);
        }
        let actionData_: LooseObject = {};
        actionData_.sendResults = insertSendResults;
        actionData_.isReceive = false;
        actionData_.ownNumber = common.STR.EMPTY_STR;
        actionData_.isSender = common.is_sender.NO;
        actionData_.hasDraft = this.isDraft;
        actionData_.hasReport = settingService.judgeIsDeliveryReport(item?.isMsm) ? 1 : 0;
        actionData_.isMms = item?.isMsm;
        actionData_.mmsSource = item?.mmsSource;
        actionData_.hasAttachment = item?.isMsm ? true : false;
        actionData_.sessionContacts = this.sessionContactsInfo;
        if (actionData.isChatbot) {
            actionData_.isChatbot = actionData.isChatbot;
        }
        if (actionData && typeof actionData.groupId === 'number' && !isNaN(actionData.groupId)) {
            actionData_.groupId = actionData.groupId;
        }
        if (item.isRcs === common.MESSAGE_TYPE.RCS) {
            actionData_.type = commonData.RCS_TYPE.RCS_SEND;
            actionData_.isRcsType = item.rcsType;
            HiLog.iw(TAG, 'item.msgType：' + actionData_.isRcsType);
        }
        if(actionData.resendStateIsRcs===true){
            actionData_.type = commonData.RCS_TYPE.RCS_SEND;
        }
        if(actionData.resendStateIsRcs!==undefined){
            if(actionData.resendStateIsRcs===false){
                actionData_.type = commonData.RCS_TYPE.MMS_SEND;
            }
        }
        ConversationService.getInstance().insertSessionAndDetail(actionData_, callback, context);
        hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_INSERT_INIT_DATA,
            TraceConstant.TRACE_CONVERSATION_INSERT_INIT_DATA_ID);
    }

    buildTextSendItemOfEnhancedInfo(isEditMms: boolean) {
        // Obtains the day of the week.
        hiTraceMeter.startTrace(TraceConstant.TRACE_SEND_MSG_REFRESH, TraceConstant.TRACE_SEND_MSG_REFRESH_ID);
        HiLog.i(TAG, 'buildTextSendItemOfEnhancedInfo, start')
        let item: mmsListType = new mmsListType();
        item.date = common.STR.EMPTY_STR;
        item.detailTime = $r('app.string.justNow');
        item.timeMillisecond = new Date().getTime();
        DateUtil.convertTimeStampToDateWeek(item, false);
        DateUtil.fullDate(item);
        item.content = this.textValue;
        item.msgType = this.mmsEditList.length != 0 ? this.mmsEditList[0].type : common.MSG_ITEM_TYPE.TEXT;
        item.smsType = this.smsType;
        item.isFullScreenImg = false;
        item.msgUriPath = this.mmsEditList.length != 0 ? this.mmsEditList[0].uriPath : common.STR.EMPTY_STR;
        let time = (this.mmsEditList.length != 0 && (this.mmsEditList[0].type == 3 || this.mmsEditList[0].type == 5)) ?
        this.mmsEditList[0].time : common.STR.SUCCESS;
        item.audioTime = time;
        item.isCbChecked = false;
        item.is_collect = false;
        item.isReceive = false;
        item.sendStatus = 1;
        item.subId = this.slotId;
        item.mmsEditListTemp = this.mmsEditList;
        item.rcsType = commonData.ENHANCED_INFO_ITEM_TYPE.TEXT;
        if (this.contactsNum > 1) {
            item.completeNumber = 0;
            item.failuresNumber = 0;
        }
        item.hasReport = settingService.judgeIsDeliveryReport(item.isMsm);
        item.mmsSource = [];
        item.isMsm = isEditMms;
        this.setDateShow(item, this.mmsList, -1);
        item.isRcs = common.MESSAGE_TYPE.RCS;
        hiTraceMeter.finishTrace(TraceConstant.TRACE_SEND_MSG_REFRESH, TraceConstant.TRACE_SEND_MSG_REFRESH_ID);
        return item
    }

    changeReceiveContactValue(value: string) {
        this.receiveContactValue = value
    }

    updatePreview(idx: number) {
        // Delete Preview
        HiLog.i(TAG, 'updatePreview, idx: ' + idx);
        // If not audio (picture or video) is deleted from the preview, you need to change the value of
        // checkbox in the thumbnail of the gallery.
        if (this.mmsEditList[idx].type != common.MSG_ITEM_TYPE.AUDIO) {
            let that = this;
            this.pictureListFromGallery.forEach(item => {
                if (item.path == that.mmsEditList[idx].uriPath) {
                    item.checkedValue = false;
                    that.curEdtFileSize -= that.mmsEditList[idx].fileSize;
                    that.msgSendTip = Math.ceil(that.curEdtFileSize) + COMMON_FILE_SIZE_STRING;
                }
            });
        }
        this.isOnlyAudio = !this.mmsEditList.some((item, index) => item.type != common.MSG_ITEM_TYPE.AUDIO);
        if (this.mmsEditList.length == 0) {
            this.convertingSms();
        }
    }

    initSendItem(context: Context, item: mmsListType, textValue:string) {
        // Obtains the day of the week.
        hiTraceMeter.startTrace(TraceConstant.TRACE_SEND_MSG_REFRESH,TraceConstant.TRACE_SEND_MSG_REFRESH_ID);
        HiLog.iw(TAG, 'initSendItem, start')
        item.date = common.STR.EMPTY_STR;
        item.detailTime = $r('app.string.justNow');
        item.timeMillisecond = new Date().getTime();
        DateUtil.convertTimeStampToDateWeek(item, false);
        DateUtil.fullDate(item);
        item.content = this.getSendText(context, textValue, true);
        item.msgType = this.mmsEditList.length != 0 ? this.mmsEditList[0].type : common.MSG_ITEM_TYPE.TEXT;
        item.smsType = this.smsType;
        item.isFullScreenImg = false;
        item.msgUriPath = this.mmsEditList.length != 0 ? this.mmsEditList[0].uriPath : common.STR.EMPTY_STR;
        let time = (this.mmsEditList.length != 0 && (this.mmsEditList[0].type == 3 || this.mmsEditList[0].type == 5)) ?
            this.mmsEditList[0].time : common.STR.SUCCESS;
        item.audioTime = time;
        item.isCbChecked = false;
        item.is_collect = false;
        item.isReceive = false;
        item.sendStatus = this.getMessageSendStatus();
        item.subId = this.slotId;
        item.mmsEditListTemp = this.mmsEditList;
        if (this.contactsNum > 1) {
            item.completeNumber = 0;
            item.failuresNumber = 0;
        }
        item.hasReport = settingService.judgeIsDeliveryReport(item.isMsm);
        item.mmsSource = [];
        item.isMsm = this.isEditMms;
        this.setDateShow(item, this.mmsList, -1);
        this.setShowTitle(item, this.mmsList);
        this.mmsList.push(item);
        hiTraceMeter.finishTrace(TraceConstant.TRACE_SEND_MSG_REFRESH,TraceConstant.TRACE_SEND_MSG_REFRESH_ID);
        ConversationDataSource.getInstance().refresh(this.mmsList);
    }


    public getSendText(context: Context, str: string, onlyShow: boolean): string {
        let content:string = str;
        return content;
    }


  /**
   * Set 'dateShow' property, it means whether the time on the top of each SMS message is displayed.
   * @param currentItem
   * @param list
   * @param index  Index of the item in the list. For items not in the list, value is -1.
   */
  setDateShow(currentItem: mmsListType, list: mmsListType[], index: number) {
    if (!currentItem || !list || index == undefined) {
      return;
    }
    let isDateShow = false;
    try {
      if (index === -1 && list.length === 0) {
        isDateShow = true;
      } else if (index === -1 && list.length > 0) {
        let lastItem = list[list.length - 1];
        isDateShow = DateUtil.isNotSameDay(lastItem.timeMillisecond, currentItem.timeMillisecond);
      } else if (index === 0) {
        isDateShow = true;
      } else {
        isDateShow = DateUtil.isNotSameDay(list[index - 1].timeMillisecond, currentItem.timeMillisecond);
      }
    } catch (e) {
      HiLog.e(TAG, `setDateShow error:` + JSON.stringify(e));
    }
    currentItem.dateShow = isDateShow;
  }

    getThemeContent() {
        HiLog.i(TAG, 'getThemeContent, start')
        this.isEditMms = true;
        let content = '';
        let first: string = this.textareaDatasource[0]?.textValue;
        let text: string = this.textareaDatasource[1]?.textValue;
        if (first !== common.STR.EMPTY_STR) {
            content = $r('app.string.msg_theme') + ': ' + first;
        }
        if (text !== common.STR.EMPTY_STR) {
            if (content === common.STR.EMPTY_STR) {
                content = text;
            } else {
                content = content + '\n' + text;
            }
        }
        return content;
    }

    sendMassMessage(context: Context, actionData: ActionDataType, item: mmsListType, callback?: Function, copySourceIndex?: number) {
        HiLog.w(TAG, 'sendMassMessage start');
        this.insertInitData(context, actionData, item, (result: InsertResult) => {
            // 插入失败的时候，result = {"code":-1}。需要判断异常。对于新创建的会话，会出现有session，无info的情况。
            if (!result || !Array.isArray(result.initDatas)) {
                HiLog.e(TAG, `insertInitData error`);
                return;
            }
            this.isFoldSend(context, this.strContactsNumber)
            // Processing the sent result
            if (this.threadId != result.rowId) {
                // When modifying the recipient information, click Send and delete the session before the modification.
                let condition: LooseObject = {};
                condition.threadId = this.threadId;
                ConversationListService.getInstance().deleteSessionByCondition(condition, () => {}, context);
            }
            if (this.threadId !== result?.rowId) {
                // 对于新建会话，会话id刷新后需要同步更新首选项中代表处于当前会话的标记currentTheadId
                HiLog.i(TAG, `insertInitData before threadId is ${this.threadId}`);
                HiLog.i(TAG, `insertInitData after threadId is ${result?.rowId}`);
                this.threadId = result.rowId;
                this.publishData(true, this.threadId);
            }
            this.smsType = 0;
            this.initCurrentQueryTimeID();
            if (this.contactsNum === 1 && this.portraitColor === common.STR.EMPTY_STR) {
                this.portraitColor = AvatarColor?.background.Color[Math.abs(this.threadId) % 6];
            }
            item.groupId = result.groupId;
            item.id = result.initDatas[0].id;
            item.threadId = result.rowId;
            if(item.isRcs === common.MESSAGE_TYPE.RCS){
                item.rcsId = result.initDatas[0].id;
            }
            if (item.isRcs !== common.MESSAGE_TYPE.RCS || item.rcsType !== commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE) {
                ConversationDataSource.getInstance().refresh(this.mmsList);
            }
            let isMmsVideo: boolean = item?.isMsm && (item?.mmsSource?.length > 1) &&
                item?.mmsSource?.[1]?.type === common.MM_ATTACHMENT_TYPE.VIDEO ? true : false;
            if (item.rcsType === common.ENHANCED_INFO_ITEM_TYPE.VIDEO || isMmsVideo) {
                setTimeout(() => {
                    this.scroller.scrollEdge(Edge.End);
                }, 200);
            }
            HiLog.i(TAG, 'itemId=' + item.id + 'normal send event: ' + item.isMsm);
            this.sendMessage(context, actionData, item, result.initDatas, callback)
            // 该字段赋值为打点使用。
            item.receiverNumber = actionData.destinationHost;
            item.slotId = actionData.slotId;
            this.storageMessageTimeout.sendMessageStorageAndTimeout(item);
            if (callback) { callback(); }
            HiLog.w(TAG, 'sendMassMessage end');
        });
    }

    async sendMessage(context: Context, actionData: ActionDataType, item: mmsListType, initDatas: InitData[], callback?: Function) {
        HiLog.w(TAG, 'sendMessage start');
        if (item.isRcs === common.MESSAGE_TYPE.SMS_OR_MMS && actionData.destinationHost.startsWith('sip:') &&
        actionData.destinationHost.includes('botplatform')) {
            if (this.chatbotMmsNumber) {
                actionData.hosts = [];
                actionData.hosts?.push(this.chatbotMmsNumber);
            } else {
                const start = actionData.destinationHost.indexOf(':') + 1;
                const end = actionData.destinationHost.indexOf('@');
                actionData.hosts = [];
                actionData.hosts?.push(actionData.destinationHost.substring(start, end));
            }
            actionData.isChatbot = true;
        }
        if (item.isMsm || (item.isRcs && item.rcsType)) {
            HiLog.w(TAG, 'sendMessage rich Message');
            actionData.threadId = item.threadId;
            if (MmsUtil.isRcsMap(item?.msgType) && actionData.hosts?.length === 1) {
                item.isMsm = false;
                this.dealSendResult(context, actionData, item, initDatas);
            } else {
                this.sendMmsMessage(context, actionData, item, initDatas);
                if (item.id === this.mmsList[0]?.id) {
                    item.showTitle = true;
                }
            }
            this.scrollToEnd();
        } else {
            HiLog.w(TAG, 'sendMessage Text Message');
            this.dealSendResult(context, actionData, item, initDatas, callback);
        }
        HiLog.w(TAG, 'sendMessage end');
    }

    clearMsm() {
        if (this.isEditMms) {
            this.isEditMms = false;
        }
        // Deleting the preview image of an MMS message
        if (this.mmsEditList.length != 0) {
            for (let index = 0; index < this.mmsEditList.length; ++index) {
                this.updatePreview(index);
            }
            this.mmsEditList = [];
        }
    }

    resetMmsSource() {
        let selectChatbotType: selectContactType[] = [{
            telephone: this.strContactsNumber,
            telephoneFormat: this.strContactsNumberFormat,
            contactName: this.strContactsName
        }]
        this.setSelectContacts(selectChatbotType)
        this.resetAttachAreaPicture();
        this.mAttachAreaCtrl.resetMms();
        this.canSendMessage = false;
        setTimeout(()=>{
            this.isSendPicture = false;
            AppStorage.setOrCreate('comeFromContact', false);
            AppStorage.setOrCreate('comeFromServiceaccess', false);
        }, 350);
    }
  /**
   * Message Not In Attachment Area: voice, vCard, FIle
   */
  resetMmsSourceOfRcsMessageNotInAttachmentArea() {
    HiLog.i(TAG, 'resetMmsSourceOfRcsMessageNotInAttachmentArea');
    this.mAttachAreaCtrl.rcsDisplaySource = [];
    this.mAttachAreaCtrl.refreshDisplay();
    let mmDisplaySource = this.mAttachAreaCtrl?.mmDisplaySource;
    this.canSendMessage = (mmDisplaySource && mmDisplaySource.length > 0) ? true : false;
    setTimeout(() => {
      this.isSendPicture = false;
    }, 350);
  }

    /**
     * 短彩信模式的发送函数，即在新建会话或历史会话页面中点击发送按钮的场景
     * @param context Context
     * @param newConversationSendData 可选参数，只用于新建会话跳转历史会话的发送场景
     */
    send(context: Context, newConversationSendData?: NewConversationSendData) {
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_SEND, TraceConstant.TRACE_CONVERSATION_SEND_ID);
        HiLog.w(TAG, 'send, start');
        let reportParams: Record<string, number | number[] | string | boolean> = {
            'msgType': common.ueMsgType.SMS,
            'sendResult': common.ueMsgSendType.RETURN
        };
        if (!this.preSendStatusCheck(context)){
            HiLog.e(TAG, 'can not pass preSendStatusCheck!');
            reportParams.failReason = 'can not pass preSendStatusCheck!';
            DotUtil.getInstance().reportSendMessageCommon(reportParams);
            return;
        }

        this.isChangeInputPlaceholder = true;
        sendMmsParams.MMS_NUM = newConversationSendData?.attachmentDataList?.length ??
        this.mAttachAreaCtrl.mmDisplaySource.length;
        this.sendPublish(context, newConversationSendData);
        hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_SEND, TraceConstant.TRACE_CONVERSATION_SEND_ID);
        return;
    }
    //发送信息前的基本信息检查
    preSendStatusCheck(context: Context): boolean {
        // The Send button is dimmed and messages cannot be sent.
        if (this.isAirPlaneMode) {
            HiLog.w(TAG, `send, canSendMessage=${this.canSendMessage}, isAirPlaneMode=${this.isAirPlaneMode}`);
            this.showToast($r('app.string.air_plane_mode_message'));
            this.isChangeInputPlaceholder = true;
            return false;
        }
        if (!this.canSendMessage &&
            !(DeviceUtil.isSubDeviceWithConnected(context) && !this.isAirPlaneMode)) {
            HiLog.w(TAG, 'send, canSendMessage=false');
            this.isChangeInputPlaceholder = true;
            return false;
        }
        return true
    }

    /**
     * send rcs audio, vcard and file message
     * @param context
     */
    async sendAudio(context: Context) {
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_SEND, TraceConstant.TRACE_CONVERSATION_SEND_ID);
        HiLog.iw(TAG, 'sendAudio, start');
        let inRepairMode = SharedPreferencesUtils.getFromPreferences('inRepairMode', false);
        if (inRepairMode) {
            HiLog.iw(TAG, 'inRepairMode' + JSON.stringify(inRepairMode));
            this.isChangeInputPlaceholder = true;
            return;
        }
        // The Send button is dimmed and messages cannot be sent.
        if (this.isAirPlaneMode) {
            HiLog.w(TAG, `send, canSendMessage=${this.canSendMessage}, isAirPlaneMode=${this.isAirPlaneMode}`);
            this.showToast($r('app.string.air_plane_mode_message'));
            this.isChangeInputPlaceholder = true;
            return;
        }
        if (!this.canSendMessage) {
            if (this.isNewMsg) {
                if (this.receiveContactValue !== common.STR.EMPTY_STR || this.getSelectContactsLength() > 0) {
                    this.canSendMessage = true;
                }
            } else {
                this.canSendMessage = true;
            }
        }
        if (!this.canSendMessage) {
            HiLog.w(TAG, 'send, canSendMessage=false');
            this.isChangeInputPlaceholder = true;
            return;
        }
        if (this.isNewMsg) {
            HiLog.iw(TAG, 'send, isNewMsg: ' + this.isNewMsg);
            this.isNewMsgWithDraft = false;
            this.isChangeInputPlaceholder = false;
            this.newSend(context, () => {
                HiLog.iw(TAG, 'send, newSendBack');
                this.sendRcsDataRefreshNoWithImgAndText(context);
                this.publishData(true, this.threadId);
            });
        } else {
            HiLog.iw(TAG, 'send, isOldMsg');
            this.sendRcsDataRefreshNoWithImgAndText(context);
            this.publishData(true, this.threadId);
        }
        this.vCardJumpBack = false;
    }

    async sendRcsDataRefreshNoWithImgAndText(context: Context) {
        hiTraceMeter.startTrace(TraceConstant.TRACE_SEND_MSG_CLEAN_TEXT, TraceConstant.TRACE_SEND_MSG_CLEAN_TEXT_ID);
        this.isSendStatus = true;
        this.slotId = MmsPreferences.getInstance().getSendMessageSlotIdOfRcs();
        let isSendFlag = await this.initAudioItem(context);
        let actionData: ActionDataType = new ActionDataType();
        actionData.slotId = this.slotId;
        actionData.destinationHost = this.strContactsNumber;
        actionData.isReSend = false;
        actionData.contactName = this.strContactsName;
        actionData.content = '';
        actionData.isEditMms = false;
        this.formatDisplayPhoneNum();
        if (isSendFlag) {
            // 收发成功率打点-开始发送
            DotUtil.getInstance().reportSuccessRateForSendStart(dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_RCS);
            // Real SMS Sending
            this.sendInterval(context, actionData, this.mmsList);
        }
        this.textValue = common.STR.EMPTY_STR;
        hiTraceMeter.finishTrace(TraceConstant.TRACE_SEND_MSG_CLEAN_TEXT, TraceConstant.TRACE_SEND_MSG_CLEAN_TEXT_ID);
        this.canSendMessage = false;
        this.isShowFullScreen = false;
        this.clearMsm();
        this.resetMmsSourceOfRcsMessageNotInAttachmentArea();
        this.setTabOperationStatus(false);
        this.distanceBottomFlag = false;
        this.receiveContactValue = common.STR.EMPTY_STR;
        this.clearSelectContacts();
        this.isNewMsg = false;
        this.scroller.scrollEdge(Edge.End);
    }

    async initAudioItem(context: Context): Promise<boolean> {
        HiLog.i(TAG, 'initAudioItem, start');
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_INIT_MMS,
            TraceConstant.TRACE_CONVERSATION_INIT_MMS_ID);
        let rcsDisplaySource = MMAttachmentAreaController.getInstance().rcsDisplaySource;
        let item: mmsListType = new mmsListType();
        item.date = common.STR.EMPTY_STR;
        item.detailTime = $r('app.string.justNow');
        item.timeMillisecond = new Date().getTime();
        DateUtil.convertTimeStampToDateWeek(item, false);
        DateUtil.fullDate(item);
        item.content = '';
        item.isFullScreenImg = false;
        item.isCbChecked = false;
        item.is_collect = false;
        item.isReceive = false;
        item.sendStatus = this.getMessageSendStatus();
        item.subId = this.slotId;
        item.isMsm = true;
        item.isRcs = common.MESSAGE_TYPE.RCS;
        item.mmsSource = await this.getSmiledRcsSource(context);

        if (rcsDisplaySource && rcsDisplaySource.length > 0 &&
            rcsDisplaySource[rcsDisplaySource.length - 1].type === common.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
            const thumbnailItem = await this.getRcsVideoThumbnailItemToMmsSource(context,
                rcsDisplaySource[rcsDisplaySource.length - 1].path)
            if (thumbnailItem) {
                item.mmsSource.push(thumbnailItem);
            }
        }
        if (item.mmsSource.length < 2) {
            return false;
        }
        item.contentType = MmsUtil.getRcsContentType(item.mmsSource);
        item.rcsType = rcsDisplaySource && rcsDisplaySource.length > 0 ?
        rcsDisplaySource[rcsDisplaySource.length - 1].type :
        commonData.ENHANCED_INFO_ITEM_TYPE.FILE;

        this.setDateShow(item, this.mmsList, -1);
        this.setShowTitle(item, this.mmsList);
        this.mmsList.push(item);
        hiTraceMeter.finishTrace(TraceConstant.TRACE_SEND_MSG_REFRESH, TraceConstant.TRACE_SEND_MSG_REFRESH_ID);
        ConversationDataSource.getInstance().refresh(this.mmsList);
        if (item.contentType === commonData.MMS_CONTENT_TYPE.VCARD ||
            item.contentType === commonData.MMS_CONTENT_TYPE.FILE) {
            setTimeout(() => {
                HiLog.i(TAG, `initAudioItem setTimeout`);
                ConversationDataSource.getInstance().refresh(this.mmsList);
            }, 50);
        }
        return true;
    }

    /**
     * 增强信息模式的发送函数，即在新建会话或历史会话页面中点击发送按钮的场景
     * @param context Context
     * @param newConversationSendData 可选参数，只用于新建会话跳转历史会话的发送场景
     */
    sendOfEnhancedInfo(context: Context, newConversationSendData?: NewConversationSendData) {
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_SEND, TraceConstant.TRACE_CONVERSATION_SEND_ID);
        HiLog.w(TAG, 'sendOfEnhancedInfo, start');
        let reportParams: Record<string, number | number[] | string | boolean> = {
            'msgType': common.ueMsgType.RCS,
            'sendResult': common.ueMsgSendType.RETURN
        };
        if (this.mAttachAreaCtrl.mmDisplaySource.length >
        commonData.int.MMS_ATTACHMENT_UPPER_LIMIT_ENHANCED_INFO_MODE) {
            this.showToast($r('app.string.attachment_upper_limit',
                commonData.int.MMS_ATTACHMENT_UPPER_LIMIT_ENHANCED_INFO_MODE,
                commonData.int.MMS_ATTACHMENT_UPPER_LIMIT_ENHANCED_INFO_MODE));
            this.isChangeInputPlaceholder = true;
            HiLog.w(TAG, 'mmDisplaySource length out of limit');
            reportParams.failReason = 'mmDisplaySource length out of limit';
            DotUtil.getInstance().reportSendMessageCommon(reportParams);
            return;
        }
        let inRepairMode = SharedPreferencesUtils.getFromPreferences('inRepairMode', false);
        if (inRepairMode) {
            HiLog.w(TAG, 'inRepairMode' + JSON.stringify(inRepairMode));
            this.isChangeInputPlaceholder = true;
            reportParams.failReason = `inRepairMode ${JSON.stringify(inRepairMode)}`;
            DotUtil.getInstance().reportSendMessageCommon(reportParams);
            return;
        }
        // The Send button is dimmed and messages cannot be sent.
        if (this.isAirPlaneMode) {
            HiLog.w(TAG, `send, canSendMessage=${this.canSendMessage}, isAirPlaneMode=${this.isAirPlaneMode}`);
            this.showToast($r('app.string.air_plane_mode_message'));
            this.isChangeInputPlaceholder = true;
            reportParams.failReason = `send, canSendMessage=${this.canSendMessage}, isAirPlaneMode=${this.isAirPlaneMode}`;
            DotUtil.getInstance().reportSendMessageCommon(reportParams);
            return;
        }
        if (!this.canSendMessage) {
            HiLog.w(TAG, 'send, canSendMessage=false');
            this.isChangeInputPlaceholder = true;
            reportParams.failReason = `send, canSendMessage=false`;
            DotUtil.getInstance().reportSendMessageCommon(reportParams);
            return;
        }
        // Switching from the new state to the session state
        if (this.isNewMsg) {
            HiLog.w(TAG, 'send, isNewMsg: ' + this.isNewMsg);
            this.isNewMsgWithDraft = false;
            this.isChangeInputPlaceholder = false;
            this.newSend(context, () => {
                HiLog.iw(TAG, 'send, newSendBack');
                if (this.isDraft) {
                    this.deleteDraftDataByThread(context);
                }
                this.sendDataRefreshOfEnhancedInfo(context, this.textValue, newConversationSendData);
                this.publishData(true, this.threadId);
            });
        } else {
            HiLog.w(TAG, 'send, isOldMsg');
            this.isChangeInputPlaceholder = false;
            this.sendDataRefreshOfEnhancedInfo(context, this.textValue, newConversationSendData);
            this.publishData(true, this.threadId);

            DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.REPLY_TO_SMS_EVENT);
        }
    }

  /**
   * 在短彩信模式与增强信息模式切换过程中，设置附件待发区时，图片、视频、vCard和位置消息会被保留，其他消息类型将被清除。
   */
  public async resetValuesSwitchBetweenMmsAndRcs(lastIsRcs: boolean) {
    HiLog.i(TAG, 'resetValuesSwitchBetweenMmsAndRcs');
    this.isShowFullScreen = false;
    let isSendPicture = false;
    isSendPicture = await this.handleMmDisplaySourceOnSwitchBetweenMmsAndRcs(lastIsRcs, isSendPicture);
    this.mAttachAreaCtrl.refreshDisplay();
    setTimeout(() => {
      this.isSendPicture = isSendPicture;
    }, 100);
    this.setTabOperationStatus(false);
    this.distanceBottomFlag = false;
    this.receiveContactValue = common.STR.EMPTY_STR;
    const tempBol = AppStorage.get<boolean>('isConversationNeedChangeOfRcs');
    AppStorage.setOrCreate('isConversationNeedChangeOfRcs', !tempBol);
    if (!this.isInInit || StringUtil.isEmpty(this.searchMsgId)) {
      this.scroller.scrollEdge(Edge.End);
    }
  }

  /**
   * 当增强信息和短彩信模式相互切换时转换附件待发区的附件数据
   * @param lastIsRcs 切换前是否是增强信息模式
   * @param isSendPicture
   * @returns
   */
  private async handleMmDisplaySourceOnSwitchBetweenMmsAndRcs(lastIsRcs: boolean, isSendPicture: boolean) {
    HiLog.i(TAG, 'handleMmDisplaySourceOnSwitchBetweenMmsAndRcs');
    if (!this.mAttachAreaCtrl?.mmDisplaySource || this.mAttachAreaCtrl.mmDisplaySource.length === 0) {
      this.mAttachAreaCtrl.mmDisplaySource = [];
      return isSendPicture;
    }

    const mmDisplaySource = [...this.mAttachAreaCtrl.mmDisplaySource];
    if (!lastIsRcs && this.isRcsMms) { // mms to rcs
      HiLog.i(TAG, 'handleMmDisplaySourceOnSwitchBetweenMmsAndRcs: mms to rcs');
      const tempList = mmDisplaySource.filter((v) => {
        return KEEP_MESSAGE_TYPE_WHEN_MMS_TO_RCS.includes(v.type);
      });
      isSendPicture = tempList.length > 0;
      for (let v of tempList) {
        if (!v?.path) {
          continue;
        }
        v.isRcs = true;

        if (v.type === commonData.MM_ATTACHMENT_TYPE.MAP) { // 彩信位置附件转增强信息位置附件
          v.type = commonData.ENHANCED_INFO_ITEM_TYPE.MAP;
          v.text = undefined;
          v.content = this.mAttachAreaCtrl.getRcsAddressJson(v.address ?? new AddressInfo(0, 0, '', ''));
        } else if (v.type !== commonData.MM_ATTACHMENT_TYPE.VCARD) {
          // 切换为增强信息时，类型为 VCARD 时，不更新 path
          v.path = fileUri.getUriFromPath(v.path);
        }
      }
      this.mAttachAreaCtrl.mmDisplaySource = tempList;
      this.mAttachAreaCtrl.copySource = [...this.mAttachAreaCtrl.mmDisplaySource];
      GlobalContext.getContext().setObject('fileTotalSize', 0);
    } else if (lastIsRcs && !this.isRcsMms) { //rcs to mms
      HiLog.i(TAG, 'handleMmDisplaySourceOnSwitchBetweenMmsAndRcs: rcs to mms');
      const tempList = mmDisplaySource.filter((v) => {
        return KEEP_MESSAGE_TYPE_WHEN_RCS_TO_MMS.includes(v.type);
      });
      isSendPicture = tempList.length > 0;
      for (let index = 0; index < tempList.length; index++) {
        const element = tempList[index];
        if (!element?.path) {
          continue;
        }
        if (element.type === commonData.ENHANCED_INFO_ITEM_TYPE.MAP) { // 增强信息位置附件转彩信位置附件
          element.type = commonData.MM_ATTACHMENT_TYPE.MAP;
          element.content = undefined;
          element.text = JSON.stringify(element.address ?? new AddressInfo(0, 0, '', ''));
        }
        const file = new fileUri.FileUri(element.path);
        element.path = file.path;
        element.isRcs = false;
        await this.mAttachAreaCtrl.setTotalSize(true, file.path);
      }
      this.mAttachAreaCtrl.mmDisplaySource = tempList;
      this.mAttachAreaCtrl.copySource = [...this.mAttachAreaCtrl.mmDisplaySource];
    }

    return isSendPicture;
  }

    public resetValuesOfEnhancedInfo() {
        HiLog.i(TAG, 'reset Values Of EnhancedInfo')
        this.resetValues();
        /*
        信息发送完成后，输入框文字清空
      */
        this.textValue = common.STR.EMPTY_STR;
        this.scroller.scrollEdge(Edge.End);
    }

    private resetValues() {
        hiTraceMeter.finishTrace(TraceConstant.TRACE_SEND_MSG_CLEAN_TEXT, TraceConstant.TRACE_SEND_MSG_CLEAN_TEXT_ID);
        this.canSendMessage = false;
        this.isShowFullScreen = false;
        this.clearMsm();
        this.resetMmsSource();
        this.setTabOperationStatus(false);
        this.distanceBottomFlag = false;
        this.receiveContactValue = common.STR.EMPTY_STR;
    }

    public resetValuesOfSwitchingCard() {
        HiLog.i(TAG, 'resetValuesOfSwitchingCards start');
        this.resetValues();
        this.canSendMessage = true;
        AppStorage.setOrCreate('isConversationNeedChange', true);
    }

    async sendDataRefreshOfEnhancedInfo(context: Context, currentStr: string,
        newConversationSendData?: NewConversationSendData) {
        this.slotId = MmsPreferences.getInstance().getSendMessageSlotIdOfRcs();
        HiLog.w(TAG, `sendDataRefreshOfEnhancedInfo slotId: ${this.slotId}`)
        this.textValue = MessageUtil.replaceForLossy7Bit(this.slotId, this.textValue, 0, this.textValue.length);
        this.isSendStatus = true;
        this.formatDisplayPhoneNum();
        const mmDisplaySource: Mms[] | undefined = newConversationSendData?.attachmentDataList ??
            this.mAttachAreaCtrl?.mmDisplaySource;
        HiLog.iw(TAG, `sendDataRefreshOfEnhancedInfo mmDisplaySource length ${mmDisplaySource?.length}`);

        let sendMsgIndexesList: SendMsgIndexes[] = [];

        if (this.textValue) {
            let item = this.buildTextSendItemOfEnhancedInfo(false);
            this.setShowTitle(item, this.mmsList);
            this.mmsList.push(item);
            sendMsgIndexesList.push({ copySourceIndex: -1, mmsListIndex: this.mmsList.length > 0 ?
                (this.mmsList.length - 1) : 0 });
        }
        if (mmDisplaySource && mmDisplaySource.length > 0) {
            let copySource: Mms[] = [];
            await this.mAttachAreaCtrl.initSourceOfEnhancedInfo(context, false, 0, copySource, mmDisplaySource);
            HiLog.iw(TAG, `sendDataRefreshOfEnhancedInfo: copySource length ${copySource.length}`);

            this.isSendPicture = true;
            for (let i = 0; i < copySource.length; i++) {
                let item = this.buildAttachmentSendItemOfEnhancedInfo(context, i, true, copySource[i].type, copySource);
                this.setShowTitle(item, this.mmsList);
                this.mmsList.push(item);
                sendMsgIndexesList.push({ copySourceIndex: i, mmsListIndex: this.mmsList.length > 0 ?
                    (this.mmsList.length - 1) : 0 });
            }
        }

        if (sendMsgIndexesList.length === 0) {
            HiLog.e(TAG, `sendDataRefreshOfEnhancedInfo sendMsgIndexesList.length is empty`);
            return;
        }
        ConversationDataSource.getInstance().addDataByIndexes([...sendMsgIndexesList.map(v => (v.mmsListIndex))]);
        //数据源已经更新就可以滚动了，在后面滚动会影响到发送动效
        this.scroller.scrollEdge(Edge.End);

        let maxGroupId: null | number = await this.getMaxGroupIdInMmsInfoTable(context);
        for (let i = 0; i < sendMsgIndexesList.length; i++) {
            let groupId: number | null = (typeof maxGroupId === 'number' && !isNaN(maxGroupId)) ?
                (maxGroupId + i + 1) : null;
            // 收发成功率打点-开始发送
            DotUtil.getInstance().reportSuccessRateForSendStart(dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_RCS);
            if (this.mmsList[sendMsgIndexesList[i].mmsListIndex].msgType === common.MSG_ITEM_TYPE.TEXT) {
                let actionData = this.buildActionDataOfEnhancedInfo(this.slotId, this.strContactsNumber,
                    this.strContactsName, this.getSendText(context, currentStr, false), false, groupId);
                this.sendInterval(context, actionData, this.mmsList, undefined, sendMsgIndexesList[i]);
            } else {
                let content = this.mmsList[sendMsgIndexesList[i].mmsListIndex].mmsSource?.[1]?.path || '';
                let actionData = this.buildActionDataOfEnhancedInfo(this.slotId, this.strContactsNumber,
                    this.strContactsName, content, true, groupId);
                this.sendInterval(context, actionData, this.mmsList, undefined, sendMsgIndexesList[i]);
            }
        }
        this.clearSelectContacts();
        this.isNewMsg = false;
        this.resetValuesOfEnhancedInfo();
    }

  private async getMaxGroupIdInMmsInfoTable(context: Context) {
    let conversationModel = new ConversationModel();
    let maxGroupId: null | number = null;
    if (context) {
      maxGroupId = await conversationModel.queryMaxGroupIdInMmsInfoTable(context);
    }
    return maxGroupId;
  }

    private buildActionDataOfEnhancedInfo(slotId: number, destinationHost: string, contactName: string | undefined,
        content: string, isEditMms: boolean, groupId: number | null): ActionDataType {
        HiLog.w(TAG, `buildActionDataOfEnhancedInfo slotId: ${slotId}`)
        let actionData: ActionDataType = new ActionDataType();
        actionData.slotId = slotId;
        actionData.destinationHost = destinationHost;
        actionData.contactName = contactName;
        actionData.isReSend = false;
        actionData.content = content;
        actionData.isEditMms = isEditMms;
        if (typeof groupId === 'number' && !isNaN(groupId)) {
            actionData.groupId = groupId;
        }
        return actionData;
    }
   /**
    * @param context Context
    * @param newConversationSendData 可选参数，只用于新建会话跳转历史会话的发送场景
    */
    sendPublish(context: Context, newConversationSendData?: NewConversationSendData):void {
        // 收发成功率打点-开始发送
        DotUtil.getInstance().reportSuccessRateForSendStart((newConversationSendData?.isEditMms ?? this.isEditMms) ?
        dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_MMS : dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_SMS);
        // Switching from the new state to the session state
        if (this.isNewMsg) {
            HiLog.w(TAG, 'send, isNewMsg: ' + this.isNewMsg);
            this.isNewMsgWithDraft = false;
            this.isChangeInputPlaceholder = false;
            this.newSend(context, () => {
                HiLog.w(TAG, 'send, newSendBack');
                if (this.isDraft) {
                    this.deleteDraftDataByThread(context);
                }
                this.sendDataRefresh(context, () => {
                    if (DeviceUtil.isSubDeviceWithConnected(context)) {
                        DotUtil.getInstance().reportEvent(dotSendParmas, dotCommon.eventName.DISTRIBUTED_SEND_MSG_EVENT);
                    } else {
                        DotUtil.getInstance().reportEvent(dotSendParmas, dotCommon.eventName.SENDING_SMS_EVENT);
                    }
                    if (AppStorage.get('currentMessagePage') as number > 1) {
                        editWordSizeParams.WORD_SIZE = 1;
                        DotUtil.getInstance().reportEvent(editWordSizeParams, dotCommon.eventName.SM_CONTENT_SIZE);
                    } else if (AppStorage.get('currentMessagePage') as number === 1) {
                        editWordSizeParams.WORD_SIZE = 2;
                        DotUtil.getInstance().reportEvent(editWordSizeParams, dotCommon.eventName.SM_CONTENT_SIZE);
                    }
                }, newConversationSendData);
                this.publishData(true, this.threadId);
            });
        } else {
            HiLog.w(TAG, 'send, isOldMsg');
            this.isChangeInputPlaceholder = false;
            if (this.isDraft) {
                DraftUtils.getInstance().deleteMessageByGroupIds([this.draftGroupId], context, () => {})
            }
            this.sendDataRefresh(context, undefined, newConversationSendData);
            this.publishData(true, this.threadId);
            // 信息回复——发信息发送打点
            if (DeviceUtil.isSubDeviceWithConnected(context)) {
                DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.DISTRIBUTED_REPLY_TO_SMS_EVENT);
            } else {
                DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.REPLY_TO_SMS_EVENT);
            }
            if (AppStorage.get('currentMessagePage') as number > 1) {
                editWordSizeParams.WORD_SIZE = 1;
                DotUtil.getInstance().reportEvent(editWordSizeParams, dotCommon.eventName.SM_CONTENT_SIZE);
            } else if (AppStorage.get('currentMessagePage') as number === 1) {
                editWordSizeParams.WORD_SIZE = 2;
                DotUtil.getInstance().reportEvent(editWordSizeParams, dotCommon.eventName.SM_CONTENT_SIZE);
            }
        }
    }
    /**
    * @param context Context
    * @param callback
    * @param newConversationSendData 可选参数，只用于新建会话跳转历史会话的发送场景
    */
    async sendDataRefresh(context: Context, callback?: Function, newConversationSendData?: NewConversationSendData) {
        hiTraceMeter.startTrace(TraceConstant.TRACE_SEND_MSG_CLEAN_TEXT,TraceConstant.TRACE_SEND_MSG_CLEAN_TEXT_ID);
        this.isSendStatus = true;
        this.slotId = MmsPreferences.getInstance().getSendMessageSlotId();
        this.textValue = MessageUtil.replaceForLossy7Bit(this.slotId,this.textValue,0,this.textValue.length);
        let item: mmsListType = new mmsListType();
        let textValue = this.textValue;

        //优先使用newConversationSendData的数据，用于新建会话跳转历史会话页面时的发送消息场景
        const isEditMms: boolean = newConversationSendData?.isEditMms ?? this.isEditMms;
        HiLog.i(TAG, `sendDataRefresh isEditMms ${isEditMms}`);
        const mmDisplaySource: Mms[] | undefined = newConversationSendData?.attachmentDataList ??
            this.mAttachAreaCtrl?.mmDisplaySource;
        HiLog.i(TAG, `sendDataRefresh mmDisplaySource length ${mmDisplaySource?.length}`);

        if (textValue != common.STR.EMPTY_STR && !isEditMms) { //初始化构建短信文本消息数据
            this.initSendItem(context, item, textValue);
        } else if (isEditMms) { //初始化构建彩信消息数据
            await this.initMmsItem(context, item, textValue, isEditMms, mmDisplaySource, (newTextValue: string) => {
                if (typeof newTextValue === 'string') {
                    textValue = newTextValue;
                }
            });
        }
        let actionData: ActionDataType = new ActionDataType();
        actionData.slotId = this.slotId;
        HiLog.w(TAG, `start getSendText slotId: ${this.slotId}`);
        actionData.destinationHost = this.strContactsNumber;
        actionData.contactName = this.strContactsName;
        actionData.content = this.getSendText(context, textValue, false);
        actionData.isEditMms = isEditMms;
        if (MmsUtil.isSlideType(item.contentType)) {
            const smilPath = item.mmsSource?.find(item => MmsUtil.isSmil(item.type))?.path || '';
            const basePath = smilPath.substring(0, smilPath.lastIndexOf('\/'));
            actionData.basePath = basePath;
        }
        this.formatDisplayPhoneNum();
        // Real SMS Sending
        this.sendInterval(context, actionData, this.mmsList, callback);
        this.isDraft = false; // 发送完后，清除草稿状态。防止误删已发送的草稿。
        this.textValue = common.STR.EMPTY_STR;
        hiTraceMeter.finishTrace(TraceConstant.TRACE_SEND_MSG_CLEAN_TEXT,TraceConstant.TRACE_SEND_MSG_CLEAN_TEXT_ID);
        this.canSendMessage = false;
        this.isShowFullScreen = false;
        this.clearMsm();
        this.resetMmsSource();
        this.setTabOperationStatus(false);
        this.distanceBottomFlag = false;
        this.receiveContactValue = common.STR.EMPTY_STR;
        this.clearSelectContacts();
        this.isNewMsg = false;
        this.scroller.scrollEdge(Edge.End);
    }

    isFoldSend(context: Context, strContactsNumber: string) {
        let curBp: string = AppStorage.get('curBp') as string;
        if (curBp !== common.STR.DEVICE_MOBILE_PHONE) {
            ConversationListController.getInstance().lastIndex = -1
            AppStorage.setOrCreate('selectPhoneNumber', strContactsNumber)
            GlobalContext.getContext().setObject('needToUpdate', true)
            ConversationListController.getInstance().refreshConversationListData(context);
        }
    }

    queryContactId(context: Context) {
        let actionData: LooseObject = {};
        actionData.telephones = [this.strContactsNumber];
        ContactsService.getInstance().queryContactDataByCondition(actionData, (res: LooseObject) => {
            if (res.code == common.int.FAILURE) {
                HiLog.i(TAG, 'new message send query contact id failed');
                return;
            }
            HiLog.i(TAG, 'new message send query contact id success');
            if (res.abilityResult.length > 0) {
                let result: BaseAbilityResult = res.abilityResult[0];
                // Use raw_contact_id instead of contact_id.
                this.rawContactId = result.rawContactId ?? '';
                this.contactId = result.contactId ?? '';
                this.portraitColor = AvatarColor.background.Color[Math.abs((Number.parseInt(this.rawContactId || '0', 10))) % 6];
                // Update session contactInfo
                this.sessionContactsInfo = [];
                (res.abilityResult as BaseAbilityResult[]).forEach((item) => {
                    let contactInfo: SessionContactInfoForDB = {
                        rawContactId: item.rawContactId ?? '',
                        contactId: item.contactId ?? '',
                        contactPhone: item.detailInfo,
                        contactName: item.displayName
                    };
                    this.sessionContactsInfo.push(contactInfo);
                })
            } else {
                this.portraitColor = common.STR.EMPTY_STR;
            }
    }, context);
    }

    newSend(context: Context, callback: Function) {
        hiTraceMeter.startTrace(TraceConstant.TRACE_NEW_SEND_CHECK,TraceConstant.TRACE_NEW_SEND_CHECK_ID);
        // Check whether the entered content has a value.
        if (this.receiveContactValue != common.STR.EMPTY_STR) {
            if (!TelephoneUtil.isPhoneNumber(this.receiveContactValue)) {
                // Invalid Recipient
                this.showToast($r('app.string.invalid_receive', this.receiveContactValue))
                HiLog.w(TAG, 'newSend, PhoneNumber is invalidate');
                hiTraceMeter.finishTrace(TraceConstant.TRACE_NEW_SEND_CHECK,TraceConstant.TRACE_NEW_SEND_CHECK_ID);
                return;
            }
        }
        if (this.getSelectContactsLength() > 0 && this.receiveContactValue != common.STR.EMPTY_STR) {
            let selectContact: selectContactType = {
                telephone: this.receiveContactValue,
                telephoneFormat: this.receiveContactValue,
                contactName: common.STR.EMPTY_STR,
                rawContactId: '',
                contactId: ''
            }
            let selectContacts = this.getSelectContacts();
            selectContacts.push(selectContact);
            this.initNewSelectContacts(selectContacts);
        } else if (this.getSelectContactsLength() > 0) {
            this.initNewSelectContacts(this.getSelectContacts());
        } else if (this.receiveContactValue != common.STR.EMPTY_STR) {
            this.contactsNum = 1;
            this.strContactsNumber = this.receiveContactValue;
            this.strContactsNumberFormat = this.receiveContactValue;
        } else {
            HiLog.w(TAG, 'newSend, the contact condition is not met.')
            hiTraceMeter.finishTrace(TraceConstant.TRACE_NEW_SEND_CHECK,TraceConstant.TRACE_NEW_SEND_CHECK_ID);
            return;
        }

        this.isNewMsg = false;
        // When the new page is displayed in full screen mode, the following table data needs to be obtained.
        if (true) {
            this.queryOldMessageList(context, this.strContactsNumber, callback);
        }
        hiTraceMeter.finishTrace(TraceConstant.TRACE_NEW_SEND_CHECK,TraceConstant.TRACE_NEW_SEND_CHECK_ID);
    }

    queryOldMessageList(context: Context, telephone: string, callback?: Function) {
        HiLog.i(TAG, 'queryOldMessageList, start');
        if (telephone == common.STR.EMPTY_STR) {
            return;
        }
        let number: string = TelephoneUtil.dealTelephoneSort(telephone);
        ConversationListService.getInstance().querySessionByTelephone(number, (res: LooseObject) => {
            HiLog.i(TAG, 'queryOldMessageList, querySessionByTelephone res.response.id: ' + res.response?.id);
            if (res.code == common.int.SUCCESS && res.response.id > 0) {
                if (this.threadId != res.response.id) {
                    // When modifying the recipient information, click Send and delete the session before the
                    // modification.
                    let condition: LooseObject = {};
                    condition.threadId = this.threadId;
                    ConversationListService.getInstance().deleteSessionByCondition(condition, () => {}, context);
                }
                this.isDraft = res.response.hasDraft;
                if (this.threadId !== res?.response?.id) {
                    // 对于新建/切换至已有老会话，会话id刷新后需要同步更新首选项中代表处于当前会话的标记currentTheadId
                    HiLog.i(TAG, `querySessionByTelephone before threadId is ${this.threadId}`);
                    HiLog.i(TAG, `querySessionByTelephone after threadId is ${res?.response?.id}`);
                    this.threadId = res.response.id;
                    this.publishData(true, this.threadId);
                }
                this.smsType = res.response?.smsType | 0;
                this.initCurrentQueryTimeID();
                this.queryMessageDetail(context, {
                    isDraft:this.isDraft,
                    currentPage:1,
                    threadId:this.threadId,
                    contactsNum:this.contactsNum,
                    queryTimeID:this.currentQueryTimeID,
                    startIndex: 0
                },() => {
                    this.scroller.scrollEdge(Edge.End);
                    if (callback) {
                        callback();
                    }
                }, true);
            } else {
                if (callback) {
                    callback();
                }
            }
        }, context, true /* isFuzzyMatch */ );
    }

    initNewSelectContacts(selectContacts: Array<selectContactType>) {
        HiLog.i(TAG, 'initNewSelectContacts, start');
        let contactsNumber = common.STR.EMPTY_STR;
        let contactsName = common.STR.EMPTY_STR;
        let contactsId = common.STR.EMPTY_STR;
        let contactsNumberFormat = common.STR.EMPTY_STR;
        let rawContactId:Array<string> = [];
        let contacts = TelephoneUtil.dealSelectContactsSort(selectContacts);
        let length = contacts.length;
        for (let index = 0; index < contacts.length; ++index) {
            let item = contacts[index];
            contactsNumber = contactsNumber + item.telephone + common.STR.COMMA;
            contactsId = contactsId + item.rawContactId + common.STR.COMMA;
            contactsNumberFormat = contactsNumberFormat + item.telephoneFormat + common.STR.COMMA;
            rawContactId.push(item.rawContactId);
            if (item.contactName != common.STR.EMPTY_STR) {
                contactsName += (item.contactName + common.STR.COMMA + common.STR.WHITE_SPACE);
            } else {
                let formatNum = TelephoneUtil.countryCodeFormatPhone(item.telephoneFormat);
                contactsName += formatNum + common.STR.COMMA + common.STR.WHITE_SPACE;
            }
        }
        this.strContactsNumber = contactsNumber.substring(0, contactsNumber.length - 1);
        this.strContactsName = contactsName.substring(0, contactsName.length - 2);
        this.rawContactId = rawContactId.join(common.STR.COMMA);
        this.photoFirstNameDeal(this.strContactsName);
        this.strContactsNumberFormat = length > 1 ? this.strContactsName :
        contactsNumberFormat.substring(0, contactsNumberFormat.length - 1);
        this.contactsNum = length;
        // Update session contactInfo
        this.sessionContactsInfo = [];
        contacts.forEach((item) => {
            let contactInfo: SessionContactInfoForDB = {
                rawContactId: (item.rawContactId ?? '') as string,
                contactId: (item.contactId ?? '') as string,
                contactPhone: item.telephone,
                contactName: item.contactName
            };
            this.sessionContactsInfo.push(contactInfo);
        })
    }

    handleWithSend(context: Context, actionData: ActionDataType, item: mmsListType, callback?: Function, copySourceIndex?: number) {
        HiLog.w(TAG, 'handleWithSend start');
        // Sending request processing
        let hosts: Array<string> = [];
        if (actionData.destinationHost.indexOf(',') == -1) {
            // single-shot
            hosts.push(actionData.destinationHost);
        } else {
            // Group Sending
            for (let host of actionData.destinationHost.split(',')) {
                hosts.push(host);
            }
        }
        actionData.hosts = hosts;
        if (item?.isRcs && (item?.mmsSource?.length > 1) && item?.mmsSource?.[1]?.type != undefined && item?.rcsType) {// Enhanced info and no text
            this.setRcsMsgType(actionData, item);
        }
        DotUtil.getInstance().reportEvent(rcsSendMsgParams, dotCommon.eventName.RCS_SEND_MSG);
        this.sendMassMessage(context, actionData, item, callback, copySourceIndex);
        HiLog.w(TAG, 'handleWithSend end');
    }

    setRcsMsgType(actionData: ActionDataType, item: mmsListType) {
        if (MmsUtil.isAudio(item.mmsSource[1].type) ||
            item.mmsSource[1].type === common.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE) {
            item.msgType = common.ENHANCED_INFO_ITEM_TYPE.AUDIO;
            rcsSendMsgParams.MSG_TYPE =  common.RCS_SEND_MSG.AUDIO;
            actionData.content = item.mmsSource[1].path;
        } else if (MmsUtil.isVcard(item.mmsSource[1].type)) {
            item.msgType = 5;
            rcsSendMsgParams.MSG_TYPE =  common.RCS_SEND_MSG.VCARD;
            let contact = item.mmsSource[1]?.contacts;
            let tempObj: SessionContentTypeOfRcs = {
                isSendMessage: 1,
                contactNum: contact?.length || 0,
                contactName: ''
            }
            let contactIndexSet = new Set(contact?.map(v => v.index));
            if (contactIndexSet.size === 1 && contact && contact[0]?.contactName) {
                tempObj.contactName = contact[0].contactName || '';
            }
            actionData.content = JSON.stringify(tempObj);
        } else if (MmsUtil.isFile(item.mmsSource[1].type)) {
            item.msgType = common.ENHANCED_INFO_ITEM_TYPE.FILE;
            rcsSendMsgParams.MSG_TYPE =  common.RCS_SEND_MSG.FILE;
            actionData.content = item.mmsSource[1].copyPath ? item.mmsSource[1].copyPath : item.mmsSource[1].path;
        } else if (item.rcsType === common.ENHANCED_INFO_ITEM_TYPE.IMAGE ||
            item.rcsType === common.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
            rcsSendMsgParams.MSG_TYPE =  item.rcsType;
            actionData.content = item.mmsSource[1].path || '';
        } else if (MmsUtil.isRcsMap(item.mmsSource[1].type)) {
            item.msgType = common.ENHANCED_INFO_ITEM_TYPE.MAP;
            rcsSendMsgParams.MSG_TYPE =  common.RCS_SEND_MSG.MAP;
            let accuracy: number = 0;
            if (item?.mmsSource[1]?.address) {
                let arrLocInfo: string = item?.mmsSource[1]?.address?.name + ';' + item?.mmsSource[1]?.address?.address;
                let arrAddressInfo: [LooseObject] = [{
                    'body': arrLocInfo,
                    'longitude': item?.mmsSource[1]?.address?.longitude.toString(),
                    'latitude': item?.mmsSource[1]?.address?.latitude.toString(),
                    'accuracy': accuracy.toString(),
                }];
                let addressJson: string = JSON.stringify(arrAddressInfo);
                addressJson = addressJson.slice(1, -1);
                actionData.content = addressJson;
            } else {
                actionData.content = item?.mmsSource[1]?.content ?? '';
            }
        }
    }

    /**
     * 插入页面消息列表前设置消息isShowTitle属性
     *
     * @param currentItem 当前消息
     * @param list 页面消息列表
     */
    setShowTitle(currentItem: mmsListType, list: mmsListType[]) {
        let preItem = list?.length > 0 ? list[list?.length - 1] : null;
        currentItem.showTitle = this.compareItemShowTitle(preItem, currentItem);
    }

    compareItemShowTitle(preItem: mmsListType | null, currentItem: mmsListType): boolean {
        //判断类型是否一样
        if (!preItem) {
            return true;
        }
        return preItem.isRcs !== currentItem.isRcs || preItem.isIpMsg !== currentItem.isIpMsg;
    }
    /*
     * 需要考虑用户修改了系统时间之后再发送消息，需要对消息进行重新排序。
     * useDefaultIndex:useDefaultIndex表示新的信息直接放到mmslist的最后一个位置。
     * mmsList 消息的列表数据。
     * 如下所示:
     * * 修改时间:20241210
     * item1:短信/彩信   20241209
     * item2:短信/彩信   20241210
     * 发送增强信息
     * item1:短信/彩信   20241209
     * item3:增强信息   20241210
     * item2:短信/彩信   20241210
     * 此时item2的日期显示需要关闭。
     * 重新插入排序之后，新的信息【index】和之后的【index+1】的数据的日期显示（dateShow）和类型显示（showTitle）都需要重新设置
     * */
    reSortMmsList(useDefaultIndex:boolean,mmsList: Array<mmsListType>){
        if (!useDefaultIndex || mmsList.length <= 1){
            //不需要重新排序的情况。
            return
        }
        // 需要考虑用户修改了系统时间之后再发送消息，需要对消息进行重新排序。
        let item = mmsList[mmsList.length-1];
        let insertItemIndex = mmsList.length - 1
        while (insertItemIndex > 0 &&
            (item.timeMillisecond as number) < (mmsList[insertItemIndex-1].timeMillisecond as number)) {
            insertItemIndex -= 1;
        }
        HiLog.i(TAG, '[reSortMmsList] insertItemIndex: ' + insertItemIndex + ' mmsList.length:' + mmsList.length)
        // 情况1:新发送的信息插入到列表最后。
        if (insertItemIndex == mmsList.length - 1) {

            //不需要重新排序，最后一个信息的日期小于修改后的时间
            //直接判断最后一个元素是否需要显示日期和标题。
            item.showTitle = this.compareItemShowTitle(mmsList[insertItemIndex-1], item);
            item.dateShow = DateUtil.isNotSameDay(mmsList[insertItemIndex-1].timeMillisecond, item.timeMillisecond);
            return;
        }
        //从时间上说，最后一个元素的排序位置不正确，
        //因此需要先把最后一个元素删除掉，然后插入到对应的位置。
        mmsList.splice(mmsList.length - 1,1)
        //把最后一个数据插入到对应的位置
        mmsList.splice(insertItemIndex , 0, item)
        if (insertItemIndex == 0) {
            // 情况2:新发送的信息插入到列表前面。
            HiLog.i(TAG, '[reSortMmsList] insert in head insertItemIndex: ' + insertItemIndex + ' mmsList.length:' +
            mmsList.length)
            item.showTitle = true
            item.dateShow = true
        } else {
            // 情况3:新发送的信息插入到列表中间。
            HiLog.i(TAG, '[reSortMmsList] insert in middle insertItemIndex: ' + insertItemIndex + ' mmsList.length:' +
            mmsList.length)
            item.showTitle = this.compareItemShowTitle(mmsList[insertItemIndex-1], item)
            item.dateShow = DateUtil.isNotSameDay(mmsList[insertItemIndex-1].timeMillisecond, item.timeMillisecond)
        }
        //情况2和3:对新插入信息的后一个信息进行重新设置。
        mmsList[insertItemIndex+1].showTitle = this.compareItemShowTitle(mmsList[insertItemIndex+1], item)
        mmsList[insertItemIndex+1].dateShow = DateUtil.isNotSameDay(mmsList[insertItemIndex+1].timeMillisecond, item.timeMillisecond)
        this.mmsList = mmsList
        ConversationDataSource.getInstance().refresh(this.mmsList);
    }

    /**
     *
     * @param actionData
     * @param mmsList
     * @param callback
     * @param mmsListIndexes mmsListIndex:need send item's index, Value Range: [0, mmsList.length - 1]
     */
    sendInterval(context: Context, actionData: ActionDataType, mmsList: Array<mmsListType>, callback?: Function,
        mmsListIndexes?: SendMsgIndexes) {
        HiLog.w(TAG, 'enter sendInterval');
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_INIT_MMS,
            TraceConstant.TRACE_CONVERSATION_INIT_MMS_ID);
        // Send Timer
        let useDefaultIndex: boolean = (mmsListIndexes === undefined) ? true : false;
        let index = (mmsListIndexes === undefined) ? (mmsList.length - 1) : mmsListIndexes.mmsListIndex;
        HiLog.w(TAG, 'sendInterval index is:' + index);
        let item = mmsList[index];
        this.reSortMmsList(useDefaultIndex, mmsList);
        this.handleWithSend(context, actionData, item, callback, mmsListIndexes?.copySourceIndex);
        HiLog.w(TAG, 'leave sendInterval');
        hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_INIT_MMS,
            TraceConstant.TRACE_CONVERSATION_INIT_MMS_ID);
    }

    changeValue(e: string) {
        HiLog.i(TAG, 'changeValue, start!');
        this.textValue = e;
        if (e == null || e == common.STR.EMPTY_STR) {
            if (this.isEditMms) {
                this.canSendMessage = true;
            } else {
                this.canSendMessage = false;
                return;
            }
        }
        if (this.isNewMsg) {
            if (this.receiveContactValue == '' && this.getSelectContactsLength() == 0) {
                this.canSendMessage = false;
                return;
            }
        }
        this.canSendMessage = MmsPreferences.getInstance().haveSimCardReady() && !this.isFlightMode;
        if (this.isNewMsg) {
            this.setCanSendMsgStatus();
        }
    }

    setTabTitleText() {
        // TabTitleText selected globally
        if (this.tabIndex != 1) {
            // Non-picture page
            this.tabTitleText = this.tabTextList[this.tabIndex];
            return;
        }
        // On the image selection page, the number of selected images is displayed.
        let size = 0;
        for (let element of this.pictureListFromGallery) {
            if (element.checkedValue) {
                size++;
            }
        }
        this.tabTitleText = size == 0 ? $r('app.string.msg_unselected_tip') : $r('app.plural.msg_selected_tip_new', size, {
            number: LocationUtil.numFormat(size)
        });
    }

    // Check whether the sending icon can be highlighted.
    judgeSendBtnCanClicked() {
        HiLog.i(TAG, 'judgeSendBtnCanClicked, start!');
        if ((MmsPreferences.getInstance().haveSimCardReady()) && (this.mmsEditList.length != 0 ||
        this.textValue != common.STR.EMPTY_STR || this.textareaDatasource.length !== 0)) {
            if (this.isNewMsg) {
                if ((this.receiveContactValue !== '' && TelephoneUtil.isPhoneNumber(this.receiveContactValue)) ||
                    this.getSelectContactsLength() !== 0) {
                    this.canSendMessage = true;
                }
            } else {
                this.canSendMessage = true;
            }
        }
    }

    // Subscribing to Public Events
    subscribeDetail(context: Context, isChatbotConversation: boolean) {
        HiLog.i(TAG, 'subscribeDetail, start');
        let events = [common.STR.RECEIVE_TRANSMIT_EVENT]
        interface  commonEventSubscribeInfoType {
            events: string[],
            publisherPermission: string;
        }
        let commonEventSubscribeInfoSms: commonEventSubscribeInfoType = {
            events: events,
            publisherPermission: 'ohos.permission.RECEIVE_SMS'
        };
        // Creating Subscription Information
        commonEvent.createSubscriber(commonEventSubscribeInfoSms, (arg1, arg2) => {
            this.createSubscriberCallBack(context, arg1, arg2, isChatbotConversation);
        });
        let commonEventSubscribeInfoMms: commonEventSubscribeInfoType = {
            events: events,
            publisherPermission: 'ohos.permission.RECEIVE_MMS'
        };
        commonEvent.createSubscriber(commonEventSubscribeInfoMms, (arg1, arg2) => {
            this.createSubscriberCallBack(context, arg1, arg2, isChatbotConversation);
        });
        this.messageTimeout.subscribeDetail();
    }

  createSubscriberCallBack(context: Context, err: BusinessError, data: commonEventManager.CommonEventSubscriber,
    isChatbotConversation: boolean) {
        this.commonEventData = data;
        // Received subscription
        commonEvent.subscribe(this.commonEventData, (arg1, arg2) => {
            this.subscriberCallBack(context, arg1, arg2, isChatbotConversation);
        });
    }

    subscriberCallBack(context: Context, err: BusinessError, data: commonEventManager.CommonEventData,
      isChatbotConversation: boolean) {
        if (!CheckUtil.hasBarProperty(data, 'parameters')) {
            HiLog.e(TAG, 'subscriberCallBack, data don`t have dataParameters');
            return;
        }
        this.dataParameters = data.parameters!;
        let notNeedScrollToEnd: boolean =
            CheckUtil.hasBarProperty(data.parameters as commonEventManager.CommonEventData, 'notNeedScrollToEnd');
        if (CheckUtil.hasBarProperty(data.parameters as commonEventManager.CommonEventData, 'telephone')) {
            this.dataParametersPhone = data.parameters?.telephone;
        } else {
            HiLog.e(TAG, 'subscriberCallBack, parameters don`t have telephone');
        }
        HiLog.i(TAG, 'subscriberCallBack, start');
        GlobalContext.getContext().setObject('needToUpdate', true);
        AppStorage.setOrCreate('mmsReceivedToRunGeoTransition', true);
        AppStorage.setOrCreate('receiveNeedUpdate', true);
        let tmp: number[] = [];
        for (let index: number = 0; index < this.mmsList.length; index++) {
            if (this.mmsList[index].isCbChecked) {
                tmp.push(index);
            }
        }
        // Receiving SMS Updates
        setTimeout(() => {
            // 将this.messageCount 置为 无效数据 触发重新查询
            this.messageCount = common.int.INVALID_DATA;
            this.queryMessageDetail(context, {
                isDraft: this.isDraft,
                currentPage: 1,
                threadId: this.threadId,
                contactsNum: this.contactsNum,
                queryTimeID:this.currentQueryTimeID,
                startIndex: 0,
                notNeedScrollToEnd: notNeedScrollToEnd
            }, () => {
                for (let index = 0; index < tmp.length; index++) {
                    this.mmsList[tmp[index]].isCbChecked = true;
                }
                if (this.mmsList != null && this.mmsList.length > 0) {
                    this.emiterSlotid(this.mmsList[this.mmsList.length - 1].subId);
                }
                ConversationDataSource.getInstance().refresh(this.mmsList);
                animateTo({
                    curve: curves.interpolatingSpring(0, 1, 342, 37), onFinish: () => {
                        AppStorage.setOrCreate('mmsReceivedToRunGeoTransition', false);
                    }
                }, () => {
                    if (!notNeedScrollToEnd) {
                        this.scroller.scrollEdge(Edge.End);
                    }
                })
            });
            this.isMessageCheckAll = false
            if (this.isSelectStatus) {
                let needChange: boolean = AppStorage.get('isNeedReloadToolBar') as boolean;
                AppStorage.setOrCreate('isNeedReloadToolBar', !needChange);
            }
            let actionData: LooseObject = this.setSubscriberCallBackActionData();
            if (!this.isPageHide) {
                HiLog.w(TAG, 'subscriberCallBack cancelMessageNotify');
                NotificationService.getInstance().cancelMessageNotify(context, actionData, () => {
                    ConversationListService.getInstance().markAllToRead(context, actionData, () => {
                        let badgeContext: IBadgeContextInfo = {
                            appContext: context,
                            updateBadgeEventCode: 'subscriberCallBack',
                            tracedId: systemDateTime.getTime().toString(),
                        }
                        NotificationService.getInstance(context).updateBadgeNumberWithContext(badgeContext);
                    });
                });
            }
        }, 500);
        if (data.parameters && data.parameters.msgId) {
            this.checkFaceMmsStatus(data.parameters.msgId, context);
        }
    }

     private async checkFaceMmsStatus(msgId: string, context: Context) {
        let faceDetectStatus = SharedPreferencesUtils.getFromPreferences('spamshield_message_live_detection', 0) as number;
        if (faceDetectStatus == 1) {
            await mmsReceive.queryMmsPartInfo(msgId, (result: LooseObject)=> {
                if (result && result.length > 0) {
                    for (let i = 0; i < result.length; i++) {
                        AiFaceChangeUtils.getInstance().startAiFaceChange(result[i].locationPath, result[i].mmsPartId, (result, fileId)=> {
                            let isFraud = AiFaceChangeUtils.getInstance().getDetectionResult(result);
                            HiLog.i(TAG, 'shike face mms mmsPartId: ' + fileId + 'isFraud: ' + isFraud);
                            if (isFraud) {
                                mmsReceive.updateMmsPartById(fileId, 1);
                                // 彩信的mmsSource中数组有2个，一个是smil文件，另一个是图片或者视频文件。
                                let mmsSourceList = this.mmsList[this.mmsList.length - 1].mmsSource;
                                for (let i = 0; i < mmsSourceList.length; i++) {
                                    if (mmsSourceList[i].type == 1) {
                                        this.mmsList[this.mmsList.length - 1].mmsSource[i].isFraud = 1;
                                    }
                                }
                                ConversationDataSource.getInstance().refresh(this.mmsList);
                            }
                        })
                    }
                    AiFaceChangeUtils.getInstance().finalizeModel();
                }
            }, context);
        }
    }

    private setSubscriberCallBackActionData(): LooseObject {
        let actionData: LooseObject = {};
        actionData.threadId = this.threadId;
        actionData.hasRead = common.is_read.UN_READ;
        return actionData;
    }

     emiterSlotid(slotId: number) {
        let eventData: emitter.EventData = {
            data: {
                'slotId': slotId
            }
        };

        let innerEvent: emitter.InnerEvent = {
            eventId: EmitterConstant.EVENT_RECEIVE_IN_CONTACT,
            priority: emitter.EventPriority.HIGH
        };
        HiLog.i(TAG, 'emiterSlotid');
        emitter.emit(innerEvent, eventData);
    }

    // Unsubscribe
    unSubscribeDetail() {
        if (this.commonEventData != null) {
            commonEvent.unsubscribe(this.commonEventData, () => {
                HiLog.i(TAG, 'unSubscribeDetail, unsubscribe');
            });
            this.commonEventData = undefined
        }
    }

    public publishData(isShow: boolean, currentThreadId: number): void {
        SharedPreferencesUtils.saveToPreferences('notificationIsShow', isShow);
        SharedPreferencesUtils.saveToPreferences('currentThreadId', currentThreadId);
    }

  async initSearchIndex(context: Context) {
    if (!StringUtil.isEmpty(this.searchMsgId)) {
      await this.getSearchIndexByMsgId(context);
    } else {
      this.searchMsgIndex = -1;
    }
  }

  async getSearchIndexByMsgId(context: Context): Promise<void> {
    if (StringUtil.isEmpty(this.searchMsgId)) {
      HiLog.w(TAG, ` getIndexByMsgId msgId is null.`);
      return;
    }
    HiLog.i(TAG, ` getIndexByMsgId,searchMsgId:${this.searchMsgId}`);
    let actionData: LooseObject = {
      'msgId': this.searchMsgId,
      'threadId': this.threadId,
      'contactsNum': this.contactsNum
    }
    let conversationModel = new ConversationModel();
    this.searchMsgIndex = await conversationModel.querySmsMmsSearchIndexByCondition(actionData, context);
  }

    async jumpToIndex(context: Context) {
        let conversationModel = new ConversationModel();
        let rcsId: null | number = null;
        if (context) {
            rcsId = await conversationModel.querySmsMmsInfoRcsIdByCondition(this.searchMsgId, context);
        }
        if (this.searchContent !== '') {
            let scrollIndex: number = this.mmsList.length - 1;
            for (let index = 0; index < this.mmsList.length; index++) {
                let mms: mmsListType = this.mmsList[index];
                if (mms?.id === Number.parseInt(this.searchMsgId)) {
                    scrollIndex = index;
                    break;
                } else if (rcsId !== 0 && mms?.rcsId === rcsId) {
                    scrollIndex = index;
                    break;
                }
            }
            this.scroller.scrollToIndex(scrollIndex);
        } else {
            this.scroller.scrollEdge(Edge.End);
        }
        HiLog.i(TAG, 'jumpToIndex end');
    }

    public scrollToEnd() {
        if (this.searchContent == '') {
            this.scroller.scrollEdge(Edge.End);
        }
    }

    // In the selection mode, tap More. In the displayed menu, select
    moreSelected(context: Context, e: number | string) {
        HiLog.i(TAG, 'moreSelected, e: ' + JSON.stringify(e))
        switch (e) {
            case '0':
            // duplicating
                this.copyText();
                break;
            case 1:
            // Share
                this.share(context);
                break;
            case 2:
            // Select Text
                this.gotoTextSelect(this.mmsIndex);
                break;
            case 3:
            // lock
                //this.lock();
                break;
            case 4:
            // Show Details
                this.showDetails();
                break;
            case 5:
            // Unlock
                //this.unlock();
                break;
            case 6:
            // View Reports
                this.showReport(this.mmsIndex);
                break;
            case 7:
            // Save Attachments
                this.saveImage(context);
                break;
            case 8:
            // Querying vCard Details
                this.showVcarDetail(this.mmsIndex);
                break;
            default:
                break;
        }
        // Exit the multi-selection mode.
        this.exitMultiselect();
    }

    /**
     * 会话页面的消息复制功能
     *
     * @param selectText 已选中的文本
     */
    copyText(selectText?: string) {
        if (!StringUtil.isEmpty(selectText)) {
            commonPasteboard.setPasteboard(selectText as string);
            return;
        }
        let text = ''
        let content = this.mmsList[this.mmsIndex]?.content
        if (this.mmsList[this.mmsIndex]?.msgShowType === common.MESSAGE_SHOW_TYPE.MAP) {//彩信位置消息
            content = (this.mmsList[this.mmsIndex].mmsSource?.find(v => (v &&
                v.type === common.MM_ATTACHMENT_TYPE.MAP))?.content) ?? '';
        }
        text += content;
        commonPasteboard.setPasteboard(text as string);
    }

    copyMultipeText() {
        let pasteData: LooseObject = [];
        let copyText: string = '';
        for(let i = 0; i < this.mmsList.length; i++) {
            if(this.mmsList[i].isCbChecked) {
                let selectText = this.mmsList[i].content as string;
                pasteData.push(selectText);
            }
        }
        copyText = pasteData.join('\n');
        commonPasteboard.setPasteboard(copyText);
    }

    share(context: Context) {
        for (let i = 0; i < this.mmsList.length; i++) {
            if (this.mmsList[i].isCbChecked == true) {
                let actionData: LooseObject = {};
                actionData.content = this.mmsList[i].content;
                ConversationService.getInstance().gotoShare(actionData, () => {}, context);
            }
        }
    }

    gotoTextSelect(idx: number) {
        this.pushToCopyController(idx, this.currentMmsItem);
    }

    showDetails() {
        for (let index = 0; index < this.mmsList.length; index++) {
            if (this.mmsList[index].isCbChecked == true) {
                let time = this.mmsList[index].timeMillisecond;
                let timeStash = this.getTime(String(time));
                this.mmsTime = timeStash + String(this.mmsList[index].time);
                if (this.mmsList[index].msgType == 0) {
                    this.isMmsType = $r('app.string.sms');
                } else {
                    this.isMmsType = $r('app.string.mms');
                }

                if (this.mmsList[index].isReceive) {
                    this.isSendRecipient = true;
                } else {
                    this.isSendRecipient = false;
                }
            }
        }
        //    this.$element('mms_details_dialog').show();
    }

    showReport(mmsIndex: number) {
        // View Reports
        let item = this.mmsList[mmsIndex];
        let param: Record<string, boolean | string | number> = {
            'isMsm': item.isMsm,
            'telephone': this.strContactsNumber,
            'sendStatus': item.sendStatus,
            'timeMillisecond': item.timeMillisecond
        }
        this.pageInfos.pushPathByName('queryReport', param);
    }

    saveImage(context: Context) {
        let actionData: LooseObject = {};
        actionData.threadId = this.mmsList[this.mmsIndex]?.threadId;
        actionData.pduId = this.mmsList[this.mmsIndex]?.pduId;
        ConversationService.getInstance().saveImage(actionData, (result: ResourceStr) => {
            this.showToast(result);
        }, context);
    }

    showVcarDetail(mmsIndex: number) {

    }

    exitMultiselect() {
        // Exit the multi-selection state.
        this.setSelectStatus(false);
        this.cancelCheckedAll();
    }

    longPressMore(context: Context, e: number) {
        switch (e) {
            case 0:
            // delete
                this.deleteDetail();
                break;
            case 1:
            // New Contact
                this.createNewContact(context, this.strContactsNumber);
                break;
            case 2:
            // Save to Existing Contacts
                this.existingContact(context, this.strContactsNumber);
                break;
            case 3:
            // Edit Before Call
                this.callEditor(context, this.strContactsNumber);
                break;
            case 4:
            // Add to Blocklist
                this.callEditor(context, this.strContactsNumber);
                break;
            case 5:
            // View Contacts
                this.titleBarAvatar(context);
                break;
            default:
                break;
        }
    }

    // Delete
    deleteDetail() {
        if (this.mmsList.length == 1) {
            this.strMsgDeleteDialogTip = $r('app.string.msg_delete_dialog_con_tip3');
        } else {
            ConversationDataSource.getInstance().selectList = [] // 点击更多-删除，清除已选择列表
            this.hasDetailDelete = false;
            this.setSelectStatus(true);
        }
    }

    // New Contact
    createNewContact(context: Context, number: string) {
        let actionData: LooseObject = {};
        actionData.phoneNumber = number;
        actionData.pageFlag = common.contactPage.PAGE_FLAG_SAVE_CONTACT;
        this.jumpToContact(context, actionData);
    }

    // Switching to the Contacts app
    viewContacts(context: Context) {
        let actionData: Record<string, string> = {
            'phoneNumber': this.strContactsNumber,
            'pageFlag': common.contactPage.PAGE_FLAG_CONTACT_DETAILS
        };
        this.jumpToContact(context, actionData);
    }

    // Edit Before Call
    callEditor(context: Context, number: string) {
        let actionData: LooseObject = {};
        actionData.phoneNumber = number;
        actionData.pageFlag = common.contactPage.PAGE_FLAG_EDIT_BEFORE_CALLING;
        this.jumpToContact(context, actionData);
    }

    // Save to Existing Contacts
    existingContact(context: Context, number: string) {
      let actionData: LooseObject = {};
        actionData.phoneNumber = number;
        actionData.pageFlag = common.contactPage.PAGE_FLAG_SAVE_EXIST_CONTACT;
        this.jumpToContact(context, actionData);
    }

    // Switching to the Contacts app
    jumpToContact(context: Context, actionData: LooseObject) {
        if (actionData.pageFlag != null) {
            let str = commonService.commonContactParam(actionData);
            (context as myCommon.UIAbilityContext).startAbility(str).then(() => {
                HiLog.i(TAG, 'jumpToContact, startAbility Success');
            }).catch((error: BusinessError) => {
                HiLog.e(TAG, 'jumpToContact, failed. Cause: ' + JSON.stringify(error.message));
            })
        }
        else {
            HiLog.e(TAG, 'jumpToContact, failed. Cause: pageFlag null');
        }
    }

    // Tap a contact's avatar to go to the contact details page.
    titleBarAvatar(context: Context) {
        let actionData: Record<string, string> = {
            'phoneNumber': this.strContactsNumber,
            'pageFlag': common.contactPage.PAGE_FLAG_CONTACT_DETAILS
        };
        this.jumpToContact(context, actionData);
    }

    public clickCall(context: Context, builder?: SelectDialogBuilder): void {
        HiLog.i(TAG, 'clickCall, start!');
        let phoneNumber: string = '';
        if (this.isChatbotNumber()) {
            phoneNumber = this.callbackPhoneNumber;
        } else {
            phoneNumber = this.strContactsNumber;
        }
        if (!MmsPreferences.getInstance().haveSimCardReady()) {
            HiLog.i(TAG, 'No SIM card!');
            CallService.fromString(phoneNumber).call();
        } else if (this.isAllCardActive && builder != null) {
            let title: string = context.resourceManager
                .getStringSync($r('app.string.contacts_call_number').id).replace('%s', phoneNumber);
            builder.title = title;
            builder.multiSimCardItems[0].name = MmsPreferences.getInstance().getDispalyNameOfSim1();
            builder.multiSimCardItems[0].phone = MmsPreferences.getInstance().getTelephoneNumberOfSim1();
            builder.multiSimCardItems[1].name = MmsPreferences.getInstance().getDispalyNameOfSim2();
            builder.multiSimCardItems[1].phone = MmsPreferences.getInstance().getTelephoneNumberOfSim2();
            builder.callback = (value: number) => {
                CallService.fromString(phoneNumber).dial({
                    accountId: value,
                });
            }
            let actionData: Record<string, string> = {
                'phoneNumber': phoneNumber
            };
            builder.lastSimId = common.int.INVALID;
            ContactsService.getInstance().queryCallLogByCondition(actionData, (result: LooseObject) => {
                builder.lastSimId = result.abilityResult
                builder.controller?.open();
            }, context)
                .catch(() => {
                    builder.controller?.open();
                })
        } else {
            CallService.fromString(phoneNumber).call();
        }
        if (this.isChatbotNumber()) {
            this.callbackPhoneNumber = '';
        }
    }

    private isChatbotNumber() {
        if (this.strContactsNumber.startsWith('sip:') && this.strContactsNumber.includes('botplatform')) {
            return true;
        }
        return false;
    }

    getTime(nS: string) {
        let date = new Date(Number.parseInt(nS));
        let year = date.getFullYear();
        let mon = date.getMonth() + 1;
        let day = date.getDate();
        return year; // + $r('app.string.year') + mon + $r('app.string.month') + day + $r('app.string.day');
    }

    // Contact data returned on the new page
    setReceiveContactValue(context: Context, receiverData: BaseItemType) {
        let selectContacts = receiverData.selectContacts;
        let receiveContactValue = selectContacts.length > 0 ? common.STR.EMPTY_STR : receiverData.contactValue;
        let hasBlur: boolean = receiverData.hasBlur;
        this.setCanSendMessage(selectContacts, receiveContactValue)
        let routerParams: mmsListType = this.pageInfos.getParamByIndex(this.pageInfos.size() - 1) as mmsListType;
        if(receiveContactValue != this.strContactsName && routerParams?.isDraft == null) {
            this.isDraft = false;
        }
        if (hasBlur && receiveContactValue != common.STR.EMPTY_STR) {
            let index = -1;
            for (let i = 0; i < selectContacts.length; i++) {
                let contact = selectContacts[i];
                if (isSameTel(contact.telephone, receiveContactValue)) {
                    index = i;
                    break;
                }
            }
            if (index >= 0) {
                selectContacts.splice(index, 1);
            }
        }
        if (receiveContactValue != common.STR.EMPTY_STR) {
            this.receiveContactValue = receiveContactValue;
        } else {
            this.receiveContactValue = common.STR.EMPTY_STR;
        }
        if(selectContacts.length > 0) {
            for (let item of selectContacts) {
                this.dealJudgeTelephone(context, item);
                this.setSelectContacts(selectContacts);
            }
        } else {
            this.clearSelectContacts();
        }
        if (this.draftModel !== null && !this.draftModel?.isHasGetContacts ) {
            this.draftModel.initialSelectContacts = [...selectContacts]
            this.draftModel.hasGetContactsThreadID = this.threadId ?? 0
            this.draftModel.isHasGetContacts = true
        }
    }

    private dealJudgeTelephone(context: Context, item: itemType) {
        if (!TelephoneUtil.isPhoneNumber(item?.telephone)) {
            item.telephone = this.replaceCode(item.telephone);
            item.telephoneFormat = this.replaceCode(item.telephoneFormat);
            if (item.contactName != common.STR.EMPTY_STR) {
                item.contactName = common.STR.EMPTY_STR;
            }
        } else {
            this.dealJudgeYellowPageExist(context, item);
        }
    }

    private dealJudgeYellowPageExist(context: Context, item: itemType) {
        if (StringUtil.isEmpty(item?.contactName)) {
            YellowPageService.getInstance()
                .judgeNewPageHasYellowPageExist(item, context).then((res: LooseObject) => {
                if (!StringUtil.isEmpty(res.yellowPageId)) {
                    item.contactName = res.name;
                    this.dealJudgeYellowPageExistEmit(res.name);
                }
            });
        }
    }

    private dealJudgeYellowPageExistEmit(name: string) {
        if (this.getSelectContactsLength() == 1) {
            let innerEvent: emitter.InnerEvent = {
                eventId: EmitterConstant.EVENT_IS_INPUT_STATUS,
            };

            let eventData: emitter.EventData = {
                data: {
                    'isInputStatus': false,
                    'contactsLength': this.getSelectContactsLength(),
                    'strSelectContact': name
                }
            }
            emitter.emit(innerEvent, eventData);
        }
    }

    setCanSendMessage(selectContacts: itemType[], receiveContactValue: string) {
        HiLog.i(TAG, 'setCanSendMessage, start!');
        if (this.textValue != common.STR.EMPTY_STR || this.isEditMms) {
            if (this.canSendMessage) {
                if (selectContacts.length == 0 && receiveContactValue == common.STR.EMPTY_STR) {
                    this.canSendMessage = false;
                }
            } else if ((selectContacts.length != 0 || receiveContactValue != common.STR.EMPTY_STR) &&
                (MmsPreferences.getInstance().haveSimCardReady())) {
                this.canSendMessage = true;
            }
        }
    }

    changeReceiveInputStatus() {
        let changeInputStatusEvent: emitter.InnerEvent = {
            eventId: EmitterConstant.EVENT_CHANGE_NEW_INPUT_STATUS,
            priority: emitter.EventPriority.HIGH
        }
        emitter.emit(changeInputStatusEvent);
    }

    pushToGroupDetail(index: number) {
        let param: Record<string, string | number | Resource | object | boolean> = {
            'threadId': this.threadId,
            'groupId': this.mmsList[index].groupId,
            'content': this.mmsList[index].content,
            'slotId': this.slotId,
            'mmsSource': this.mmsList[index].mmsSource,
            'isAirPlaneMode': this.isAirPlaneMode
        }
        this.pageInfos.pushPathByName('GroupDetail', param);
    }

    setResendIndex(index: number) {
        this.resendIndex = index;
    }

    resendMsg(context: Context, resendStateIsRcs?:boolean,isSameSoltId?:boolean) {
      HiLog.i(TAG, 'tmbtmb--resendMsg start');
      if(resendStateIsRcs){
            // let isRcsOpen: boolean = rcs.isRcsLoggedIn();
            // if(!isRcsOpen||!isSameSoltId){
            //     let option: promptAction.ShowToastOptions = {
            //         message: $r('app.string.not_loggedin_RCS'),
            //         duration: 2000,
            //         bottom: 80
            //     }
            //     MmsUtil.showToast(option);
            //     return;
            // }
        }
        if (this.mmsList.length < this.resendIndex) {
          HiLog.i(TAG, 'resendMsg this.mmsList.length < this.resendIndex');
            return;
        }
        let deleteItem = this.mmsList[this.resendIndex];
        if (!deleteItem) {
            HiLog.e(TAG, 'resendMsg deleteItem is empty');
            return;
        }

        this.slotId = MmsPreferences.getInstance().getSendMessageSlotId();
        deleteItem.position = '';
        HiLog.w(TAG, 'resendMsg deleteItem position length:' + deleteItem.position?.length);
        this.mmsList.splice(this.resendIndex, 1);
        let groupIds = [deleteItem.groupId];
        let groupInfos: Array<groupIdsInfos> = [];
        groupInfos.push({
            groupId: deleteItem.groupId,
            isRcs: deleteItem.isRcs,
            msgId: deleteItem.id,
            rcsId: deleteItem.rcsId,
            isNeedDeleteSourceFile: false,
            isMms: deleteItem.isMsm,
            isCollect: deleteItem.is_collect
        });
        DraftUtils.getInstance().deleteMessageByGroupIds(groupIds, context,
            () => {}, groupInfos,resendStateIsRcs);
        let item = this.initResendItem(deleteItem);
        item.isRcs = (resendStateIsRcs === true) ? 1 : 0;
        this.resendSms(context, this.strContactsNumber, item, this.mmsList, resendStateIsRcs);
    }

    getSelectMmsStatus(){
        if (this.mmsList.length < this.resendIndex) {
            return;
        }
        let deleteItem = this.mmsList[this.resendIndex];
        let item = this.initResendItem(deleteItem);
        return item.isRcs;
    }
    initResendItem(deleteItem: mmsListType) {
        let item: mmsListType = this.initByDeleteItem(deleteItem);
        this.setShowTitle(item, this.mmsList);
        this.mmsList.push(item);
        let tempRcsId: number = -1;
        let tempSatellite: number = -1;
        for (let item of this.mmsList) {
            item.showTitle = (tempRcsId !== item.isRcs);
            tempRcsId = item.isRcs as number;
        }
        ConversationDataSource.getInstance().refresh(this.mmsList);
        return item;
    }
    initByDeleteItem(deleteItem: mmsListType) : mmsListType {
        let item: mmsListType = new mmsListType()
        item.id = deleteItem.id;
        item.isRcs = deleteItem.isRcs;
        item.content = deleteItem.content;
        item.msgTitle = deleteItem.msgTitle;
        item.msgType = deleteItem.msgType;
        item.audioTime = deleteItem.audioTime;
        item.isCbChecked = deleteItem.isCbChecked;
        item.is_collect = deleteItem.is_collect;
        item.groupId = deleteItem.groupId;
        item.isMsm = deleteItem.isMsm;
        if (item.isMsm) {
            item.isRcs = common.MESSAGE_TYPE.SMS_OR_MMS;
        }
        item.isFullScreenImg = deleteItem.isFullScreenImg;
        item.msgUriPath = deleteItem.msgUriPath;
        item.mmsEditListTemp = deleteItem.mmsEditListTemp;
        item.hasReport = deleteItem.hasReport;
        item.contentType = deleteItem.contentType;
        item.mmsSource = deleteItem.mmsSource;
        item.rcsType = deleteItem.rcsType;
        item.totalSize = deleteItem.totalSize;
        item.isReceive = false;
        item.subId = this.slotId;
        item.date = common.STR.EMPTY_STR;
        item.detailTime = $r('app.string.just');
        item.timeMillisecond = new Date().getTime();
        DateUtil.convertTimeStampToDateWeek(item, false);
        DateUtil.fullDate(item);
        item.sendStatus = this.getMessageSendStatus();
        if (this.contactsNum > 1 && !item.isMsm) {
            item.completeNumber = this.contactsNum - deleteItem.failuresNumber;
            item.failuresNumber = 0;
        } else {
            item.completeNumber = deleteItem.completeNumber;
            item.failuresNumber = 0;
        }
        item.position = deleteItem.position;
        item.latitudeAndLongitude = deleteItem.latitudeAndLongitude;
        item.msgShowType = deleteItem.msgShowType;
        return item;
    }

    initRendContent(context: Context, item:mmsListType) : string {
        let content: string = item.content as string;
        return content;
    }

    resendSms(context: Context, destinationHost: string, item: mmsListType, mmsList: mmsListType[], resendStateIsRcs?:boolean) {
        HiLog.i(TAG, 'resendSms start');
        let msgType: number;
        if (resendStateIsRcs) {
            msgType = dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_RCS;
        } else if (item?.isMsm) {
            msgType = dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_MMS;
        } else {
            msgType = dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_SMS;
        }
        // 收发成功率打点-开始发送
        DotUtil.getInstance().reportSuccessRateForSendStart(msgType);
        const smilPath = item.mmsSource?.find(item => MmsUtil.isSmil(item.type))?.path || '';
        const basePath = smilPath.substring(0, smilPath.lastIndexOf('\/'));
        let actionData: ActionDataType = {
            slotId: this.slotId,
            destinationHost: destinationHost,
            contactName: this.strContactsName,
            content: this.initRendContent(context, item),
            isEditMms: item.isMsm,
            isReSend: true,
            id: this.buildResendActionDataId(destinationHost, item),
            isRcs: item.isRcs,
            resendStateIsRcs: resendStateIsRcs,
            basePath: basePath
        };
        this.sendInterval(context, actionData, mmsList);
    }

    private buildResendActionDataId(destinationHost: string, item: mmsListType): string | undefined {
        return (destinationHost && (destinationHost.startsWith('sip:') && destinationHost.substring(4).includes('@'))) ?
            '' : item.id as string;
    }

    /**
     * 会话页面的选择文本功能
     * @param index
     * @param mmsItem
     */
    pushToCopyController(index: number, mmsItem?: mmsListType | undefined) {
        HiLog.i(TAG, `pushToCopyController_mmsId:${this.mmsList[index]?.id}; Index: ${index}`);
        let item: mmsListType | undefined;
        if (mmsItem){
            HiLog.i(TAG, 'currentMmsItemId: ' + mmsItem.id);
            item = mmsItem
        } else {
            item = this.mmsList[index]
        }
        let info = ''
        let content = item?.content;
        if (item?.msgShowType === common.MESSAGE_SHOW_TYPE.MAP) {//彩信位置消息
            content = (item.mmsSource?.find(v => (v && v.type === common.MM_ATTACHMENT_TYPE.MAP))?.content) ?? '';
        }
        info += content;
        let param: Record<string, string | number | Resource | boolean> = {
            'info': info,
            'isFromConversation': true
        }
        this.pageInfos.pushPathByName('CopyView', param);
    }

    pushToGroupContactListController() {
        let threadId: Record<string, number> = {
            'threadId': this.threadId
        }
        this.pageInfos.pushPathByName('groupContactList', threadId);
    }
    markAllAsReadByItem(context: Context){
        HiLog.i(TAG, 'markAllAsReadByItem');
        let routerParams: LooseObject = this.pageInfos.getParamByIndex(this.pageInfos.size() - 1) as LooseObject;
        let markThreadIndex: number = -1;
        if (routerParams?.threadId){
            markThreadIndex = routerParams?.threadId;
        } else if (this.threadId || routerParams?.isFromTransmitView){
            markThreadIndex = this.threadId;
        }
        if (markThreadIndex != -1) {
            ConversationListController.getInstance().handleMarkAllAsRead(context, markThreadIndex, true);
        }
    }

    async refreshSendMessageStatus() {
        HiLog.i(TAG, 'refreshSendMessageStatus');
        this.isTextAsMms = await MessageUtil.isMmsText(
            MessageUtil.replaceForLossy7Bit(this.slotId, this.textValue, 0, this.textValue.length));
        this.hasAttachment = this.mAttachAreaCtrl.mmDisplaySource.length > 0;
        HiLog.i(TAG, 'refreshSendMessageStatus hasAttachment = ' + this.hasAttachment);
        if (this.mAttachAreaCtrl.mmDisplaySource.length > 0 || this.isTextAsMms) {
            this.isEditMms = true;
        } else {
            this.isEditMms = false;
        }
        if (this.canSendMessage && !this.isEditMms) {
            if (this.textValue === common.STR.EMPTY_STR) {
                this.canSendMessage = false;
            }
        } else if (!this.canSendMessage && this.isEditMms) {
            if (this.isNewMsg) {
                if (this.receiveContactValue !== common.STR.EMPTY_STR || this.getSelectContactsLength() > 0) {
                    this.canSendMessage = true;
                }
            } else {
                this.canSendMessage = true;
            }
        }
    }

    sendMmsMessage(context: Context, actionData: ActionDataType, item: mmsListType, initDatas: InitData[]) {
        HiLog.w(TAG, 'sendMmsMessage start');
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_SEND_MMS_MESSAGE,
            TraceConstant.TRACE_CONVERSATION_SEND_MMS_MESSAGE_ID);
        item.position = '';
        let source: Array<Mms> = item.mmsSource as Array<Mms>;
        let names: Array<string> = [];
        let fullSource: Array<Mms> = MmsUtil.getSmilMmsSourceDelEmptyPar(source);
        fullSource.unshift(source[0]);
        let ct: Array<string> = [];
        if (MmsUtil.hasVcard(source)) {
            fullSource = source
        }
        fullSource && fullSource.forEach((item) => {
            names.push(item.name);
            if (item.ct != undefined) {
                ct.push(item.ct);
            } else {
                ct.push('');
            }
        });
        let sendNumbers: string[] = actionData.hosts as string[];
        let sendNumbersLength: number = sendNumbers.length;
        let contactNames: string[] = actionData.contactName?.split(',') as string[];
        let params: Record<string, Array<string> | string | number | boolean> = {
            'to': actionData.hosts as Array<string>,
            'subject': actionData.msgTitle || item.msgTitle,
            'ct': ct,
            'names': names,
            'slotId': this.slotId,
            'destinationHost': sendNumbers[0],
            'id': actionData?.id as string,
            'content': (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO) ?
                (item?.mmsSource?.find(v => (v.type === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO))?.path ?? '') :
                (item?.mmsSource && item.mmsSource.length > 0 && item.mmsSource[item.mmsSource.length - 1]?.path) || '',
            'resendStateIsRcs': actionData?.resendStateIsRcs as boolean,
            'basePath': actionData?.basePath || '',
            'msgIdReport': item.id
        };
        let id: number = this.getSendMessageId(initDatas, sendNumbers[0]);
        let sendResult: Record<string, number | string[] | string> = { 'id': id, 'telephone': sendNumbers[0],
            'content': actionData.content, 'contactName': contactNames[0] }
            sendMsgService.sendMmsMessage(context, params, item.mmsSource, (err: BusinessError | string) => {
                if (err) {
                    HiLog.e(TAG, 'sendMmsMessage failed' + JSON.stringify(err));
                    item.sendStatus = common.int.SEND_MESSAGE_FAILED;
                    let hosts: Array<string> = actionData.hosts as string[];
                    item.failuresNumber = hosts.length;
                    item.completeNumber = hosts.length;
                    sendMmsParams.SEND_STATE = 2;
                } else {
                    HiLog.w(TAG, 'sendMmsMessage success');
                    item.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
                    if (settingService.judgeIsDeliveryReport(item.isMsm)) {
                        item.hasReport = true;
                    }
                    sendMmsParams.SEND_STATE = 1;
                }
                item.isRcs = common.MESSAGE_TYPE.SMS_OR_MMS;
                let tempRcsId: number = -1;
                for (let item of this.mmsList) {
                    item.showTitle = tempRcsId !== item.isRcs;
                    tempRcsId = item.isRcs as number;
                }
                this.resetItem(item);
                ConversationDataSource.getInstance().refresh(this.mmsList);
                this.updateMmsSession(context, item);
                this.dealMmsMessageResult(context, actionData, item.sendStatus as number);
                hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_SEND_MMS_MESSAGE,
                    TraceConstant.TRACE_CONVERSATION_SEND_MMS_MESSAGE_ID);
              if (item.sendStatus === common.int.SEND_MESSAGE_SUCCESS) {
                // Mms 消息发送成功打点
                DotUtil.getInstance()
                  .reportSuccessRateForSendFinished(dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_MMS);
              }
                sendMmsParams.MODE_NAME = SystemMode.getInstance().mode;
                DotUtil.getInstance().reportEvent(sendMmsParams, dotCommon.eventName.SEND_MMS);
            });
        HiLog.w(TAG, 'sendMmsMessage end');
    }

  private generateLocalThumbnailForDisplay = async (videoPath: string, imagePath: string) => {
    if (!videoPath || !imagePath) {
      return Promise.resolve('');
    }
    return new Promise((resolve: (value: string) => void, reject: () => void) => {
      ImageUtil.getFetchFrameByTime(videoPath, async (pixMap: PixelMap) => {
        if (!pixMap) {
          resolve('');
          return;
        }
        EnhancedInfoTemporaryDataSource.getInstance().mapKeyToPixelMap?.set(imagePath, pixMap)
        await ImageUtil.encodePixelMapToFile(imagePath, pixMap);
        resolve(imagePath);
      });
    })
  }
  private getRcsVideoThumbnailItemToMmsSource = (context: Context, videoPath: string) => {
    if (!context || !videoPath) {
      return null;
    }
    const imageName = 'IMG_' + (getTime(true) ?? Date.now()) + '.jpg';
    let imagePath = FileUtil.getSandboxPath(context) + OBLIQUE + imageName;
    this.generateLocalThumbnailForDisplay(videoPath, imagePath);
    const thumbnailItem: Mms = {
      type: commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO_THUMBNAIL,
      name: imageName,
      path: imagePath,
      duration: '',
      isOriginalImage: false,
      isRcs: true,
      size: ''
    }
    return thumbnailItem;
  }

    /**
     *
     * @param copySourceIndex
     * @param isEditMms
     * @param type {@link commonData.MSG_ITEM_TYPE}
     */
    buildAttachmentSendItemOfEnhancedInfo(context: Context, copySourceIndex: number, isEditMms: boolean, type: number,
        copySource: Mms[]) {
        let textValue = '';
        HiLog.i(TAG, 'buildAttachmentSendItemOfEnhancedInfo, start')
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_INIT_MMS,
            TraceConstant.TRACE_CONVERSATION_INIT_MMS_ID);
        let item: mmsListType = new mmsListType();
        item.date = common.STR.EMPTY_STR;
        item.detailTime = $r('app.string.justNow');
        item.timeMillisecond = new Date().getTime();
        DateUtil.convertTimeStampToDateWeek(item, false);
        DateUtil.fullDate(item);
        item.content = textValue;
        item.isFullScreenImg = false;
        item.isCbChecked = false;
        item.is_collect = false;
        item.isReceive = false;
        item.sendStatus = this.getMessageSendStatus();
        item.subId = this.slotId;
        item.isMsm = isEditMms;
        item.rcsType = type;
        item.mmsSource = [];
        if (copySource && copySource.length > 0 && copySource[copySourceIndex]) {
            let source: Mms[] = [];
            source = [copySource[copySourceIndex]];
            item.totalSize = Number(copySource[copySourceIndex].size);
            let smilSource = this.getSmilSource(context, textValue, source);
            source.unshift(smilSource);
            if (type === common.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
              const thumbnailItem = this.getRcsVideoThumbnailItemToMmsSource(context, copySource[copySourceIndex].path);
              if (thumbnailItem) {
                source.push(thumbnailItem);
              }
            }
            item.mmsSource = source;
        }
        item.contentType = MmsUtil.getMmsContentType(item.mmsSource);
        this.setDateShow(item, this.mmsList, -1);
        item.isRcs = common.MESSAGE_TYPE.RCS;
        hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_INIT_MMS,
            TraceConstant.TRACE_CONVERSATION_INIT_MMS_ID);
        return item;
    }
    async initRcsSource(isEnd: boolean, index: number, copySource: Mms[]) {
        let item = this.mAttachAreaCtrl.rcsDisplaySource[index];
        let length = this.mAttachAreaCtrl.rcsDisplaySource.length;

        if (!item) {
            return;
        }
        let copyItem = ObjectUtil.getCopyObject(item) as Mms;
        // Write images and videos to the sandbox.
        if (copyItem.type === common.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
            copyItem.copyPath = copyItem.galleryPath ? copyItem.galleryPath : copyItem.path;
            copyItem.name = FileUtil.getFileName(copyItem.path);
        }
        copySource.push(copyItem);
        if (length - 1 == index) {
            isEnd = true;
        }
        if (!isEnd) {
            await this.initRcsSource(isEnd, ++index, copySource);
        }
    }
    async getSmiledRcsSource(context: Context) {
        let copySource: Mms[] = [];
        await this.initRcsSource(false, 0, copySource);
        HiLog.i(TAG, `getSmiledRcsSource: copySource length: ${copySource.length}`);
        let source: Mms[] = [];
        copySource.forEach((mms) => {
            source.push(mms);
        })
        source.unshift(this.getSmilSourceForMore(context, source));
        return source;
    }
    /**
     *
     * @param source
     * @returns
     */
    getSmilSourceForMore(context: Context, source: Array<Mms>): Mms {
        HiLog.i(TAG, 'getSmilSourceForMore');
        let smilContent: string = SmilFile.buildSmilFile(source);
        let smilFileInfo: Record<string, string> = FileUtil.writeTextToSandBox(context, smilContent, true);
        let smilSource: Mms = {
            duration: '',
            type: common.MM_ATTACHMENT_TYPE.SMIL,
            path: smilFileInfo.path,
            name: smilFileInfo.name,
            text: smilContent
        }
        return smilSource;
    }

    updateMmsSession(context: Context, item: mmsListType) {
        HiLog.w(TAG, 'updateMmsSession start');
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_UPDATE_MMS_SESSION,
            TraceConstant.TRACE_CONVERSATION_UPDATE_MMS_SESSION_ID);
        let sessionActionData: Record<string, number> = {
            'threadId': item.threadId
        }
        let sessionValueBucket: ValuesBucket = {
            'sending_status': item.sendStatus
        };
        if (item.sendStatus === common.int.SEND_MESSAGE_FAILED) {
            HiLog.i(TAG, 'updateMmsSession sending_status is : ' + item.sendStatus);
        }
        ConversationListService.getInstance()
          .updateSessionByCondition(context, sessionActionData, sessionValueBucket, null, true);
        let mmsActionData: Record<string, number> = {
            'groupId': item.groupId,
            'threadId': item.threadId
        }
        let valueBucket: Record<string, number> = {
            'msg_state': item.sendStatus
        }
        ConversationService.getInstance().updateSmsMmsInfoByCondition(context, mmsActionData, valueBucket, null);
        hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_UPDATE_MMS_SESSION,
            TraceConstant.TRACE_CONVERSATION_UPDATE_MMS_SESSION_ID);
        HiLog.w(TAG, 'updateMmsSession end');
    }

    dealMmsMessageResult(context: Context, actionData: ActionDataType, sendStatus: number) {
        const tmplBol = this.sendReportable
            && sendStatus == common.int.SEND_MESSAGE_SUCCESS;
        if (tmplBol) {
            const msg: string = !actionData.contactName
                ? actionData.destinationHost
                : actionData.contactName;
            const receivedResource: Resource = $r('app.string.message_received_2', msg);
            const context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
            const receivedMsg: string = context.resourceManager.getStringSync(receivedResource, msg);
            this.showToast(receivedMsg);
        }
    }

    /**
     * 初始化构建彩信发送消息的数据
     * @param context
     * @param item
     * @param textValue
     * @param isEditMms 是否发送彩信消息
     * @param mmDisplaySource 附件待发区的附件数据列表
     * @param setNewTextValue 设置消息的文本数据，目前用于发送彩信位置消息的场景
     */
    private async initMmsItem(context: Context, item: mmsListType, textValue: string, isEditMms: boolean,
        mmDisplaySource: Mms[] | undefined, setNewTextValue: (newTextValue: string) => void) {
        HiLog.i(TAG, 'initMmsItem, start')
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_INIT_MMS,
            TraceConstant.TRACE_CONVERSATION_INIT_MMS_ID);
        item.date = common.STR.EMPTY_STR;
        item.detailTime = $r('app.string.justNow');
        item.timeMillisecond = new Date().getTime();
        DateUtil.convertTimeStampToDateWeek(item, false);
        DateUtil.fullDate(item);
        item.isFullScreenImg = false;
        item.isCbChecked = false;
        item.is_collect = false;
        item.isReceive = false;
        item.sendStatus = this.getMessageSendStatus();
        item.subId = this.slotId;
        item.isMsm = isEditMms;
        let newTextValue = textValue;
       //设置消息的附件数据列表，多个附件即为幻灯片消息
        item.mmsSource = await ((mmDisplaySource && mmDisplaySource.length > 1) ? this.getSlideMmsDataSource(context,
          textValue, mmDisplaySource) : this.getMmsDataSource(context, textValue, mmDisplaySource, (value) => {
            setNewTextValue(''); //将彩信位置消息在sms_mms_info表中的msg_content置空，为了屏蔽主页的搜索功能
            newTextValue = value;
        }, (msgShowType) => {
            item.msgShowType = msgShowType ?? common.MESSAGE_SHOW_TYPE.NORMAL;
        }));
        item.content = this.getSendText(context, newTextValue, true);
        item.contentType = MmsUtil.getMmsContentType(item.mmsSource);
        this.setDateShow(item, this.mmsList, -1);
        sendMmsParams.SEND_STATE = -1;
        this.isSendPicture = true;
        this.setShowTitle(item, this.mmsList);
        this.mmsList.push(item);
        ConversationDataSource.getInstance().refresh(this.mmsList);
        hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_INIT_MMS,
            TraceConstant.TRACE_CONVERSATION_INIT_MMS_ID);
    }

    resetAttachAreaPicture() {
        this.pictureCtrl.resetPictureStatus();
    }

    async initSouce(context: Context, isEnd: boolean, index: number) {
        let item = this.mAttachAreaCtrl.mmDisplaySource[index];
        let length = this.mAttachAreaCtrl.mmDisplaySource.length;
        if (!item) {
            return;
        }
        let copyItem = ObjectUtil.getCopyObject(item) as Mms;
        // Write images and videos to the sandbox.
        if (copyItem.type === common.MM_ATTACHMENT_TYPE.VIDEO) {
            copyItem.copyPath = copyItem.galleryPath ? copyItem.galleryPath : copyItem.path;
            copyItem.name = FileUtil.getFileName(copyItem.path);
        }
        if (copyItem.type === common.MM_ATTACHMENT_TYPE.IMAGE) {
            copyItem.copyPath = copyItem.galleryPath ? copyItem.galleryPath : copyItem.path;
            let a = await FileUtil.packingSize(copyItem.path)
            let name = FileUtil.getFileName(copyItem.path);
            if (a.data.byteLength != 0) {
                let dotPosition = name.indexOf('.');
                let fileFormat: string = name.substring(dotPosition + 1);
                let mediaName = 'IMG_' + Date.now() + '.' + fileFormat;
                let targetPath = FileUtil.getSandboxPath(context) + '/' + mediaName;
                copyItem.name = mediaName;
                copyItem.path = targetPath;
                let file = fs.openSync(targetPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
                let fd = file.fd;
                fs.writeSync(fd, a.data)
                fs.closeSync(file);
            } else {
                copyItem.name = name
            }
        }
        let size = FileUtil.getFileSizeByPath(copyItem.path);
        copyItem.size = JSON.stringify(size);
        this.copySource.push(copyItem);
        if (length - 1 == index) {
            isEnd = true;
        }
        if (!isEnd) {
            await this.initSouce(context, isEnd, ++index);
        }
    }

    async getSlideMmsDataSource(context: Context, textValue: string, mmDisplaySource?: Mms[]): Promise<Array<Mms>> {
        HiLog.i(TAG, 'getSlideMmsDataSource start')
        const basePath = FileUtil.getSandboxPath(context);
        this.mAttachAreaCtrl.copySource = [];
        await this.mAttachAreaCtrl.initSlideSource(context, false, 0, basePath, mmDisplaySource);
        let source: Array<Mms> = [];
        source = this.mAttachAreaCtrl.copySource.slice(0);
        if (textValue !== '') {
            let textSource = this.getTextSource(context, textValue, basePath);
            source.push(textSource);
        }
        const slideSmilStr = await SmilFile.getSlideSmil(textValue, source, context);
        const textValueObj: mmsSourceItem = {
            mms: source,
            content: textValue,
            contentType: MmsUtil.getSlideShowTypeByFirstItemType(source[0].type),
            smilStr: slideSmilStr,
            basePath: basePath
        }
        let smilSource = this.getSmilSource(context, textValueObj, source);
        source.unshift(smilSource);
        return source;
    }

     /**
     * 生成除幻灯片以外的其他类型的彩信附件数据
     * @param context
     * @param textParam
     * @param mmDisplaySource 附件待发区的附件数据列表
     * @param setNewTextValue
     * @param setMsgShowType
     * @returns
     */
    async getMmsDataSource(context: Context, textParam: string, mmDisplaySource: Mms[] | undefined,
        setNewTextValue: (newTextValue: string) => void, setMsgShowType: (type: number) => void): Promise<Array<Mms>> {
        HiLog.i(TAG, 'getMmsDataSource start')
        let textValue: string = textParam;
        if (!mmDisplaySource || mmDisplaySource.length === 0 && !this.isTextAsMms) {
            return [];
        }

        if (this.mAttachAreaCtrl.copySource.length === 0) {
            HiLog.i(TAG, 'copySource is empty, use mmDisplaySource')
            this.mAttachAreaCtrl.copySource = mmDisplaySource;
            this.mAttachAreaCtrl.copySource.forEach((copyItem, index) => {
                if (copyItem && copyItem.path) {
                    let pos = copyItem.path.lastIndexOf('/');
                    if (pos != -1) {
                        HiLog.i(TAG, 'copySource reset attachment name, index: ' + index);
                        copyItem.name = copyItem.path.substring(pos + 1);
                    }
                }
            })
        }
        let source: Array<Mms> = [];
        source = this.mAttachAreaCtrl.copySource.slice(0);
        if (source?.[0]?.type === commonData.MM_ATTACHMENT_TYPE.MAP) { //彩信位置消息
            setMsgShowType(common.MESSAGE_SHOW_TYPE.MAP);
            //生成彩信位置的文本内容txt附件数据
            let textSource = await getMmsMapTextSource(context, textValue, source[0].address, (newTextValue) => {
                textValue = newTextValue;
                setNewTextValue(newTextValue);
            });
            source.push(textSource);
        } else if (textValue !== '') {
            let textSource = this.getTextSource(context, textValue);
            source.push(textSource);
        }
        let smilSource = this.getSmilSource(context, textValue, source);
        source.unshift(smilSource);
        return source;
    }

    getSmilSource(context: Context, textValueObj: string | mmsSourceItem, source: Array<Mms>): Mms {
        HiLog.i(TAG, 'getSmilSource');
        let textValue: string = typeof textValueObj === 'string' ? textValueObj : textValueObj.content;
        let basePath = '';
        let smilSource: Mms = {
            duration: '',
            type: common.MM_ATTACHMENT_TYPE.SMIL,
            path: '',
            name: ''
        }
        let smil: string = '';
        if (typeof textValueObj === 'object' &&
        MmsUtil.isSlideType(textValueObj.contentType as number)) {
            smil = textValueObj.smilStr || '';
            basePath = textValueObj?.basePath || '';
        } else {
            smil = SmilFile.getSmil(textValue, source);
        }
        let smilObj: Record<string, string> = FileUtil.writeTextToSandBox(context, smil, true, basePath);
        smilSource.path = smilObj.path;
        smilSource.name = smilObj.name;
        smilSource.text = smil;
        HiLog.i(TAG, 'send mms smil');
        return smilSource;
    }

    getTextSource(context: Context, textValue: string, basePath?: string) {
        HiLog.i(TAG, 'getTextSource');
        let textSource: Mms = {
            duration: '',
            type: common.MM_ATTACHMENT_TYPE.TEXT,
            path: '',
            name: ''
        }
        let textObj: Record<string, string> = FileUtil.writeTextToSandBox(context, textValue, false, basePath);
        textSource.path = textObj.path;
        textSource.name = textObj.name;
        return textSource;
    }

    recentEmojiList(EmojiArr:number[]){
        let MAX_EmojiNumber = 27
        let testEmoji = SharedPreferencesUtils.getFromPreferences('recentListPreferences', []) as Array<string>;
        let currentValue = JSON.stringify(EmojiArr);
        let findIndex = testEmoji.indexOf(currentValue);
        if (findIndex > -1) {
            testEmoji.splice(findIndex, 1);
        }
        if(testEmoji.length > MAX_EmojiNumber){
            testEmoji.unshift(currentValue) && testEmoji.pop()
        } else {
            testEmoji.unshift(currentValue)
        }
        return testEmoji
    }

    getRecentEmojiList(){
        let recentLists = SharedPreferencesUtils.getFromPreferences('recentListPreferences', []) as Array<string>
        let recentEmojiChangeTypeToUse: number[][] = [];
        for (let i = 0;i < recentLists.length; i++) {
            if (recentLists[i] !== '[128405]') {
                recentEmojiChangeTypeToUse.push(JSON.parse(recentLists[i]));
            }
        }
        return recentEmojiChangeTypeToUse
    }

    getTabSrc(index: number): Resource {
        let imgSrc = $rawfile('icon/emo_recent.svg');
        if (index === 1) {
            imgSrc = $rawfile('icon/emo_person.svg');
        }
        if (index === 2) {
            imgSrc = $rawfile('icon/emo_animal.svg');
        }
        if (index === 3) {
            imgSrc = $rawfile('icon/emo_food.svg');
        }
        if (index === 4) {
            imgSrc = $rawfile('icon/emo_activity.svg');
        }
        if (index === 5) {
            imgSrc = $rawfile('icon/emo_travel.svg');
        }
        if (index === 6) {
            imgSrc = $rawfile('icon/emo_body.svg');
        }
        if (index === 7) {
            imgSrc = $rawfile('icon/emo_symbol.svg');
        }
        if (index === 8) {
            imgSrc = $rawfile('icon/emo_flag.svg');
        }
        if (index === 9) {
            imgSrc = $rawfile('icon/emo_flag.svg');
        }
        return imgSrc;
    }

    getTabSrcSelected(index: number): Resource {
        let imgSrc = $r('app.media.emo_recent_selected');
        if (index === 1) {
            imgSrc = $r('app.media.emo_person_selected');

        }
        if (index === 2) {
            imgSrc = $r('app.media.emo_animal_selected');
        }
        if (index === 3) {
            imgSrc = $r('app.media.emo_food_selected');
        }
        if (index === 4) {
            imgSrc = $r('app.media.emo_activity_selected');
        }
        if (index === 5) {
            imgSrc = $r('app.media.emo_travel_selected');
        }
        if (index === 6) {
            imgSrc = $r('app.media.emo_body_selected');
        }
        if (index === 7) {
            imgSrc = $r('app.media.emo_symbol_selected');
        }
        if (index === 8) {
            imgSrc = $r('app.media.emo_flag_selected');
        }
        if (index === 9) {
            imgSrc = $r('app.media.emo_flag_selected');
        }
        return imgSrc;
    }

    async downloadMms(data: mmsInfo, context: Context) {
        let result = await mmsReceive.changeStateToDowning(data, context);
        if (result) {
            //开启彩信下载定时器
            let mmsData = new mmsListType()
            mmsData.id = data.id;
            mmsData.isMsm = data.isMsm;
            this.messageTimeout.messageDownloadTimeout(mmsData);
            mmsReceive.startDownloadMMs(data, true, context);
        }
    }

    checkMessageDownloadTimeout() {
        this.messageTimeout.checkMessageDownloadTimeout();
    }

    canResendMms(isMms: boolean): boolean {
        HiLog.i(TAG, 'canResendMms isMms: ' + isMms);
        let haveSimCard = MmsPreferences.getInstance().haveSimCardReady();
        // In airplane mode or without a SIM card, a message is displayed for MMS message resending.
        if ((!haveSimCard || this.isAirPlaneMode) && isMms) {
            this.showToast($r('app.string.no_network'))
            HiLog.i(TAG, `haveSimCard: ${haveSimCard}, isAirPlaneMode: ${this.isAirPlaneMode}`);
            return false;
        } else {
            return true;
        }
    }

    /**
     * Adjusting the lowMessageList of the message list
     *
     * @param currentSendBarGlobalY The topY of sendBar
     * @param msgListGlobalY The topY ofMessageList
     * @returns true: update success. false: update failed.
     */
    adjustLowListHeight(
        currentSendBarGlobalY: number,
        msgListGlobalY: number,
        listLightTimerId:number
    ): boolean {
        if (currentSendBarGlobalY < 0 || msgListGlobalY < 0) {
            // Someone layout info has not been obtained, and related calculation should not be performed.
            HiLog.i(TAG, 'Invalid data. Update msgList low height failed.')
            return false;
        }
        this.updateListHeightInsensitive(currentSendBarGlobalY - msgListGlobalY, listLightTimerId)
        return true;
    }

    /**
     * ListHeight is updated too frequently, causing message list jitter.
     * Therefore, limit the update frequency of ListHeight.
     *
     * @param height listHeight
     * @return Indicates whether to trigger the timer
     */
    updateListHeightInsensitive(height: number, listLightTimerId: number): boolean {
        let clearFlag = false;
        if (listLightTimerId !== -1) {
            clearTimeout(listLightTimerId);
            clearFlag = true;
        }
        this.insensitiveListHeight = height;
        listLightTimerId = setTimeout(() => {
            listLightTimerId = -1;
            this.listHeight = this.insensitiveListHeight;
            HiLog.i(TAG, `Update List height success: ${this.listHeight}`)
        }, LIST_HEIGHT_INSENSITIVE_TIMEOUT);
        return clearFlag;
    }

    /**
     * If there is no data in the memory, create the data again.
     *
     * @returns Byte array of all emojis
     */
    private getAllEmojiValues(): number[][] {
        if (this.allEmojiValues === undefined) {
            this.allEmojiValues = new Array<Emoji>().concat(...tabTextList)
                .map<number[]>((emoji) => {
                    return emoji.value;
                })
                .map<number[]>((v) => {
                    let hexValues: number[] = [];
                    let emojiStr = String.fromCodePoint(...v);
                    for (let i = 0; i < emojiStr.length; i++) {
                        hexValues.push(emojiStr.charCodeAt(i))
                    }
                    return hexValues
                });
        }
      return this.allEmojiValues;
    }

    /**
     * If there is no data in the memory, create the data again.
     *
     * @returns The emoji strings
     */
    private getEmojiStrArray(): string[] {
        if (this.emojiStrArray === undefined) {
            // Convert all Emoji codes to string array and calculate the maximum length of Emoji codes
            this.emojiStrArray = this.getAllEmojiValues().map<string>((value) => {
                if (value.length > this.emojiCodesMaxLen) {
                    this.emojiCodesMaxLen = value.length
                }
                return String.fromCharCode(...value)
            });
        }
        return this.emojiStrArray;
    }

    /**
     * Find all indexes in EmojiCodes corresponding to a specified code
     *
     * @param code. specified code
     * @param emojiCodes. Char Codes of an emoji
     * @returns All found indexes
     */
    private indexOfEmojiCodes(code: number, emojiCodes: number[]): number[] {
        let indexArr: number[] = [];
        for (let i = 0; i < emojiCodes.length; i++) {
            if (code === emojiCodes[i]) {
                indexArr.push(i);
            }
        }
        return indexArr;
    }

    /**
     * Deletes characters from string with emojis.
     */
    deleteCharForEmojiStr(str: string, index: number): string {
        if (index < 0 || index >= str.length) {
            HiLog.i(TAG, `Index(${index})out of range. Nothing to do.`)
            return str;
        }
        // Unicode corresponding to the emoticon
        let charCode = str.charCodeAt(index);
        // Byte array of all emojis
        let emojiValues: number[][] = this.getAllEmojiValues();
        // Emoji containing charCode
        let relatedEmojis: number[][] = [];
        for (let emojiValue of emojiValues) {
            if (emojiValue.indexOf(charCode) !== -1) {
                relatedEmojis.push(emojiValue);
            }
        }
        if (relatedEmojis.length === 0) {
            // Not found any emojis, it indicates that the current character is not an emoji. Delete it directly.
            HiLog.i(TAG, `The character(Not Emoji) of the index(${index}) is deleted successfully}`)
            return str.slice(0, index) + str.slice(index + 1, str.length);
        }
        // Sorted by EmojiValue length in descending order
        relatedEmojis.sort((a, b) => {
            return b.length - a.length
        })
        // Traverse relatedEmojis and delete the emoji if it matches exactly on str
        for (let emojiValue of relatedEmojis) {
            // Some emoji have duplicate codes.
            // We cannot find all indexes by using Array#indexOf.
            let indexArr = this.indexOfEmojiCodes(charCode, emojiValue)
            let emojiStr = String.fromCharCode(...emojiValue);
            for (let i of indexArr) {
                let lIndex = index - i;
                let rIndex = index + emojiValue.length - i;
                let subStr = str.slice(lIndex, rIndex);
                if (subStr == emojiStr) {
                    // Delete current emoji
                    HiLog.i(TAG, `The character(Emoji) of the index(${index}) is deleted successfully}`)
                    return str.slice(0, lIndex) + str.slice(rIndex, str.length);
                }
            }
        }
        // Delete it directly
        HiLog.i(TAG, `The character(Not Emoji) of the index(${index}) is deleted successfully}`)
        return str.slice(0, index) + str.slice(index + 1, str.length);
    }

    /**
     * Determine whether to display bubbles.
     * (Not required when pure EmojiStr and count <= 3)
     *
     * @param str messageStr
     * @param emojiCount
     * @returns
     */
    showBubbleOrEmoji(str: string, emojiCount: number): boolean {
        let len = 0;
        // Convert all Emoji codes to string array and calculate the maximum length of Emoji codes
        let emojiStrArray = this.getEmojiStrArray()
        for (let i = 0; i < str.length; i++) {
            let isMatched = false;
            for (let j = this.emojiCodesMaxLen; j > 0; j--) {
                if (i + j > str.length) {
                    continue;
                }
                let subStr = str.slice(i, i + j)
                if (emojiStrArray.indexOf(subStr) !== -1) {
                    i += j - 1;
                    len++;
                    if (len > emojiCount) {
                        // Emoji count in string > 3
                        return true
                    }
                    isMatched = true;
                    break
                }
            }
            if (!isMatched) {
                // Str contains text
                return true
            }
        }
        // Emoji count in string < 3; And without text
        return false;
    }

    isHasEmoji(str: ResourceStr) {
        if (typeof str !== 'string') {
            HiLog.i(TAG, 'isHasEmoji type is resource');
            return false;
        }
        let emojiStrArray = this.getEmojiStrArray();
        let has: boolean = false;
        for (let i = 0; i < emojiStrArray.length; i++) {
            let emoji = emojiStrArray[i];
            if (str.indexOf(emoji) >= 0) {
                has = true;
                break;
            }
        }
        return has;
    }

    getMmsCount() {
        let arr = this.mmsList.filter(item => item.isCbChecked);
        let mms = arr.filter(item => (item.mmsPdu && item.mmsPdu !== ''))
        return mms.length > 0;
    }

    /**
     * 是否选中了包含ip消息并且非纯文本消息类型
     *
     * @returns true 选择了ip卡片类型的消息
     */
    isSelectedContainIpCardMsgItems() {
        return this.mmsList.filter(item => item.isCbChecked && item.isIpMsg && !item.isSimpleIpMsg).length > 0;
    }

    async setMmsDataSource(context: Context, mmsSource: Array<Mms>, isCallOnInitRequestMessageList?: boolean) {
        let deleteCount = 0;
        let addCount = 0;
        let pushList: Array<Mms> = [];
        mmsSource.forEach(async (ele, index) => {
                await FileUtil.packingSize(ele.path).then(async res => {
                    if (res.size == 0 && res.data.byteLength == 0) {
                        deleteCount++;
                        return;
                    } else {
                        let fileSize = GlobalContext.getContext().getObject('fileTotalSize') as number;
                        fileSize = !fileSize ? 0 : fileSize;
                        fileSize += res.size
                        GlobalContext.getContext().setObject('fileTotalSize', fileSize);
                        let item: Mms = await this.setMmsDataSourcePushListItem(ele, index,
                          isCallOnInitRequestMessageList);
                        if (item.type !== commonData.MM_ATTACHMENT_TYPE.TEXT &&
                            item.type !== commonData.MM_ATTACHMENT_TYPE.SMIL) {
                            pushList.push(item);
                        }
                        addCount++;
                    }
                })
        })
        // 赋值附件的初始草稿
        if (this.draftModel !== null && !this.draftModel.isHasSetValueForInitialDraftAttachments) {
            HiLog.i(TAG, 'initialDraftAttachments has set value' + pushList.length)
            this.draftModel.initialDraftAttachments = pushList
            this.draftModel.isHasSetValueForInitialDraftAttachments = true
        }
        this.timeoutID = setInterval(() => {
            if (addCount + deleteCount == mmsSource.length) {
                if (pushList.length >= 2) {
                    pushList.sort((a, b) => {
                        if (a.index !== undefined && b.index !== undefined) {
                            return a.index - b.index
                        } else {
                            return 0
                        }
                    })
                }
                this.mAttachAreaCtrl.mmDisplaySource = [];
                pushList.forEach(ele => {
                    animateTo({ curve:curves.interpolatingSpring(0, 1, 228, 30) }, () => {
                        this.mAttachAreaCtrl.setDisplaySource(context, ele);
                    })
                })
                if (this.draftModel !== null && !this.draftModel.attachmentAreaHasSetValue) {
                    this.draftModel.attachmentAreaHasSetValue = true
                }
                clearInterval(this.timeoutID);
                this.timeoutID = -1
            }
        }, 100)
    }

    releaseConversationPixelMap() {
        if (this.conversationPixelMap != null) {
            this.conversationPixelMap.forEach(value => {
                value?.release()
            });
        }
    }

    /**
     *
     * @param item
     * @param index
     * @param isCallOnInitRequestMessageList 是否在会话页面初始化请求消息列表数据的时候调用
     * @returns
     */
    async setMmsDataSourcePushListItem(item: Mms, index: number, isCallOnInitRequestMessageList?: boolean) {
        HiLog.i(TAG, `setMmsDataSourcePushListItem: isCallOnInitRequestMessageList: ${
        isCallOnInitRequestMessageList}, isRcsMms: ${this.isRcsMms}`);
        if (item.type == commonData.MM_ATTACHMENT_TYPE.IMAGE ||
          item.type === commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE) {
            let pixMap: image.PixelMap | undefined;
            let hasStorage: boolean = this.conversationPixelMap.hasKey(item.path);
            HiLog.i(TAG, 'favorite hasStorage:' + hasStorage)
            if (hasStorage) {
                pixMap = this.conversationPixelMap.get(item.path) as PixelMap;
            } else {
                try {
                    HiLog.i(TAG, 'create setMmsDataSourcePushListItem')
                    pixMap = await ImageUtil.convertImageToPixmap(item.path);
                    this.conversationPixelMap.set(item.path, pixMap)
                } catch (w) {
                    HiLog.w(TAG, 'setMmsDataSourcePushListItem convertImageToPixmap warn：' + JSON.stringify(w));
                }
            }
            item.pixelMap = pixMap;
            item.index = index;
            return item;
        } else if (item.type == commonData.MM_ATTACHMENT_TYPE.VIDEO ||
          item.type === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
            await ImageUtil.getFetchFrameByTime(item.path, (pixMap: PixelMap) => {
                item.pixelMap = pixMap;
                item.index = index;
                return item;
            })
        }
        else if (item.type == commonData.MM_ATTACHMENT_TYPE.AUDIO) {
            item.isOnAudio = false;
            item.index = index;
            return item;
        }
        else if (item.type == commonData.MM_ATTACHMENT_TYPE.TEXT) {
            return item;
        } else if (item.type == commonData.ENHANCED_INFO_ITEM_TYPE.MAP) {
            let pixMap: image.PixelMap | undefined;
            try {
                pixMap = await ImageUtil.convertImageToPixmap(item.path);
                this.conversationPixelMap.set(item.path, pixMap)
                let address = JSON.parse(item.content ?? '') as RcsSendLoc;
                let addressInfo = address.body.split(';');
                item.address = new AddressInfo(Number(address.latitude), Number(address.longitude),
                    addressInfo[0] ?? '', addressInfo[addressInfo.length - 1] ?? '');
            } catch (w) {
                HiLog.w(TAG, 'rcs setMmsDataSourcePushListItem convertImageToPixmap warn：' + JSON.stringify(w));
            }
            item.pixelMap = pixMap;
            item.index = index;
            return item;
        } else if (item?.path && item.type === commonData.MM_ATTACHMENT_TYPE.MAP) { //彩信位置附件
          //当会话页面初始化请求消息列表数据，当前是增强模式，且为彩信位置附件，将其转换成增强信息位置附件
          if (!item.address && isObjectJSONString(item.text)) {
            item.address = JSON.parse(item.text as string);
          }
          if (this.isRcsMms && isCallOnInitRequestMessageList) {
            HiLog.i(TAG, 'setMmsDataSourcePushListItem: convert mmsMapAttachment to rcsMapAttachment');
            item.isRcs = true;
            item.type = commonData.ENHANCED_INFO_ITEM_TYPE.MAP;
            item.text = undefined;
            item.content = this.mAttachAreaCtrl.getRcsAddressJson(item.address ?? new AddressInfo(0, 0, '', ''));
          }
        }
        return item;
    }

    private formatLatLng(location:string):string {
        if (location == null) {
            return '';
        }
        let symbolIndex:number = location.indexOf('.');
        if (symbolIndex > 0 && location.length > symbolIndex + 7) {
            return location.substring(0, symbolIndex + 7);
        }
        return location;
    }

    public getConvertDegreeString(digitalDegree:number):string {
        let degree:number = Math.trunc(digitalDegree);
        let tmp:number = (digitalDegree - degree) * DOUBLE;
        let minute:number = Math.trunc(tmp);
        let second:number = Math.trunc((tmp - minute) * DOUBLE);
        return Math.abs(degree) + DEGREE + Math.abs(minute) + MINUTE + Math.abs(second) + SECOND;
    }

    getLocationInfo(context: Context, convertLongitude: number, convertLatitude: number): string {
        HiLog.w(TAG,
            `getLocationInfo convertLongitude:${convertLatitude >= 0}, convertLatitude:${convertLongitude >= 0}`);
        //刷新经纬度信息到界面
        if (convertLatitude >= 0) {
            if (convertLongitude >= 0) {
                return context.resourceManager.getStringSync($r('app.string.location_north_east'),
                    this.getConvertDegreeString(convertLatitude),
                    this.getConvertDegreeString(convertLongitude));
            } else {
                return context.resourceManager.getStringSync($r('app.string.location_north_west'),
                    this.getConvertDegreeString(convertLatitude),
                    this.getConvertDegreeString(convertLongitude));
            }
        } else {
            if (convertLongitude >= 0) {
                return context.resourceManager.getStringSync($r('app.string.location_south_east'),
                    this.getConvertDegreeString(convertLatitude),
                    this.getConvertDegreeString(convertLongitude));
            } else {
                return context.resourceManager.getStringSync($r('app.string.location_south_west'),
                    this.getConvertDegreeString(convertLatitude),
                    this.getConvertDegreeString(convertLongitude));
            }
        }
    }

    public cancelReceiveFileOnclick(msgId: string, path: string): void {
        // let temp: rcs.RcsFileOptions = {
        //     msgId: msgId,
        //     dstFileName: path,
        //     srcFileName: '',
        //     fileType: 'image/jpeg',
        // };
        // try {
        //     // rcs.cancelFile(temp);
        // } catch (e) {
        //     HiLog.e(TAG, 'cancelReceiveFileOnclick rcs.cancelFile fail, error: ' + JSON.stringify(e));
        // }
    }

    public async rcsVCardMessageContentAppear(context: Context, item: Mms, isSingleContactOrMultipleTel: boolean, contacts: ContactType[]) {
        HiLog.i(TAG, 'RcsVCardMessageContentAppear');
        item.contacts = await VCardUtil.getInstance().parseVCard(context, item.path, 0);
        contacts = [...item.contacts];
        isSingleContactOrMultipleTel = item.contacts.filter(contact => {
            return contact.contactName != '';
        }).length < 2
        if (!isSingleContactOrMultipleTel) {
            let nameArr: string[] = [];
            let newContacts: ContactType[] = []
            for (let index = 0; index < contacts.length; index++) {
                if (!nameArr.includes(contacts[index].contactName) ||
                    contacts[index].id && contacts[index].id != contacts[index - 1].id) {
                    nameArr.push(contacts[index].contactName);
                    newContacts.push(contacts[index]);
                }
            }
            contacts = [...newContacts]
        }
        return contacts
    }

    public mmCheckVcardDialogAppear(contacts: ContactTypeForUI[], filterAfterArr: ContactTypeForUI[]) {
        HiLog.i(TAG, 'mmCheckVcardDialogAppear');
        let nameArr: string[] = [];
        for (let index = 0; index < contacts.length; index++) {
            if (!nameArr.includes(contacts[index].contactName) ||
                contacts[index].id && contacts[index].id != contacts[index - 1].id) {
                nameArr.push(contacts[index].contactName);
                filterAfterArr.push(contacts[index]);
            }
        }
        return filterAfterArr
    }

    /*
       * 注册通知事件（联系人变化时，通知短信，联系人信息发生了变化）
        */
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

    /*
    * 注销联系人事件
     */
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

    //刷新联系人信息
    refreshUserInfoWithUpdateIdStr(context: Context, updateIdStr: string, callBack: () => void) {
        HiLog.i(TAG, 'refreshList row start updateIdStr :' + updateIdStr);
        /*
         * updateIdStr为空，则为删除联系人(单独删除和批量删除)，用当前用户联系人id查询是否删除的是否是当前用户
         * 否则，根据手机号和最近时间，查看当前更新用户
         */
        if (updateIdStr === '') {
            let actionData: LooseObject = {};
            HiLog.i(TAG, 'refreshUserInfo row telephone ');
            actionData.contactIds = [this.rawContactId];
            ContactsService.getInstance().queryContactDataByCondition(actionData, (objc: LooseObject) => {
                if (objc !== undefined && objc.abilityResult.length === 0) {
                    this.strContactsName = '';
                    this.formatStrContactsName = '';
                    this.photoFirstName = common.STR.WHITE_SPACE;
                    if (DeviceUtil.isPC()) {
                        AppStorage.setOrCreate('isPCPageRefresh', !AppStorage.get('isPCPageRefresh'));
                    }
                }
                callBack();
            }, context)
        } else {
            this.onContactDataChangeObserver(context);
            callBack();
        }
    }

    public async handleProtocolChange(content: string): Promise<void> {
        if (StringUtil.isEmpty(content)) {
            HiLog.i(TAG, 'not handleProtocolChange for empty');
            this.isTextAsMms = await MessageUtil.isMmsText(
                MessageUtil.replaceForLossy7Bit(this.slotId, content, 0, content.length));
            if (this.isNeedChangeFromMmsToSms()) {
                this.isEditMms = false;
                HiLog.i(TAG, 'empty text,change to sms');
                this.changeValue(content);
            }
            return;
        }
        this.isTextAsMms = await MessageUtil.isMmsText(
            MessageUtil.replaceForLossy7Bit(this.slotId, content, 0, content.length));
        this.mAttachAreaCtrl.setTextMms(this.isTextAsMms);
        this.pictureCtrl.setTextMms(this.isTextAsMms);
        if (this.isNeedChangeFromSmsToMms()) {
            this.isEditMms = true;
            HiLog.i(TAG, 'larger text,change to mms');
            this.showToast($r('app.string.converting_mms'));
        } else if (this.isNeedChangeFromMmsToSms()) {
            this.isEditMms = false;
            HiLog.i(TAG, 'small text,change to sms');
            this.showToast($r('app.string.converting_sms'));
        }
    }

    public isNeedChangeFromSmsToMms(): boolean {
        return this.isTextAsMms && !this.isEditMms && !this.isRcsMms && !this.hasAttachment;
    }

    public isNeedChangeFromMmsToSms(): boolean {
        return !this.isTextAsMms && this.isEditMms && !this.isRcsMms && !this.hasAttachment;

    }

    public sendChatbot(context: Context, serviceId: string, displayText: string, data?: string, isRcsMms?: boolean,
        trafficType?: string, contributionId?: string) {
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_SEND, TraceConstant.TRACE_CONVERSATION_SEND_ID);
        HiLog.iw(TAG, 'sendChatbot, start');
        let inRepairMode = SharedPreferencesUtils.getFromPreferences('inRepairMode', false);
        if (inRepairMode) {
            HiLog.iw(TAG, 'inRepairMode' + JSON.stringify(inRepairMode));
            this.isChangeInputPlaceholder = true;
            return;
        }
        // The Send button is dimmed and messages cannot be sent.
        if (this.isAirPlaneMode) {
            HiLog.w(TAG, `send, canSendMessage=${this.canSendMessage}, isAirPlaneMode=${this.isAirPlaneMode}`);
            this.showToast($r('app.string.air_plane_mode_message'));
            this.isChangeInputPlaceholder = true;
            return;
        }
        // 收发成功率打点-开始发送
        DotUtil.getInstance().reportSuccessRateForSendStart(dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_RCS);
        if (this.isNewMsg) {
            this.newSend(context, () => {
                HiLog.iw(TAG, 'send, isNewMsg');
                this.sendChatbotDataRefresh(context, serviceId, displayText, data, isRcsMms, trafficType,
                    contributionId);
                this.publishData(true, this.threadId);
                this.vCardJumpBack = false;
            });
        } else {
            HiLog.iw(TAG, 'send, isOldMsg');
            this.sendChatbotDataRefresh(context, serviceId, displayText, data, isRcsMms, trafficType, contributionId);
            this.publishData(true, this.threadId);
            this.vCardJumpBack = false;
        }

    }

    public async sendChatbotDataRefresh(context: Context, serviceId: string, displayText: string, data?: string,
        isRcsMms?: boolean, trafficType?: string, contributionId?: string) {
        hiTraceMeter.startTrace(TraceConstant.TRACE_SEND_MSG_CLEAN_TEXT, TraceConstant.TRACE_SEND_MSG_CLEAN_TEXT_ID);
        this.isSendStatus = true;
        this.slotId = await DataService.getDefaultCellularDataSlotId();
        HiLog.iw(TAG, 'sendChatbotDataRefresh slotId' + this.slotId);
        this.updateSimSlotId(this.slotId);
        this.initChatbotItem(displayText);
        let actionData: ActionDataType = new ActionDataType();
        actionData.slotId = this.slotId;
        HiLog.iw(TAG, 'sendChatbotDataRefresh isRcsMms' + isRcsMms);
        this.isRcsMms = isRcsMms ? isRcsMms : this.isRcsMms;
        actionData.destinationHost = serviceId;
        actionData.isReSend = false;
        actionData.content = displayText;
        actionData.isEditMms = false;
        actionData.isChatbot = true;
        actionData.contactName = this.strContactsName;
        actionData.data = data;
        actionData.trafficType = trafficType ? trafficType : '';
        actionData.contributionId = contributionId ? contributionId : '';
        this.sendInterval(context, actionData, this.mmsList);
        hiTraceMeter.finishTrace(TraceConstant.TRACE_SEND_MSG_CLEAN_TEXT, TraceConstant.TRACE_SEND_MSG_CLEAN_TEXT_ID);
        this.isShowFullScreen = false;
        this.resetMmsSource();
        this.setTabOperationStatus(false);
        this.distanceBottomFlag = false;
        this.receiveContactValue = common.STR.EMPTY_STR;
        this.clearSelectContacts();
        this.isNewMsg = false;
        this.scroller.scrollEdge(Edge.End);
    }

    public initChatbotItem(content: string) {
        HiLog.i(TAG, 'initChatbotItem, start');
        hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_INIT_MMS,
            TraceConstant.TRACE_CONVERSATION_INIT_MMS_ID);
        let item: mmsListType = new mmsListType();
        item.date = common.STR.EMPTY_STR;
        item.detailTime = $r('app.string.justNow');
        item.timeMillisecond = new Date().getTime();
        DateUtil.convertTimeStampToDateWeek(item, false);
        DateUtil.fullDate(item);
        item.content = content;
        item.isFullScreenImg = false;
        item.isCbChecked = false;
        item.is_collect = false;
        item.isReceive = false;
        item.sendStatus = this.getMessageSendStatus();
        item.subId = this.slotId;
        item.isMsm = false;
        item.mmsSource = [];
        item.isRcs = common.MESSAGE_TYPE.RCS;
        this.setDateShow(item, this.mmsList, -1);
        this.setShowTitle(item, this.mmsList);
        this.mmsList.push(item);
        hiTraceMeter.finishTrace(TraceConstant.TRACE_SEND_MSG_REFRESH, TraceConstant.TRACE_SEND_MSG_REFRESH_ID);
        ConversationDataSource.getInstance().refresh(this.mmsList);
    }

  /**
   * 获取消息的状态
   */
  private getMessageSendStatus(): number {
    return common.int.SEND_MESSAGE_SENDING;
  }

    public setMessageData(actionData: ActionDataType) {
        let displayText = actionData.content;
        let reply = new Reply();
        reply.displayText = displayText;
        let postback = new Postback();
        if (actionData.data) {
            postback.data = actionData.data;
            reply.postback = postback;
        } else {
            postback.data = 'new_bot_user_initiation';
            reply.postback = postback;
        }
        let response = new Response();
        response.reply = reply;
        let clientMessage = new ClientMessage();
        clientMessage.response = response;
        let message = JSON.stringify(clientMessage);
        return message;
    }

    public startBrowsableAbility(uri: string, context: myCommon.UIAbilityContext): void {;
        let want: Want = {
            action: 'ohos.want.action.viewData',
            entities: ['entity.system.browsable'],
            uri: uri
        };
        context.startAbility(want)
            .then(() => {
                HiLog.i(TAG, 'Start browsableAbility successfully.');
            })
            .catch((err: BusinessError) => {
                HiLog.e(TAG, `Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
            });
    }

    public setSlideInfoOffset() {
        HiLog.i(TAG, '[setSlideInfoOffset]')
        try {
            this.slideYOffset = this.scroller.getItemRect(this.slideMmsIndex).y;
            HiLog.i(TAG, 'slide offset is :' + this.slideYOffset)
        } catch (err) {
            HiLog.i(TAG, `Failed to getItemRect, Code is ${err.code}, message is ${err.message}`);
        }
    }

    public scrollToSlideIndex() {
        HiLog.i(TAG, '[scrollToSlideIndex]')
        if (this.slideMmsIndex >= 0) {
            HiLog.i(TAG, 'slide index is :' + this.slideMmsIndex)
            let mun: LengthMetrics = new LengthMetrics(-this.slideYOffset);
            this.scroller.scrollToIndex(this.slideMmsIndex, false, ScrollAlign.START, {
                extraOffset: mun
            });
            this.slideMmsIndex = -1;
            this.slideYOffset = -1;
        }
    }

    public sendMessageIsHasMap(): boolean {
        let isSendMms = true;
        let source = this.mAttachAreaCtrl.mmDisplaySource;
        if (source.length > 0) {
            for (let i = 0; i < source.length; i++) {
                HiLog.i(TAG,'sendMessageisHasMap source type: ' + source[i]?.type);
                if (source[i]?.type === commonData.ENHANCED_INFO_ITEM_TYPE.MAP) {
                    isSendMms = false;
                    break;
                }
            }
        }
        if (!isSendMms) {
            Prompt.showToast({
                message: $r('app.string.not_loggedin_RCS'),
                duration: 2000,
            });
            return false;
        }
        return true;
    }

    public async shareFileIsForward(streams: string[], bundleName: string): Promise<boolean> {
        if (bundleName !== 'com.ohos.photos') {
            HiLog.i(TAG, 'shareFileIsForward is not photo');
            return true;
        }
        let isOnlineRcs = SharedPreferencesUtils.getFromPreferences('isUIOpenRcs', '') as boolean;
        let isRcsStatus = AppStorage.get('rcsStatus') as boolean;
        let size: number = 0;
        for (let i = 0; i < streams.length; i++) {
            let fd: number = -1;
            try {
                let file = fs.openSync(streams[i], fs.OpenMode.READ_ONLY);
                size += fs.statSync(file.fd).size;
                fs.closeSync(file);
            } catch (err) {
                HiLog.i(TAG, `shareFileIsForward getFileSize err: ${err}` );
            } finally {
                if (fd != -1) {
                    fs.closeSync(fd);
                }
            }
        }
        HiLog.i(TAG, 'shareFileIsForward size: ' + size);
        if ((size / commonData.int.RCS_AUDIO_DURATION_CONVERSION) > common.TRANSMIT_ITEM_HEIGHT.THEME_IMAGE_HEIGHT) {
            let msg: Resource = $r('app.string.send_file_exceed_max_size',
                formatFileSize(common.TRANSMIT_ITEM_HEIGHT.THEME_IMAGE_HEIGHT * commonData.int.RCS_AUDIO_DURATION_CONVERSION,
                    common.int.RETRY_TIME_THIRD));
            promptAction.showToast({
                message: msg,
                duration: common.int.MAX_RETRY_TIME * commonData.int.RCS_AUDIO_DURATION_CONVERSION
            });
            return false;
        }
        return true;
    }

    getVcardPath () {
        return this.mmsList[this.mmsIndex].mmsSource.filter(item => MmsUtil.isVcard(item.type))[0]?.path;
    }


    /**
     * 短信为服务号信息时打点
     * @param isHasLogo 是否含有logo
     * @param isHasName 是否含有 名称
     * @param portNum 端口号，脱敏处理
     */
    public reportReceiveServiceNumberEvent(isHasLogo: boolean, isHasName: boolean, portNum: string) {
        if (!isHasLogo && !isHasName || StringUtil.isEmpty(portNum)) {
            HiLog.w(TAG, `reportSendReceiveSuccessRate params invalid type`);
            return;
        }
        let param = new MsgServiceNumberParams();
        param.IS_HAS_SERVICE_LOGO = isHasLogo;
        param.IS_HAS_SERVICE_NAME = isHasName;
        param.PORNUM = StringUtil.phoneMask(portNum);
        DotUtil.getInstance().reportServiceNumberEvent(param, dotCommon.eventName.SMS_ISSERVICE_MSG);
    }
}

/**
 * Stores the contact information of each session.
 * The information needs to be saved to the Session table in the database.
 */
export interface SessionContactInfoForDB {
    rawContactId: string;
    contactId: string;
    contactPhone: string;
    contactName: string;
}

export interface ResultInfo {
    sendStatus: number;
    msgId: string;
}

export interface RcsFileOptions {
    msgId: string;
    dstFileName: string;
    srcFileName: string;
    fileType: string;
    extraParam?: object;
}

export interface RcsSendOptions {
    destination: string;
    msgType?: number;
    content: string;
    extraParam?: object;
}

export interface RcsChatbotOptions {
    threadId?: number;
    strContactsName?: string;
    strContactsNumber?: string;
    chatbotPageIcon?: string;
    content?: string;
    suggestions?: string;
    isDeeplink?: boolean;
    isSendHello?: boolean;
    smsType: number;
    isInvokeCamera?: boolean;
    isVoicing?: boolean;
    isNewMsg?: boolean;
}

export function updateFavorite(searchContent: string): void {
    if (!StringUtil.isEmpty(searchContent)) {
        AppStorage.setOrCreate(Constant.IS_FAVORITE_CHANGE, true);
    }
}
