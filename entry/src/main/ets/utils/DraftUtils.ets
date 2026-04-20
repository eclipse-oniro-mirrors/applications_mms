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
import { ValuesBucket } from '@kit.ArkData';
import { Mms, SessionContentTypeOfRcs } from './TypesUtils';
import ConversationController, {
  groupIdsInfos,
  mmsListType, selectContactType } from '../pages/conversation/conversationController';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import LooseObject from '../data/LooseObject';
import ConversationListService from '../service/ConversationListService';
import common from '../data/commonData';
import commonData from '../data/commonData';
import HiLog from './HiLog';
import ConversationService from '../service/ConversationService';
import ConversationListController from '../pages/conversationlist/conversationListController';
import { Context } from '@kit.AbilityKit';
import Constant from '../data/Constant';
import { display } from '@kit.ArkUI';
import DeviceUtil from './DeviceUtil';
import { isMmsMapMessageByMmsListType } from './MmsUtil';

export class ActionData {
  // 是否为新建信息
  public isNewMsg: boolean = false
  // sms 卡号
  public slotId: number = 0
  // 会话详情id
  public threadId: number = 0
  // 联系人字符串
  public receiveContactValue: string = ''
  // 当前草稿内容
  public content: string = ''
  public isReceive: boolean = false;
  public ownNumber: string = ''
  // 是否发送
  public isSender: number = 0
  // 是否有草稿
  public hasDraft: number = 0
  // 是否已经发送打点报告
  public hasReport: boolean = false
  // 是否彩信
  public isMms: boolean = false
  // 当前的附件
  public mmsSource: Mms[] = []
  // 会话id
  public groupId: number = 0
  public hasAttachment: boolean = false
  // 之前是否存在草稿
  public isDraft: boolean = false
  // 会话详情电话号码
  public telephone: string = ''
  // 当前联系人
  public selectContacts: selectContactType[] = []
}

export class DraftModel {
  // 原始草稿文本
  public initialDraftText: string = ''
  // 原始草稿附件
  public initialDraftAttachments: Mms[] = []
  // 原始联系人（新建信息使用）
  public initialSelectContacts: selectContactType[] = []
  // 是否已经将原始附件草稿赋值
  public isHasSetValueForInitialDraftAttachments: boolean = false
  // 是否已经将原始文本草稿赋值
  public isHasSetValueForInitialDraftText: boolean = false
  // 是否已经获取到联系人(对于新建信息，如果还没获取到联系人就切换信息列表，不保存草稿, 防止误删新建会话)
  public isHasGetContacts: boolean = false
  // 获取到的联系人的threadID
  public hasGetContactsThreadID = -1
  // 如果不是新建信息，并且已经加载过内容，（防止切换快内容未加载误删）但是用户删除了所有会话内容，不保存草稿， 需要删除会话
  public needDeleteSession: LooseObject = { isLoaded: false, isNeedDelete: false }
  /*
   是否已经获取到附件区已经获取到完整的初始附件草稿
   （由于附件区是100毫秒添加一个附件，做了延时操作，为了保证快速切换，
   附件区还没获取到附件草稿，导致附件草稿丢失，如果未获取到，就不保存草稿）
   */
  public attachmentAreaHasSetValue: boolean = false
  // 是否为转发后的conversation
  public isForwardingDraftModel: boolean = false
  // 新建信息草稿集合
  public newCreatDrafts: mmsListType[] = []
  // 用户清空数据后需要展示最后的content
  public mmsList: mmsListType[] = []
  // 需要保存的草稿session数据
  public actionData: ActionData = new ActionData()
}

const TAG = 'DraftUtils'

export class DraftUtils {
  // 需要保存的草稿队列
  public draftModelArray: DraftModel[] = []
  // 上下文环境
  private context: Context | null = null
  // PAUSED状态当草稿被清空后，删除草稿后需要重置输入框
  private isNeedClearTextArea: boolean = false
  // 是否为PAUSED状态 (应用进入后台，默认为不可交互状态)
  private isPausedStatus: boolean = false
  private static _instance: DraftUtils | null = null
  private rcsMapStatus: number = 0;
  private constructor() {
  }

