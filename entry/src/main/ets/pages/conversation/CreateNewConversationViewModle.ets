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
// import rcs from '@ohos.telephony.rcs';
// import { BDMsgAuthSdk } from '@bdmsg/bdmsgsdk';
import Prompt from '@ohos.promptAction';
import promptAction from '@ohos.promptAction';
import emitter from '@ohos.events.emitter';
import HiLog from '../../utils/HiLog';
import common from '../../data/commonData';
import commonData from '../../data/commonData';
import EmitterConstant from '../../data/EmitterConstant';
import commonEvent from '@ohos.commonEventManager';
import ConversationService from '../../service/ConversationService';
import ConversationListService from '../../service/ConversationListService';
import LooseObject from '../../data/LooseObject';
import settingService from '../../service/SettingService';
import TelephoneUtil from '../../utils/TelephoneUtil';
import MmsPreferences from '../../utils/MmsPreferences';
import lazy { DateUtil } from '../../utils/DateUtil';
import commonCtrl from './common';
import AvatarColor from '../../model/common/AvatarColor';
import { addAirPlaneModeListener, queryAirPlaneMode, removeAirPlaneModeListener } from './AirplaneMode';
import ConversationListController, { Params } from '../conversationlist/conversationListController';
import ConListController, { photoFirstNamesType } from '../conversationlist/conversationListController';
import { AsyncCallback, BusinessError } from '@ohos.base';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import MMAttachmentAreaController from '../../views/AttachmentArea/MMAttachmentAreaController';
import MmsUtil, { KEEP_MESSAGE_TYPE_WHEN_MMS_TO_RCS, KEEP_MESSAGE_TYPE_WHEN_RCS_TO_MMS } from '../../utils/MmsUtil';
import FileUtil from '../../utils/FileUtil';
import { AddressInfo, Mms, RcsSendLoc, SessionContentTypeOfRcs } from '../../utils/TypesUtils';
import hiTraceMeter from '@ohos.hiTraceMeter';
import TraceConstant from '../../data/TraceConstant';
import MMPictureController from '../../views/AttachmentArea/MMPictureController';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import tabTextList from './emoji'
import lazy { Emoji } from './emoji'
import AdvancedSettingsController from '../settings/advancedSettings/advancedSettingsController';
import MessageUtil from '../../../cust/utils/MessageUtil';
import StringUtil, { isObjectJSONString } from '../../utils/StringUtil';
import ObjectUtil from '../../utils/ObjectUtil';
import sim from '@ohos.telephony.sim';
import fileUri from '@ohos.file.fileuri';
import DotUtil from '../../utils/MmsDot/DotUtils';
import dotCommon, {
  dotNoNeedParmas,
  dotSendParmas,
  otherEntranceParmas,
  sendMmsParams,
} from '../../utils/MmsDot/DotCommon';
import ImageUtil from '../../utils/ImageUtil';
import image from '@ohos.multimedia.image';
import curves from '@ohos.curves';
import {
  IQueryMessageDetailAll,
  IQueryMessageDetailInfo,
  IQueryMsgDetailSizeInfo
} from '../../model/type/ConversationParams';
import DataShareHelper from '../../model/repository/DataShareHelper';
import { EnhancedInfoTemporaryDataSource } from '../../model/EnhancedInfoTemporaryDataSource';
import YellowPageService from '../../service/yellowPageService';
import { call } from '@kit.TelephonyKit';
import I18n from '@ohos.i18n';
import { HashMap, LinkedList } from '@kit.ArkTS';
import ConversationModel from '../../model/ConversationModel';
import { settings } from '@kit.BasicServicesKit';
import OperatorConfigUtil from '../../../cust/utils/OperatorConfigUtil';
import ReportSpamMessageManager from '../../report/ReportSpamMessageManager';
import { GlobalContextKey } from '../../data/commonData';
import {
  ActionDataType,
  BaseItemType,
  groupIdsInfos,
  InitData,
  itemType,
  mmsListType,
  MmsSourceType,
  ResultInfo,
  selectContactType,
  SendMsgIndexes,
  SessionContactInfoForDB,
} from './conversationController';
import SmilFile from '../../utils/SmilFile';
import { ActionData as Action, DraftModel, DraftUtils } from '../../utils/DraftUtils';
import Constant from '../../data/Constant';
import DeviceUtil from '../../utils/DeviceUtil';
import lazy { isSameTel } from '../../utils/TelephoneUtilEnhancde';
import { removeAIFaceChangeModeListener } from './AIFaceChangeMode';
import ContactsService from '../../service/ContactsService';

const TAG = 'CreateNewConversationViewModle';
const SINGLE_CONTACT: number = 1;
const DOUBLE: number = 60;
const DEGREE: string = '°';
const MINUTE: string = '\'';
const SECOND: string = '\"';
const ONE_HOUR_IN_MILLISECOND = 3600000;

interface pictureListFromGalleryType {
  checkedValue: boolean
  path: string
}

interface InsertResult {
  rowId: number
  initDatas: InitData[]
  groupId: number
}

@Observed
export default class CreateNewConversationViewModle {
  public isRcsMms: boolean = false;
  public haveTwoCards: boolean = false;
  public commonCtrl = commonCtrl.getInstance();
  // Is it just a recording?
  public isOnlyAudio: boolean = false;
  // Text entered in the text box, which is also the content of the SMS message to be sent.
  public textValue: string = '';
  // Whether SMS messages can be sent.
  public canSendMessage: boolean = false;
  // Whether air plane mode.
  public isAirPlaneMode: boolean = false;
  // Whether the currently edited message is an MMS message
  public isEditMms: boolean = false;
  // Contact First Name
  public strContactsName: string = '';
  // Contact contactId
  public contactId: string = '';
  // Stores the contact information that needs to be saved to the database.
  public sessionContactsInfo: SessionContactInfoForDB[] = [];
  // Contact Phone Number
  public strContactsNumber: string = '';
  // Contact Phone Number Formatting
  public strContactsNumberFormat: string = '';
  // Indicates whether the information is created.
  public isNewMsg: boolean = false;
  // Number of Contacts
  public contactsNum: number = 0;
  // Original Contacts Names List
  public contactsNameList: string[] = [];
  // MM Edit List
  public mmsEditList: Array<MmsSourceType> = [];
  // Information List
  public mmsList: Array<mmsListType> = [];
  // Thumbnails in Gallery
  public pictureListFromGallery: Array<pictureListFromGalleryType> = [];
  // Contact list, which is obtained from the contact app and used as an attachment for sending MMS messages.
  // contactListFromContactApp: Array<any> = [];
  // Card slot
  public slotId: number = 0;
  // 记录SessionId和SelectContacts的对应关系
  public selectContactsMap: Map<number, Array<selectContactType>> = new Map();
  // Content in the recipient text box
  public receiveContactValue: string = '';
  // ID of the session list.
  public threadId: number = 0;
  // Is it grass?
  public isDraft: boolean = false;
  // Contents of the draft
  public draftContent: string = '';
  public draftGroupId: number = 0;
  // 0: normal; 1: notification
  public smsType: number = 0;
  public textareaDatasource: Array<LooseObject> = [];
  public photoFirstName: string = '';
  public portraitColor: string | Resource = common.STR.EMPTY_STR;
  public rawContactId: string = '';
  public reg: RegExp = new RegExp('[\\u4e00-\\u9fa5_a-zA-Z]');
  public allChinese: RegExp = new RegExp('^[\\u3400-\\u4db5_\\u4e00-\\u9fa5]+$');
  public hasChinese: RegExp = new RegExp('[\\u3400-\\u4db5_\\u4e00-\\u9fa5]');
  public hasEnglish: RegExp = new RegExp('[a-zA-Z]');
  public isBackToIndex: boolean = true;
  public pageInfos: NavPathStack = new NavPathStack();
  public conListCtrl: ConListController = ConListController.getInstance();
  public mAttachAreaCtrl: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
  public pictureCtrl: MMPictureController = MMPictureController.getInstance();
  // Byte array of all emojis
  private allEmojiValues: number[][] | undefined = undefined;
  // The emoji strings
  private emojiStrArray: string[] | undefined = undefined;
  // The max length of emoji codes
  private emojiCodesMaxLen: number = 0;
  public copySource: Array<Mms> = [];
  public mAdvancedSettingsCtrl: AdvancedSettingsController = AdvancedSettingsController.getInstance();
  public isChangeInputPlaceholder: boolean = false;
  public setMMsFlag: boolean = false;
  public contactsNameIsNotEqualToContactsNumberFormat: boolean = false;
  public sendReportable: boolean = false;
  // Are both SIM cards not activated
  public isNoCardActive: boolean = false;
  // Activate both SIM cards
  public isAllCardActive: boolean = false;
  public isAllCardReady: boolean = false;
  public isAllCardCanSend: boolean = false;
  private context: myCommon.UIAbilityContext =
    GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext
  private covLatitude: string = '';
  private covLongitude: string = ''
  public yellowPageId: string = '';
  public hasYellowPageIcon: string = '';
  public callingSlotId: number = -1;
  private dsdsMode: sim.DsdsMode = 0;
  public queryTerminate = new Map<number, number>();
  private isShow: boolean = false;
  public currentQueryTimeID: number = 0;
  private conversationPixelMap: HashMap<string, PixelMap> = new HashMap();
  public vCardJumpBack: boolean = false;
  public caretPosition: number = 0;
  public isEmoChange: boolean = false
  public isNewSend: boolean = false;
  public messageCount: number = 0;
  public maxSizeOfMms: number = OperatorConfigUtil.getInstance().getCustMMSSize(commonData.int.MMS_FILE_MAX_SIZE) ||
    307200;
  private isSmartOpen: boolean = false;
  // public smartMmsCardController: SmartMmsCardController = new SmartMmsCardController()
  private timeoutID: number = -1
  public isSend: boolean = false
  public isTextAsMms: boolean = false;
  public hasAttachment: boolean = false;
  public draftModel: DraftModel = new DraftModel()
  public newEmojiLength: number = 0;
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

