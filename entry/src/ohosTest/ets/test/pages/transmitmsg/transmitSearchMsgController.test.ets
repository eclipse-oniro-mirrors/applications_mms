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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import { MySearch } from '../../../../../main/ets/pages/transmitmsg/transmitSearchMsg';
import TransmitSearchController from '../../../../../main/ets/pages/transmitmsg/transmitSearchMsgController';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import MySet from '../../MySet';
import SettingService from '../../../../../main/ets/service/SettingService';
import HiLog from '../../../../../main/ets/utils/HiLog';
import CommonService from '../../../../../main/ets/service/CommonService';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import { StartOptions, Want } from '@kit.AbilityKit';
import myCommon from '@ohos.app.ability.common';
import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import { ResponseType } from '../../../../../main/ets/service/ConversationListService';
import { DTGlobalContext } from '../../../testability/TestAbility';

export default function transmitSearchMsgControllerTest() {
  describe('transmitSearchMsgControllerTest', () => {

    let transmitSearchCtrl: TransmitSearchController;
    const TAG = 'TransmitSearchController';
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      transmitSearchCtrl = new TransmitSearchController();
    })

    it('TransmitSearchMsgController_getInstance', 0, () => {
      expect(typeof TransmitSearchController.getInstance()).assertEqual(typeof transmitSearchCtrl);
    })

    it('TransmitSearchMsgController_init_dialogMsg', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(transmitSearchCtrl, transmitSearchCtrl.queryPageMessages);
      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('TransmitSearchMsg', [{
        dialogMsg: 'message',
        transmitContentList: [],
        isRcs: false
      } as LooseObject]);
      when(mocker.mockFunc(transmitSearchCtrl.pageInfos,
        transmitSearchCtrl.pageInfos?.getParamByName))('TransmitSearchMsg')
        .afterReturn([{
          dialogMsg: 'message',
          transmitContentList: [],
          isRcs: false
        } as LooseObject])
      transmitSearchCtrl.init(pageInfos);
      mocker.verify('queryPageMessages', []).once();
      mocker.clear(transmitSearchCtrl);
    })

    it('TransmitSearchMsgController_init', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(transmitSearchCtrl, transmitSearchCtrl.queryPageMessages);
      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('TransmitSearchMsg', [{
        dialogMsg: undefined,
        transmitContentList: [],
        isRcs: false
      } as LooseObject]);
      transmitSearchCtrl.init(pageInfos);
      mocker.verify('queryPageMessages', []).once();
      mocker.clear(transmitSearchCtrl);
    })

    it('TransmitSearchMsgController_back', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('TransmitSearchMsg', [{
        dialogMsg: undefined,
        transmitContentList: [],
        isRcs: false
      } as LooseObject]);
      transmitSearchCtrl.pageInfos = pageInfos;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(transmitSearchCtrl, transmitSearchCtrl.refresh);
      expect(transmitSearchCtrl.back()).assertTrue();
      mocker.clear(transmitSearchCtrl);
    })

    it('TransmitSearchMsgController_queryPageMessages', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(SettingService, SettingService.getSettingFlagForConvListPage))()
        .afterReturn({
          'hasAggregate': true,
          'isShowContactHeadIcon': true
        } as Record<string, boolean>);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper);
      mocker.mockFunc(transmitSearchCtrl, transmitSearchCtrl.refresh);
      transmitSearchCtrl.queryPageMessages();
      expect(transmitSearchCtrl.messageList.length).assertEqual(0);
      mocker.clear(SettingService);
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(transmitSearchCtrl);
    })

    it('TransmitSearchMsgController_search_inputText_empty', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(transmitSearchCtrl, transmitSearchCtrl.refresh);
      let value: string = '';
      transmitSearchCtrl.search(context, value);
      expect(transmitSearchCtrl.searchCount).assertEqual(0);
    })

    it('TransmitSearchMsgController_search', 0, () => {
      let mySet: MySet = new MySet();
      mySet.rowCount = 1;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(transmitSearchCtrl.transmitSearchListDataSource,
        transmitSearchCtrl.transmitSearchListDataSource.refresh);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper);
      let value: string = 'xx';
      transmitSearchCtrl.search(context, value);
      expect(transmitSearchCtrl.searchCount).assertEqual(0);
      mocker.clear(transmitSearchCtrl.transmitSearchListDataSource);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('TransmitSearchMsgController_dealSearchList_1', 0, () => {
      let list: Array<LooseObject> = [];
      let item1: LooseObject = {
        detailInfo: ''
      };
      list.push(item1);
      transmitSearchCtrl.dealSearchList(list);
      expect(transmitSearchCtrl.searchList.length).assertEqual(0);
    })

    it('TransmitSearchMsgController_dealSearchList_2', 0, () => {
      let list: Array<LooseObject> = []
      let item1: LooseObject = {
        detailInfo: 'hello',
        id: '',
        displayName: ''
      }
      list.push(item1);
      transmitSearchCtrl.dealSearchList(list);
      expect(transmitSearchCtrl.searchList[0].firstName).assertEqual('');
    })

    it('TransmitSearchMsgController_dealSearchList_3', 0, () => {
      let list: Array<LooseObject> = [];
      let item1: LooseObject = {
        detailInfo: 'hello',
        id: 'id1',
        displayName: 'hello'
      };
      list.push(item1);
      transmitSearchCtrl.dealSearchList(list);
      expect(transmitSearchCtrl.searchList[0].firstName).assertEqual('H');
    })

    it('TransmitSearchMsgController_refresh', 0, () => {
      transmitSearchCtrl.refresh();
      expect(transmitSearchCtrl.searchCount).assertEqual(0);
    })

    it('TransmitSearchMsgController_refreshSearchList_1', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(transmitSearchCtrl.transmitSearchListDataSource,
        transmitSearchCtrl.transmitSearchListDataSource.refresh);
      transmitSearchCtrl.refreshSearchList(true);
      mocker.verify('refresh', [transmitSearchCtrl.searchList, true]).once();
      mocker.clear(transmitSearchCtrl.transmitSearchListDataSource);
    })

    it('TransmitSearchMsgController_getSearchListCount', 0, () => {
      expect(transmitSearchCtrl.getSearchListCount()).assertEqual(0)
    })

    it('TransmitSearchMsgController_isDividerShow_isExpand_true_index_minus1', 0, () => {
      transmitSearchCtrl.searchList.length = 1;
      let isShow = transmitSearchCtrl.isDividerShow(true, -1);
      expect(isShow).assertTrue();
    })

    it('TransmitSearchMsgController_isDividerShow_isExpand_true_index_0', 0, () => {
      transmitSearchCtrl.searchList = [{} as LooseObject, {} as LooseObject];
      let isShow = transmitSearchCtrl.isDividerShow(true, 0);
      expect(isShow).assertTrue();
    })

    it('TransmitSearchMsgController_isDividerShow_isExpand_false_length_0', 0, () => {
      let isShow = transmitSearchCtrl.isDividerShow(false, -1);
      expect(isShow).assertFalse();
    })

    it('TransmitSearchMsgController_isDividerShow_isExpand_false_length_4_index_0', 0, () => {
      transmitSearchCtrl.searchList = [{} as LooseObject, {} as LooseObject, {} as LooseObject, {} as LooseObject];
      let isShow = transmitSearchCtrl.isDividerShow(false, 0);
      expect(isShow).assertTrue();
    })

    it('TransmitSearchMsgController_isDividerShow_isExpand_false_length_4_index_2', 0, () => {
      transmitSearchCtrl.searchList = [{} as LooseObject, {} as LooseObject, {} as LooseObject, {} as LooseObject];
      let isShow = transmitSearchCtrl.isDividerShow(false, 2);
      expect(isShow).assertFalse();
    })

    it('TransmitSearchMsgController_judgeInputIsNumber_1', 0, () => {
      transmitSearchCtrl.inputText = '12345678';
      let result = transmitSearchCtrl.judgeInputIsNumber();
      expect(result).assertTrue();
    })

    it('TransmitSearchMsgController_judgeInputIsNumber_2', 0, () => {
      transmitSearchCtrl.inputText = 'abc';
      let result = transmitSearchCtrl.judgeInputIsNumber();
      expect(result).assertFalse();
    })

    it('TransmitSearchMsgController_clickAvatar', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(transmitSearchCtrl, transmitSearchCtrl.jumpToContact);
      mocker.mockFunc(HiLog, HiLog.i);
      let item: MySearch = new MySearch();
      item.detailInfo = '10086';
      transmitSearchCtrl.clickAvatar(item);
      mocker.verify('i', [TAG, 'click avatar']).once();
      mocker.clear(transmitSearchCtrl);
      mocker.clear(HiLog);
    })

    it('TransmitSearchMsgController_jumpToContact', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(CommonService, CommonService.commonContactParam);
      mocker.mockFunc(HiLog, HiLog.e);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility: (want: Want,
            options?: StartOptions | undefined): Promise<void> => new Promise<void>(resolve => resolve())
        } as myCommon.UIAbilityContext);
      let actionData: LooseObject = {};
      transmitSearchCtrl.jumpToContact(actionData);
      mocker.verify('e', [TAG, 'jumpToContact, failed Cause: ']).never();
      mocker.clear(CommonService);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(HiLog);
    })

    it('TransmitSearchMsgController_jumpToContact_catch', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(CommonService, CommonService.commonContactParam);
      mocker.mockFunc(HiLog, HiLog.i);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility: (want: Want,
            options?: StartOptions | undefined): Promise<void> => new Promise<void>((resolve: () => void,
            reject: (reason: BusinessError) => void) => reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as myCommon.UIAbilityContext);
      let actionData: LooseObject = {};
      transmitSearchCtrl.jumpToContact(actionData);
      mocker.verify('i', [TAG, 'jumpToContact, startAbility success']).never();
      mocker.clear(CommonService);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(HiLog);
    })

    it('TransmitSearchMsgController_clickContactAction', 0, () => {
      let item: MySearch = new MySearch();
      item.displayName = 'name1,name2';
      item.detailInfo = '570977632';
      item.rawContactId = '1';
      transmitSearchCtrl.clickContactAction(item);
      expect(transmitSearchCtrl.telephone).assertEqual('570977632');
    })

    it('TransmitSearchMsgController_clickPhone', 0, () => {
      transmitSearchCtrl.inputText = '1111';
      transmitSearchCtrl.clickPhone();
      expect(transmitSearchCtrl.telephone).assertEqual('1111');
    })

    it('TransmitSearchMsgController_getThreadId', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                id: 1
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      transmitSearchCtrl.getThreadId(context, () => {
        expect(JSON.stringify(transmitSearchCtrl.threadId)).assertEqual('0');
      });
      mocker.clear(GlobalContext.getContext());
    })

    it('TransmitSearchMsgController_getThreadId_fail', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
              abilityResult: [{
                id: 1
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      transmitSearchCtrl.getThreadId(context, () => {
        expect(transmitSearchCtrl.threadId).assertEqual(0);
      });
      mocker.clear(GlobalContext.getContext());
    })

    it('TransmitSearchMsgController_transmit', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('TransmitSearchMsg', [{
        dialogMsg: undefined,
        transmitContentList: [],
        isRcs: false
      } as LooseObject]);
      transmitSearchCtrl.pageInfos = pageInfos;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      mocker.mockFunc(HiLog, HiLog.w);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
              abilityResult: [{
                id: 1
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      transmitSearchCtrl.transmit(context, true);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(HiLog);
    })
  })
}