  public static getInstance(): DraftUtils {
    if (DraftUtils._instance === null) {
      DraftUtils._instance = new DraftUtils()
    }
    return DraftUtils._instance
  }

  // 是否需要保存草稿
  private isNeedUpdateDraft(context: Context, draftModel: DraftModel, isNeedContact?: boolean): boolean {
    if (!draftModel) {
      HiLog.e(TAG, 'draftModel is null')
      return false
    }
    let selectContactsCount: number = draftModel.actionData.selectContacts.length
    let mmsSourceCount: number = draftModel.actionData.mmsSource.length
    let draftText: string = draftModel.actionData.content
    let isNewCreatMessage: boolean = draftModel.actionData.isNewMsg
    let threadId: number = draftModel.actionData.threadId
    // 不需要走保存草稿流程， 但需要删除会话 (新建信息，无联系人，或者无草稿)
    if (isNewCreatMessage) {
      // 如果是新建信息还没获取到联系人数据就切换短信列表，不保存草稿
      if (!draftModel.isHasGetContacts && threadId !== 0) {
        HiLog.i(TAG, 'new create message but not get contacts')
        return false
      }
      if (selectContactsCount <= 0 &&
        (draftText === common.STR.EMPTY_STR && mmsSourceCount === 0)) {
        HiLog.i(TAG, 'selectContactsCount = ' + selectContactsCount + 'mmsSourceCount  = ' + mmsSourceCount)
        if (draftModel.actionData.threadId !== 0) {
          deleteSession(draftModel, () => {
            HiLog.i(TAG, 'delete new create message session')
            this.updateConversationList(context)
          }, this.context as Context)
          return false
        } else {
          this.clearDirtyNoReceiverDraft(draftModel.newCreatDrafts, getContext(this), () => {})
          return false
        }
      }
      // 新建消息，联系人为空，但草稿不为空
      if (selectContactsCount <= 0 ) {
        HiLog.i(TAG, 'selectContactsCount less than zero' + selectContactsCount)
        if ((draftText !== draftModel.initialDraftText || mmsSourceCount > 0)) {
          this.insertNewCreatMessageDraft(context, draftModel, isNeedContact)
        }
        // 如果之前已生成草稿会话，需要删除会话，并清除草稿
        if (draftModel.actionData.threadId !== 0) {
          deleteSession(draftModel, () => {
            HiLog.i(TAG, 'delete new create message session for has session')
            this.updateConversationList(context)
          }, this.context as Context)
        }
        return false
      }

      // 新建消息，联系人不为空，草稿为空
      if (selectContactsCount > 0 && (draftText === common.STR.EMPTY_STR && mmsSourceCount === 0)) {
        HiLog.i(TAG, 'selectContactsCount greater than zero' + selectContactsCount)
        if (draftModel.actionData.threadId !== 0) {
          deleteSession(draftModel, () => {
            HiLog.i(TAG, 'delete new create message session')
            this.updateConversationList(context);
          }, this.context as Context)
        }
        return false
      }
      // 新建信息，如果联系人发生了变化，保存草稿(当联系人数量很多时，耗性能)
      if (draftModel.isHasGetContacts &&
        draftModel.hasGetContactsThreadID === draftModel.actionData.threadId) {
        // 联系人数量发生变化，保存草稿
        if (draftModel.initialSelectContacts.length !== selectContactsCount) {
          HiLog.i(TAG, 'initialSelectContacts length does not equal selectContactsCount')
          return true
        }
        // 数量没变 判断号码是否有变化
        let initialSelectContacts: selectContactType[] = draftModel.initialSelectContacts
        let selectContacts: selectContactType[] = draftModel.actionData.selectContacts
        for (let i = 0; i < selectContactsCount; i++) {
          if (initialSelectContacts[i].telephone !== selectContacts[i].telephone) {
            HiLog.i(TAG, 'initialSelectContacts telephone does not equal selectContacts')
            return true
          }
        }
        HiLog.i(TAG, 'new create message about contacts ')
      }
    }

    // 非新建信息，用户删了所有的会话内容， 但留有草稿
    if (!isNewCreatMessage && draftModel.needDeleteSession.isLoaded &&
    draftModel.needDeleteSession.isNeedDelete && (draftText !== common.STR.EMPTY_STR || mmsSourceCount !== 0)
    ) {
      return true
    }

    // 非新建信息，用户删了所有的会话内容， 直接删除会话
    if (!isNewCreatMessage && draftModel.needDeleteSession.isLoaded && draftModel.needDeleteSession.isNeedDelete) {
      deleteSession(draftModel, () => {
        HiLog.i(TAG, 'delete list is null session')
        this.updateConversationList(context)
      }, this.context as Context)
      return false
    }

    // 附件区没有获取到草稿就切换了信息列表，不保存草稿
    if (draftModel.initialDraftAttachments.length > 0 && !draftModel.attachmentAreaHasSetValue) {
      HiLog.i(TAG, 'draftModel.initialDraftAttachments.length than zero')
      return false
    }

    // 非新建信息，之前有草稿，现在草稿为空
    if (!isNewCreatMessage &&
    draftModel.actionData.isDraft &&
      draftText === common.STR.EMPTY_STR && draftModel.isHasSetValueForInitialDraftText &&
      mmsSourceCount === 0) {
      deleteDraft(context, draftModel, () => {
        this.updateConversationList(context)
        if (this.isPausedStatus) {
          this.isNeedClearTextArea = true
          this.updateConversationControllerDraftModel(draftModel)
        }
      })
      return false
    }
    // 文本内容改变或者附件多少改变
    if ((mmsSourceCount !== draftModel.initialDraftAttachments.length) ||
      (draftText !== draftModel.initialDraftText && draftModel.isHasSetValueForInitialDraftText)) {
      HiLog.i(TAG,
        'mmsSourceCount = ' + mmsSourceCount + 'initLength = ' + draftModel.initialDraftAttachments.length)
      return true
    }
    // 图片草稿保存
    if (draftModel?.initialDraftAttachments?.length !== 0 &&
      (mmsSourceCount !== draftModel?.initialDraftAttachments?.length)) {
      return true
    }

    if (!draftModel.actionData.mmsSource || !draftModel.initialDraftAttachments ||
      draftModel.actionData.mmsSource.length != draftModel.initialDraftAttachments.length) {
      return false;
    }

    // 附件多少未改变 但路径有改变（更换附件）
    for (let index = 0; index < mmsSourceCount; index++) {
      if (draftModel.actionData.mmsSource[index]?.path !== draftModel.initialDraftAttachments[index]?.path) {
        HiLog.i(TAG, 'mmsSource path change')
        return true
      }
    }
    return false
  }