  handleSendReportable() {
    const deliveryReportSwitch = MmsPreferences.getInstance().getValueOfDeliveryReportSwitch();
    this.sendReportable = deliveryReportSwitch == common.DELIVERY_REPORTS.MMS
      || deliveryReportSwitch == common.DELIVERY_REPORTS.SMS_AND_MMS;
  }

  onInit(context: Context, pageInfos: NavPathStack) {
    HiLog.i(TAG, 'onInit');
    this.pageInfos = pageInfos;
    this.isSmartOpen = SharedPreferencesUtils.getFromPreferences('isOpenSmart', false) as boolean;
    this.handleSendReportable();
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_INIT,
      TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_INIT_ID);
    if (AppStorage.get('comeFromContact')) {
      // 新建信息-三方应用拉起打点
      otherEntranceParmas.OTHER_PNAMEID = 'com.ohos.contacts';
      DotUtil.getInstance().reportEvent(otherEntranceParmas, dotCommon.eventName.OTHER_APP_PULL);
    }
    this.initData();
    this.initRouterData();
    // 异步渲染 智能信息卡片相关
    // this.smartMmsCardController.init(this.strContactsNumber);
    this.initNewPageContacts();
    this.initYellowPageData();
    this.rcsLoggedIn();
    this.rcsStateChange();
    this.getHasSimCard();
    this.mAdvancedSettingsCtrl.getAdvancedPageSwitchValue(); // use 3ms
    AppStorage.setOrCreate('isConversationNeedChange', true);
    this.initCurrentQueryTimeID();
    this.isShow = false;
    // Obtains the actual data. You do not need to query the data when creating new data.
    this.obtainSessionInformation(context);
    this.resetDraftContactsParam();
    EnhancedInfoTemporaryDataSource.getInstance().clearMapImageMsgIdToData();
    hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_INIT,
      TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_INIT_ID);
  }

  onInitBySmc(pageInfos: NavPathStack) {
    HiLog.i(TAG, 'onInit');
    this.pageInfos = pageInfos;
    this.initData();
    this.initCurrentQueryTimeID();
    this.isShow = false;
  }

  initCurrentQueryTimeID() {
    // 进入页面 or threadId 重新生成情况，需要重新生成对应 currentQueryTimeID
    this.currentQueryTimeID = new Date().getTime();
    HiLog.i(TAG, `initCurrentQueryTimeID currentQueryTimeID: ${this.currentQueryTimeID}, threadId: ${this.threadId}`);
    this.queryTerminate.set(this.threadId, this.currentQueryTimeID);
  }

  setIsShow() {
    this.isShow = true;
  }

  async initYellowPageData() {
    if (StringUtil.isEmpty(this.rawContactId) && StringUtil.isEmpty(this.yellowPageId)) {
      let res = await YellowPageService.getInstance()
        .judgeYellowPageByTelephone(this.strContactsNumber, this.context);
      this.yellowPageId = res.yellowPageId;
      if (this.yellowPageId) {
        this.strContactsName = res.name;
        this.smsType = 1;
        this.contactsNameIsNotEqualToContactsNumberFormat = true;
      }
    }
  }

  obtainSessionInformation(context: Context): void {
    if (this.contactsNum == 0) {
      DraftUtils.getInstance().queryNoReceiverDraft(getContext(this),
        (result: LooseObject) => {
          if (result.code == common.int.SUCCESS) {
            HiLog.i(TAG, `no receiver draft length: ${result.response?.length}`);
            this.dealMessageDetailTime(context, result, true);
            if (result.response?.length > 0) {
              if (this.draftContent !== common.STR.EMPTY_STR) {
                this.isDraft = true;
                this.draftModel.initialDraftText = this.draftContent;
              }
              this.setDraft();
              this.draftModel.newCreatDrafts = result.response;
            }
            /*
             * 有多个没有联系人的草稿，表示出现脏数据，需要清理脏数据；
             * 跑稳定性发现，特殊情况下会存在多个匿名草稿的问题，会造成其他应用拉去短信时的草稿内容异常。
             * */
            if (result.response?.length > 1) {
              DraftUtils.getInstance().clearDirtyNoReceiverDraft(result.response, getContext(this), () => {});
            }
          }
        })
    } else {
      this.queryMessageDetail(context,
        {
          isDraft: this.isDraft,
          currentPage: 1,
          threadId: this.threadId,
          contactsNum: this.contactsNum,
          queryTimeID: this.currentQueryTimeID,
          startIndex: 0,
          isCallOnInitRequestMessageList: true
        }
        , () => {
          this.getHasSimCard().then(() => {
            if (this.haveTwoCards) {
              this.twoCardsJudging(context);
            }
          }).catch((error: BusinessError) => {
            HiLog.e(TAG, error.message);
          });
        });
      HiLog.i(TAG, 'conversation queryMessageDetail');
    }
    let subId: number = MmsPreferences.getInstance().getSendMessageSlotId();
    this.updateSimSlotId(subId);
  }

  twoCardsJudging(context: Context) {
    setTimeout(() => {
      this.querySmsMmsInfoSlotIdByCondition(context, (result: LooseObject) => {
        let subId: number = result.abilityResult != -1 ? result.abilityResult : 0;
        this.updateSimSlotId(subId);
      })
    }, 50)
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
    GlobalContext.getContext().setObject(GlobalContextKey.IS_JUMP_TO_PREVIEW, false);
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_SHOW,
      TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_SHOW_ID);
    // Check whether the Send button can be clicked.
    this.judgeSendBtnCanClicked();
    // Subscribe to airPlane mode
    this.initAirPlaneMode(context);
    hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_SHOW,
      TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_SHOW_ID);
  }

  changeIsRcsMms(isRcsMms: boolean, isSlotIdChange: boolean) {
    this.isRcsMms = isRcsMms;
    if (!isSlotIdChange) {
      this.resetValuesSwitchBetweenMmsAndRcs(!isRcsMms);
    }
    HiLog.i(TAG, 'changeIsRcsMms this.isRcsMms: ' + this.isRcsMms);
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

  updateSimSlotId(subId: number) {
    AppStorage.setOrCreate('simSlotId', subId);
    let innerEvent: emitter.InnerEvent = { eventId: EmitterConstant.EVENT_CHANGE_SUBID_STATUS }
    let eventData: emitter.EventData = {
      data: {
        'subId': subId
      }
    }
    emitter.emit(innerEvent, eventData)
    MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SELECTED_SLOTID, subId);
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
        this.draftModel.initialDraftText = result[1]
        this.draftModel.isHasSetValueForInitialDraftText = true
      }
    })
  }

  onHide() {
    HiLog.i(TAG, 'onHide');
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_HIDE,
      TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_HIDE_ID);
    if (this.isShow) {
      this.currentQueryTimeID = new Date().getTime();
      this.queryTerminate.clear();
      this.queryTerminate.set(this.threadId, this.currentQueryTimeID);
      this.isShow = false;
    }
    GlobalContext.getContext().setObject('transmitFlag', false)
    hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_HIDE,
      TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_HIDE_ID);
  }

  initData() {
    this.textValue = '';
    this.receiveContactValue = '';
    this.isDraft = false;
  }

  initAirPlaneMode(context: Context) {
    HiLog.i(TAG, 'initAirPlaneMode');
    addAirPlaneModeListener((data: number) => {
      this.isAirPlaneMode = data == 1 ? true : false;
      AppStorage.setOrCreate('isAirPlaneMode', data == 1 ? true : false)
    }, context);
  }

  removeAirPlaneMode() {
    HiLog.i(TAG, 'removeAirPlaneMode');
    removeAirPlaneModeListener();
  }

  getAirPlaneMode() {
    HiLog.i(TAG, 'getAirPlaneMode');
    queryAirPlaneMode((data: number) => {
      HiLog.i(TAG, 'getAirPlaneMode callback');
      this.isAirPlaneMode = data == 1 ? true : false;
    });
  }

  removeSatelliteMode() {
    HiLog.i(TAG, 'removeSatelliteMode');
    removeAIFaceChangeModeListener();
  }

  release() {
    this.textValue = '';
    this.receiveContactValue = '';
    this.isDraft = false;
    this.mmsList = [];
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
    let contactsNames = this.strContactsName.split(',');
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
  }

  initRouterData() {
    let routerParams: LooseObject = this.pageInfos.getParamByIndex(this.pageInfos.size() - 1) as LooseObject;
    //let routerParams: LooseObject = AppStorage.get('ShowNewMmsParams') as LooseObject;
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
    this.isDraft = StringUtil.isEmpty(routerParams.isDraft) ? false : routerParams.isDraft;
    this.draftContent = StringUtil.isEmpty(routerParams.draftContent) ? '' : routerParams.draftContent;
    this.isNewMsg = StringUtil.isEmpty(routerParams.isNewMsg) ? false : routerParams.isNewMsg;
    let photoFirstNames: Array<photoFirstNamesType> =
      StringUtil.isEmpty(routerParams.photoFirstNames) ? [] : routerParams.photoFirstNames;
    this.photoFirstNameDeal(this.strContactsName, photoFirstNames);
    this.isBackToIndex = routerParams?.isFromInfoMsgView ? false : true;
    this.textValue = StringUtil.isEmpty(routerParams.content) ? '' : routerParams.content;
    this.rawContactId = StringUtil.isEmpty(routerParams.rawContactId) ? '' : routerParams.rawContactId;
    this.yellowPageId = StringUtil.isEmpty(routerParams.yellowPageId) ? '' : routerParams.yellowPageId;
    this.hasYellowPageIcon = StringUtil.isEmpty(routerParams.hasYellowPageIcon) ? '' : routerParams.hasYellowPageIcon;
    this.smsType = StringUtil.isEmpty(routerParams.smsType) ? 0 : routerParams.smsType;
    this.portraitColor = AvatarColor.background.Color[Number(this.rawContactId.split(',')[0] || '0') % 6];
    this.messageCount = Number.isNaN(routerParams.messageCount) ? 0 : routerParams.messageCount;
    HiLog.i(TAG, 'isNewMsg : ' + this.isNewMsg)
    this.draftModel.needDeleteSession.isLoaded = true
    this.formatDisplayPhoneNum();
  }

  formatDisplayPhoneNum() {
    if (this.contactsNum > SINGLE_CONTACT) {
      let strContactNameArr = this.strContactsName.split(',');
      let strNumberArr = this.strContactsNumber.split(',');
      let contactsName = common.STR.EMPTY_STR;
      let formatNum = common.STR.EMPTY_STR;
      for (let index = 0; index < strNumberArr.length; ++index) {
        if (strNumberArr[index] != null && strContactNameArr[index] != null &&
          strNumberArr[index].replace(/^\s*|\s*$/g, '') == strContactNameArr[index].replace(/^\s*|\s*$/g, '')) {
          formatNum = TelephoneUtil.formatDisplayPhoneNum(strNumberArr[index]);
          contactsName += (formatNum + common.STR.COMMA + common.STR.WHITE_SPACE);
        } else {
          contactsName += (strContactNameArr[index] + common.STR.COMMA + common.STR.WHITE_SPACE);
        }
      }
      this.strContactsName = contactsName.substring(0, contactsName.length - 2);
    }
    const regContactsName = this.strContactsName?.replace(new RegExp('\\s*', 'g'), '');
    this.contactsNameIsNotEqualToContactsNumberFormat = regContactsName !== this.strContactsNumberFormat;
  }

  rcsLoggedIn(): void {
    HiLog.i(TAG, 'onRcsStateChange Invoking');
    // try {
    //   //设置中RCS开关是否打开
    //   let isRcsSetting: boolean = SharedPreferencesUtils.getFromPreferences('isUIOpenRcs', '') as boolean;
    //   //如果关闭isRcsOpen就为false 否则走isRcsLoggedIn的逻辑
    //   let isRcsOpen: boolean = isRcsSetting ? rcs.isRcsLoggedIn() : false;
    //   HiLog.i(TAG, 'isOnlineRcs isRcsOpen: ' + isRcsOpen);
    //   AppStorage.setOrCreate('isOnlineRcs', isRcsOpen);
    // } catch (err) {
    //   HiLog.e(TAG, 'onRcsStateChange err: ' + err);
    // }
    // return;
  }

  // rcsOn(cb: (message: rcs.RcsEvent) => void): Promise<void> {
  //   return new Promise((resolved, reject: Function) => {
  //     try {
  //       rcs.on('loginStatusChanged', cb);
  //     } catch (error) {
  //       HiLog.e(TAG, 'loginStatusChanged error: ' + JSON.stringify(error));
  //     }
  //     resolved();
  //   });
  // }

  rcsStateChange(): void {
    // try {
    //   this.rcsOn(async (message: rcs.RcsEvent) => {
    //     HiLog.i(TAG, 'on message rcsStateChange: ' + JSON.stringify(message))
    //     if (message.type == 1) {
    //       AppStorage.setOrCreate('isOnlineRcs', true);
    //     } else if (message.type == 0) {
    //       AppStorage.setOrCreate('isOnlineRcs', false);
    //     }
    //   });
    // } catch (err) {
    //   HiLog.e(TAG, 'rcsStateChange err: ' + err);
    // }
    // return;
  }

  photoFirstNameDeal(strContactsName: string, photoFirstNames?: Array<photoFirstNamesType>, callBack?: Function) {
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
          this.photoFirstName = common.FIRST_NAME_TYPE.NOT_CHARACTER;
        }
      } else {
        this.photoFirstName = common.FIRST_NAME_TYPE.NOT_CHARACTER;
      }
      if (photoFirstNames && photoFirstNames.length > 0) {
        let photoObj: photoFirstNamesType = photoFirstNames[0];
        this.portraitColor = photoObj.portraitColor ? photoObj.portraitColor : this.portraitColor;
      }
    }
    if (callBack) {
      callBack(this.photoFirstName, this.portraitColor)
    }
  }

  replaceCode(str: string) {
    if (str != null && str.length != 0) {
      return str.replace(new RegExp('e|-|#|\\*|\\.', 'g'), common.STR.EMPTY_STR);
    } else {
      return common.STR.EMPTY_STR;
    }
  }

  // onBackPress2() {
  //   HiLog.i(TAG, 'onBackPress2');
  //   this.commonCtrl.paramContact.transmitContacts = [];
  //   this.navPageChange2();
  //
  //   if (!this.pageInfos) {
  //     HiLog.i(TAG, 'this.pageInfos is null');
  //     return false;
  //   }
  //   return true;
  // }

  onBackPress(context: Context) {
    HiLog.i(TAG, 'onBackPress');
    if (AppStorage.get(commonData.STR.IS_BACK_HOMEPAGE)) {
      AppStorage.set(commonData.STR.IS_BACK_HOMEPAGE, false);
      (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext).moveAbilityToBackground();
      return true;
    }
    GlobalContext.getContext().setObject('backFromConversation', true);
    this.conListCtrl.isJumping = true;
    this.conListCtrl.lastIndex = -1;
    this.commonCtrl.paramContact.transmitContacts = [];
    // 保存草稿
    this.setDraftModel(() => {
      DraftUtils.getInstance().saveDraft(this.context)
      this.navPageChange()
      this.pictureCtrl.pictureList.forEach(item => {
        item.pixelMap?.release()
      });
      this.pictureCtrl.pictureList = []
      this.pictureCtrl.pictureDataSource.refresh(this.pictureCtrl.pictureList)
    })
    //是否来自联系人（从联系人发短信进到新建短信）
    if (AppStorage.get('comeFromContact')) {
      AppStorage.set('comeFromContact', false);
      (context as myCommon.UIAbilityContext).moveAbilityToBackground();
      HiLog.i(TAG, 'onBackPress isFromContacts!')
      return true;
    }
    if (!this.pageInfos) {
      HiLog.i(TAG, 'this.pageInfos is null');
      return false;
    }
    return true;
  }

  // navPageChange2() {
  //   HiLog.i(TAG, 'onBackPress isBackToIndex');
  //   //router.back({url: 'pages/index'});
  //   this.pageInfos?.clear();
  //   if (this.pageInfos?.getParamByName('SmcConversation')?.length > 0) {
  //     HiLog.i(TAG, `pagesInfos has InfoMsg, now pop to infoMsg!`);
  //     this.pageInfos?.popToName('SmcConversation');
  //   } else {
  //     // 对pathInfos可能没有InfoMsg的情况加保护
  //     HiLog.w(TAG, 'no InfoMsg in pageInfos! ' +
  //       ' this.pageInfos:' +
  //     JSON.stringify(this.pageInfos))
  //     this.pageInfos?.pushPathByName('SmcConversation', {} as LooseObject)
  //   }
  //
  // }

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

  setDraftModel(callback: Function, isNeedToSetNull: boolean = true) {
    if (this.timeoutID >= 0) {
      clearInterval(this.timeoutID)
      this.timeoutID = -1
    }
    let source: Mms[] = this.mAttachAreaCtrl.mmDisplaySource
    let actionData: Action = this.getDraftActionData(source)
    actionData.isNewMsg = true
    actionData.telephone = this.strContactsNumber
    actionData.selectContacts = this.getSelectContacts()
    actionData.receiveContactValue = this.receiveContactValue
    this.draftModel.actionData = actionData
    DraftUtils.getInstance().draftModelArray.push(JSON.parse(JSON.stringify(this.draftModel)))
    if (isNeedToSetNull) {
      this.resetMmsSource();
      this.release()
    }
    callback()
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

  formateDuration(time: string) {
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

  showReportToast(msg: ResourceStr, reportScreenPadding: number) {
    let option: promptAction.ShowToastOptions = {
      message: msg,
      duration: 2000,
      bottom: 80 + reportScreenPadding
    }
    MmsUtil.showToast(option);
  }

  async handleAppealSmsContent(item: mmsListType, actionData: LooseObject, valueBucket: ValuesBucket,
    reportScreenPadding: number, context: Context) {
    HiLog.i(TAG, 'handleAppealSmsContent');
    await ReportSpamMessageManager.getInstance().initReportSpamMessageManager(this.context);
    let reportResult: boolean =
      await ReportSpamMessageManager.getInstance()
        .reportSmsContent(this.context, item.content.toString(),
          item.senderNumber);
    if (reportResult) {
      // update is_report to mms conversation
      ConversationService.getInstance().updateSmsMmsInfoByCondition(context, actionData, valueBucket,
        (res: LooseObject) => {
          HiLog.i(TAG, `updateSmsMmsInfoByCondition result.code: ${res.code}`);
          if (res.code == common.int.SUCCESS) {
            item.isReport = common.is_report.REPORT;
          } else {
            this.showReportToast($r('app.string.messageReportFailed'), reportScreenPadding);
          }
        });
    } else {
      this.showReportToast($r('app.string.messageReportFailed'), reportScreenPadding);
    }
  }

  deleteMessageByGroupIds(context: Context, groupIds: number[], groupInfos?: Array<groupIdsInfos>, isReSend?: boolean,
    isGroupSession?: boolean): void {
    HiLog.i(TAG, 'deleteMessageByGroupIds groupId is :' + JSON.stringify(groupIds));
    let actionData: LooseObject = {};
    let groupIdMms: number[] = [];
    let groupIdRcs: number[] = [];
    let msgIdsRcs: string[] = [];
    let rcsId: number[] = [];
    if (groupInfos !== undefined) {
      for (let index = 0; index < groupInfos?.length; index++) {
        // if (groupInfos[index].isRcs === common.MESSAGE_TYPE.RCS) {
        //   groupIdRcs.push(groupInfos[index].groupId as number)
        //   msgIdsRcs.push(groupInfos[index].msgId as string)
        //   rcsId.push(groupInfos[index].rcsId as number)
        //   groupIdMms.push(groupInfos[index].groupId as number)
        // } else {
          groupIdMms.push(groupInfos[index].groupId as number)
        // }
      }
      if (groupIdMms.length == 1) {
        actionData.groupId = groupIdMms[0];
      } else {
        actionData.groupIds = groupIdMms;
      }
      if (groupIdRcs.length == 1) {
        actionData.groupIdRcs = groupIdRcs[0];
        actionData.msgIdsRcs = msgIdsRcs;
        actionData.rcsId = rcsId[0];
      } else {
        actionData.groupIdsRcs = groupIdRcs;
        actionData.msgIdsRcs = msgIdsRcs;
        actionData.rcsIds = rcsId;
      }
    } else {
      if (groupIds.length == 1) {
        actionData.groupId = groupIds[0];
      } else {
        actionData.groupIds = groupIds;
      }
    }
    if (isReSend) {
      actionData.isReSendRcs = true;
    }
    actionData.isGroupSession = Boolean(isGroupSession);
    // Invoke the database deletion method.
    ConversationService.getInstance().deleteSmsMmsInfoByCondition(context, actionData, () => {
    });
  }

  public querySmsMmsInfoSlotIdByCondition(context: Context, callBack: Function): void {
    let phoneNumber: string = this.strContactsNumber;
    ConversationService.getInstance().querySmsMmsInfoSlotIdByCondition(context, phoneNumber, (res: LooseObject) => {
      callBack(res);
    });
  }

  /**
   * Obtain information details.
   *
   * @param callback
   */
  public async queryMessageDetail(context: Context, queryInfoObj: IQueryMessageDetailInfo, callback?: Function): Promise<void> {
    GlobalContext.getContext().setObject('is24HourTime', I18n.System.is24HourClock());
    HiLog.i(TAG, 'start queryMessageDetail , threadId:' + this.threadId + ', queryInfoObj.threadId: ' +
    queryInfoObj.threadId + ',queryInfoObj.queryTimeID: ' + queryInfoObj.queryTimeID);
    if (this.queryTerminate.get(queryInfoObj.threadId) != queryInfoObj.queryTimeID || this.vCardJumpBack) {
      HiLog.i(TAG, `DqueryMessageDetail return queryTerminate: ${queryInfoObj.queryTimeID}`);
      this.vCardJumpBack = false;
      return;
    }
    let actionData: IQueryMsgDetailSizeInfo = { threadId: this.threadId, needDistinct: false };
    if ((this.messageCount == undefined || this.messageCount == common.int.INVALID_DATA) && !this.isSmartOpen) {
      this.messageCount = await ConversationService.getInstance().queryAllInfoSizeByCondition(context, actionData);
    }
    if (this.messageCount == 0 && !queryInfoObj.isDraft) {
      HiLog.i(TAG, 'current session msgCount = 0');
      hiTraceMeter.startTrace(TraceConstant.TRACE_QUERY_ALL_INFO_SIZE,
        TraceConstant.TRACE_QUERY_ALL_INFO_SIZE_ID);
      this.messageCount = await ConversationService.getInstance().queryAllInfoSizeByCondition(context, actionData);
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
    queryInfoObj.resultTotal = queryInfoObj.isDraft ? --this.messageCount : this.messageCount;
    if (!queryInfoObj.lastListSize) {
      if (this.isSmartOpen && this.isSmartQueryFlag()) {
        actionData.contactsNum = 1;
        this.messageCount = await ConversationService.getInstance().queryAllInfoSizeByCondition(context, actionData);
        queryInfoObj.resultTotal = queryInfoObj.isDraft ? --this.messageCount : this.messageCount;
      }
      queryInfoObj.lastListSize = -1;
      queryInfoObj.startIndex = queryInfoObj.resultTotal;
    }
    if (this.mmsList.length == 0 && this.isSmartOpen && this.isSmartQueryFlag()) {
      this.mmsList = new Array(queryInfoObj.resultTotal).fill(new mmsListType());
      HiLog.i(TAG, 'queryMessageDetail new this.mmsList.length ' + this.mmsList.length);
    }
    let queryActionData: IQueryMessageDetailAll = {
      actionDataName: Constant.ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL,
      threadId: queryInfoObj.threadId,
      page: queryInfoObj.currentPage,
      contactsNum: queryInfoObj.contactsNum
    };
    (this.isSmartOpen && this.isSmartQueryFlag()) ?
    this.queryMessageDetailAllSmart(context, queryInfoObj, queryActionData, callback)
      : this.queryMessageDetailAllInner(context, queryInfoObj, queryActionData, callback);
  }

  private isSmartQueryFlag(): boolean {
    if (this.contactsNum == 1 && TelephoneUtil.judgeIsInfoMsg(this.strContactsNumber)) {
      return true;
    }
    return false;
  }

  private queryMessageDetailAllInner(context: Context, queryInfoObj: IQueryMessageDetailInfo, queryActionData: IQueryMessageDetailAll,
    callback?: Function) {
    ConversationService.getInstance().queryMessageDetailAll(context, queryActionData, (result: LooseObject) => {
      if (result.code == common.int.SUCCESS) {
        let curBp: string = AppStorage.get('curBp') as string;
        if (queryInfoObj.threadId != this.threadId && curBp === common.STR.DEVICE_MOBILE_PHONE) {
          HiLog.i(TAG, `not need refresh threadId: ${queryInfoObj.threadId}, this.threadId: ${this.threadId}`);
          return;
        }
        result = this.dealMessageDetailTime(context, result);
        if (queryInfoObj.currentPage == 1) {
          this.mmsList = result as mmsListType[]
        } else {
          let newQueryMmsList: mmsListType[] = result as mmsListType[]
          this.mmsList = newQueryMmsList.concat(this.mmsList)
        }
        HiLog.i(TAG, `1 Detail, this.mmsList.length: ${this.mmsList.length} , total: ${queryInfoObj.resultTotal},
                    this.page: ${queryInfoObj.currentPage}`);
        if (queryInfoObj.resultTotal && this.mmsList.length < queryInfoObj.resultTotal &&
        queryInfoObj.lastListSize && queryInfoObj.lastListSize < this.mmsList.length) {
          queryInfoObj.lastListSize = 0;
          queryInfoObj.currentPage++;
          setTimeout(() => {
            this.queryMessageDetail(context, queryInfoObj, callback);
          }, 200);
          return;
        }
        if (queryInfoObj.isDraft) {
          HiLog.i(TAG, 'queryMessageDetail, isNewMsg = true');
          this.isNewMsg = true;
        }
      } else {
        HiLog.w(TAG, 'queryMessageDetail fail! actionData: ' + JSON.stringify(queryActionData));
      }
      if (queryInfoObj.isDraft) {
        this.setDraft();
      }
      if (callback) {
        callback();
      }
    }, 0);
  }

  private queryMessageDetailAllSmart(context: Context, queryInfoObj: IQueryMessageDetailInfo, queryActionData: IQueryMessageDetailAll,
    callback?: Function) {
    ConversationService.getInstance().queryMessageDetailAll(context, queryActionData, (result: LooseObject) => {
      if (result.code == common.int.SUCCESS) {
        let curBp: string = AppStorage.get('curBp') as string;
        if (queryInfoObj.threadId != this.threadId && curBp === common.STR.DEVICE_MOBILE_PHONE) {
          HiLog.i(TAG, `not need refresh threadId: ${queryInfoObj.threadId}, this.threadId: ${this.threadId}`);
          return;
        }
        result = this.dealMessageDetailTime(context, result, queryInfoObj.isCallOnInitRequestMessageList);
        let newQueryMmsList: mmsListType[] = result as mmsListType[];
        let start = queryInfoObj.startIndex - newQueryMmsList.length;
        HiLog.i(TAG, `1 Detail, this.mmsList.length: ${queryInfoObj.startIndex - start} ,
                    total: ${queryInfoObj.resultTotal}, this.page: ${queryInfoObj.currentPage} ,
                    queryInfoObj.startIndex: ${queryInfoObj.startIndex}`);
        this.mmsList.splice(start, newQueryMmsList.length, ...newQueryMmsList)
        if (start != queryInfoObj.startIndex && start > 0 &&
        queryInfoObj.lastListSize && queryInfoObj.lastListSize < this.mmsList.length) {
          queryInfoObj.lastListSize = this.mmsList.length - start;
          queryInfoObj.startIndex = start;
          queryInfoObj.currentPage++;
          this.queryMessageDetailAllSmartQuery(context, queryInfoObj, callback)
          return;
        }
        if (this.mmsList.length == 0 && queryInfoObj.isDraft) {
          HiLog.i(TAG, 'queryMessageDetail, isNewMsg = true');
          this.isNewMsg = true;
        }
      } else {
        HiLog.w(TAG, 'queryMessageDetail fail! actionData: ' + JSON.stringify(queryActionData));
      }
      if (queryInfoObj.isDraft) {
        this.setDraft();
      }
      if (callback) {
        callback();
      }
    }, 0);
  }

  private queryMessageDetailAllSmartQuery(context: Context, queryInfoObj: IQueryMessageDetailInfo, callback?: Function) {
    setTimeout(() => {
      this.queryMessageDetail(context, queryInfoObj, callback)
    }, 200);
  }

  /**
   *
   * @param context
   * @param result
   * @param isCallOnInitRequestMessageList 是否在页面初始化请求数据的时候调用
   * @returns
   */
  private dealMessageDetailTime(context: Context, result: Record<string, mmsListType[]>,
    isCallOnInitRequestMessageList?: boolean): Array<LooseObject> {
    let resultList: Array<mmsListType> = [];
    if (result.response && result.response.length > 0) {
      for (let entry of result.response.entries()) {
        let item = entry[1];
        item.timeMillisecond = Number.parseInt(item.timeMillisecond as string);
        DateUtil.fullDate(item);
        DateUtil.convertTimeStampToDateWeek(item, false);
        this.setDateShow(item, resultList, -1);
        DateUtil.convertDateFormatForItem(item);
        if (item.sendStatus == common.int.SEND_DRAFT) {
          this.dealDraftData(context, item, isCallOnInitRequestMessageList);
        } else {
          resultList.push(item);
        }
      }
    }
    return resultList;
  }

  /**
   * @param context
   * @param item
   * @param isCallOnInitRequestMessageList 是否在页面初始化请求数据的时候调用
   * @returns
   */
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
        this.draftModel.initialDraftText = this.draftContent
        this.draftModel.isHasSetValueForInitialDraftText = true
      }
      this.canSendMessage = MmsPreferences.getInstance().haveSimCardReady();
    }
  }

  updateDetail(context: Context, threadId: number, sendResult: Record<string, string | number | string[]>, sendNumbersLength: number,
    msgId: string, resendStateIsRcs?: boolean) {
    let actionData: LooseObject = {};
    let sendResults: Array<Object> = [];
    sendResults.push(sendResult);
    actionData.sendResults = sendResults;
    actionData.threadId = threadId;
    let isRcsMmsType: boolean = false;
    if (sendResult.isRcs === common.MESSAGE_TYPE.RCS) {
      isRcsMmsType = true;
    } else {
      isRcsMmsType = false;
    }
    ConversationService.getInstance()
      .updateSessionAndDetail(context, isRcsMmsType, actionData, sendNumbersLength, msgId, resendStateIsRcs);
    let sendStatus: number = sendResult.sendStatus as number;
    let deliveryReportSwitch: string = MmsPreferences.getInstance().getValueOfDeliveryReportSwitch();
    HiLog.i(TAG, 'updateDetail, sendStatus=' + sendStatus + ', deliveryReportSwitch=' + deliveryReportSwitch);
    if ((deliveryReportSwitch == common.DELIVERY_REPORTS.SMS_AND_MMS ||
      deliveryReportSwitch == common.DELIVERY_REPORTS.SMS) && sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
      let msg: string = '';
      let phoneNumber: string = sendResult.telephone as string;
      if (sendResult.contactName === common.STR.EMPTY_STR) {
        msg = TelephoneUtil.formatDisplayPhoneNum(sendResult.telephone as string) + '';
      } else if (phoneNumber.startsWith('sip')) {
        msg = sendResult.contactName as string;
      } else {
        msg = sendResult.contactName + '<' + TelephoneUtil.formatDisplayPhoneNum(sendResult.telephone as string) + '>'
      }
      let receivedResource: Resource = $r('app.string.message_received', msg)
      let receivedMsg: string = (GlobalContext.getContext()
        .getObject('mmsContext') as myCommon.UIAbilityContext).resourceManager.getStringSync(receivedResource, msg);
      this.showToast(receivedMsg)
    }
    let tempRcsId: number = -1;
    let tempSatellite: number = -1;
    for (let item of this.mmsList) {
      item.showTitle = (tempRcsId !== item.isRcs);
      tempRcsId = item.isRcs as number;
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


  initSendParams(actionData: ActionDataType, sendNumber: string, bodyText: string, rcsMsgType: number) {
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

  initSendResult(initDatas: InitData[], sendNumber: string, contactName: string, content: string) {
    let id: number = this.getSendMessageId(initDatas, sendNumber);
    let sendResult: Record<string, number | string[] | string> = {
      'id': id,
      'telephone': sendNumber,
      'content': content,
      'contactName': contactName
    }
    return sendResult;
  }



  insertInitData(actionData: ActionDataType, item: mmsListType, callback: Function): void {
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_INSERT_INIT_DATA,
      TraceConstant.TRACE_CONVERSATION_INSERT_INIT_DATA_ID);
    let sendNumbers: string[] = actionData.hosts as string[];
    let insertSendResults: LooseObject[] = [];
    for (let i = 0; i < sendNumbers.length; i++) {
      let sendResult: Record<string, number | string[] | number | string> = {
        'slotId': actionData.slotId,
        'telephone': sendNumbers[i],
        'content': actionData.content,
        'sendStatus': common.int.SEND_MESSAGE_SENDING
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
    if (actionData && typeof actionData.groupId === 'number' && !isNaN(actionData.groupId)) {
      actionData_.groupId = actionData.groupId;
    }
    if (item.isRcs === common.MESSAGE_TYPE.RCS) {
      actionData_.type = commonData.RCS_TYPE.RCS_SEND;
      actionData_.isRcsType = item.rcsType;
      HiLog.iw(TAG, 'item.msgType：' + actionData_.isRcsType);
    }
    if (actionData.resendStateIsRcs === true) {
      actionData_.type = commonData.RCS_TYPE.RCS_SEND;
    }
    if (actionData.resendStateIsRcs !== undefined) {
      if (actionData.resendStateIsRcs === false) {
        actionData_.type = commonData.RCS_TYPE.MMS_SEND;
      }
    }
    ConversationService.getInstance().insertSessionAndDetail(actionData_, callback,
      GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);
    hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_INSERT_INIT_DATA,
      TraceConstant.TRACE_CONVERSATION_INSERT_INIT_DATA_ID);
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
        }
      });
    }
    this.isOnlyAudio = !this.mmsEditList.some((item, index) => item.type != common.MSG_ITEM_TYPE.AUDIO);
    if (this.mmsEditList.length == 0) {
      this.convertingSms();
    }
  }

  initSendItem() {
    // Obtains the day of the week.
    hiTraceMeter.startTrace(TraceConstant.TRACE_SEND_MSG_REFRESH, TraceConstant.TRACE_SEND_MSG_REFRESH_ID);
    HiLog.i(TAG, 'initSendItem, start')
    let item: mmsListType = new mmsListType();
    item.date = common.STR.EMPTY_STR;
    item.detailTime = $r('app.string.justNow');
    item.timeMillisecond = new Date().getTime();
    DateUtil.convertTimeStampToDateWeek(item, false);
    DateUtil.fullDate(item);
    item.content = this.getSendText(this.textValue, true);
    item.msgType = this.mmsEditList.length != 0 ? this.mmsEditList[0].type : common.MSG_ITEM_TYPE.TEXT;
    item.smsType = this.smsType;
    item.isFullScreenImg = false;
    item.msgUriPath = this.mmsEditList.length != 0 ? this.mmsEditList[0].uriPath : common.STR.EMPTY_STR;
    let time = (this.mmsEditList.length != 0 && (this.mmsEditList[0].type == 3 || this.mmsEditList[0].type == 5)) ?
    this.mmsEditList[0].time : common.STR.SUCCESS;
    item.audioTime = time;
    item.isCbChecked = false;
    item.isReceive = false;
    item.sendStatus = 1;
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
    this.mmsList.push(item);
    hiTraceMeter.finishTrace(TraceConstant.TRACE_SEND_MSG_REFRESH, TraceConstant.TRACE_SEND_MSG_REFRESH_ID);
  }


  public getSendText(str: string, onlyShow: boolean): string {
    let content: string = str;
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
    this.resetAttachAreaPicture();
    this.mAttachAreaCtrl.resetMms();
    this.canSendMessage = false;
    setTimeout(() => {
      AppStorage.setOrCreate('comeFromContact', false);
      AppStorage.setOrCreate('comeFromServiceaccess', false);
    }, 350);
  }

  resetDraftContactsParam() {
    if (!this.draftModel?.isHasGetContacts) {
      this.draftModel.initialSelectContacts = [];
      this.draftModel.hasGetContactsThreadID = this.threadId ?? 0;
      this.draftModel.isHasGetContacts = true;
    }
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
  }

  newSend2(callback: Function) {
    hiTraceMeter.startTrace(TraceConstant.TRACE_NEW_SEND_CHECK,TraceConstant.TRACE_NEW_SEND_CHECK_ID);
    // Check whether the entered content has a value.
    if (this.receiveContactValue != common.STR.EMPTY_STR) {
      if (!TelephoneUtil.isPhoneNumber(this.receiveContactValue)) {
        // Invalid Recipient
        this.showToast($r('app.string.invalid_receive', this.receiveContactValue))
        HiLog.w(TAG, 'newSend, PhoneNumber is invalidate. receiveContactValue.length is ' +
        this.receiveContactValue.length);
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
      let selectContact: selectContactType = {
        telephone: this.receiveContactValue,
        telephoneFormat: this.receiveContactValue,
        contactName: common.STR.EMPTY_STR,
        rawContactId: '',
        contactId: ''
      }
      let selectContacts: selectContactType[] = [];
      selectContacts.push(selectContact);
      this.initNewSelectContacts(selectContacts);
    } else {
      HiLog.w(TAG, 'newSend, the contact condition is not met.')
      hiTraceMeter.finishTrace(TraceConstant.TRACE_NEW_SEND_CHECK,TraceConstant.TRACE_NEW_SEND_CHECK_ID);
      return;
    }

    this.isNewMsg = false;
    callback();

    hiTraceMeter.finishTrace(TraceConstant.TRACE_NEW_SEND_CHECK,TraceConstant.TRACE_NEW_SEND_CHECK_ID);
  }

  queryOldMessageList(telephone: string, callback?: Function) {
    HiLog.i(TAG, 'queryOldMessageList, start');
    if (!telephone) {
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
          ConversationListService.getInstance().deleteSessionByCondition(condition, () => {}, getContext(this));
        }
        this.isDraft = res.response.hasDraft;
        this.threadId = res.response.id;
        this.initCurrentQueryTimeID();
        this.queryMessageDetail(
          getContext(this), {
          isDraft:this.isDraft,
          currentPage:1,
          threadId:this.threadId,
          contactsNum:this.contactsNum,
          queryTimeID:this.currentQueryTimeID,
          startIndex: 0
        },() => {
          if (callback) {
            callback();
          }
        });
      } else {
        if (callback) {
          callback();
        }
      }
    }, getContext(this), true /* isFuzzyMatch */);
  }

  public publishData(isShow: boolean, currentThreadId: number): void {
    SharedPreferencesUtils.saveToPreferences('notificationIsShow', isShow);
    SharedPreferencesUtils.saveToPreferences('currentThreadId', currentThreadId);
  }

  async deleteDraftDataByThread() {
    HiLog.i(TAG, 'deleteDraftDataByThread: threadId is:' + this.threadId);
    let threadIds: number[] = [this.threadId];
    let actionData: Record<string, number | number[]> = {
      'threadIds': threadIds,
      'msgState': commonData.int.SEND_DRAFT,
    };
    ConversationService.getInstance().deleteSmsInfoByCondition(getContext(this), actionData, () => {});
  }

  send() {
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_SEND, TraceConstant.TRACE_CONVERSATION_SEND_ID);
    HiLog.i(TAG, 'send, start');
    this.isChangeInputPlaceholder = true;
    sendMmsParams.MMS_NUM = this.mAttachAreaCtrl.mmDisplaySource.length;
    let inRepairMode = SharedPreferencesUtils.getFromPreferences('inRepairMode', false);
    if (inRepairMode) {
      HiLog.iw(TAG, `inRepairMode ${inRepairMode}`);
      this.isChangeInputPlaceholder = true;
      return;
    }
    // The Send button is dimmed and messages cannot be sent.
    if (this.isAirPlaneMode) {
      HiLog.w(TAG, `sendOfEnhancedInfo, canSendMessage=${this.canSendMessage}, isAirPlaneMode=${this.isAirPlaneMode}`);
      this.showToast($r('app.string.air_plane_mode_message'));
      this.isChangeInputPlaceholder = true;
      return;
    }
    if (!this.canSendMessage && !this.isAirPlaneMode
      && !(DeviceUtil.isSubDeviceWithConnected(getContext(this)) && !this.isAirPlaneMode)) {
      HiLog.w(TAG, 'sendOfEnhancedInfo, canSendMessage=false');
      this.isChangeInputPlaceholder = true;
      return;
    }
    hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_SEND, TraceConstant.TRACE_CONVERSATION_SEND_ID);
    this.jumpToConversationPage(true,false,false)
  }

  async sendAudio() {
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_SEND, TraceConstant.TRACE_CONVERSATION_SEND_ID);
    HiLog.i(TAG, 'sendAudio, start');
    let inRepairMode = SharedPreferencesUtils.getFromPreferences('inRepairMode', false);
    if (inRepairMode) {
      HiLog.i(TAG, 'inRepairMode' + JSON.stringify(inRepairMode));
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
    this.jumpToConversationPage(false,true,true);
    this.vCardJumpBack = false;
  }

  async initAudioItem(context: Context): Promise<boolean> {
    HiLog.i(TAG, 'initAudioItem, start');
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_INIT_MMS,
      TraceConstant.TRACE_CONVERSATION_INIT_MMS_ID);
    let item: mmsListType = new mmsListType();
    item.date = common.STR.EMPTY_STR;
    item.detailTime = $r('app.string.justNow');
    item.timeMillisecond = new Date().getTime();
    DateUtil.convertTimeStampToDateWeek(item, false);
    DateUtil.fullDate(item);
    item.content = '';
    item.isFullScreenImg = false;
    item.isCbChecked = false;
    item.isReceive = false;
    item.sendStatus = 1;
    item.subId = this.slotId;
    item.isMsm = true;
    item.mmsSource = await this.getSmiledRcsSource(context);
    if (item.mmsSource.length < 2) {
      return false;
    }
    item.contentType = MmsUtil.getRcsContentType(item.mmsSource);
    let rcsDisplaySource = MMAttachmentAreaController.getInstance().rcsDisplaySource;
    item.rcsType = rcsDisplaySource && rcsDisplaySource.length > 0 ?
    rcsDisplaySource[rcsDisplaySource.length - 1].type :
    commonData.ENHANCED_INFO_ITEM_TYPE.FILE;

    this.setDateShow(item, this.mmsList, -1);
    this.mmsList.push(item);
    hiTraceMeter.finishTrace(TraceConstant.TRACE_SEND_MSG_REFRESH, TraceConstant.TRACE_SEND_MSG_REFRESH_ID);
    if (item.contentType === commonData.MMS_CONTENT_TYPE.VCARD ||
      item.contentType === commonData.MMS_CONTENT_TYPE.FILE) {
    }
    return true;
  }

  sendOfEnhancedInfo() {
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_SEND, TraceConstant.TRACE_CONVERSATION_SEND_ID);
    HiLog.i(TAG, 'sendOfEnhancedInfo, start');
    if (this.mAttachAreaCtrl.mmDisplaySource.length >
    commonData.int.MMS_ATTACHMENT_UPPER_LIMIT_ENHANCED_INFO_MODE) {
      this.showToast($r('app.string.attachment_upper_limit',
        commonData.int.MMS_ATTACHMENT_UPPER_LIMIT_ENHANCED_INFO_MODE,
        commonData.int.MMS_ATTACHMENT_UPPER_LIMIT_ENHANCED_INFO_MODE));
      this.isChangeInputPlaceholder = true;
      return;
    }
    let inRepairMode = SharedPreferencesUtils.getFromPreferences('inRepairMode', false);
    if (inRepairMode) {
      HiLog.w(TAG, 'inRepairMode' + JSON.stringify(inRepairMode));
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
      HiLog.w(TAG, 'send, canSendMessage=false');
      this.isChangeInputPlaceholder = true;
      return;
    }
    this.jumpToConversationPage(true,false,true)
  }

  /**
   * 在短彩信模式与增强信息模式切换过程中，设置附件待发区时，图片、视频、vCard和位置消息会被保留，其他消息类型将被清除。
   */
  public async resetValuesSwitchBetweenMmsAndRcs(lastIsRcs: boolean) {
    HiLog.i(TAG, 'resetValuesSwitchBetweenMmsAndRcs');
    let isSendPicture = false;
    isSendPicture = await this.handleMmDisplaySourceOnSwitchBetweenMmsAndRcs(lastIsRcs, isSendPicture);
    this.mAttachAreaCtrl.refreshDisplay();
    this.receiveContactValue = common.STR.EMPTY_STR;
    const tempBol = AppStorage.get<boolean>('isConversationNeedChangeOfRcs');
    AppStorage.setOrCreate('isConversationNeedChangeOfRcs', !tempBol);
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



  private resetValues() {
    hiTraceMeter.finishTrace(TraceConstant.TRACE_SEND_MSG_CLEAN_TEXT, TraceConstant.TRACE_SEND_MSG_CLEAN_TEXT_ID);
    this.canSendMessage = false;
    this.clearMsm();
    this.resetMmsSource();
    this.receiveContactValue = common.STR.EMPTY_STR;
  }

  public resetValuesOfSwitchingCard() {
    HiLog.i(TAG, 'resetValuesOfSwitchingCards start');
    this.resetValues();
    this.canSendMessage = true;
    AppStorage.setOrCreate('isConversationNeedChange', true);
  }


  private async getMaxGroupIdInMmsInfoTable() {
    let conversationModel = new ConversationModel();
    let maxGroupId: null | number = null;
    let mmsContext: Context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
    if (mmsContext) {
      maxGroupId = await conversationModel.queryMaxGroupIdInMmsInfoTable(mmsContext);
    }
    return maxGroupId;
  }

  jumpToSmcConversationPage() {
    HiLog.i(TAG,'jumpToSmcConversationPage')
    this.pageInfos.removeByName('SmcConversation');
    this.pageInfos.replacePathByName('SmcConversation', [], false);
  }

  /**
   * 清除chatbotSmsNumber对应的会话的草稿
   *
   * @param chatbotSmsNumber 应用号的短信号码
   */
  private deleteChatbotSmsNumberDraft = (context: Context, chatbotSmsNumber: string) => {
    ConversationListService.getInstance().querySessionByTelephone(chatbotSmsNumber, (res: LooseObject) => {
      if (!res?.response || res.code !== common.int.SUCCESS) {
        HiLog.e(TAG, 'deleteChatbotSmsNumberDraft: querySessionByTelephone result error');
        return;
      }
      if (!res.response.id || res.response.id < 0) {
        HiLog.w(TAG, 'deleteChatbotSmsNumberDraft: threadId of this session is not normal');
        return;
      }
      if (!res.response.hasDraft) {
        HiLog.w(TAG, 'deleteChatbotSmsNumberDraft: this session does not have draft data');
        return;
      }
      let threadId: number = res.response.id;
      HiLog.iw(TAG, `deleteChatbotSmsNumberDraft: threadId is: ${threadId} messageCount: ${res.response.messageCount}`);
      const threadIds = [threadId];
      if (res.response.messageCount > 0) {
        this.updateSessionByLastMessage(threadId, context, true, res.response.messageCount);
      } else if (res.response.messageCount === 0) { // 会话除了草稿没有其他消息，删除会话
        ConversationListService.getInstance().deleteSessionByCondition({
          'threadIds': threadIds,
        }, () => { }, context);
      }
      // 在sms_mms_info里清除草稿
      ConversationService.getInstance().deleteSmsInfoByCondition(context, {
        'threadIds': threadIds,
        'msgState': commonData.int.SEND_DRAFT
      }, null);
    }, context);
  }

  /**
   * 将threadId对应的会话数据更新成会话当前最后一条非草稿消息的数据
   *
   * @param threadId
   * @param context
   * @param isClearDraft 是否清除threadId对应的会话的草稿属性
   * @param messageCount 会话的消息数量
   */
  private updateSessionByLastMessage(threadId: number, context: Context, isClearDraft: boolean, messageCount: number) {
    let queryActionData: IQueryMessageDetailAll = {
      actionDataName: Constant.ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL,
      threadId: threadId,
      page: 1,
      contactsNum: 1
    };
    //按消息的时间戳降序查询threadId对应的会话第一页的数据 (一般一页最多20条消息), 第一页数据内部按消息时间戳升序
    ConversationService.getInstance().queryMessageDetailAll(context, queryActionData, (result: LooseObject) => {
      if (!result?.response || result.code !== common.int.SUCCESS || result.response.length === 0) {
        HiLog.e(TAG, 'updateSessionByLastMessage: queryMessageDetailAll result error or empty');
        return;
      }

      let mmsList = (result.response as mmsListType[]).filter(item => (item.sendStatus !== common.int.SEND_DRAFT));

      let actionData: Record<string, number | mmsListType[]> = {
        'mmsList': mmsList,
        'threadId': threadId
      };
      ConversationListService.getInstance().updateLastItemContent(actionData, () => { }, context, isClearDraft,
        messageCount);
    }, 0);
  }

  async jumpToConversationPage(isNeedSend: boolean, isNeedsendAudio: boolean, isRCS: boolean) {
    GlobalContext.getContext().setObject('isFromNewCreatMessage', true)
    HiLog.i(TAG, 'jumpToConversationPage')
    this.isSend = true; //用于草稿逻辑
    let selectContacts = this.getSelectContacts().slice(0);
    this.newSend();
    let context = getContext(this);
    let actionData: LooseObject = {};
    actionData.telephones = [this.strContactsNumber];
    ContactsService.getInstance().queryContactDataByCondition(actionData, (res: LooseObject) => {
      if (res.code == common.int.FAILURE) {
        HiLog.iw(TAG, 'new message send query contact id failed');
        return;
      }
      HiLog.iw(TAG, 'new message send query contact id success');
      this.contactId = res.abilityResult[0]?.contactId ? res.abilityResult[0].contactId : '';
      ConversationListService.getInstance().querySessionByTelephone(this.strContactsNumber, (res: LooseObject) => {
        HiLog.iw(TAG, 'querySessionByTelephone res.response.id: ' + res.response?.id);
        if (res.code == common.int.SUCCESS && res.response.id > 0) {
          this.threadId = res.response.id;
        } else {
          this.threadId = 0;
        }
        let params: LooseObject = {
          isNewMsg: true,
          isConversationNewMsg: true,
          strContactsNumber: this.strContactsNumber,
          threadId: this.threadId,
          slotId: this.slotId,
          receiveContactValue: this.receiveContactValue,
          selectContacts: selectContacts,
          inputText: this.textValue,
          isNeedSend: isNeedSend,
          isNeedsendAudio: isNeedsendAudio,
          isRCS: isRCS,
          isMsm: this.isEditMms,
          mmsSource: this.mAttachAreaCtrl.mmDisplaySource.slice(0),
          vCardJumpBack: this.vCardJumpBack,
          rcsDisplaySource: this.mAttachAreaCtrl.rcsDisplaySource.slice(0),
          isTextAsMms: this.isTextAsMms,
          contactId: this.contactId,
          strContactsName: this.strContactsName,
          hasYellowPageIcon: this.hasYellowPageIcon,
          yellowPageId: this.yellowPageId
        }
        this.pageInfos.replacePathByName('Conversation', params, false);
      }, context);
    }, context);
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

  newSend() {
    hiTraceMeter.startTrace(TraceConstant.TRACE_NEW_SEND_CHECK, TraceConstant.TRACE_NEW_SEND_CHECK_ID);
    // Check whether the entered content has a value.
    if (this.receiveContactValue != common.STR.EMPTY_STR) {
      if (!TelephoneUtil.isPhoneNumber(this.receiveContactValue)) {
        // Invalid Recipient
        this.showToast($r('app.string.invalid_receive', this.receiveContactValue))
        HiLog.w(TAG, 'newSend, PhoneNumber is invalidate');
        hiTraceMeter.finishTrace(TraceConstant.TRACE_NEW_SEND_CHECK, TraceConstant.TRACE_NEW_SEND_CHECK_ID);
        return;
      }
    }
    if (this.getSelectContactsLength() > 0 && this.receiveContactValue != common.STR.EMPTY_STR) {
      let selectContact: selectContactType = {
        telephone: this.receiveContactValue,
        telephoneFormat: this.receiveContactValue,
        contactName: common.STR.EMPTY_STR,
        rawContactId: ''
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
      hiTraceMeter.finishTrace(TraceConstant.TRACE_NEW_SEND_CHECK, TraceConstant.TRACE_NEW_SEND_CHECK_ID);
      return;
    }
    hiTraceMeter.finishTrace(TraceConstant.TRACE_NEW_SEND_CHECK, TraceConstant.TRACE_NEW_SEND_CHECK_ID);
  }

  initNewSelectContacts(selectContacts: Array<selectContactType>) {
    HiLog.i(TAG, 'initNewSelectContacts, start');
    let contactsNumber = common.STR.EMPTY_STR;
    let contactsName = common.STR.EMPTY_STR;
    let contactsId = common.STR.EMPTY_STR;
    let contactsNumberFormat = common.STR.EMPTY_STR;
    let rawContactId: Array<string> = [];
    let contacts = TelephoneUtil.dealSelectContactsSort(selectContacts);
    let length = 0;
    if (selectContacts.length === 1 && selectContacts[0].contactName === commonData.STR.EMPTY_STR) {
      length = 0;
    } else {
      length = contacts.length;
    }
    for (let index = 0; index < contacts.length; ++index) {
      let item = contacts[index];
      contactsNumber = contactsNumber + item.telephone + common.STR.COMMA;
      contactsId = contactsId + item.rawContactId + common.STR.COMMA;
      contactsNumberFormat = contactsNumberFormat + item.telephoneFormat + common.STR.COMMA;
      rawContactId.push(item.rawContactId);
      if (item.contactName != common.STR.EMPTY_STR) {
        contactsName += (item.contactName + common.STR.COMMA + common.STR.WHITE_SPACE);
      } else {
        this.isNewSend = true;
        let formatNum = TelephoneUtil.formatDisplayPhoneNum(item.telephoneFormat);
        contactsName += formatNum + common.STR.COMMA + common.STR.WHITE_SPACE;
      }
    }
    this.strContactsNumber = contactsNumber.substring(0, contactsNumber.length - 1);
    if (contacts.length === 1) {
      this.strContactsName = contacts[0].contactName;
    } else {
      this.strContactsName = contactsName.substring(0, contactsName.length - 2);
    }
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
        contactId: item.contactId ?? '',
        contactPhone: item.telephone,
        contactName: item.contactName
      };
      this.sessionContactsInfo.push(contactInfo);
    })
  }

  setRcsMsgType(actionData: ActionDataType, item: mmsListType) {
    if (MmsUtil.isAudio(item.mmsSource[1].type) ||
      item.mmsSource[1].type === common.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE) {
      item.msgType = common.ENHANCED_INFO_ITEM_TYPE.AUDIO;
      actionData.content = item.mmsSource[1].path;
    } else if (MmsUtil.isVcard(item.mmsSource[1].type)) {
      item.msgType = 5;
      let contact = item.mmsSource[1]?.contacts;
      let tempObj: SessionContentTypeOfRcs = {
        isSendMessage: 1,
        contactNum: contact?.length || 0,
        contactName: '',
      }
      actionData.content = JSON.stringify(tempObj);
    } else if (MmsUtil.isFile(item.mmsSource[1].type)) {
      item.msgType = common.ENHANCED_INFO_ITEM_TYPE.FILE;
      actionData.content = item.mmsSource[1].copyPath ? item.mmsSource[1].copyPath : item.mmsSource[1].path;
    } else if (item.rcsType === common.ENHANCED_INFO_ITEM_TYPE.IMAGE) {
      actionData.content = item.mmsSource[1].path || '';
      item.totalSize = Number(item.mmsSource[1].size) || 0;
    } else if (MmsUtil.isRcsMap(item.mmsSource[1].type)) {
      item.msgType = common.ENHANCED_INFO_ITEM_TYPE.MAP;
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
    if (this.receiveContactValue == '' && this.getSelectContactsLength() == 0) {
      this.canSendMessage = false;
      return;
    }
    this.canSendMessage = MmsPreferences.getInstance().haveSimCardReady() && !this.isAirPlaneMode;
    this.setCanSendMsgStatus();
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
    emitter.emit(innerEvent, eventData);
  }


  // Contact data returned on the new page
  setReceiveContactValue(receiverData: BaseItemType, threadId?: number) {
    let selectContacts = receiverData.selectContacts;
    let receiveContactValue = selectContacts.length > 0 ? common.STR.EMPTY_STR : receiverData.contactValue;
    let hasBlur: boolean = receiverData.hasBlur;
    this.setCanSendMessage(selectContacts, receiveContactValue)
    let routerParams: mmsListType = this.pageInfos.getParamByIndex(this.pageInfos.size() - 1) as mmsListType;
    if (receiveContactValue != this.strContactsName && routerParams?.isDraft == null) {
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
    if (selectContacts.length > 0) {
      for (let item of selectContacts) {
        this.dealJudgeTelephone(item);
        this.setSelectContacts(selectContacts);
      }
    } else {
      AppStorage.setOrCreate('contactsCount', 0);
      this.clearSelectContacts();
    }
    if (!this.draftModel?.isHasGetContacts ) {
      this.draftModel.initialSelectContacts = [...selectContacts]
      this.draftModel.hasGetContactsThreadID = threadId ?? 0
      this.draftModel.isHasGetContacts = true
    }
  }

  private dealJudgeTelephone(item: itemType) {
    if (!TelephoneUtil.isPhoneNumber(item.telephone)) {
      item.telephone = this.replaceCode(item.telephone);
      item.telephoneFormat = this.replaceCode(item.telephoneFormat);
      if (item.contactName != common.STR.EMPTY_STR) {
        item.contactName = common.STR.EMPTY_STR;
      }
    } else {
      this.dealJudgeYellowPageExist(item);
    }
  }

  private async dealJudgeYellowPageExist(item: itemType) {
    let res = await YellowPageService.getInstance()
      .judgeYellowPageByTelephone(item.telephone, this.context);
    if (res.yellowPageId) {
      this.yellowPageId = res.yellowPageId;
    }
    if (res.photo) {
      this.hasYellowPageIcon = res.photo;
    }
    if (StringUtil.isEmpty(item.contactName)) {
      YellowPageService.getInstance()
        .judgeNewPageHasYellowPageExist(item, this.context).then((res: LooseObject) => {
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


  async initRcsSource(isEnd: boolean, index: number) {
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
    this.copySource.push(copyItem);
    if (length - 1 == index) {
      isEnd = true;
    }
    if (!isEnd) {
      await this.initRcsSource(isEnd, ++index);
    }
  }

  async getSmiledRcsSource(context: Context) {
    this.copySource = [];

    await this.initRcsSource(false, 0);
    let source: Mms[] = [];
    this.copySource.forEach((mms) => {
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
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_UPDATE_MMS_SESSION,
      TraceConstant.TRACE_CONVERSATION_UPDATE_MMS_SESSION_ID);
    let sessionActionData: Record<string, number> = {
      'threadId': item.threadId
    }
    let sessionValueBucket: ValuesBucket = {
      'sending_status': item.sendStatus
    };

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
  }

  dealMmsMessageResult(actionData: ActionDataType, sendStatus: number) {
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

  async initMmsItem(context: Context) {
    HiLog.i(TAG, 'initMmsItem, start')
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_INIT_MMS,
      TraceConstant.TRACE_CONVERSATION_INIT_MMS_ID);
    let item: mmsListType = new mmsListType();
    item.date = common.STR.EMPTY_STR;
    item.detailTime = $r('app.string.justNow');
    item.timeMillisecond = new Date().getTime();
    DateUtil.convertTimeStampToDateWeek(item, false);
    DateUtil.fullDate(item);
    item.content = this.getSendText(this.textValue, true);
    item.isFullScreenImg = false;
    item.isCbChecked = false;
    item.isReceive = false;
    item.sendStatus = 1;
    item.subId = this.slotId;
    item.isMsm = this.isEditMms;
    item.mmsSource = await this.getMmsDataSource(context);
    item.contentType = MmsUtil.getMmsContentType(item.mmsSource);
    this.setDateShow(item, this.mmsList, -1);
    sendMmsParams.SEND_STATE = -1;
    this.mmsList.push(item);
    hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_INIT_MMS,
      TraceConstant.TRACE_CONVERSATION_INIT_MMS_ID);
  }

  resetAttachAreaPicture() {
    this.pictureCtrl.resetPictureStatus();
  }

  async getMmsDataSource(context: Context): Promise<Array<Mms>> {
    if (this.mAttachAreaCtrl.mmDisplaySource.length === 0 && !this.isTextAsMms) {
      return [];
    }
    let source: Array<Mms> = [];
    source = this.mAttachAreaCtrl.copySource.slice(0);
    if (this.textValue !== '') {
      let textSource = this.getTextSource(context);
      source.push(textSource);
    }
    let smilSource = MmsUtil.setSmilSource(context, this.textValue, source);
    source.unshift(smilSource);
    return source;
  }

  getTextSource(context: Context) {
    HiLog.i(TAG, 'getTextSource');
    let textSource: Mms = {
      duration: '',
      type: common.MM_ATTACHMENT_TYPE.TEXT,
      path: '',
      name: ''
    }
    let textObj: Record<string, string> = FileUtil.writeTextToSandBox(context, this.textValue, false);
    textSource.path = textObj.path;
    textSource.name = textObj.name;
    return textSource;
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

  /**
   * @param context
   * @param mmsSource
   * @param isCallOnInitRequestMessageList 是否在页面初始化请求数据的时候调用
   */
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
          let item: Mms = await this.setMmsDataSourcePushListItem(ele, index, isCallOnInitRequestMessageList);
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
        pushList.forEach(ele => {
          animateTo({ curve: curves.interpolatingSpring(0, 1, 228, 30) }, () => {
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

  /**
   * @param item
   * @param index
   * @param isCallOnInitRequestMessageList 是否在页面初始化请求数据的时候调用
   */
  async setMmsDataSourcePushListItem(item: Mms, index: number, isCallOnInitRequestMessageList?: boolean) {
    HiLog.i(TAG, `setMmsDataSourcePushListItem: isCallOnInitRequestMessageList: ${
    isCallOnInitRequestMessageList}, isRcsMms: ${this.isRcsMms}`);
    if (item.type == commonData.MM_ATTACHMENT_TYPE.IMAGE) {
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
    } else if (item.type == commonData.MM_ATTACHMENT_TYPE.VIDEO) {
      await ImageUtil.getFetchFrameByTime(item.path, (pixMap: PixelMap) => {
        item.pixelMap = pixMap;
        item.index = index;
        return item;
      })
    } else if (item.type == commonData.MM_ATTACHMENT_TYPE.AUDIO) {
      item.isOnAudio = false;
      item.index = index;
      return item;
    } else if (item.type == commonData.MM_ATTACHMENT_TYPE.TEXT) {
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
      if (!item.address && isObjectJSONString(item.text)) {
        item.address = JSON.parse(item.text as string);
      }
      //当会话页面初始化请求消息列表数据，当前是增强模式，且为彩信位置附件，将其转换成增强信息位置附件
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

  private publishSatelliteEvent() {
    HiLog.i(TAG, 'publishSatelliteEvent, start');
    try {
      commonEvent.publish('event.custom.satellite.ACTION_SATELLITE_CONNECT', {
        subscriberPermissions: ['ohos.permission.SET_TELEPHONY_STATE'],
        isOrdered: false,
      }, () => {
      });
    } catch (err) {
      HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
    }
  }

  private formatLatLng(location: string): string {
    if (location == null) {
      return '';
    }
    let symbolIndex: number = location.indexOf('.');
    if (symbolIndex > 0 && location.length > symbolIndex + 7) {
      return location.substring(0, symbolIndex + 7);
    }
    return location;
  }

  public getConvertDegreeString(digitalDegree: number): string {
    let degree: number = Math.trunc(digitalDegree);
    let tmp: number = (digitalDegree - degree) * DOUBLE;
    let minute: number = Math.trunc(tmp);
    let second: number = Math.trunc((tmp - minute) * DOUBLE);
    return Math.abs(degree) + DEGREE + Math.abs(minute) + MINUTE + Math.abs(second) + SECOND;
  }

  getLocationInfo(convertLongitude: number, convertLatitude: number): string {
    //刷新经纬度信息到界面
    if (convertLatitude >= 0) {
      if (convertLongitude >= 0) {
        return this.context.resourceManager.getStringSync($r('app.string.location_north_east'),
          this.getConvertDegreeString(convertLatitude),
          this.getConvertDegreeString(convertLongitude));
      } else {
        return this.context.resourceManager.getStringSync($r('app.string.location_north_west'),
          this.getConvertDegreeString(convertLatitude),
          this.getConvertDegreeString(convertLongitude));
      }
    } else {
      if (convertLongitude >= 0) {
        return this.context.resourceManager.getStringSync($r('app.string.location_south_east'),
          this.getConvertDegreeString(convertLatitude),
          this.getConvertDegreeString(convertLongitude));
      } else {
        return this.context.resourceManager.getStringSync($r('app.string.location_south_west'),
          this.getConvertDegreeString(convertLatitude),
          this.getConvertDegreeString(convertLongitude));
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

  public sendMessageIsHasMap(): boolean {
    let source = this.mAttachAreaCtrl.mmDisplaySource;
    if (source.length > 0) {
      for (let i = 0; i < source.length; i++) {
        HiLog.i(TAG,'sendMessageIsHasMap source type: ' + source[i]?.type);
        if (source[i]?.type === commonData.ENHANCED_INFO_ITEM_TYPE.MAP) {
          return true;
        }
      }
    }
    return false;
  }
}