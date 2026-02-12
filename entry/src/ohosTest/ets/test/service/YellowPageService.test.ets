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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers, afterEach } from '@ohos/hypium';
import LooseObject from '../../../../main/ets/data/LooseObject';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';
import YellowPageService from '../../../../main/ets/service/yellowPageService';
import { DTGlobalContext } from '../../testability/TestAbility';
import { window } from '@kit.ArkUI';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import MySet from '../MySet';


export default function yellowPageServiceTest() {
  describe('yellowPageServiceTest', () => {

    let yellowPageService: YellowPageService;
    let mocker: MockKit;

    beforeEach(() => {
      yellowPageService = YellowPageService.getTestInstance();
      mocker = new MockKit();
    })

    afterEach(() => {
      mocker.clear(YellowPageService.getInstance());
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('yellowPageServiceTest_getInstance', 0, async () => {
      expect(typeof yellowPageService).assertEqual(typeof YellowPageService.getInstance());
    })

    it('yellowPageServiceTest_queryYellowPageListInfoByCondition_getObject', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);

      yellowPageService.queryYellowPageListInfoByCondition({}, (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      }, context);
    })

    it('yellowPageServiceTest_queryYellowPageListInfoByCondition_queryYellowPageListInfoByCondition', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initYellowPageDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      yellowPageService.queryYellowPageListInfoByCondition({}, (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      }, context);
    })

    it('yellowPageServiceTest_judgeYellowPageByTelephone_if', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      let queryYellowPageInfoByCondition: Function = mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().queryYellowPageInfoByCondition);
      when(queryYellowPageInfoByCondition)(ArgumentMatchers.any)
        .afterReturn(new  Promise<LooseObject>(resolve => resolve({
          code: 0,
          abilityResult: [{
            name: 'roxy',
            photo: '',
            id: 1
          }]
        })));

      let result: LooseObject = await yellowPageService.judgeYellowPageByTelephone('570977632', context);
      expect(result.name).assertEqual('roxy');
    })

    it('yellowPageServiceTest_judgeNewPageHasYellowPageExist_if', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let param: LooseObject = {
        'telephone': '570977632',
        'icon': '',
        'contactName': 'roxy',
        'headImage': ''
      };
      let queryYellowPageInfoByCondition: Function = mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().queryYellowPageInfoByCondition);
      when(queryYellowPageInfoByCondition)(ArgumentMatchers.any)
        .afterReturn(new  Promise<LooseObject>(resolve => resolve({
          code: 0,
          abilityResult: [{
            name: 'roxy',
            photo: '',
            id: 1
          }]
        })));
      let result1: LooseObject = await yellowPageService.judgeNewPageHasYellowPageExist(param, context);
      expect(result1.photo).assertEqual('');
    })

    it('yellowPageServiceTest_judgeNewPageHasYellowPageExist_if_photo_xx', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      let param: LooseObject = {
        'telephone': '570977632',
        'icon': 'icon.jpg',
        'contactName': 'roxy',
        'headImage': '',
        'photo': 'xx'
      };

      let queryYellowPageInfoByCondition: Function = mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().queryYellowPageInfoByCondition);
      when(queryYellowPageInfoByCondition)(ArgumentMatchers.any)
        .afterReturn(new  Promise<LooseObject>(resolve => resolve({
          code: 0,
          abilityResult: [{
            name: 'roxy',
            photo: 'xx.jpg',
            id: 1
          }]
        })));

      let result1: LooseObject = await yellowPageService.judgeNewPageHasYellowPageExist(param, context);

      expect(result1.photo).assertEqual('xx.jpg');
    })

    it('yellowPageServiceTest_judgeNewPageHasYellowPageExist_else', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      let param: LooseObject = {
        'telephone': '570977632',
        'icon': 'icon.jpg',
        'contactName': 'roxy',
        'headImage': ''
      };

      let queryYellowPageInfoByCondition: Function = mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().queryYellowPageInfoByCondition);
      when(queryYellowPageInfoByCondition)(ArgumentMatchers.any)
        .afterReturn(new  Promise<LooseObject>(resolve => resolve({
          code: -1
        })));

      let result1: LooseObject = await yellowPageService.judgeNewPageHasYellowPageExist(param, context);

      expect(result1.photo).assertEqual('');
    })

    it('yellowPageServiceTest_judgeYellowPageExist_if', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let param: LooseObject = {
        'telephone': '570977632',
        'icon': 'icon.jpg',
        'contactName': 'roxy',
        'headImage': '',
        'name': 'roxy'
      };
      let queryYellowPageInfoByCondition: Function = mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().queryYellowPageInfoByCondition);
      when(queryYellowPageInfoByCondition)(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          code: 0,
          abilityResult: [{
            name: 'roxy',
            photo: '',
            id: 1
          }]
        })));
      let result1: LooseObject = await yellowPageService.judgeYellowPageExist(param, context);
      expect(result1.name).assertEqual('roxy');
      expect(result1.yellowPageId).assertEqual(1);
      expect(result1.photo).assertEqual('icon.jpg');
    })

    it('yellowPageServiceTest_judgeYellowPageExist_if_photo', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let param: LooseObject = {
        'telephone': '570977632',
        'icon': '',
        'contactName': 'roxy',
        'headImage': '',
        'name': 'roxy'
      };
      let queryYellowPageInfoByCondition: Function = mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().queryYellowPageInfoByCondition);
      when(queryYellowPageInfoByCondition)(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          code: 0,
          abilityResult: [{
            name: 'roxy',
            photo: 'xx.jpg',
            id: 1
          }]
        })));
      let result1: LooseObject = await yellowPageService.judgeYellowPageExist(param, context);
      expect(result1.name).assertEqual('roxy');
      expect(result1.photo).assertEqual('xx.jpg');
    })

    it('yellowPageServiceTest_judgeYellowPageExist_else', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let param: LooseObject = {
        'telephone': '570977632',
        'icon': 'icon.jpg',
        'contactName': 'roxy',
        'headImage': '',
        'name': 'roxy'
      };
      let queryYellowPageInfoByCondition: Function = mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().queryYellowPageInfoByCondition);
      when(queryYellowPageInfoByCondition)(ArgumentMatchers.any)
        .afterReturn(new  Promise<LooseObject>(resolve => resolve({
          code: -1
        })));
      let result1: LooseObject = await yellowPageService.judgeYellowPageExist(param, context);
      expect(result1.photo).assertEqual('icon.jpg');
    })

    it('yellowPageServiceTest_judgeNoticeYellowPageExist_if_pixelMap', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let param: LooseObject = {
        'telephone': '570977632',
        'icon': '',
        'contactName': 'roxy',
        'headImage': '',
        'message': {
          title: 'title'
        }
      };
      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initYellowPageDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => {
            resolve(myset);
          })
        } as dataShare.DataShareHelper)));
      let result1: LooseObject = await yellowPageService.judgeNoticeYellowPageExist(param, context);
      expect(result1.photo).assertEqual('');
    })

    it('yellowPageServiceTest_judgeNoticeYellowPageExist_else', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let param: LooseObject = {
        'telephone': '570977632',
        'icon': 'icon.jpg',
        'contactName': 'roxy',
        'headImage': '',
        'message': {
          title: 'title'
        }
      };
      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initYellowPageDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      let result1: LooseObject = await yellowPageService.judgeNoticeYellowPageExist(param, context);
      expect(JSON.stringify(result1))
        .assertEqual('{"name":"title","photo":"","yellowPageId":"","hasYellowPageIcon":""}');
    })

    it('yellowPageServiceTest_queryYellowPageInfoByCondition', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      let result: LooseObject | null = await yellowPageService.queryYellowPageInfoByCondition({}, context);
      expect(result?.code).assertEqual(0);
    })

    it('yellowPageServiceTest_queryYellowPageInfoByCondition_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack(null) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      let result: LooseObject | null = await yellowPageService.queryYellowPageInfoByCondition({}, context);
      expect(result).assertNull();
    })

    it('yellowPageServiceTest_queryYellowPageInfoByCondition_else', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initYellowPageDB))(context)
        .afterReturn(undefined);
      let result: LooseObject | null = await yellowPageService.queryYellowPageInfoByCondition({}, context);
      expect(result?.code).assertEqual(-1);
    })
  })
}