  public saveDraft(context: Context, callback?: Function, isNeedResetConversationDraftModel: boolean = false,
    isWindowStageSave?: boolean, isNeedContact?: boolean) {
    if (context === null || context === undefined) {
      HiLog.e(TAG, 'context is empty')
      this.rcsMapStatus = 0;
      return
    }
    // 不需要保存草稿（草稿未改变 | 删除会话 | 删除草稿）
    this.context = context
    if (this.draftModelArray.length <= 0) {
      HiLog.e(TAG, 'draftModelArray is empty')
      if (callback !== undefined) {
        callback()
      }
      this.rcsMapStatus = 0;
      return
    }
    let tempDraftModelArray: DraftModel[] = [...this.draftModelArray]
    this.draftModelArray = []
    this.isPausedStatus = isNeedResetConversationDraftModel
    for (let i = 0; i < tempDraftModelArray.length; i++) {
      let draftModel = tempDraftModelArray[i]
      let mmsInfo = draftModel.actionData.mmsSource;
      let source: Mms[] = [];
      if (mmsInfo.length > 0) {
        for (let item = 0; item < mmsInfo.length; item++) {
          if (mmsInfo[item].type === commonData.ENHANCED_INFO_ITEM_TYPE.MAP &&
            this.rcsMapStatus === commonData.WEBVIEW_MENU_ID.SHARE_ID) {
            HiLog.i(TAG, 'ignore this location draft');
          } else {
            source.push(mmsInfo[item]);
          }
        }
        draftModel.actionData.mmsSource = source;
      }
      this.rcsMapStatus = 0;
      if (!this.isNeedUpdateDraft(context, draftModel, isNeedContact)) {
        if (callback !== undefined) {
          callback()
        }
        HiLog.i(TAG, 'do not need save draft')
        continue
      } else {
        try {
          if (isWindowStageSave &&
            (this.isFoldableScreenAndFullyUnfolded())) {
            HiLog.i(TAG, 'WindowStageSaveDraft true');
            AppStorage.setOrCreate('isWindowStageSaveDraft', true);
          } else {
            HiLog.i(TAG, 'WindowStageSaveDraft false');
            AppStorage.setOrCreate('isWindowStageSaveDraft', false);
          }
        } catch (err) {
          HiLog.e(TAG, `Failed to getFoldStatus, Code: ${err.code}, message: ${err.message}`);
        }
        HiLog.i(TAG, 'need save draft')
        updateDraft(draftModel, () => {
          this.updateConversationList(context)
          if (isNeedResetConversationDraftModel) {
            this.updateConversationControllerDraftModel(draftModel)
          }
          if (callback !== undefined) {
            callback()
          }
        }, this.context)
      }
    }
  }

