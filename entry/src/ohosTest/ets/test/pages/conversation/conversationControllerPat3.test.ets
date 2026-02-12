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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers, afterEach, } from '@ohos/hypium';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import TelephoneUtil from '../../../../../main/ets/utils/TelephoneUtil';
import ConversationController, {
  ActionDataType,
  groupIdsInfos,
  InitData,
  mmsListType,
  MmsSourceType,
  ResultInfo,
} from '../../../../../main/ets/pages/conversation/conversationController';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import { dataShare} from '@kit.ArkData';
import ConversationDataSource from '../../../../../main/ets/model/ConversationDataSource';
import { window } from '@kit.ArkUI';
import ConversationService from '../../../../../main/ets/service/ConversationService';
import ConversationListService from '../../../../../main/ets/service/ConversationListService';
import MmsUtil from '../../../../../main/ets/utils/MmsUtil';
import { resourceManager } from '@kit.LocalizationKit';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import InfoMsgController from '../../../../../main/ets/pages/infomsg/InfoMsgController';
import { IQueryMessageDetailAll, IQueryMessageDetailInfo } from '../../../../../main/ets/model/type/ConversationParams';
import MmsPreferences from '../../../../../main/ets/utils/MmsPreferences';
import SharedPreferencesUtils from '../../../../../main/ets/utils/SharedPreferencesUtils';
import DotUtil from '../../../../../main/ets/utils/MmsDot/DotUtils';
import {
  EnhancedInfoTemporaryDataSource,
  ImageData
} from '../../../../../main/ets/model/EnhancedInfoTemporaryDataSource';
import SsmUtils from '../../../../../main/ets/utils/SsmUtils';
import { BusinessError } from '@kit.BasicServicesKit';
import dateUtil, { DateUtil } from '../../../../../main/ets/utils/DateUtil';
import { DTGlobalContext } from '../../../testability/TestAbility';
import ConversationListController from '../../../../../main/ets/pages/conversationlist/conversationListController';

