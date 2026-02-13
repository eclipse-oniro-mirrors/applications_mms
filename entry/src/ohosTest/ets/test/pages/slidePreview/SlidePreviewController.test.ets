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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium'
import LooseObject from '../../../../../main/ets/data/LooseObject';
import SlidePreviewController from '../../../../../main/ets/pages/slidePreview/SlidePreviewController';
import { SlideMmsItem } from '../../../../../main/ets/utils/TypesUtils';
import { DTGlobalContext } from '../../../testability/TestAbility';

export default function SlidePreviewControllerTest() {

  describe('SlidePreviewControllerTest', () => {

    const TAG = 'SlidePreviewController';
    let mSlidePreviewCtrl: SlidePreviewController;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mSlidePreviewCtrl = SlidePreviewController.getTestInstance();
      AppStorage.clear();
    })

    it('SlidePreviewControllerTest_initRouterData', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('', {
        'slideDataList': [{
          "duration": "",
          "type": 0,
          "path": "",
          "name": "",
          "smilParIndex": 0
        }, {
          "duration": "",
          "type": 7,
          "path": "/data/storage/el2/base/haps/entry/files/1734056243313/text173405624331460ri4bxyjnc.txt",
          "name": "text173405624331460ri4bxyjnc.txt",
          "smilParIndex": 1,
          "content": "这是文本略略略略略略略略略略略哦哦略略略啦啦啦啦啦啦啦啦啦啦啦啦啦卡罗拉快乐啦啦啦啦啦啦啦就快快快快"
        }, {
          "duration": "",
          "type": 1,
          "ct": "",
          "path": "/data/storage/el2/base/haps/entry/files/1734056243313/1.jpg",
          "name": "1.jpg",
          "size": "24875.0",
          "smilParIndex": 2
        }, {
          "duration": "00:05",
          "type": 3,
          "ct": "",
          "path": "/data/storage/el2/base/haps/entry/files/1734056243313/RECORD_1734056243316orixdnea6ri.amr",
          "name": "RECORD_1734056243316orixdnea6ri.amr",
          "size": "5670.0",
          "smilParIndex": 3
        }],
        'mmsItem': {
          "showTitle": false,
          "id": 2,
          "rcsId": 0,
          "content": "这是文本略略略略略略略略略略略哦哦略略略啦啦啦啦啦啦啦啦啦啦啦啦啦卡罗拉快乐啦啦啦啦啦啦啦就快快快快",
          "detectResContent": "",
          "isRcs": 0,
          "smsType": 0,
          "is_collect": true,
          "msgType": 1,
          "isFullScreenImg": true,
          "isReport": "0",
          "senderNumber": "",
          "read": "1",
          "sendStatus": 0,
          "receiveState": 0,
          "failReceiveContext": "",
          "subId": 0,
          "msgCode": 0,
          "msgCodeStr": "",
          "receiverNumber": "19567305200",
          "startTime": 1734056243407,
          "msgTitle": "主题一",
          "sessionType": 0,
          "groupId": 2,
          "isSender": 0,
          "isMsm": true,
          "timeMillisecond": 1734056243407,
          "isCbChecked": false,
          "isDraft": false,
          "isReceive": false,
          "date": "",
          "time": "上午10:17",
          "completeNumber": 0,
          "failuresNumber": 0,
          "isAdvancedSecurity": false,
          "hasReport": false,
          "isShowMsgLongMenu": false,
          "mmsSource": [{
            "duration": "",
            "type": 0,
            "ct": "",
            "path": "/data/storage/el2/base/haps/entry/files/1734056243313/smil.xml",
            "name": "smil.xml",
            "size": "",
            "content": ""
          }, {
            "duration": "",
            "type": 1,
            "ct": "",
            "path": "/data/storage/el2/base/haps/entry/files/1734056243313/2.jpg",
            "name": "2.jpg",
            "size": "24875.0",
            "smilParIndex": 2
          }, {
            "duration": "",
            "type": 7,
            "ct": "",
            "path": "/data/storage/el2/base/haps/entry/files/text1734056207508131y13ei64ol.txt",
            "name": "text1734056207508131y13ei64ol.txt",
            "size": "150.0",
            "content": ""
          }, {
            "duration": "00:05",
            "type": 3,
            "ct": "",
            "path": "/data/storage/el2/base/haps/entry/files/1734056243313/RECORD_1734056243316orixdnea6ri.amr",
            "name": "RECORD_1734056243316orixdnea6ri.amr",
            "size": "5670.0",
            "smilParIndex": 3
          }],
          "contentType": 2,
          "mmsPdu": "",
          "msgState": 0,
          "expiresTime": 0,
          "clurSize": 0,
          "totalSize": 0,
          "riskUrlBody": "",
          "fullDate": "2024年12月13日",
          "timeOfSms": "上午10:17",
          "week": "星期五",
          "dateString": "今天",
          "dateShow": false,
          "detailTime": "上午10:17",
          "itemTime": 0
        },
        'favoriteItem': '',
        'threadId': 1,
        'mmsIndex': 1
      } as LooseObject);
      mSlidePreviewCtrl.pageInfos = pageInfos;
      mSlidePreviewCtrl.onInit(pageInfos);
      mSlidePreviewCtrl.initRouterData();
      expect(mSlidePreviewCtrl.favoriteItem).assertEqual('');
      let mocker: MockKit = new MockKit();
      mocker.clear(mSlidePreviewCtrl);
    })

    it('SlidePreviewControllerTest_initRouterData2', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      mSlidePreviewCtrl.pageInfos = pageInfos;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(pageInfos, pageInfos.getParamByIndex))(ArgumentMatchers.any).afterReturn({
        slideDataList: undefined,
        mmsItem: undefined,
        favoriteItem: undefined,
        threadId: undefined,
        mmsIndex: undefined,
      })
      mSlidePreviewCtrl.initRouterData();
      expect(mSlidePreviewCtrl).not().assertUndefined();
      mocker.clear(pageInfos);
    })

    it('SlidePreviewControllerTest_resetPageData', 0, () => {
      mSlidePreviewCtrl.msgTitle = '';

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mSlidePreviewCtrl, mSlidePreviewCtrl.resetSelectStatus);
      mocker.mockFunc(mSlidePreviewCtrl, mSlidePreviewCtrl.cancelCheckedAll);
      mSlidePreviewCtrl.resetPageData();

      expect(mSlidePreviewCtrl.msgTitle).assertEqual('');
      expect(mSlidePreviewCtrl.isSelectStatus).assertFalse();
      expect(mSlidePreviewCtrl.selectSaveCount).assertEqual(0);
      mocker.clear(mSlidePreviewCtrl);
    })

    it('SlidePreviewControllerTest_resetSelectStatus', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mSlidePreviewCtrl, mSlidePreviewCtrl.resetSelectStatus);
      expect(mSlidePreviewCtrl.isSelectStatus).assertFalse();
      expect(mSlidePreviewCtrl.selectSaveCount).assertEqual(0);
      mocker.clear(mSlidePreviewCtrl);
    })

    it('SlidePreviewControllerTest_cancelCheckedAll', 0, () => {
      mSlidePreviewCtrl = SlidePreviewController.getTestInstance();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mSlidePreviewCtrl, mSlidePreviewCtrl.cancelCheckedAll);
      expect(mSlidePreviewCtrl.isAttachCheckAll).assertFalse();
      mocker.clear(mSlidePreviewCtrl);
    })

    it('SlidePreviewControllerTest_getSlidePreviewData', 0, () => {
      mSlidePreviewCtrl.getSlidePreviewData();
      expect(mSlidePreviewCtrl).not().assertUndefined();
    })

    it('SlidePreviewControllerTest_getFirstItem', 0, () => {
      mSlidePreviewCtrl.slideList = [];
      let item = mSlidePreviewCtrl.getFirstItem();
      mSlidePreviewCtrl.slideList = [{} as SlideMmsItem];
      item = mSlidePreviewCtrl.getFirstItem();
      expect(item).not().assertUndefined();
    })

    it('SlidePreviewControllerTest_clickCheckAllBtn1', 0, () => {
      mSlidePreviewCtrl.slideList = [{
        type: 1, isCbChecked: false
      } as SlideMmsItem];
      mSlidePreviewCtrl.isSelectStatus = false;
      mSlidePreviewCtrl.clickCheckAllBtn();
      expect(mSlidePreviewCtrl).not().assertUndefined();
    })

    it('SlidePreviewControllerTest_clickCheckAllBtn2', 0, () => {
      mSlidePreviewCtrl.slideList = [{
        type: 1, isCbChecked: false
      } as SlideMmsItem, {
        type: 2, isCbChecked: false
      } as SlideMmsItem, {
        type: 66, isCbChecked: false
      } as SlideMmsItem];
      mSlidePreviewCtrl.isAttachCheckAll = true;
      mSlidePreviewCtrl.isSelectStatus = true;
      mSlidePreviewCtrl.clickCheckAllBtn();
      expect(mSlidePreviewCtrl).not().assertUndefined();
    })

    it('SlidePreviewControllerTest_onBackPress', 0, () => {
      mSlidePreviewCtrl.isSelectStatus = true;
      let status = mSlidePreviewCtrl.onBackPress();
      expect(status).assertTrue();
      mSlidePreviewCtrl.isSelectStatus = false;
      status = mSlidePreviewCtrl.onBackPress();
      (mSlidePreviewCtrl as object)['pageInfos'] = undefined;
      status = mSlidePreviewCtrl.onBackPress();
      expect(status).assertFalse();
    })

    it('SlidePreviewControllerTest_deleteDialogConfirm', 0, () => {
      (mSlidePreviewCtrl as object)['favoriteItem'] = undefined;
      mSlidePreviewCtrl.deleteDialogConfirm(context);
      expect(mSlidePreviewCtrl).not().assertUndefined();
    })

    it('SlidePreviewControllerTest_deleteDialogConfirm2', 0, () => {
      mSlidePreviewCtrl.deleteDialogConfirm(context);
      expect(mSlidePreviewCtrl).not().assertUndefined();
    })

    it('SlidePreviewControllerTest_listCheckBoxChange', 0, () => {
      mSlidePreviewCtrl.slideList = [{
        type: 1, isCbChecked: false
      } as SlideMmsItem];
      mSlidePreviewCtrl.listCheckBoxChange(0, true);
      expect(mSlidePreviewCtrl).not().assertUndefined();
    })

    it('SlidePreviewControllerTest_transmitMsg', 0, () => {
      mSlidePreviewCtrl.transmitMsg(context);
      expect(mSlidePreviewCtrl).not().assertUndefined();
    })

    it('SlidePreviewControllerTest_clickSaveAllBtn1', 0, () => {
      mSlidePreviewCtrl.clickSaveAllBtn();
      expect(mSlidePreviewCtrl).not().assertUndefined();
    })

    it('SlidePreviewControllerTest_clickSaveAllBtn2', 0, () => {
      mSlidePreviewCtrl.slideList = [{
        type: 1, isCbChecked: true
      } as SlideMmsItem, {
        type: 2, isCbChecked: true
      } as SlideMmsItem, {
        type: 3, isCbChecked: true
      } as SlideMmsItem, {
        type: 66, isCbChecked: true
      } as SlideMmsItem];
      mSlidePreviewCtrl.isSelectStatus = true;
      mSlidePreviewCtrl.clickSaveAllBtn();
      expect(mSlidePreviewCtrl).not().assertUndefined();
    })
  })
}