  private isFoldableScreenAndFullyUnfolded(): boolean {
    try {
      return DeviceUtil.isFoldable() && display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED;
    } catch (err) {
      HiLog.e(TAG, `Failed to get isFoldableScreenAndFullyUnfolded, Code: ${err.code}, message: ${err.message}`);
    }
    return false;
  }

  // 查询新建threadId为0的草稿
  public queryNoReceiverDraft(context: Context, callBack: Function) {
    let queryActionData: LooseObject = {};
    queryActionData.isNoReceiverDraft = true;
    ConversationService.getInstance().queryMessageNoReceiverDraft(context, queryActionData, (result: LooseObject) => {
      callBack(result);
    }, 0)
  }

  // 通过id获取文本草稿
  public getDraftTextData(context: Context, threadId: number, callback: Function) {
    ConversationService.getInstance().queryDraftBySessionId(threadId, context).then((result) => {
      callback(result)
    })
  }

  // 删除所有新建信息草稿
  public clearDirtyNoReceiverDraft(draftItemList: mmsListType[], context: Context, callback: Function): number {
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
      this.deleteMessageByGroupIds(needDeleteGroupIds, context, callback);
    }
    return needDeleteGroupIds.length;
  }

  // 插入新建短信
  private insertNewCreatMessageDraft(context: Context, draftModel: DraftModel, isNeedContact?: boolean) {
    if (draftModel.actionData.isDraft) {
      HiLog.i(TAG, 'insert new create message but need clear after draft')
      this.clearDirtyNoReceiverDraft(draftModel.newCreatDrafts, getContext(this), () => {})
    }
    HiLog.i(TAG, `insert new create message is need contact:${isNeedContact}`);
    if (!isNeedContact) {
      ConversationService.getInstance().insertNoReceiverDraft(context, draftModel.actionData)
    }
  }

  // 更新短信列表
  private updateConversationList(context: Context) {
    GlobalContext.getContext().setObject('needToUpdate', true)
    ConversationListController.getInstance().lastIndex = -1
    ConversationListController.getInstance().refreshConversationListData(context)
  }

  // 更新原始草稿
  private updateConversationControllerDraftModel(draftModel: DraftModel) {
    HiLog.i(TAG, '[updateConversationControllerDraftModel]')
    let conversationController: ConversationController = ConversationController.getInstance()
    if (conversationController.draftModel !== null) {
      conversationController.draftModel.initialSelectContacts = draftModel.actionData.selectContacts
      conversationController.draftModel.initialDraftAttachments = draftModel.actionData.mmsSource
      conversationController.draftModel.initialDraftText = draftModel.actionData.content
    }
    if (this.isNeedClearTextArea) {
      conversationController.textValue = draftModel.actionData.content
      conversationController.draftContent = draftModel.actionData.content
    }
  }

  // 删除数据库草稿
  public deleteMessageByGroupIds(groupIds: number[], context: Context, callback: Function,
    groupInfos?: Array<groupIdsInfos>, isReSend?: boolean,
    isGroupSession?: boolean): void {
    HiLog.w(TAG, 'deleteMessageByGroupIds groupId is :' + JSON.stringify(groupIds));
    let actionData: LooseObject = {};
    let groupIdMms: number[] = [];
    let groupIdRcs: number[] = [];
    let msgIdsRcs: string[] = [];
    let rcsId: number[] = [];
    // 非文本消息groupId集合
    let groupIdIsMms: number[] = [];
    // 非文本消息rcsId集合
    let rcsIdIsMms: number[] = [];
    // 已被收藏消息groupId集合
    let groupIdIsCollect: number[] = [];
    // 已被收藏消息rcsId集合
    let rcsIdIsCollect: number[] = [];
    // 只需删除mms_part表记录，同时删除资源文件消息groupId集合（重发/草稿等场景只删除数据库mms_part表记录，不删除沙箱文件）
    let groupIdNeedDeleteFile: number[] = [];
    let rcsIdNeedDeleteFile: number[] = [];
    if (groupInfos !== undefined) {
      for (let index = 0; index < groupInfos?.length; index++) {
        if (groupInfos[index].isRcs === common.MESSAGE_TYPE.RCS) {
          groupIdRcs.push(groupInfos[index].groupId as number)
          msgIdsRcs.push(groupInfos[index].msgId as string)
          rcsId.push(groupInfos[index].rcsId as number)
          groupIdMms.push(groupInfos[index].groupId as number)
        } else {
          groupIdMms.push(groupInfos[index].groupId as number)
        }
        if (groupInfos[index].isMms) {
          groupIdIsMms.push(groupInfos[index].groupId as number);
          if (groupInfos[index].isRcs === common.MESSAGE_TYPE.RCS) {
            rcsIdIsMms.push(groupInfos[index].rcsId as number);
          }
        }
        if (groupInfos[index].isCollect) {
          if (groupInfos[index].isRcs === common.MESSAGE_TYPE.RCS) {
            rcsIdIsCollect.push(groupInfos[index].rcsId as number);
          }
          groupIdIsCollect.push(groupInfos[index].groupId as number);
        }
        if (groupInfos[index].isNeedDeleteSourceFile) {
          if (groupInfos[index].isRcs === common.MESSAGE_TYPE.RCS) {
            rcsIdNeedDeleteFile.push(groupInfos[index].rcsId as number);
          }
          groupIdNeedDeleteFile.push(groupInfos[index].groupId as number);
        }
      }
      actionData.groupIds = groupIdMms;
      actionData.groupIdsRcs = groupIdRcs;
      actionData.msgIdsRcs = msgIdsRcs;
      actionData.rcsIds = rcsId;
      actionData.groupIdIsMms = groupIdIsMms;
      actionData.rcsIdIsMms = rcsIdIsMms;
      actionData.groupIdIsCollect = groupIdIsCollect;
      actionData.rcsIdIsCollect = rcsIdIsCollect;
      actionData.groupIdNeedDeleteFile = groupIdNeedDeleteFile;
      actionData.rcsIdNeedDeleteFile = rcsIdNeedDeleteFile;
      // 删除参数从groupInfos解析，用作后续删除mms_part表逻辑判断
      actionData.isFromGroupInfos = true;
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
    if (AppStorage.get(Constant.IS_CHANGE_DRAFT)) {
      ConversationService.getInstance().querySmsMmsInfoByCondition(context, actionData, (item: LooseObject) => {
        if (item && item.abilityResult && item.abilityResult[0] != null) { // 宽松比较，排查undefined、null
          //这里保存删除草稿的id和电话号码，用于在融合搜中 把搜出来已经删除的草稿给过滤掉
          AppStorage.setOrCreate(Constant.DELETED_DRAFT_MSG_ID, item.abilityResult[0].msgId);
          AppStorage.setOrCreate(Constant.DELETED_DRAFT_NUMBER, item.abilityResult[0].receiverNumber);
          ConversationService.getInstance().deleteSmsMmsInfoByCondition(context, actionData, callback);
        } else {
          HiLog.w(TAG, 'querySmsMmsInfoByCondition abilityResult null callback');
          callback();
        }
      });
    } else {
      ConversationService.getInstance().deleteSmsMmsInfoByCondition(context, actionData, callback);
    }
  }

  public setIsRcsMms(rcsMapStatus: number) {
    this.rcsMapStatus = rcsMapStatus;
  }
}