export default function conversationControllerPart3Test() {
  describe('conversationControllerTest3', () => {

    let mConversationCtrl: ConversationController;
    let mocker: MockKit;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mocker = new MockKit();
      mConversationCtrl = ConversationController.getInstance();
    })

    afterEach(() => {
      mocker.clear(ConversationService.getInstance());
      mocker.clear(ConversationService);
      mocker.clear(ConversationListService.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(DateUtil);
      mocker.clear(mConversationCtrl.scroller);
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(TelephoneUtil);
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(MmsUtil);
      mocker.clear(SsmUtils);
      mocker.clear(mConversationCtrl);
      AppStorage.clear();
    })

    it('ConversationControllerTest_selectStatusOnDeleteMsg_isSelectStatus_false_isCbChecked_false_mmsIndex_1', 0,
      () => {
        mConversationCtrl.isSelectStatus = false;
        let mmsList: mmsListType = new mmsListType();
        mmsList.msgItemIndex = 0;
        mmsList.isCbChecked = true;
        mConversationCtrl.mmsList = [mmsList, mmsList];
        mConversationCtrl.mmsIndex = 1;
        mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().deleteByIndex);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetSelectData);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);
        mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().notifyDataReload);

        mConversationCtrl.selectStatusOnDeleteMsg([], [], 0);

        expect(mConversationCtrl.mmsIndex).assertEqual(1);
        mocker.clear(mConversationCtrl);
        mocker.clear(ConversationDataSource.getInstance());
      })

    it('ConversationControllerTest_selectStatusOnDeleteMsg_isSelectStatus_false_item_undefined', 0, () => {
      mConversationCtrl.isSelectStatus = false;
      let mmsList: mmsListType = new mmsListType();
      mmsList.msgItemIndex = 0;
      mmsList.isCbChecked = true;
      mConversationCtrl.mmsList = [mmsList, mmsList];
      mConversationCtrl.mmsIndex = 2;
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().notifyDataReload);

      mConversationCtrl.selectStatusOnDeleteMsg([], [], 0);

      expect(mConversationCtrl.mmsIndex).assertEqual(2);
      mocker.clear(ConversationDataSource.getInstance());
    })

    it('ConversationControllerTest_pageNeedChange_sm', 0, () => {
      AppStorage.setOrCreate('curBp', 'sm');
      mConversationCtrl.pageInfos = new NavPathStack();
      mConversationCtrl.pageInfos.pushPathByName('EmptyConversationList', {} as LooseObject);

      mConversationCtrl.pageNeedChange();

      expect(mConversationCtrl.pageInfos.getAllPathName().length).assertEqual(0);
    })

    it('ConversationControllerTest_pageNeedChange_bp_isBackToIndex_true', 0, () => {
      AppStorage.setOrCreate('curBp', 'bp');
      InfoMsgController.getInstance().total = 1;
      mConversationCtrl.isBackToIndex = true;
      mConversationCtrl.pageInfos = new NavPathStack();
      mConversationCtrl.pageInfos.pushPathByName('EmptyConversationList', {} as LooseObject);

      mConversationCtrl.pageNeedChange();

      expect(mConversationCtrl.pageInfos.getParamByName('EmptyConversationList').length).assertEqual(0);
    })

    it('ConversationControllerTest_pageNeedChange_bp_isBackToIndex_false', 0, () => {
      AppStorage.setOrCreate('curBp', 'bp');
      InfoMsgController.getInstance().total = 1;
      mConversationCtrl.isBackToIndex = false;
      mConversationCtrl.pageInfos = new NavPathStack();
      mConversationCtrl.pageInfos.pushPathByName('EmptyConversationList', {} as LooseObject);

      mConversationCtrl.pageNeedChange();

      expect(JSON.stringify(mConversationCtrl.pageInfos.getParamByName('EmptyConversationList'))).assertEqual('[]');
    })

    it('ConversationControllerTest_deleteMessageByGroupIds_groupInfos_notUndefined_groupIdMmsLength_2_groupIdRcsLength_2_isReSend_true',
      0, () => {
        let groupInfos: Array<groupIdsInfos> = [{
          groupId: 0,
          isRcs: 1,
          msgId: '',
          rcsId: 0
        }, {
          groupId: 0,
          isRcs: 1,
          msgId: '',
          rcsId: 0
        }, {
          groupId: 0,
          isRcs: 0,
          msgId: '',
          rcsId: 0
        }];
        let res = false;
        when(mocker.mockFunc(ConversationService.getInstance(),
          ConversationService.getInstance().deleteSmsMmsInfoByCondition))(ArgumentMatchers.any)
          .afterAction(() => {
            res = true;
          });

        expect(res).assertFalse();
        mocker.clear(ConversationService.getInstance());
      })

    it('ConversationControllerTest_deleteMessageByGroupIds_groupInfos_notUndefined_groupIdMmsLength_1_groupIdRcsLength_1_isReSend_false',
      0, () => {
        let groupInfos: Array<groupIdsInfos> = [{
          groupId: 0,
          isRcs: 1,
          msgId: '',
          rcsId: 0
        }];
        let res = false;
        when(mocker.mockFunc(ConversationService.getInstance(),
          ConversationService.getInstance().deleteSmsMmsInfoByCondition))(ArgumentMatchers.any)
          .afterAction(() => {
            res = true;
          });

        expect(res).assertFalse();
        mocker.clear(ConversationService.getInstance());
      })

    it('ConversationControllerTest_deleteMessageByGroupIds_groupInfos_undefined_groupIdsLength_1',
      0, () => {
        let res = false;
        when(mocker.mockFunc(ConversationService.getInstance(),
          ConversationService.getInstance().deleteSmsMmsInfoByCondition))(ArgumentMatchers.any)
          .afterAction(() => {
            res = true;
          });

        expect(res).assertFalse();
        mocker.clear(ConversationService.getInstance());
      })

    it('ConversationControllerTest_deleteMessageByGroupIds_groupInfos_undefined_groupIdsLength_0',
      0, () => {
        let res = false;
        when(mocker.mockFunc(ConversationService.getInstance(),
          ConversationService.getInstance().deleteSmsMmsInfoByCondition))(ArgumentMatchers.any)
          .afterAction(() => {
            res = true;
          });

        expect(res).assertFalse();
        mocker.clear(ConversationService.getInstance());
      })

    it('ConversationControllerTest_updateLastItemContent', 0, () => {
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().updateLastItemContent))(ArgumentMatchers.any)
        .afterReturnNothing();

      mConversationCtrl.updateLastItemContent(context);

      expect(mConversationCtrl).not().assertUndefined();
      mocker.clear(ConversationListService);
    })

    it('ConversationControllerTest_deleteMessageById', 0, () => {
      let res = false;
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().deleteMessageById))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      mConversationCtrl.deleteMessageById(context, 1);
      mConversationCtrl.deleteMessageById(context, 1, ()=>{});

      expect(res).assertTrue();
      mocker.clear(ConversationListService.getInstance());
    })

    it('ConversationControllerTest_clickGroupDelete_selectDeleteMsgCount_0', 0, () => {
      mConversationCtrl.strMsgDeleteDialogTip = undefined;

      mConversationCtrl.clickGroupDelete(0);

      expect(mConversationCtrl.strMsgDeleteDialogTip).assertUndefined();
    })

    it('ConversationControllerTest_clickGroupDelete_selectDeleteMsgCount_1', 0, () => {
      mConversationCtrl.strMsgDeleteDialogTip = undefined;

      mConversationCtrl.clickGroupDelete(1);

      expect(JSON.stringify(mConversationCtrl.strMsgDeleteDialogTip))
        .assertEqual(JSON.stringify($r('app.string.msg_delete_dialog_con_tip1')));
    })

    it('ConversationControllerTest_clickGroupDelete_selectDeleteMsgCount_2', 0, () => {
      mConversationCtrl.strMsgDeleteDialogTip = undefined;
      mConversationCtrl.mmsList = [new mmsListType(), new mmsListType()];

      mConversationCtrl.clickGroupDelete(2);

      expect(JSON.stringify(mConversationCtrl.strMsgDeleteDialogTip))
        .assertEqual(JSON.stringify($r('app.string.msg_delete_dialog_con_tip3')));
    })

    it('ConversationControllerTest_clickGroupDelete_selectDeleteMsgCount_3', 0, () => {
      mConversationCtrl.strMsgDeleteDialogTip = undefined;
      mConversationCtrl.mmsList = [new mmsListType(), new mmsListType()];

      mConversationCtrl.clickGroupDelete(3);

      expect(JSON.stringify(mConversationCtrl.strMsgDeleteDialogTip))
        .assertEqual(JSON.stringify($r('app.plural.msg_delete_dialog_con_tip2', 3, 3)));
    })

    it('ConversationControllerTest_onContactDataChangeObserver_strContactsNumber_empty', 0, () => {
      mConversationCtrl.strContactsNumber = '';
      mConversationCtrl.rawContactId = '';

      mConversationCtrl.onContactDataChangeObserver(context);

      expect(mConversationCtrl.rawContactId).assertEqual('');
    })

    it('ConversationControllerTest_onContactDataChangeObserver_strContactsNumber_notEmpty', 0, () => {
      mConversationCtrl.strContactsNumber = '1111,2222';
      mConversationCtrl.rawContactId = '';
      let res = false;

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            res = true;
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                receiverNumber: '',
                senderNumber: ''
              }] as LooseObject[]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.photoFirstNameDeal))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertTrue();
        });

      mConversationCtrl.onContactDataChangeObserver(context);
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_onContactDataChangeObserver_strContactsNumber_notEmpty_fail', 0, () => {
      mConversationCtrl.strContactsNumber = '1111,2222';
      mConversationCtrl.rawContactId = '';
      let res = false;

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            res = true;
            callBack ? callBack({
              code: -1,
              abilityResult: [] as LooseObject[]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.photoFirstNameDeal);

      mConversationCtrl.onContactDataChangeObserver(context);

      mocker.verify('photoFirstNameDeal', ['']).never();
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_querySmsMmsInfoSlotIdByCondition', 0, () => {
      mConversationCtrl.strContactsNumber = '1111,2222';

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
              abilityResult: [] as LooseObject[]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.photoFirstNameDeal);

      mConversationCtrl.querySmsMmsInfoSlotIdByCondition(context, (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      });
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_reReceivedRcsSmsSetTimeOut', 0, () => {
      mConversationCtrl.reReceivedRcsSmsSetTimeOut(context, [1]);
      expect(mConversationCtrl.isMessageCheckAll).assertFalse();
    })

    it('ConversationControllerTest_queryMessageDetail_queryTerminate_notHas', 0, async () => {
      let queryInfoObj: IQueryMessageDetailInfo = {
        isDraft: false,
        currentPage: 0,
        threadId: 0,
        contactsNum: 0,
        isDownloadQuery: false,
        resultTotal: 0,
        lastListSize: 0,
        queryTimeID: 0,
        startIndex: 0
      };

      mConversationCtrl.queryTerminate.set(0, 1);
      mConversationCtrl.vCardJumpBack = true;

      await mConversationCtrl.queryMessageDetail(context, queryInfoObj, () => {
      });

      expect(mConversationCtrl.vCardJumpBack).assertFalse();
    })

    it('ConversationControllerTest_queryMessageDetail_queryTerminate_has_vCardJumpBack_true', 0, async () => {
      let queryInfoObj: IQueryMessageDetailInfo = {
        isDraft: false,
        currentPage: 0,
        threadId: 0,
        contactsNum: 0,
        isDownloadQuery: false,
        resultTotal: 0,
        lastListSize: 0,
        queryTimeID: 0,
        startIndex: 0
      };

      mConversationCtrl.queryTerminate.set(0, 0);
      mConversationCtrl.vCardJumpBack = true;

      await mConversationCtrl.queryMessageDetail(context, queryInfoObj, () => {
      });

      expect(mConversationCtrl.vCardJumpBack).assertFalse();
    })

    it('ConversationControllerTest_queryMessageDetail_queryTerminate_has_vCardJumpBack_false_isDraft_false_fail', 0,
      async () => {
        let queryInfoObj: IQueryMessageDetailInfo = {
          isDraft: false,
          currentPage: 0,
          threadId: 0,
          contactsNum: 0,
          isDownloadQuery: false,
          resultTotal: 0,
          lastListSize: 0,
          queryTimeID: 0,
          startIndex: 0
        };

        mConversationCtrl.queryTerminate.set(0, 0);
        mConversationCtrl.vCardJumpBack = false;

        mocker.mockFunc(ConversationService.getInstance(),
          ConversationService.getInstance().queryAllInfoSizeByCondition);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
        when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
          .afterReturn({
            sendRequest: (request: string, requestData?: Object | undefined,
              callBack?: ((result: Object) => void) | undefined): Promise<void> => {
              callBack ? callBack({
                code: -1
              } as LooseObject) : '';
              return new Promise<void>(resolve => resolve())
            }
          } as Object | window.WindowStage);

        mocker.mockFunc(mConversationCtrl, mConversationCtrl.queryMessageDetailWithoutPreFillItem);

        await mConversationCtrl.queryMessageDetail(context, queryInfoObj, () => {
          expect(mConversationCtrl.vCardJumpBack).assertFalse();
        });
        mocker.clear(ConversationService.getInstance());
        mocker.clear(mConversationCtrl);
        mocker.clear(GlobalContext.getContext());
      })

    it('ConversationControllerTest_queryMessageDetail_queryTerminate_has_vCardJumpBack_false_isDraft_false_success', 0,
      async () => {
        let queryInfoObj: IQueryMessageDetailInfo = {
          isDraft: false,
          currentPage: 0,
          threadId: 0,
          contactsNum: 0,
          isDownloadQuery: false,
          resultTotal: 0,
          lastListSize: 2,
          queryTimeID: 0,
          startIndex: 0
        };

        mConversationCtrl.queryTerminate.set(0, 0);
        mConversationCtrl.vCardJumpBack = false;

        mocker.mockFunc(ConversationService.getInstance(),
          ConversationService.getInstance().queryAllInfoSizeByCondition);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
        when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
          .afterReturn({
            sendRequest: (request: string, requestData?: Object | undefined,
              callBack?: ((result: Object) => void) | undefined): Promise<void> => {
              callBack ? callBack({
                code: 0
              } as LooseObject) : '';
              return new Promise<void>(resolve => resolve())
            }
          } as Object | window.WindowStage);

        mocker.mockFunc(mConversationCtrl, mConversationCtrl.queryMessageDetailWithoutPreFillItem);

        await mConversationCtrl.queryMessageDetail(context, queryInfoObj, () => {
          expect(mConversationCtrl.vCardJumpBack).assertFalse();
        });
        mocker.clear(ConversationService.getInstance());
        mocker.clear(mConversationCtrl);
        mocker.clear(GlobalContext.getContext());
      })

    it('ConversationControllerTest_queryMessageDetailAllInner_success_curBp_sm', 0, () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let queryInfoObj: IQueryMessageDetailInfo = {
        isDraft: true,
        currentPage: 1,
        threadId: 0,
        contactsNum: 0,
        isDownloadQuery: false,
        resultTotal: 10,
        lastListSize: 1,
        queryTimeID: 0,
        startIndex: 0
      };
      mConversationCtrl.mmsList = [{
        dateShow: true,
        timeMillisecond: 0,
        showTitle: true,
        isRcs: 0,
      } as mmsListType, {
        dateShow: true,
        timeMillisecond: 0,
        showTitle: true,
        isRcs: 0,
      } as mmsListType];
      mConversationCtrl.threadId = 0;
      AppStorage.setOrCreate('curBp', 'sm');
      let queryActionData: IQueryMessageDetailAll = {
        threadId: queryInfoObj.threadId,
        page: queryInfoObj.currentPage,
        contactsNum: queryInfoObj.contactsNum,
        actionDataName: ''
      };

      mConversationCtrl.queryTerminate.set(0, 0);
      mConversationCtrl.vCardJumpBack = false;

      mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().queryAllInfoSizeByCondition);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDraft);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                rcsId: '',
                isRcs: 0,
                smsType: '1',
                msgId: 1,
                ct: 'image',
                msgContent: '',
                isReceive: true,
                mmsList: [{
                  ct: 'image'
                }]
              } as LooseObject],
              response: [{
                timeMillisecond: 0,
              } as mmsListType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          },
          resourceManager: {
            getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      mocker.mockFunc(mConversationCtrl.scroller.scrollEdge, mConversationCtrl.scroller.scrollEdge);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.queryMessageDetail);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.convertDateFormatForItem);
      when(mocker.mockFunc(DateUtil, DateUtil.isNotSameDay))(ArgumentMatchers.any).afterReturn(true);

      mConversationCtrl.queryMessageDetailWithoutPreFillItem(context, queryInfoObj, queryActionData, () => {
        mocker.verify('deleteDraftData', []).never();
      });

      expect(mConversationCtrl.vCardJumpBack).assertFalse();
      mocker.clear(DateUtil);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(ConversationService.getInstance());
      mocker.clear(mConversationCtrl);
      mocker.clear(mConversationCtrl.scroller.scrollEdge);
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_queryMessageDetailAllInner_success_resultTotal_equal_mmsListLength', 0, () => {
      let queryInfoObj: IQueryMessageDetailInfo = {
        isDraft: true,
        currentPage: 0,
        threadId: 0,
        contactsNum: 0,
        isDownloadQuery: false,
        resultTotal: 10,
        lastListSize: 1,
        queryTimeID: 0,
        startIndex: 0
      };
      mConversationCtrl.mmsList = [{
        dateShow: true,
        timeMillisecond: 0,
        showTitle: true,
        isRcs: 0,
      } as mmsListType, {
        dateShow: true,
        timeMillisecond: 0,
        showTitle: true,
        isRcs: 0,
      } as mmsListType];
      let queryActionData: IQueryMessageDetailAll = {
        threadId: queryInfoObj.threadId,
        page: queryInfoObj.currentPage,
        contactsNum: queryInfoObj.contactsNum,
        actionDataName: ''
      };

      mConversationCtrl.queryTerminate.set(0, 0);
      mConversationCtrl.vCardJumpBack = false;

      mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().queryAllInfoSizeByCondition);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDraft);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                rcsId: '',
                msgId: 'msgId',
                isRcs: 0,
                smsType: '1',
                ct: 'audio',
                mmsList: [{
                  ct: 'audio'
                }]
              } as LooseObject],
              response: [{
                timeMillisecond: 0,
              } as mmsListType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          },
          resourceManager: {
            getStringSync:(resId: number): string => 'xx：'
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      mocker.mockFunc(mConversationCtrl.scroller.scrollEdge, mConversationCtrl.scroller.scrollEdge);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.queryMessageDetail);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.convertDateFormatForItem);
      when(mocker.mockFunc(DateUtil, DateUtil.isNotSameDay))(ArgumentMatchers.any).afterReturn(true);

      mConversationCtrl.queryMessageDetailWithoutPreFillItem(context, queryInfoObj, queryActionData, () => {
        mocker.verify('deleteDraftData', []).never();
      });

      expect(mConversationCtrl.vCardJumpBack).assertFalse();
      mocker.clear(DateUtil);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(ConversationService.getInstance());
      mocker.clear(mConversationCtrl);
      mocker.clear(mConversationCtrl.scroller.scrollEdge);
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_queryMessageDetailAllInner_success_mmsList_length_0', 0, () => {
      let queryInfoObj: IQueryMessageDetailInfo = {
        isDraft: true,
        currentPage: 1,
        threadId: 0,
        contactsNum: 0,
        isDownloadQuery: false,
        resultTotal: 1,
        lastListSize: 1,
        queryTimeID: 0,
        startIndex: 0
      };
      mConversationCtrl.mmsList = [];
      let queryActionData: IQueryMessageDetailAll = {
        threadId: queryInfoObj.threadId,
        page: queryInfoObj.currentPage,
        contactsNum: queryInfoObj.contactsNum,
        actionDataName: ''
      };

      mConversationCtrl.queryTerminate.set(0, 0);
      mConversationCtrl.vCardJumpBack = false;

      mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().queryAllInfoSizeByCondition);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDraft);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                rcsId: '',
                msgId: 'msgId',
                isRcs: 0,
                smsType: '1',
                ct: 'audio',
                mmsList: [{
                  ct: 'audio'
                }]
              } as LooseObject],
              response: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          },
          resourceManager: {
            getStringSync:(resId: number): string => 'xx：'
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      mocker.mockFunc(mConversationCtrl.scroller.scrollEdge, mConversationCtrl.scroller.scrollEdge);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.queryMessageDetail);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.convertDateFormatForItem);
      when(mocker.mockFunc(DateUtil, DateUtil.isNotSameDay))(ArgumentMatchers.any).afterReturn(true);

      mConversationCtrl.queryMessageDetailWithoutPreFillItem(context, queryInfoObj, queryActionData, () => {
        mocker.verify('deleteDraftData', []).never();
      });

      expect(mConversationCtrl.vCardJumpBack).assertFalse();
      mocker.clear(DateUtil);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(ConversationService.getInstance());
      mocker.clear(mConversationCtrl);
      mocker.clear(mConversationCtrl.scroller.scrollEdge);
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_queryMessageDetailAllInner_success', 0, () => {
      let queryInfoObj: IQueryMessageDetailInfo = {
        isDraft: true,
        currentPage: 0,
        threadId: 0,
        contactsNum: 0,
        isDownloadQuery: false,
        resultTotal: 1,
        lastListSize: 1,
        queryTimeID: 0,
        startIndex: 0
      };
      let mmsList: mmsListType = new mmsListType();
      mmsList.isRcs = 0;
      mmsList.timeMillisecond = 0;
      mmsList.dateShow = true;
      mmsList.showTitle = true;
      let mmsList1: mmsListType = new mmsListType();
      mmsList1.isRcs = 0;
      mmsList1.timeMillisecond = 1;
      mmsList1.dateShow = true;
      mmsList1.showTitle = true;
      mConversationCtrl.mmsList = [mmsList, mmsList1];
      let queryActionData: IQueryMessageDetailAll = {
        threadId: queryInfoObj.threadId,
        page: queryInfoObj.currentPage,
        contactsNum: queryInfoObj.contactsNum,
        actionDataName: ''
      };

      mConversationCtrl.queryTerminate.set(0, 0);
      mConversationCtrl.vCardJumpBack = false;

      mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().queryAllInfoSizeByCondition);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDraft);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                rcsId: '',
                msgId: 'msgId',
                isRcs: 0,
                smsType: '1',
                ct: 'audio',
                mmsList: [{
                  ct: 'audio'
                }]
              } as LooseObject],
              response: [{
                timeMillisecond: 0,
              } as mmsListType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          },
          resourceManager: {
            getStringSync:(resId: number): string => 'xx：'
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      mocker.mockFunc(mConversationCtrl.scroller.scrollEdge, mConversationCtrl.scroller.scrollEdge);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.queryMessageDetail);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.convertDateFormatForItem);
      when(mocker.mockFunc(DateUtil, DateUtil.isNotSameDay))(ArgumentMatchers.any).afterReturn(true);

      mConversationCtrl.queryMessageDetailWithoutPreFillItem(context, queryInfoObj, queryActionData, () => {
        mocker.verify('deleteDraftData', []).never();
      });

      expect(mConversationCtrl.vCardJumpBack).assertFalse();
      mocker.clear(DateUtil);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(ConversationService.getInstance());
      mocker.clear(mConversationCtrl);
      mocker.clear(mConversationCtrl.scroller.scrollEdge);
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_queryMessageDetailAllInner_fail', 0, () => {
      let queryInfoObj: IQueryMessageDetailInfo = {
        isDraft: false,
        currentPage: 2,
        threadId: 0,
        contactsNum: 0,
        isDownloadQuery: false,
        resultTotal: 10,
        lastListSize: 1,
        queryTimeID: 0,
        startIndex: 0
      };
      let queryActionData: IQueryMessageDetailAll = {
        threadId: queryInfoObj.threadId,
        page: queryInfoObj.currentPage,
        contactsNum: queryInfoObj.contactsNum,
        actionDataName: ''
      };

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDraft);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | window.WindowStage);

      mConversationCtrl.queryMessageDetailWithoutPreFillItem(context, queryInfoObj, queryActionData, () => {
        mocker.verify('deleteDraftData', []).never();
      });
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_deleteDraftData', 0, () => {
      mConversationCtrl.isDraft = true;
      mConversationCtrl.draftGroupId = 1;

      mConversationCtrl.deleteDraftData(context);

      expect(mConversationCtrl.draftGroupId).assertEqual(0);
    })

    it('ConversationControllerTest_deleteDraftData_if', 0, () => {
      mConversationCtrl.isDraft = false;
      mConversationCtrl.draftGroupId = 1;

      mConversationCtrl.deleteDraftData(context);

      expect(mConversationCtrl.draftGroupId).assertEqual(1);
    })

    it('ConversationControllerTest_dealDraftData_isMsm_true_setMMsFlag_true', 0, () => {
      let item: mmsListType = new mmsListType();
      item.content = '';
      item.groupId = 1;
      item.isMsm = true;
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.setMMsFlag = true;

      mConversationCtrl.dealDraftData(context, item);

      expect(mConversationCtrl.isEditMms).assertTrue();
    })

    it('ConversationControllerTest_dealDraftData_isMsm_false', 0, () => {
      let item: mmsListType = new mmsListType();
      item.content = '';
      item.groupId = 1;
      item.isMsm = false;
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.setMMsFlag = true;

      mConversationCtrl.dealDraftData(context, item);

      expect(mConversationCtrl.isEditMms).assertFalse();
    })

    it('ConversationControllerTest_setDraft_isDraft_true_draftContent_empty', 0, () => {
      mConversationCtrl.isDraft = true;
      mConversationCtrl.draftContent = '';
      mConversationCtrl.textValue = '';

      mConversationCtrl.setDraft();

      expect(mConversationCtrl.textValue).assertEqual('');
    })

    it('ConversationControllerTest_setDraft_isDraft_true_textValue_empty', 0, () => {
      mConversationCtrl.isDraft = true;
      mConversationCtrl.draftContent = 'xx';
      mConversationCtrl.textValue = '';
      mocker.mockFunc(MmsPreferences.getInstance(),MmsPreferences.getInstance().haveSimCardReady);

      mConversationCtrl.setDraft();

      expect(mConversationCtrl.textValue).assertEqual('xx');
      mocker.clear(MmsPreferences.getInstance());
    })

    it('ConversationControllerTest_updateDetail_isRcs_1_deliveryReportSwitch_3_contactName_empty_isRcs_minus1', 0,
      () => {
        let sendResult: Record<string, string | number | string[]> = {
          'isRcs': 1,
          'sendStatus': 0,
          'contactName': '',
          'telephone': '111111',
        };
        let mmsList: mmsListType = new mmsListType();
        mmsList.isRcs = -1;
        mmsList.timeMillisecond = 0;
        mConversationCtrl.mmsList = [mmsList, mmsList];
        mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().updateSessionAndDetail);
        when(mocker.mockFunc(MmsPreferences.getInstance(),
          MmsPreferences.getInstance().getValueOfDeliveryReportSwitch))()
          .afterReturn('3');
        when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNum))(ArgumentMatchers.any)
          .afterReturn('');
        when(mocker.mockFunc(GlobalContext.getContext(),
          GlobalContext.getContext().getObject))('mmsContext')
          .afterReturn({
            resourceManager: {
              getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'xx'
            } as resourceManager.ResourceManager
          } as Object | window.WindowStage);
        let res = false;
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast))(ArgumentMatchers.any)
          .afterAction(() => {
            res = true;
          });
        when(mocker.mockFunc(ConversationDataSource.getInstance(),
          ConversationDataSource.getInstance().refresh))(ArgumentMatchers.any)
          .afterAction(() => {
            expect(res).assertTrue();
          });

        mConversationCtrl.updateDetail(context, 0, sendResult, 0, '0', false);
        mocker.clear(MmsPreferences.getInstance());
        mocker.clear(ConversationService.getInstance());
        mocker.clear(GlobalContext.getContext());
        mocker.clear(mConversationCtrl);
        mocker.clear(TelephoneUtil);
        mocker.clear(ConversationDataSource.getInstance());
      })

    it('ConversationControllerTest_updateDetail_isRcs_0_deliveryReportSwitch_1_contactName_empty_isRcs_0', 0,
      () => {
        let sendResult: Record<string, string | number | string[]> = {
          'isRcs': 0,
          'sendStatus': 0,
          'contactName': 'xx',
          'telephone': '111111',
        };
        let mmsList: mmsListType = new mmsListType();
        mmsList.isRcs = 0;
        mmsList.timeMillisecond = 0;
        mConversationCtrl.mmsList = [mmsList, mmsList];
        mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().updateSessionAndDetail);
        when(mocker.mockFunc(MmsPreferences.getInstance(),
          MmsPreferences.getInstance().getValueOfDeliveryReportSwitch))()
          .afterReturn('1');
        when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNum))(ArgumentMatchers.any)
          .afterReturn('');
        when(mocker.mockFunc(GlobalContext.getContext(),
          GlobalContext.getContext().getObject))('mmsContext')
          .afterReturn({
            resourceManager: {
              getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'xx'
            } as resourceManager.ResourceManager
          } as Object | window.WindowStage);
        let res = false;
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast))(ArgumentMatchers.any)
          .afterAction(() => {
            res = true;
          });
        when(mocker.mockFunc(ConversationDataSource.getInstance(),
          ConversationDataSource.getInstance().refresh))(ArgumentMatchers.any)
          .afterAction(() => {
            expect(res).assertTrue();
          });

        mConversationCtrl.updateDetail(context, 0, sendResult, 0, '0', false);
        mocker.clear(MmsPreferences.getInstance());
        mocker.clear(ConversationService.getInstance());
        mocker.clear(GlobalContext.getContext());
        mocker.clear(mConversationCtrl);
        mocker.clear(TelephoneUtil);
        mocker.clear(ConversationDataSource.getInstance());
      })

    it('ConversationControllerTest_updateDetail_isRcs_0_deliveryReportSwitch_1_contactName_xxx_isRcs_0', 0,
      () => {
        let sendResult: Record<string, string | number | string[]> = {
          'isRcs': 0,
          'sendStatus': 0,
          'contactName': 'xxx',
          'telephone': '111111',
        };
        let mmsList: mmsListType = new mmsListType();
        mmsList.isRcs = 0;
        mmsList.timeMillisecond = 0;
        mConversationCtrl.mmsList = [mmsList, mmsList];
        mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().updateSessionAndDetail);
        when(mocker.mockFunc(MmsPreferences.getInstance(),
          MmsPreferences.getInstance().getValueOfDeliveryReportSwitch))()
          .afterReturn('0');
        when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNum))(ArgumentMatchers.any)
          .afterReturn('');
        when(mocker.mockFunc(GlobalContext.getContext(),
          GlobalContext.getContext().getObject))('mmsContext')
          .afterReturn({
            resourceManager: {
              getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'xx'
            } as resourceManager.ResourceManager
          } as Object | window.WindowStage);
        let res = false;
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast))(ArgumentMatchers.any)
          .afterAction(() => {
            res = true;
          });
        when(mocker.mockFunc(ConversationDataSource.getInstance(),
          ConversationDataSource.getInstance().refresh))(ArgumentMatchers.any)
          .afterAction(() => {
            expect(res).assertFalse();
          });

        mConversationCtrl.updateDetail(context, 0, sendResult, 0, '0', false);
        mocker.clear(MmsPreferences.getInstance());
        mocker.clear(ConversationService.getInstance());
        mocker.clear(GlobalContext.getContext());
        mocker.clear(mConversationCtrl);
        mocker.clear(TelephoneUtil);
        mocker.clear(ConversationDataSource.getInstance());
      })

    it('ConversationControllerTest_setCanSendMsgStatus_receiveContactValue_empty', 0, () => {
      mConversationCtrl.canSendMessage = true;
      mConversationCtrl.receiveContactValue = '';
      mConversationCtrl.selectContacts = [];

      mConversationCtrl.setCanSendMsgStatus();

      expect(mConversationCtrl.canSendMessage).assertTrue();
    })

    it('ConversationControllerTest_setCanSendMsgStatus', 0, () => {
      mConversationCtrl.canSendMessage = true;
      mConversationCtrl.mmsEditList = [];
      mConversationCtrl.curEdtFileSize = 0;

      mConversationCtrl.setCanSendMsgStatus();

      expect(mConversationCtrl.curEdtFileSize).assertEqual(0);
    })

    it('ConversationControllerTest_getCurEdtFileSize_isEditMms_false', 0, () => {
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.curEdtFileSize = 0;
      mConversationCtrl.mmsEditList = [];

      mConversationCtrl.getCurEdtFileSize();

      expect(mConversationCtrl.curEdtFileSize).assertEqual(0);
    })

    it('ConversationControllerTest_getCurEdtFileSize_isEditMms_true', 0, () => {
      mConversationCtrl.isEditMms = true;
      mConversationCtrl.curEdtFileSize = 0;
      mConversationCtrl.mmsEditList = [{
        fileSize: 0
      } as MmsSourceType];

      mConversationCtrl.getCurEdtFileSize();

      expect(mConversationCtrl.curEdtFileSize).assertEqual(0);
    })

    it('ConversationControllerTest_dealSmsSendResult_isRcs_1_isReSend_true_resendStateIsRcs_true', 0, () => {
      let params: LooseObject = {
        isReSend: true,
        resendStateIsRcs: true,
        destinationHost: '',
        rcsMsgType: 0,
        content: '',
        slotId: 0,
        id: 0
      };
      let item: mmsListType = new mmsListType();
      item.isRcs = 1;
      item.position = '';
      item.timeMillisecond = 0;
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.updateUI))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertTrue();
        });

      mConversationCtrl.dealSmsSendResult(context, params, item, {}, 0, () => {
        mocker.clear(mConversationCtrl);
      });
    })

    it('ConversationControllerTest_dealSmsSendResult_isRcs_1_isReSend_true_resendStateIsRcs_false', 0, () => {
      let params: LooseObject = {
        isReSend: true,
        resendStateIsRcs: false,
        destinationHost: '',
        rcsMsgType: 0,
        content: '',
        slotId: 0,
        id: 0
      };
      let item: mmsListType = new mmsListType();
      item.isRcs = 1;
      item.position = '';
      item.timeMillisecond = 0;
      let res = false;

      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('deliveryReportSwitch')
        .afterAction(() => {
          res = true;
          throw new Error('error');
        });
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportFaultEvent);

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.updateUI))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertTrue();
          mocker.clear(SharedPreferencesUtils);
        });

      mConversationCtrl.dealSmsSendResult(context, params, item, {}, 0, () => {
      });
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(mConversationCtrl);
      mocker.clear(DotUtil.getInstance());
    })

    it('ConversationControllerTest_dealSmsSendResult_isRcs_1_isReSend_false_resendStateIsRcs_false', 0, () => {
      let params: LooseObject = {
        isReSend: false,
        resendStateIsRcs: false,
        destinationHost: '',
        rcsMsgType: 0,
        content: '',
        slotId: 0,
        id: 0
      };
      let item: mmsListType = new mmsListType();
      item.isRcs = 1;
      item.position = '';
      item.timeMillisecond = 0;
      let res = false;

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.updateUI))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertTrue();
        });

      mConversationCtrl.dealSmsSendResult(context, params, item, {}, 0, () => {
      });
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_dealSmsSendResult_isRcs_0_resendStateIsRcs_true', 0, () => {
      let params: LooseObject = {
        isReSend: false,
        resendStateIsRcs: true,
        destinationHost: '',
        rcsMsgType: 0,
        content: '',
        slotId: 0,
        id: 0
      };
      let item: mmsListType = new mmsListType();
      item.isRcs = 0;
      item.position = '';
      item.timeMillisecond = 0;
      let res = false;

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.updateUI))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertTrue();
        });

      mConversationCtrl.dealSmsSendResult(context, params, item, {}, 0, () => {
      });
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_dealSmsSendResult_isRcs_0_resendStateIsRcs_false_callback_undefined', 0, () => {
      let params: LooseObject = {
        isReSend: false,
        resendStateIsRcs: false,
        destinationHost: '',
        rcsMsgType: 0,
        content: '',
        slotId: 0,
        id: 0
      };
      let item: mmsListType = new mmsListType();
      item.isRcs = 0;
      item.position = '';
      item.timeMillisecond = 0;
      let res = false;

      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('deliveryReportSwitch')
        .afterAction(() => {
          res = true;
          throw new Error('error');
        });
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportFaultEvent);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.updateUI))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertTrue();
        });

      mConversationCtrl.dealSmsSendResult(context, params, item, {}, 0);
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_dealSmsSendResult_isRcs_0_resendStateIsRcs_false_callback_notUndefined', 0, () => {
      let params: LooseObject = {
        isReSend: false,
        resendStateIsRcs: false,
        destinationHost: '',
        rcsMsgType: 0,
        content: '',
        slotId: 0,
        id: 0
      };
      let item: mmsListType = new mmsListType();
      item.isRcs = 0;
      item.position = '';
      item.timeMillisecond = 0;
      let res = false;

      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('deliveryReportSwitch')
        .afterAction(() => {
          res = true;
          throw new Error('error');
        });
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportFaultEvent);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.updateUI);

      mConversationCtrl.dealSmsSendResult(context, params, item, {}, 0, () => {
        expect(res).assertTrue();
      });
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_dealSmsSendResult_catch', 0, () => {
      let params: LooseObject = {
        isReSend: true,
        resendStateIsRcs: true,
        destinationHost: '',
        rcsMsgType: 0,
        content: '',
        slotId: 0,
        id: 0
      };
      let item: mmsListType = new mmsListType();
      item.isRcs = 0;
      item.position = '';
      item.timeMillisecond = 0;
      let res = false;

      mConversationCtrl.dealSmsSendResult(context, params, item, {}, 0, () => {
      });
      expect(res).assertTrue();
    })

    it('ConversationControllerTest_updateUi_sendStatus_2_contactsNum_1_sendNumbersLength_1_completeNumber_1_failuresNumber_0',
      0, () => {
        mConversationCtrl.contactsNum = 1;
        let item: mmsListType = new mmsListType();
        item.failuresNumber = 1;
        item.success = 1;
        item.completeNumber = 2;
        item.isRcs = 1;

        mocker.mockFunc(mConversationCtrl, mConversationCtrl.addProgressSize);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetItem);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.refreshDetail);

        mConversationCtrl.updateUI(context, 2, 1, item, {
          'sendStatus': 0, 'isRcs': 1
        }, '0', false);

        expect(mConversationCtrl.progressValue).assertEqual(0);
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_updateUi_sendStatus_0_contactsNum_0', 0, () => {
      mConversationCtrl.contactsNum = 10;
      let item: mmsListType = new mmsListType();
      item.failuresNumber = 0;
      item.success = 3;
      item.completeNumber = 2;
      item.isRcs = 1;

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.addProgressSize);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetItem);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.refreshDetail);

      mConversationCtrl.updateUI(context, 0, 2, item, {
        'sendStatus': 0, 'isRcs': 1
      }, '', true);

      expect(mConversationCtrl.progressValue).assertEqual(0);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_updateUi_sendStatus_9_contactsNum_0', 0, () => {
      mConversationCtrl.contactsNum = 0;
      let item: mmsListType = new mmsListType();
      item.failuresNumber = 0;
      item.success = 3;
      item.completeNumber = 2;
      item.isRcs = 1;

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.addProgressSize);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetItem);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.refreshDetail);

      mConversationCtrl.updateUI(context, 9, 2, item, {
        'sendStatus': 0, 'isRcs': 1
      }, '', true);

      expect(mConversationCtrl.progressValue).assertEqual(0);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_updateUi_sendStatus_9_contactsNum_0_sendNumbersLength_2_completeNumber_3', 0, () => {
      mConversationCtrl.contactsNum = 0;
      let item: mmsListType = new mmsListType();
      item.failuresNumber = 0;
      item.success = 3;
      item.completeNumber = 3;
      item.isRcs = 1;

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.addProgressSize);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetItem);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.refreshDetail);

      mConversationCtrl.updateUI(context, 9, 2, item, {
        'sendStatus': 0, 'isRcs': 1
      }, '', true);

      expect(mConversationCtrl.progressValue).assertEqual(0);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_addProgressSize', 0, () => {
      let item: mmsListType = new mmsListType();

      EnhancedInfoTemporaryDataSource.getInstance().mapImageMsgIdToData.set('0', {
        clurSize: 1,
        totalSize: 10,
        isExistInfoInRcsInfoWithMsgId: false
      } as ImageData)

      mConversationCtrl.addProgressSize(item, '0');

      expect(item.clurSize).assertEqual(1);
    })

    it('ConversationControllerTest_addProgressSize_clurSize_undefined', 0, () => {
      let item: mmsListType = new mmsListType();

      EnhancedInfoTemporaryDataSource.getInstance().mapImageMsgIdToData.set('0', {
        isExistInfoInRcsInfoWithMsgId: false
      } as ImageData)

      mConversationCtrl.addProgressSize(item, '0');

      expect(item.clurSize).assertEqual(0);
    })

    it('ConversationControllerTest_refreshDetail_getObject_undefined', 0, () => {
      let item: mmsListType = new mmsListType();
      let res = false;
      mConversationCtrl.currentQueryTimeID = 0;
      mConversationCtrl.queryTerminate.set(0, 0);

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.updateDetail);
      when(mocker.mockFunc(ConversationDataSource.getInstance(),
        ConversationDataSource.getInstance().refresh))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      mConversationCtrl.refreshDetail(context, item, {}, 0, '0', false);

      expect(res).assertFalse();
      mocker.clear(mConversationCtrl);
      mocker.clear(ConversationDataSource.getInstance());
    })

    it('ConversationControllerTest_refreshDetail_getObject', 0, () => {
      let item: mmsListType = new mmsListType();
      let res = false;
      mConversationCtrl.isDraft = false;
      mConversationCtrl.currentQueryTimeID = 0;
      mConversationCtrl.queryTerminate.set(0, 0);

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.updateDetail);
      when(mocker.mockFunc(ConversationDataSource.getInstance(),
        ConversationDataSource.getInstance().refresh))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('transmitFlag')
        .afterReturn({} as Object | window.WindowStage)
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
      mocker.mockFunc(mConversationCtrl.scroller, mConversationCtrl.scroller.scrollEdge);

      mConversationCtrl.refreshDetail(context, item, {}, 0, '0', false);

      expect(res).assertFalse();
      mocker.clear(mConversationCtrl);
      mocker.clear(mConversationCtrl.scroller);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(ConversationDataSource.getInstance());
    })

    it('ConversationControllerTest_resetItem', 0, () => {
      let item: mmsListType = new mmsListType();
      item.id = 1;
      item.isRcs = 1;

      let item1: mmsListType = new mmsListType();
      item1.id = 2;
      item.isRcs = 0;

      let item2: mmsListType = new mmsListType();
      item1.id = 1;
      item.isRcs = 0;

      mConversationCtrl.mmsList = [item, item1, item2];
      mConversationCtrl.resetItem(item);

      expect(mConversationCtrl.mmsList.length).assertEqual(3);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_resetItem_rcsId_1', 0, () => {
      let item: mmsListType = new mmsListType();
      item.id = 1;
      item.isRcs = 1;
      item.rcsId = 1;

      let item1: mmsListType = new mmsListType();
      item1.id = 2;
      item1.isRcs = 0;
      item1.rcsId = 1;
      mConversationCtrl.mmsList = [item1];
      mConversationCtrl.resetItem(item);

      expect(mConversationCtrl.mmsList.length).assertEqual(1);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_resetItem_id_1', 0, () => {
      let item: mmsListType = new mmsListType();
      item.id = 1;
      item.isRcs = 0;
      item.rcsId = 1;

      let item1: mmsListType = new mmsListType();
      item1.id = 1;
      item1.isRcs = 0;
      item1.rcsId = 1;
      mConversationCtrl.mmsList = [item1];

      mConversationCtrl.resetItem(item);

      expect(mConversationCtrl.mmsList.length).assertEqual(1);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_getSendMessageId_found', 0, () => {
      let initDatas: InitData[] = [{
        telephone: '1111',
        id: 1
      } as InitData];

      let res: number = mConversationCtrl.getSendMessageId(initDatas, '1111');

      expect(res).assertEqual(1);
    })

    it('ConversationControllerTest_getSendMessageId', 0, () => {
      let initDatas: InitData[] = [{
        telephone: '2222',
        id: 2
      } as InitData];

      let res: number = mConversationCtrl.getSendMessageId(initDatas, '1111');

      expect(res).assertEqual(-1);
    })

    it('ConversationControllerTest_convertingSms', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast);

      mConversationCtrl.convertingSms();

      expect(mConversationCtrl.isEditMms).assertFalse();
      mocker.clear(mConversationCtrl);
    })


    it('ConversationControllerTest_dealDraftData_isMsm_false_setMMsFlag_false', 0, () => {
      let item: mmsListType = new mmsListType();
      item.content = '';
      item.groupId = 1;
      item.isMsm = true;
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.setMMsFlag = false;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setMmsDataSource);

      mConversationCtrl.dealDraftData(context, item);

      expect(mConversationCtrl.isEditMms).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_selectStatusOnDeleteMsg_isSelectStatus_true', 0, () => {
      mConversationCtrl.isSelectStatus = true;
      let mmsList: mmsListType = new mmsListType();
      mmsList.msgItemIndex = 0;
      mmsList.isCbChecked = false;
      let mmsList1: mmsListType = new mmsListType();
      mmsList1.msgItemIndex = 0;
      mmsList1.isCbChecked = true;
      mConversationCtrl.mmsList = [mmsList, mmsList1];
      mConversationCtrl.mmsIndex = 2;
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().notifyDataReload);

      mConversationCtrl.selectStatusOnDeleteMsg([], [], 0);

      expect(mConversationCtrl).not().assertUndefined();
      mocker.clear(ConversationDataSource.getInstance());
    })
  })
}