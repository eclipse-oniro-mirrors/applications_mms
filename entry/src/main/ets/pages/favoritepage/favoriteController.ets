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
import ConversationController, { mmsListType, updateFavorite } from '../conversation/conversationController';
import LooseObject from '../../data/LooseObject';
import conversationService from  '.././../service/ConversationService'
import ConversationListDataSource from '../../model/ConversationListDataSource';
import ConListController from '../conversationlist/conversationListController';
import ConversationListController, { messageType } from '../conversationlist/conversationListController';
import common, { SmsRcsInfo } from '../../data/commonData';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import ConversationService from '.././../service/ConversationService';
import lazy { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import hiTraceMeter from '@ohos.hiTraceMeter';
import TraceConstant from '../../data/TraceConstant';
import HiLog from '../../utils/HiLog';
import ConversationDataSource from '../../model/ConversationDataSource';
import { commonPasteboard } from '../../data/Pasteboard';
import lazy utd from '@ohos.data.uniformTypeDescriptor';
import myCommon from '@ohos.app.ability.common';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import fileUri from '@ohos.file.fileuri';
import MmsUtil, {
  findMapSourceOfMmsMapMessage,
 // getMmsMapLinkShareData,
  parseAddressInfo } from '../../utils/MmsUtil';
import PanGestureUtil from '../../utils/PanGestureUtil';
import { AddressInfo, Mms, PageJumpType, ShareExtraData } from '../../utils/TypesUtils';
import lazy { DateUtil } from '../../utils/DateUtil';
import lazy fs from '@ohos.file.fs';
import prompt from '@ohos.promptAction';
import { AsyncCallback, BusinessError } from '@ohos.base';
import ConversationListService from '../../service/ConversationListService';
import DataShareHelper from '../../model/repository/DataShareHelper';
import ConversationModel from '../../model/ConversationModel';
import StringUtil from '../../utils/StringUtil';
import lazy { isSameTel } from '../../utils/TelephoneUtilEnhancde';
import { ChatbotUtils } from '../../chatbot/utils/ChatbotUtils';
import DeviceUtil from '../../utils/DeviceUtil';
import Constant from '../../data/Constant';
import MmsPartModel from '../../model/MmsPartModel';
import commonData from '../../data/commonData';

const TAG = 'FavoriteController';
const SMS_TABLE = 'SMSInfoTable';
const RCS_TABLE = 'RCSInfoTable';
export interface mmsType {
  msgId:number;
  rcsId: number;
  partIndex: number,
  partSize: string,
  type: number,
  ct: string,
  locationPath:string;
  content:string;
  recordingTime:string;
}

export interface messageInfoS {
  msgId: string;
  slotId: string;
  receiverNumber: string;
  senderNumber: string;
  startTime: string;
  endTime: string;
  msgType: string;
  smsType: string;
  msgTitle: string;
  msgContent: string;
  msgState: string;
  msgCode: string
  isRead: string
  isCollect: string
  sessionType: string
  sessionId: string
  groupId: string
  isSender: string
  isSendReport: string;
  isFvChecked: boolean;
}

export class GroupIdsInfos {
  public groupId: number | string = 0;
  public isRcs: number | string = 0;
  public msgId: number | string = ''
}

export default class FavoriteController {
  private static sInstance: FavoriteController | undefined = undefined;
  isFavorite:boolean = false;
  allMessage: Array<messageInfoS> =[]
  favoriteList: ConversationListDataSource = new ConversationListDataSource();
  mmsMessage:Array<Object> = []
  mFavoriteController: ConversationController = ConversationController.getInstance();
  conListCtrl: ConListController = this.mFavoriteController.conListCtrl;
  messageList: Array<messageType> = this.conListCtrl.messageList;
  public searchContent: string = '';
  // Select Status
  public isSelectStatus: boolean = false;
  // Information List
  public mmsList: Array<mmsListType> = [];
  public pageInfos: NavPathStack = new NavPathStack();
  public mmsListFromFavo: Array<messageType> = [];
  public conversationDataSource: ConversationDataSource = new ConversationDataSource();
  public conversationListDataSource: ConversationListDataSource = new ConversationListDataSource();
  // Deleted Count
  public selectDeleteMsgCount: number = 0;
  // Index of the selected information
  public mmsIndex: number = 0;
  // Text entered in the text box, which is also the content of the SMS message to be sent.
  public textValue: string = '';
  public mmsCount: number = 0;
  // Whether to support sending reports
  public hasReport: boolean = false;
  // Check whether all the options are selected.
  public isMessageCheckAll: boolean = false;
  public hasContent: boolean = false;
  public audioStatus: number = common.MMS_AUDIO_STATUS.NO_AUDIO;
  // Message deletion prompt
  public strMsgDeleteDialogTip?: Resource;
  // ID of the session list.
  public threadId: number = 0;
  // Dynamic change sign from bottom
  public distanceBottomFlag: boolean = false;
  // More Actions
  public isShowMoreOperation: boolean = false;
  // Send Toolbar Distance from Bottom Position
  public sendBarMarginBottom: number = 0;
  public isClickMore: boolean = true
  private hasAudio: boolean = false;
  private hasOther: boolean = false;
  public msgListForFav: messageType[] = [];
  public contactIdMap: Map<string, string> = new Map<string, string>();
  public richMediaCards: number = common.MMS_AUDIO_STATUS.NO_AUDIO;
  private mmsPartModel: MmsPartModel = new MmsPartModel();
  static getInstance() {
    if (!FavoriteController.sInstance) {
      FavoriteController.sInstance = new FavoriteController();
    }
    return FavoriteController.sInstance
  }

  public static release() {
    FavoriteController.sInstance = undefined;
  }

  static getTestInstance() {
    return new FavoriteController();
  }

  public sorting(a: LooseObject, b: LooseObject): number{
    return b.startTime - a.startTime;
  }

  async getFavoriteData(context: Context) {
    this.contactIdMap = await conversationService.getInstance().getContactId(context);
    let actionData : LooseObject = {};
    actionData.isCollect = 1;
    let mmsList : messageType[] = [];
    // 处理只查询收藏对应的session
    let sessionSet: Set<number> = new Set<number>();
    let sessionArray: number[] = [];
    conversationService.getInstance().queryAllInfoByFavorite(context, actionData, async (res:LooseObject)=>{
      if (res?.code == common.int.SUCCESS) {
        if (res?.abilityResult?.length !== 0) {
          this.isFavorite = true
          this.allMessage = res.abilityResult
          for (let i = 0; i < res.abilityResult.length; i++) {
            this.fillterPush(res, i, mmsList);
            if (ChatbotUtils.isChatbotNumber(res.abilityResult[i].senderNumber)) {
              res.abilityResult[i]['isChatbotMessage'] = true;
            }
            sessionSet.add(res.abilityResult[i].sessionId);
          }
          mmsList.sort(this.sorting)
          sessionArray = Array.from(sessionSet);
          this.getInfoMsgData(getContext(this), sessionArray);
        }
      }
      if (mmsList.length === 0) {
        this.isFavorite = false;
      }
      this.favoriteList.reload(mmsList, 'getFavoriteData');
      this.mmsListFromFavo = this.favoriteList.mmsList;
    })

    let actionData1:LooseObject = {};
    conversationService.getInstance().queryFavoriteResultAll(actionData1, (res: LooseObject) => {
      this.mmsMessage = res?.abilityResult
    }, context)
  }

  private fillterPush(res: LooseObject, i: number, mmsList: messageType[]) {
    let fIndex = this.favoriteList.mmsList.findIndex(item => item.msgId === res.abilityResult[i].msgId)
    if (fIndex >= 0) {
      res.abilityResult[i].isCbChecked = this.favoriteList.mmsList[fIndex].isCbChecked
    }
    res.abilityResult[i].rcsType = res.abilityResult[i].partType;
    if (res.abilityResult[i].smsType == common.sms_type.RCS) {
      res.abilityResult[i].hasMms = res.abilityResult[i].partType != 0;
      res.abilityResult[i].isMsm = res.abilityResult[i].partType != 0;
    }
    //判断，如果当前isSender为1，senderNumber为空，将receiverNumber赋值给senderNumber，解决演示版本数据库中数据错误问题
    if (res.abilityResult[i].isSender === commonData.int.SEND_MESSAGE_SENDING && StringUtil.isEmpty(res.abilityResult[i].senderNumber)) {
      res.abilityResult[i].senderNumber = res.abilityResult[i].receiverNumber;
    }
    //mms_Part表删除信息会导致isMsm是true但是mmsList和mmsSource为空的情况。从favorite_info表补充对应值
    if (res.abilityResult[i].isMsm && res.abilityResult[i]?.mmsList?.length == 0) {
      res.abilityResult[i].mmsList = [{
        'path': res.abilityResult[i].partLocationPath,
        'type': res.abilityResult[i].partType,
        'msgId': res.abilityResult[i].msgId,
        'groupId': res.abilityResult[i].groupId,
        'rcsId': res.abilityResult[i].rcsId
      }]
      res.abilityResult[i].mmsSource = [{
        'path': res.abilityResult[i].partLocationPath,
        'type': res.abilityResult[i].partType
      }]
    }
    if (res.abilityResult[i].msgContent || res.abilityResult[i].partLocationPath) {
      mmsList.push(res.abilityResult[i]);
    }
  }

  registerDataChangeObserver(callback: AsyncCallback<void>, context: Context) {
    HiLog.i(TAG, 'registerDataChangeObserver');
    let contactDataUri: string = common.STR.URI_ROW_CONTACTS + common.STR.CONTACT_DATA_URI;
    DataShareHelper.getInstance().initContactDB(context).then((dataAbilityHelper) => {
      if (dataAbilityHelper) {
        dataAbilityHelper.on('dataChange', contactDataUri, callback);
      }
    }).catch((error: BusinessError) => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
    });
  }

  unregisterDataChangeObserver(callback: AsyncCallback<void>, context: Context) {
    let contactDataUri: string = common.STR.URI_ROW_CONTACTS + common.STR.CONTACT_DATA_URI;
    DataShareHelper.getInstance().initContactDB(context).then((dataAbilityHelper) => {
      if (dataAbilityHelper) {
        dataAbilityHelper.off('dataChange', contactDataUri, callback);
      }
    }).catch((error: BusinessError) => {
      HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
    });
  }
 /**
  * 长按删除时，弹出框文字提示
  */
  clickLongPressDelete() {
    this.strMsgDeleteDialogTip = $r('app.string.msg_delete_dialog_con_tip1');
  }

  clickGroupDelete() {
    if (this.selectDeleteMsgCount == 0) {
      return;
    }
    if (this.selectDeleteMsgCount == 1) {
      this.strMsgDeleteDialogTip = $r('app.string.msg_delete_dialog_con_tip1');
    } else if (this.selectDeleteMsgCount == this.mmsListFromFavo.length) {
      this.strMsgDeleteDialogTip = $r('app.string.msg_delete_dialog_con_tip3');
    } else {
      this.strMsgDeleteDialogTip = $r('app.plural.msg_delete_dialog_con_tip2', this.selectDeleteMsgCount, this.selectDeleteMsgCount);
    }
  }

  public async getInfoMsgData(context: Context, sessionIds: Array<number>) {
    HiLog.i( TAG, 'getInfoMsgData  sessionIds.length: ' + sessionIds.length)
    let actionData: LooseObject = {
      'sessionIds': sessionIds
    };
    let data = await ConversationListService.getInstance().getSessionListResultNew(actionData,
      context)
    if (data && data.response) {
      this.msgListForFav = data.response;
    }
  }

  // Tap a contact's avatar to go to the contact details page.
  titleBarAvatar(context: Context, props:string) {
    let actionData: Record<string, string> = {
      'phoneNumber': props ,
      'pageFlag': common.contactPage.PAGE_FLAG_CONTACT_DETAILS
    };
    this.mFavoriteController.jumpToContact(context, actionData);
  }

  mmsScreening(id:number,num:number){
    let arr = this.mmsMessage.filter((value)=>{
      let val = value as mmsType
      return val.msgId == id && val.type == num})
    let res = arr[0] as  mmsType
    return  res
  }

  mmsRcsScreening(id: number, num: number) {
    let arr = this.mmsMessage.filter((value) => {
      let val = value as mmsType
      return val.rcsId == id && val.type == num
    })
    let res = arr[0] as mmsType
    return res
  }

  nameAndPicture(sendNum:string){
    let arr = this.msgListForFav.filter((value)=>{
      let nameAndPictureVal = value as messageType
      return nameAndPictureVal.name && !isSameTel(nameAndPictureVal.name, sendNum) &&
      isSameTel(nameAndPictureVal.telephone, sendNum)
    })
    let res = arr[0] as messageType
    return res
  }

  nameNoPicture(sendNum:string){
    let arr = this.msgListForFav.filter((value) => {
      let nameAndPictureVal = value as messageType
      return isSameTel(nameAndPictureVal.telephone, sendNum)
    })
    let res = arr[0] as messageType
    return res
  }

  showBubbleOrEmoji(content:string){
    return this.mFavoriteController.showBubbleOrEmoji(content,3)
  }

  cancelFavorites(context: Context) {
    for (let element of this.mmsListFromFavo) {
      if (element.isCbChecked == true) {
        let item: LooseObject = {
          'conversation': element
        }
        this.cancelFavorite(context, element)
      }
    }
  }

  cancelFavorite(context: Context, item: LooseObject) {
    HiLog.w(TAG, '[cancelFavorite] deleteFavorite start');
    let conversationModel = new ConversationModel();
    let mmsContext: Context =
      GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let valueBucket: ValuesBucket = {
        'is_collect': common.is_collect.NOT_FAVORITE,
      }
      let actionData: LooseObject = {
        'msgId': item.msgId,
      }
      ConversationService.getInstance().updateSmsMmsInfoByCondition(context, actionData, valueBucket, () => {
        conversationModel.deleteFavorite(item.msgId, async (res: LooseObject) => {
          updateFavorite(this.searchContent);
          this.getFavoriteData(context)
          if (item.isMsm) {
            // 处理mms_part表
            this.dealDeleteMmsPart(item.msgId, context, SMS_TABLE);
          }
        }, mmsContext)
      });
    HiLog.w(TAG, '[cancelFavorite] deleteFavorite end');
  }

  private async dealDeleteMmsPart(msgId: number, context: Context, table: string) {
    if (!context || ![SMS_TABLE, RCS_TABLE].includes(table) || !msgId || msgId <= 0) {
      HiLog.e(TAG, 'dealMmsPart param invalid');
      return;
    }
    let conversationModel = new ConversationModel();
    let msgIds: number[] = [msgId];
    HiLog.i(TAG, `dealMmsPart  msgIds:${msgIds?.toString()}`);
    let existMsgIds: number[] = [];
    // sms_info 与 rcs_info 分开处理
    if (table === SMS_TABLE) {
      existMsgIds = await conversationModel.querySmsMmsInfoByMsgIds(msgIds, context);
      HiLog.i(TAG, `dealMmsPart querySmsMmsInfoByMsgIds existMsgIds:${existMsgIds?.toString()}`);
    } else if (table === RCS_TABLE) {
      existMsgIds = await conversationModel.queryRCSInfoByMsgIds(msgIds, context);
      HiLog.i(TAG, `dealMmsPart queryRCSInfoByMsgIds existMsgIds.length:${existMsgIds?.toString()}`);
    } else {
      HiLog.e(TAG, 'dealMmsPart params table invalid');
      return;
    }
    let smsMsgIds: SmsRcsInfo[] = [];
    let smsMsgInfo: SmsRcsInfo;
    for (let element of msgIds) {
      smsMsgInfo = new SmsRcsInfo();
      smsMsgInfo.msgId = element;
      // 被收藏的原信息详情未被删除时不需要删除mms_part表信息,这里使用反向被收藏区分，原消息已删除的可删除part表。
      if (existMsgIds.includes(element)) {
        smsMsgInfo.isCollect = commonData.is_collect.FAVORITE;
      } else {
        smsMsgInfo.isCollect = commonData.is_collect.NOT_FAVORITE;
      }
      smsMsgIds.push(smsMsgInfo);
    }
    // sms_info 与 rcs_info 分开处理
    if (table === SMS_TABLE) {
      this.mmsPartModel.deleteByIds(smsMsgIds, [], context);
    } else if (table === RCS_TABLE) {
      this.mmsPartModel.deleteByIds([], smsMsgIds, context);
    } else {
      HiLog.e(TAG, 'dealMmsPart params table invalid');
      return;
    }
  }

  onBackPress() {
    if (this.isSelectStatus) {
      // Multi-choice status
      this.resetSelectData();
      this.resetMmsCount();
      this.cancelCheckedAll();
      this.conversationListDataSource.reload(this.messageList, 'onBackPress')
      return true;
    }
    if (!this.pageInfos) {
      HiLog.i(TAG, 'this.pageInfos is null');
      return false;
    }
    return false;
  }

  resetMmsCount() {
    this.mmsCount = 0;
  }

  public delConversionController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: this.mFavoriteController.strMsgDeleteDialogTip,
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {}
      },
      secondaryButton: {
        value: $r('app.string.delete'),
        action: () => {
          this.mFavoriteController.deleteDialogConfirm(getContext(this))
        },
        role: ButtonRole.ERROR
      }
    }),
    autoCancel: false,
  });

  deleteDialogConfirm(context: Context) {
    hiTraceMeter.startTrace(TraceConstant.TRACE_DEL_MSG, TraceConstant.TRACE_DEL_MSG_ID)
    let groupIds: number[] = [];
    let groupInfos: GroupIdsInfos[] = [];
    let sum = 1;
    ConversationListController.getInstance().resetLastIndexValue();
    this.selectStatusOnDeleteMsg(groupIds, groupInfos, sum);
    hiTraceMeter.finishTrace(TraceConstant.TRACE_DEL_MSG, TraceConstant.TRACE_DEL_MSG_ID)
    this.cancelCheckedAll();
    if (groupIds.length > 0) {
      this.deleteMessageByGroupIds(context, groupIds, groupInfos);
    }
    let tempRcsId: number = -1;
    this.favoriteList.reload(this.mmsListFromFavo, 'deleteDialogConfirm');
  }

  clickGroupCheckAll() {
    for (let element of this.mmsListFromFavo) {
      element.isCbChecked = !this.isMessageCheckAll;
    }
    this.favoriteList.refreshList(this.mmsListFromFavo);
    PanGestureUtil.addFirstSelect(0, true, true, this.mmsListFromFavo.length)
    if (this.isMessageCheckAll) {
      this.setMessageCheckAll(common.int.CHECKBOX_SELECT_NONE);
    } else {
      this.setMessageCheckAll(common.int.CHECKBOX_SELECT_ALL);
    }
    HiLog.i('clickGroupCheckAll', JSON.stringify(this.isMessageCheckAll))
  }

  selectStatusOnDeleteMsg(groupIds: number[], groupInfos: Array<GroupIdsInfos>, sum: number) {
    let mmsListCopy: messageType[] = [];
    if (this.isSelectStatus) {
      // Delete the selected item through the filter.
      for (let index = 0; index < this.mmsListFromFavo.length; index++) {
        let element = this.mmsListFromFavo[index];
        if (!element.isCbChecked) {
          mmsListCopy.push(element);
        } else {
          groupInfos.push({
            groupId: element.groupId, isRcs: '', msgId: element.id
          })
          groupIds.push(element.groupId);
          animateTo({
            duration: 200
          }, () => {
            this.favoriteList.deleteByIndex(index);
          })
          index--;
          sum++;
        }
      }
      // Set to non-multi-choice status
      this.resetSelectData();
      this.mmsListFromFavo = mmsListCopy;
      this.mmsIndex = 0;
    } else if ((this.mmsList[this.mmsIndex] != undefined)) {
      let item = this.mmsList[this.mmsIndex];
      for (let i = 0; i < this.mmsList.length; i++) {
        if (this.mmsIndex == i) {
          continue;
        } else {
          mmsListCopy.push(this.mmsListFromFavo[i]);
        }
      }
      this.mmsListFromFavo = mmsListCopy;
      groupIds.push(item.groupId);
      groupInfos.push({
        groupId: item.groupId, isRcs: item.isRcs, msgId: item.id
      })
      animateTo({
        duration: 200
      }, () => {
        this.favoriteList.deleteByIndex(this.mmsIndex);
        sum++;
      })
    }
  }

  // Number of selected multimedia messages and enhanced messages
  multiSelectMmsMsg(index: number) {
    if (this.mmsListFromFavo[index].isCbChecked) {
      if (this.mmsListFromFavo[index].hasMms) {
        this.mmsCount--;
      }
    } else {
      if (this.mmsListFromFavo[index].hasMms) {
        this.mmsCount++;
      }
    }
  }

  /**
   * 滑动多选设置全选与单选更多按钮内容
   */
  gesTureListCheckBox(selectDeleteMsgCount: number) {
    if (selectDeleteMsgCount === this.mmsListFromFavo.length) {
      this.isMessageCheckAll = true
      this.hasReport = false;
    } else if (this.isMessageCheckAll) {
      this.isMessageCheckAll = false
    }
    if (selectDeleteMsgCount == 1) {
      let item: messageType = new messageType;
      for (let i = 0; i < this.mmsListFromFavo.length; i++) {
        if (this.mmsListFromFavo[i].isCbChecked) {
          item = this.mmsListFromFavo[i];
          this.mmsIndex = i;
          break;
        }
      }
      if (item != null) {
        this.setGroupMoreMenu(item);
      }
    }
  }

  listCheckBoxChange(index: number, e: boolean) {
    // When API 7 is used, the isOn type is not boolean but is of the number type. If the isOn type is displayed,
    // an error may occur.
    let isCheck: string = e === true ? '1' : '0';
    let item: messageType = this.mmsListFromFavo[index];
    item.isCbChecked = isCheck == '1' ? true : false;
    this.hasReport = item.hasReport;
    this.favoriteList.selectData(index, item.isCbChecked)
    PanGestureUtil.addFirstSelect(index, item.isCbChecked, true)
    this.setMessageCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
    if (this.selectDeleteMsgCount == 1) {
      let item: messageType = new messageType;
        for (let i = 0; i < this.mmsListFromFavo.length; i++) {
        if (this.mmsListFromFavo[i].isCbChecked) {
          item = this.mmsListFromFavo[i];
          this.mmsIndex = i;
          break;
        }
      }
      if (item != null) {
        this.setGroupMoreMenu(item);
      }
    }
    if (this.isClickMore && e) {
      this.isClickMore = false
      this.favoriteList.reload(this.mmsListFromFavo, 'listCheckBoxChange');
    }
    this.judgeOnlyAudio();
  }

  setGroupMoreMenu(item: messageType) {
    if (!item.hasMms) {
      this.hasContent = true;
    } else {
      this.judgeOnlyAudio();
    }
  }

  judgeOnlyAudio() {
    this.audioStatus = common.MMS_AUDIO_STATUS.NO_AUDIO;
    this.richMediaCards = common.MMS_AUDIO_STATUS.NO_AUDIO;
    let selectedArr: messageType[] = [];
    this.mmsListFromFavo.forEach((item) => {
      if (item.isCbChecked) {
        selectedArr.push(item);
      }
    });
    this.hasAudio = false;
    this.hasOther = false;
    for (let i = 0; i < selectedArr.length; i++) {
      let item: messageType = selectedArr[i];
      if (!item.mmsSource || item.mmsSource.length === 0) {
        this.hasOther = true;
      } else {
        this.checkOnlyAudio(item)
      }
      if (this.hasOther && this.hasAudio) {
        this.audioStatus = common.MMS_AUDIO_STATUS.HAS_AUDIO;
      } else if (this.hasOther && !this.hasAudio) {
        this.audioStatus = common.MMS_AUDIO_STATUS.NO_AUDIO;
        if (item?.rcsType === common.ENHANCED_INFO_ITEM_TYPE.CHATBOT_CARD) {
          this.richMediaCards = common.MMS_AUDIO_STATUS.ONLY_AUDIO;
        }
      } else if (!this.hasOther) {
        this.audioStatus = common.MMS_AUDIO_STATUS.ONLY_AUDIO;
      }
    }
  }
  checkOnlyAudio(item: messageType) {
    for (let j = 0; j < item?.mmsSource?.length; j++) {
      let mms: Mms = item.mmsSource[j];
      if (mms.type === common.MM_ATTACHMENT_TYPE.AUDIO) {
        if (item.content !== '' && item.content != null) {
          this.hasOther = true;
        }
        this.hasAudio = true;
      } else if (mms.type !== common.MM_ATTACHMENT_TYPE.AUDIO &&
        mms.type !== common.MM_ATTACHMENT_TYPE.SMIL) {
        this.hasOther = true;
      }
    }
  }

  resetSelectData() {
    this.setSelectStatus(false);
    this.selectDeleteMsgCount = 0;
    this.favoriteList.selectList = []
    AppStorage.setOrCreate('selectLength', 0)
  }

  setSelectStatus(isSelect: boolean) {
    HiLog.i(TAG, 'setSelectStatus isSelect:' + isSelect);
    this.isSelectStatus = isSelect;
  }

  cancelCheckedAll() {
    for (let element of this.mmsListFromFavo) {
      element.isCbChecked = false;
    }
  }

  deleteMessageByGroupIds(context: Context, groupIds: number[], groupInfos?: Array<GroupIdsInfos>, isReSend?: boolean): void {
    let actionData: LooseObject = {};
    let groupIdMms: number[] = [];
    let groupIdRcs: number[] = [];
    let msgIdsRcs: string[] = [];
    if (groupInfos !== undefined) {
      for (let index = 0; index < groupInfos?.length; index++) {
        if (groupInfos[index].isRcs === common.MESSAGE_TYPE.RCS) {
          groupIdRcs.push(groupInfos[index].groupId as number)
          msgIdsRcs.push(groupInfos[index].msgId as string)
        } else {
          groupIdMms.push(groupInfos[index].groupId as number)
        }
      }
      if (groupIdMms.length == 1) {
        actionData.groupId = groupIdMms[0];
      } else {
        actionData.groupIds = groupIdMms;
      }
      if (groupIdRcs.length == 1) {
        actionData.groupIdRcs = groupIdRcs[0];
        actionData.msgIdsRcs = msgIdsRcs;
      } else {
        actionData.groupIdsRcs = groupIdRcs;
        actionData.msgIdsRcs = msgIdsRcs;
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
    // Invoke the database deletion method.
    ConversationService.getInstance().deleteSmsMmsInfoByCondition(context, actionData, () => {
    });
  }

  setMessageCheckAll(type: number) {
    if (!this.isSelectStatus) {
      return;
    }
    if (type == common.int.CHECKBOX_SELECT_ALL) {
      this.selectDeleteMsgCount = this.mmsListFromFavo.length;
      this.isMessageCheckAll = true;
      this.hasReport = false;
      this.mmsCount = 0;
      this.favoriteList.selectData(0, true, this.mmsListFromFavo.length)
      // Check whether all of them are locked.
      for (let element of this.mmsListFromFavo) {
        if (element.isCbChecked && element.hasMms) {
          this.mmsCount++;
        }
      }
    } else if (type == common.int.CHECKBOX_SELECT_NONE) {
      this.selectDeleteMsgCount = 0;
      this.isMessageCheckAll = false;
      this.hasReport = false;
      this.favoriteList.selectList = []
      AppStorage.setOrCreate('selectLength', 0)
    } else {
      // The default value is CHECKBOX_SELECT_UNKNOWN. Check whether there is any unselected item.
      this.checkBoxSelectUnknow();
    }
  }

  checkBoxSelectUnknow() {
    HiLog.i(TAG, 'checkBoxSelectUnknow, start');
    // The default value is CHECKBOX_SELECT_UNKNOWN. Check whether there is any unselected item.
    this.isMessageCheckAll = true;
    this.selectDeleteMsgCount = 0;
    this.mmsCount = 0;
    let countReport = 0;
    for (let element of this.mmsListFromFavo) {
      if (element.isCbChecked) {
        this.selectDeleteMsgCount++;
        if (element.hasMms) {
          this.mmsCount++;
        }
        this.setSelectStatus(true);
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

  getMmsCount() {
    let arr = this.mmsListFromFavo.filter(item => item.isCbChecked);
    let mms = arr.filter(item => (item.mmsPdu && item.mmsPdu !== ''))
    return mms.length > 0;
  }

  onInit(pageInfos: NavPathStack) {
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_INIT,
      TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_INIT_ID);
    this.pageInfos = pageInfos;
    this.initRouterData();
    hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_INIT,
      TraceConstant.TRACE_CONVERSATION_CONTROLLER_ON_INIT_ID);
  }

  initRouterData() {
    HiLog.i(TAG, 'initRouterData')
    let routerParams: LooseObject = this.pageInfos.getParamByIndex(this.pageInfos.size() - 1) as LooseObject;
    this.searchContent = StringUtil.isEmpty(routerParams.searchContent) ? '' : routerParams.searchContent;
  }

  /**
   * 收藏页面的复制功能
   * @param index
   */
  copyText() {
    if (this.favoriteList.selectList.length > 1) {
      this.copyMultipeText()
    } else {
      let content = this.mmsListFromFavo[this.mmsIndex]?.msgContent;
      const mapImageAttach = findMapSourceOfMmsMapMessage(Boolean(this.mmsListFromFavo[this.mmsIndex]?.isRcs),
        this.mmsListFromFavo[this.mmsIndex]?.mmsSource);
      if (mapImageAttach) { //彩信位置消息
        content = mapImageAttach.content ?? '';
      }
      commonPasteboard.setPasteboard(content as string);
    }
  }

  copyMultipeText() {
    let pasteData: LooseObject = [];
    let copyText: string = '';
    for (let i = 0; i < this.mmsListFromFavo.length; i++) {
      if (this.mmsListFromFavo[i].isCbChecked) {
        let selectText = this.mmsListFromFavo[i].msgContent as string;
        pasteData.push(selectText);
      }
    }
    copyText = pasteData.join('\n');
    commonPasteboard.setPasteboard(copyText);
  }

  /**
   * 收藏页面的选择文本功能
   * @param index
   */
  pushToCopyController(index: number) {
    let content = this.mmsListFromFavo[index].msgContent;
    const mapImageAttach = findMapSourceOfMmsMapMessage(Boolean(this.mmsListFromFavo[this.mmsIndex]?.isRcs),
      this.mmsListFromFavo[this.mmsIndex]?.mmsSource);
    if (mapImageAttach) { //彩信位置消息
      content = mapImageAttach.content ?? '';
    }
    let param: Record<string, string | number | Resource | boolean> = {
      'info': content,
      'isFromConversation': true
    }
    this.pageInfos.pushPathByName('CopyView', param);
  }

  gotoTextSelect(idx: number) {
    this.pushToCopyController(idx);
  }

  longPressSelected(index: number, jumpPageAfterAnimationEffect?: (type: PageJumpType, pageName: string,
    param: Record<string, number | boolean | string | LooseObject[]>, pageInfos: NavPathStack) => void) {
    switch (index) {
      case 0:
      // duplicating
        this.copyText();
        break;
      case 1:
      // Forwarding
        this.transmitMsg(this.mmsIndex, jumpPageAfterAnimationEffect);
        break;
      case 3:
      // Select Text
        this.gotoTextSelect(this.mmsIndex);
        break;
      case 4:
      //more
        this.more();
        break;
      default:
        break;
    }
  }

  // more
  more() {
    this.setTabOperationStatus(false);
    this.distanceBottomFlag = false;
    let item = this.mmsListFromFavo[1];

    item.isCbChecked = !item.isCbChecked;
    if (item.isCbChecked) {
      if (item.hasMms) {
        this.mmsCount++;
      }
    }

    this.conversationListDataSource.reload(this.mmsListFromFavo, 'more');
    this.setSelectStatus(true);
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

  /**
   * 收藏页面分享功能
   * @param target 选择分享的消息数据
   * @returns
   */
  shareMmsMessage(target: messageType) {
    HiLog.i(TAG, 'shareMmsMessage');
    //let data: systemShare.SharedData | undefined = undefined;
    let type: number = -1;
    let path: string = '';
    let duration: string = '';
    let ct: string | undefined = '';
    //该消息是否为增强信息消息
    let isRcs: boolean = Boolean(target.isRcs);
    HiLog.i(TAG, 'shareMmsMessage isRcs:' + isRcs);
    //该消息是否彩信位置消息且有彩信位置附件
    let mmsMapSource = findMapSourceOfMmsMapMessage(isRcs, target.mmsSource);
    //彩信位置消息的文本内容
    let mmsMapText: string | undefined = '';

    for (let i = 0; i < target.mmsSource?.length; i++) {
      if (!target.mmsSource[i]) {
        continue;
      }
      if (mmsMapSource) {
        if (target.mmsSource[i].type === common.MM_ATTACHMENT_TYPE.MAP) {
          type = target.mmsSource[i].type;
          path = target.mmsSource[i].path;
          mmsMapText = target.mmsSource[i].content;
          break;
        }
      } else if (target.mmsSource[i].type != 0) {
        type = target.mmsSource[i].type;
        path = target.mmsSource[i].path;
        duration = target.mmsSource[i].duration;
        if (target.mmsSource[i].ct !== undefined && target.mmsSource[i].ct != '') {
          ct = target.mmsSource[i].ct?.split('/')[1];
        }
        break;
      }
    }
    if (path == '' || type == -1) {
      HiLog.i(TAG, 'shareMmsMessage error');
      return;
    }

    let extraData: Record<string, string | number | boolean | Array<string | number | boolean>> = {};
    let uri: string = fileUri.getUriFromPath(path);
    if (MmsUtil.isAudio(type)) {
      HiLog.i(TAG, 'shareMessage type Audio');
      // data = new systemShare.SharedData({
      //   utd: MmsUtil.getFileUTD(path, ct),
      //   uri: uri,
      //   content: duration
      // });
    } else if (MmsUtil.isImage(type)) {
      HiLog.i(TAG, 'shareMessage type Image');
      // data = new systemShare.SharedData({
      //   utd: MmsUtil.getFileUTD(path, ct),
      //   uri: uri
      // });
    } else if (MmsUtil.isVideo(type)) {
      HiLog.i(TAG, 'shareMessage type video');
      // data = new systemShare.SharedData({
      //   utd: MmsUtil.getFileUTD(path, ct),
      //   uri:uri
      // });
    } else if (MmsUtil.isVcard(type)) {
      HiLog.i(TAG, 'shareMessage type vcard');
      // data = new systemShare.SharedData({
      //   utd: MmsUtil.getFileUTD(path, ct),
      //   uri:uri
      // });
    } else if (mmsMapSource && MmsUtil.isMmsMapAttach(isRcs, type)) { //彩信位置消息
      HiLog.i(TAG, 'shareMessage type MmsMap');
      const addressInfo: AddressInfo = parseAddressInfo(mmsMapSource.text) || new AddressInfo(0, 0, '', '');
      //extraData用于将彩信位置消息分享给信息应用的场景
      extraData[ShareExtraData.MESSAGE_TYPE] = commonData.MM_ATTACHMENT_TYPE.MAP;
      extraData[ShareExtraData.MESSAGE_IS_RCS] = Number(target.isRcs);
      extraData[ShareExtraData.MESSAGE_CONTENT] = mmsMapSource.content ?? '';
      extraData[ShareExtraData.MESSAGE_LONGITUDE] = addressInfo.longitude;
      extraData[ShareExtraData.MESSAGE_LATITUDE] = addressInfo.latitude;
      // data = new systemShare.SharedData({
      //   utd: MmsUtil.getFileUTD(path, ct),
      //   uri: uri,
      //   extraData: extraData
      // });
      if (mmsMapText && typeof mmsMapText === 'string') { //增加位置链接分享选项
       // data.addRecord(getMmsMapLinkShareData(mmsMapText));
      }
    }
   // return data;
  }

  async shareMessage() {
    let target: messageType | undefined = this.mmsListFromFavo.find((item: messageType) => item.isCbChecked === true);
    if (target == undefined) {
      HiLog.e(TAG, 'shareMessage target empty');
      return;
    }
    try {
      //let data: systemShare.SharedData | undefined = undefined;
      if (target.isMsm) {
        //data = this.shareMmsMessage(target);
      } else {
        let length = (target.msgContent as string).length;
        // let desc = getContext(this).resourceManager.getPluralStringValueSync($r('app.plural.share_description').id, length);
        // data = new systemShare.SharedData({
        //   utd: utd.UniformDataType.PLAIN_TEXT,
        //   content: target.msgContent as string,
        //   description: desc
        // });
      }
      // if (data != null) {
      //   HiLog.i(TAG, '-----shareMessage add data');
      //   let controller: systemShare.ShareController = new systemShare.ShareController(data);
      //   let context: myCommon.UIAbilityContext = (GlobalContext.getContext()
      //     .getObject('mmsContext') as myCommon.UIAbilityContext);
      //   controller.show(context, {
      //     previewMode: systemShare.SharePreviewMode.DETAIL,
      //     selectionMode: systemShare.SelectionMode.SINGLE
      //   });
      // }
    } catch (err) {
      HiLog.i(TAG, `message share` + JSON.stringify(err));
    }
  }

  isNeedTransmitTip(): boolean {
    let onlyAudioMms: messageType | undefined = this.mmsListFromFavo.find((mms: messageType) => {
      if (mms.hasMms && mms.isCbChecked) {
        let mmsArr: Mms[] = mms.mmsSource;
        if (mms.mmsSource.length >= 3) {
          return false
        }
        let audioResource: Mms | undefined =
          mmsArr.find((source: Mms) => source.type === common.MM_ATTACHMENT_TYPE.AUDIO);
        return audioResource !== undefined
      }
      return false
    });
    return onlyAudioMms !== undefined
  }

  filterAudio(mmsArr: Mms[]): boolean {
    let hasAudio = false;
    let isAdd:boolean = false;
    mmsArr.forEach((mms) => {
      if (mms.type === common.MM_ATTACHMENT_TYPE.AUDIO) {
        hasAudio = true;
      }
    });
    if (!hasAudio) {
      isAdd = true;
    }
    return isAdd;
  }

  filterAttachmentAndSmil(item:messageType): boolean {
    let isAdd:boolean = false;
    if (item.isCbChecked) {
      if (this.audioStatus === common.MMS_AUDIO_STATUS.HAS_AUDIO && item.hasMms) {
        let mmsArr: Mms[] = item.mmsSource;
        // If the number of attachments is greater than 3, the attachments can be forwarded.
        if (mmsArr.length >= 3) {
          isAdd = true;
        } else {
          isAdd = this.filterAudio(mmsArr);
        }
      } else {
        isAdd = true;
      }
    }
    return isAdd;
  }
  filerSelected(index?: number): messageType[] {
    let selectedArr: messageType[] = [];
    if (index != undefined && this.mmsListFromFavo.length > index) {
      selectedArr.push(this.mmsListFromFavo[index]);
    } else {
      this.mmsListFromFavo.forEach((item) => {
        if (this.filterAttachmentAndSmil(item)) {
          selectedArr.push(item);
        }
      });
    }
    return selectedArr;
  }

  createTransmitContentDetail(element: messageType, index: number): string {
    let transmitContentDetail: string = ''
    if (index === 0) {
      transmitContentDetail = element.msgContent as string;
    } else {
      transmitContentDetail = transmitContentDetail + '\n' + ' ' + '\n' + element.msgContent;
    }
    return transmitContentDetail;
  }

  transmitMsg(index?: number, jumpPageAfterAnimationEffect?: (type: PageJumpType, pageName: string,
    param: Record<string, number | boolean | string | LooseObject[]>, pageInfos: NavPathStack) => void) {// favoriteList
    let transmitContentList: LooseObject[] = [];
    let transmitContentStr: string = '';
    let transmitContentDetail: string = '';
    let selectedArr: messageType[] = this.filerSelected(index);
    let mmsNumber: number = 0;
    for (let index = 0; index < selectedArr.length; index++) {
      const element = selectedArr[index];
      if (element.mmsSource && element.mmsSource.length > 0) {
        element.hasMms = true;
      }
      let title: string | Resource = common.STR.EMPTY_STR;
      let transInfos = this.nameNoPicture(element.senderNumber)
      if (transInfos != null && transInfos.name.length > 0) {
        title = transInfos.name;
      } else {
        title = element.senderNumber;
      }
      let transmitContent: Resource | null = null;
      transmitContent = element.isReceive ? $r('app.string.transmitContentReceive', title) : $r('app.string.transmitContent');
      if (element.isReceive) {
        transmitContentStr = (GlobalContext.getContext()
          .getObject('mmsContext') as myCommon.UIAbilityContext).resourceManager.getStringSync(transmitContent, title);
      } else {
        transmitContentStr = (GlobalContext.getContext()
          .getObject('mmsContext') as myCommon.UIAbilityContext).resourceManager.getStringSync(transmitContent);
      }
      let transmitObj = this.transmitObj(element, transmitContent)
      if (transmitObj.isRcs && transmitObj.isMsm && (element.rcsType === common.ENHANCED_INFO_ITEM_TYPE.IMAGE ||
        element.rcsType === common.ENHANCED_INFO_ITEM_TYPE.VIDEO)) {
        transmitObj.content = '';
      }
      if (selectedArr.length > 1) {
        transmitObj.info = transmitContentStr;
        transmitContentStr = '';
      }
      if (index === 0) {
        transmitContentDetail = element.msgContent as string;
      } else {
        transmitContentDetail = transmitContentDetail + '\n' + ' ' + '\n' + element.msgContent;
      }
      transmitContentList.push(transmitObj);
      if (element.hasMms) {
        mmsNumber = mmsNumber + 1;
      }
    }
    let mmsStatus: number = this.createStatus(selectedArr, mmsNumber);
    this.jumpTransmitMsg(transmitContentStr, transmitContentDetail, transmitContentList, mmsStatus,
      jumpPageAfterAnimationEffect);
  }

  transmitObj(element: messageType, transmitContent: Resource | null): LooseObject {
    let transmitObj: LooseObject = {};
    transmitObj.isRcs = element.isRcs;
    transmitObj.content = element.msgContent;
    transmitObj.contactsName = transmitContent;
    transmitObj.isMsm = element.hasMms;
    transmitObj.mms = this.getTransmitSource(element.mmsSource);
    transmitObj.contentInfo = common.STR.EMPTY_STR;
    transmitObj.contentType = element.contentType;
    try {
      if (MmsUtil.isSlideType(element.contentType) && element.mmsSource?.length) {
        const fullMmsSource = MmsUtil.getSmilMmsSourceDelEmptyPar(element.mmsSource);
        const slideData = MmsUtil.generateSlidePreviewData(element.mmsSource);
        transmitObj.msgTitleTransmit = element?.msgTitle || '';
        transmitObj.slideFirstItemTransmit = slideData[0];
        transmitObj.fullMmsSource = fullMmsSource;
        transmitObj.smilStr = fs.readTextSync(element.mmsSource[0].path)
      }
    } catch (e) {
      HiLog.e(TAG, 'readFileContent error');
    }
    return transmitObj
  }

  createStatus(selectedArr: messageType[], mmsNumber: number): number {
    let mmsStatus: number = 0;
    if (mmsNumber > 0) {
      if (mmsNumber === selectedArr.length) {
        // All MMS messages
        mmsStatus = common.TRANSMIT_MSG_STATUS.ALL_MMS;
      } else {
        // Some of them are MMS messages
        mmsStatus = common.TRANSMIT_MSG_STATUS.HAS_MMS_SMS;
      }
    }
    return mmsStatus;
  }

  getTransmitInfo(item: messageType, title: string) {
    let info: string = '';
    DateUtil.fullDates(item, true);
    let fullDateStr: string = item.fullDate as string;
    let timeOfSmsStr: string = item.timeOfSms as string;
    let timeStr: string = fullDateStr + ' ' + timeOfSmsStr.replace(new RegExp('s', 'ig'), '');
    if (item.isReceive) {
      info = timeStr + ' ' + title + ':';
    } else {
      let me: string = (GlobalContext.getContext()
        .getObject('mmsContext') as myCommon.UIAbilityContext).resourceManager.getStringSync($r('app.string.me'));
      info = timeStr + ' ' + me + ':';
    }
    return info;
  }

  getTransmitSource(mmsSource: Array<Mms>) {
    if (!mmsSource || mmsSource.length === 0) {
      return [];
    }
    let source: Mms[] = [];
    mmsSource.forEach((item) => {
      if (item.type !== common.MM_ATTACHMENT_TYPE.SMIL) {
        source.push(item);
      }
    });
    return source;
  }

  jumpTransmitMsg(transmitContent: string, transmitContentDetail: string, transmitContentList: LooseObject[],
                  mmsStatus: number, jumpPageAfterAnimationEffect?: (type: PageJumpType, pageName: string,
      param: Record<string, number | boolean | string | LooseObject[]>, pageInfos: NavPathStack) => void) {
    let param: Record<string, number | boolean | string | LooseObject[]> = {
      'threadId': this.threadId,
      'doubleCard': false,
      'transmitContent': transmitContent,
      'transmitContentList': transmitContentList,
      'isMulti': true,
      'mmsStatus': mmsStatus,
      'isMyStartPage': false,
      'transmitContentDetail': transmitContentDetail
    }
    if (DeviceUtil.isPC()) {
      AppStorage.setOrCreate('isFavoriteTransmitShow', true);
      AppStorage.setOrCreate('isTransmitSearch', false);
      AppStorage.setOrCreate('transmitParam', param);
    } else {
      if (jumpPageAfterAnimationEffect) {
        jumpPageAfterAnimationEffect(PageJumpType.PUSH_PATH_BY_NAME, 'TransmitMsg', param, this.pageInfos);
      } else {
        this.pageInfos.pushPathByName('TransmitMsg', param);
      }
    }
  }

  async saveImageToPhotoAlbums(sandBoxPath: string) {
    HiLog.i(TAG, 'saveImagePhotoAlbums');
    let context = (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);
    let photoAccessHelper = await import('@ohos.file.photoAccessHelper');
    let phAccessHelper = photoAccessHelper.default.getPhotoAccessHelper(context);
    try {
      //get fileSandbox.fd
      let fileSandbox = await fs.open(sandBoxPath, fs.OpenMode.READ_ONLY);
      let size = fs.statSync(fileSandbox.fd).size;
      let fileSandboxBuffer = new ArrayBuffer(size);
      fs.readSync(fileSandbox.fd, fileSandboxBuffer);
      //write to albums
      let uri = await phAccessHelper.createAsset(photoAccessHelper.default.PhotoType.IMAGE, 'jpg');
      let file = await fs.open(uri, fs.OpenMode.READ_WRITE);
      await fs.write(file.fd, fileSandboxBuffer);
      await fs.close(fileSandbox.fd);
      await fs.close(file.fd);
      prompt.showToast({ message: $r('app.string.Saved_to_album'), duration: 200 });
    } catch (err) {
      let error = err as BusinessError;
      HiLog.i(TAG, `saveImageToPhotoAlbums: ${error}`);
    }
  }

  async saveVideoToAlbums(sandBoxPath: string) {
    HiLog.i(TAG, 'saveVideoAlbums');
    let photoAccessHelper = await import('@ohos.file.photoAccessHelper');
    let context = (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);
    let phAccessHelper = photoAccessHelper.default.getPhotoAccessHelper(context);
    try {
      //get fileSandbox.fd
      let fileSandbox = await fs.open(sandBoxPath, fs.OpenMode.READ_ONLY);
      let size = fs.statSync(fileSandbox.fd).size;
      let fileSandboxBuffer = new ArrayBuffer(size);
      fs.readSync(fileSandbox.fd, fileSandboxBuffer);
      //write to albums
      let uri = await phAccessHelper.createAsset(photoAccessHelper.default.PhotoType.VIDEO, 'mp4');
      let fileAlbums = await fs.open(uri, fs.OpenMode.READ_WRITE);
      try {
        await fs.write(fileAlbums.fd, fileSandboxBuffer);
      } catch (err) {
        HiLog.e(TAG, `fs.write:${err}`);
      }
      await fs.close(fileSandbox);
      await fs.close(fileAlbums);
      prompt.showToast({ message: $r('app.string.Saved_to_album'), duration: 200 });
      HiLog.i(TAG, `uri:${uri}`)

    } catch (err) {
      let error = err as BusinessError
      HiLog.e(TAG, `saveVideoToAlbums: ${error}`);
    }
  }

  getVcardPath() {
    return this.mmsListFromFavo[this.mmsIndex].mmsSource.filter(item => MmsUtil.isVcard(item.type))[0]?.path;
  }
}