// 更新草稿
async function updateDraft(draftModel: DraftModel, callback: Function, context: Context) {
  let groupId: number = draftModel.actionData.groupId
  HiLog.i(TAG, 'message draft is ' + draftModel.actionData.isDraft + ', group id is ' + groupId)
  //否是修改草稿
  AppStorage.setOrCreate(Constant.IS_CHANGE_DRAFT, true);
  if (draftModel.actionData.isDraft && groupId > 0) {
    let groupIds = [groupId]
    DraftUtils.getInstance().deleteMessageByGroupIds(groupIds, context, () => {
      // 防止回调2次
      if (draftModel.actionData.groupId === 0) {
        HiLog.w(TAG, 'groupId has zero')
        return
      }
      draftModel.actionData.groupId = 0
      if (draftModel.actionData.content !== '' || draftModel.actionData.mmsSource.length > 0) {
        ConversationListService.getInstance().insertSessionDraft(draftModel.actionData, callback, context)
      }
    })
  } else {
    draftModel.actionData.groupId = 0
    ConversationController.getInstance().isDraft = true
    ConversationListService.getInstance().insertSessionDraft(draftModel.actionData, callback, context)
  }
}

async function deleteDraftByThreadId(draftModel: DraftModel, callback: Function, context: Context) {
  // 删除草稿内容 （经测试，数据库在清空草稿内容后并不会立即更改列表数据，所以必须调用更新列表)
  HiLog.i(TAG, 'deleteDraftByThreadId')
  let threadIds: number[] = [draftModel?.actionData.threadId];
  let actionData: Record<string, number | number[]> = {
    'threadIds': threadIds,
    'msgState': commonData.int.SEND_DRAFT,
  };
  ConversationService.getInstance().deleteSmsInfoByCondition(context, actionData, () => {
  })
}

// 删除草稿 (如果之前存在草稿，现在附件草稿和文本草稿都为空的时候调用)
async function deleteDraft(context: Context, draftModel: DraftModel, callback: Function) {
  let groupId: number = draftModel.actionData.groupId
  if (draftModel.actionData.isDraft && groupId > 0) {
    let groupIds = [groupId]
    DraftUtils.getInstance().deleteMessageByGroupIds(groupIds, context, () => {})
  }
  // 更新列表
  HiLog.i(TAG, 'delete draft');
  AppStorage.set(Constant.IS_DELETE_MESSAGE, true);
  let valueBucket: Record<string, string | number | Resource> = {
    'content': common.STR.EMPTY_STR,
    'has_draft': common.has_draft.NO,
    'time': new Date().getTime(),
    'has_mms': common.has_mms.NO,
    'has_attachment': common.has_attachment.NO
  }
  let length: number = draftModel.mmsList.length
  if (length > 0) {
    let item: mmsListType = draftModel.mmsList[length - 1]
    // 当获取的会话详情最新消息异常情况下，重新获取一次会话详情最新会话
    if (item.timeMillisecond === -1) {
      // 等待最新有效mmsList
      await waitMmsList(draftModel);
      item = draftModel.mmsList[draftModel.mmsList.length - 1]
      if (item.timeMillisecond === -1) {
        // 没有等待有效mmsList，则停止更新Session表
        HiLog.e(TAG, 'stop update Session');
        return;
      }
    }
    if (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.MAP && item.mmsSource.length > 1) {
      valueBucket.content = item.mmsSource[1]?.content || '';
      valueBucket.time = item.timeMillisecond;
      valueBucket.has_mms = common.has_mms.HAVE;
      valueBucket.has_attachment = common.has_attachment.HAVE;
    } else {
      if ((item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE ||
        item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO) && item.mmsSource.length > 1) {
        valueBucket.content = item.mmsSource[1].path;
      } else if (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO && item.mmsSource.length > 1) {
        valueBucket.content = item.mmsSource[1].path;
      } else if (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.VCARD && item.mmsSource.length > 1) {
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
        valueBucket.content = JSON.stringify(tempObj);
      } else if (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.FILE && item.mmsSource.length > 1) {
        valueBucket.content = item.mmsSource[1].copyPath ? item.mmsSource[1].copyPath : item.mmsSource[1].path;
      } else if (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE && item.mmsSource.length > 1) {
        valueBucket.content = item.mmsSource[1].path;
      } else if (isMmsMapMessageByMmsListType(Boolean(item.isRcs), item)) { //彩信位置消息
        valueBucket.content = '';
      } else {
        valueBucket.content = item.content;
      }
      valueBucket.time = item.timeMillisecond;
      valueBucket.has_mms = item.isMsm ? common.has_mms.HAVE : common.has_mms.NO;
      valueBucket.has_attachment = item.isMsm ? common.has_attachment.HAVE : common.has_attachment.NO;
    }
  }
  let condition: LooseObject = {};
  condition.threadId = draftModel?.actionData.threadId;
  ConversationListService.getInstance()
    .updateSessionByCondition(context, condition, valueBucket as ValuesBucket, callback, true);
}

function waitMmsList(draftModel: DraftModel) {
  return new Promise<void>(async (resolve) => {
    try {
      for (let i = 1; i <= 6; i++) {
        // 等待 50 毫秒
        await delay(50);
        draftModel.mmsList = ConversationController.getInstance().mmsList;
        let length = draftModel.mmsList.length;
        if (length > 0) {
          let item: mmsListType = draftModel.mmsList[length-1];
          if (item.timeMillisecond !== -1) {
            HiLog.i(TAG, 'waitMmsList Waiting times:' + i);
            resolve();
            return;
          }
        }
      }
      resolve();
      HiLog.e(TAG, 'No waiting for valid data');
    } catch (err) {
      HiLog.e(TAG, `waitThreeTimes, Code: ${err.code}, message: ${err.message}`);
      resolve();
    }
  });
}

function delay(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}


// 删除会话, (如果是新建信息，联系人为空，或者草稿为空的情况下直接删除整个会话)
async function deleteSession(draftModel: DraftModel, callback: Function, context: Context) {
  HiLog.i(TAG, 'delete session')
  let condition: LooseObject = {};
  condition.threadId = draftModel?.actionData.threadId;
  condition.messageCount = 0;
  ConversationListService.getInstance().deleteSessionByCondition(condition, callback, context);
  let groupId: number = draftModel.actionData.groupId
  HiLog.i(TAG, 'message draft is ' + draftModel.actionData.isDraft + ', group id is ' + groupId)
  let groupIds = [groupId]
  DraftUtils.getInstance().deleteMessageByGroupIds(groupIds, context, () => {})
}