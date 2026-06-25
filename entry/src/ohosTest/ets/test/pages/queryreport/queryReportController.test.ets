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
import { describe, beforeEach, it, expect, MockKit, afterEach, when, ArgumentMatchers } from '@ohos/hypium';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import QueryReportController from '../../../../../main/ets/pages/queryreport/queryReportController';
import dateUtil, { DateUtil } from '../../../../../main/ets/utils/DateUtil';

export default function queryReportControllerTest() {
  describe('queryReportControllerTest', () => {
    let queryReportController: QueryReportController;

    beforeEach(() => {
      queryReportController = QueryReportController.getInstance();
    })

    afterEach(()=>{
      AppStorage.clear();
    })

    it('QueryReportController_onInit', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('queryReport', {
        isMsm: true,
        sendStatus: 1,
        timeMillisecond: '1699010047',
        telephone: '18812345678'
      } as LooseObject);

      queryReportController.onInit(pageInfos);

      expect(queryReportController.telephone).assertEqual('18812345678');
    })

    it('QueryReportController_onInit2', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('queryReport', {
        isMsm: undefined,
        sendStatus: undefined,
        timeMillisecond: undefined,
        telephone: undefined
      } as LooseObject);

      queryReportController.onInit(pageInfos);

      expect(queryReportController.telephone).assertEqual('');
    })

    it('QueryReportController_onShow', 0, () => {
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(queryReportController,queryReportController.dealSendStatus);
      mocker.mockFunc(queryReportController,queryReportController.dealTime);

      queryReportController.onShow();

      mocker.verify('dealTime',[]).once();

      mocker.clear(queryReportController);
    })

    it('QueryReportController_dealSendStatus_SEND_MESSAGE_SUCCESS', 0, () => {
      queryReportController.sendStatus = 0;

      queryReportController.dealSendStatus();

      expect(JSON.stringify(queryReportController.sendStatusDesc)).assertEqual(JSON.stringify($r('app.string.received')));
    })

    it('QueryReportController_dealSendStatus_2_isMsm_true', 0, () => {
      queryReportController.sendStatus = 2;

      queryReportController.dealSendStatus();

      expect(JSON.stringify(queryReportController.sendStatusDesc)).assertEqual(JSON.stringify($r('app.string.refused')));
    })

    it('QueryReportController_dealSendStatus_2_isMsm_false', 0, () => {
      queryReportController.sendStatus = 2;
      queryReportController.isMsm = false;

      queryReportController.dealSendStatus();

      expect(JSON.stringify(queryReportController.sendStatusDesc)).assertEqual(JSON.stringify($r('app.string.failed')));
    })

    it('QueryReportController_dealSendStatus_3', 0, () => {
      queryReportController.sendStatus = 5;

      queryReportController.dealSendStatus();

      expect(JSON.stringify(queryReportController.sendStatusDesc)).assertEqual(JSON.stringify($r('app.string.rending')));
    })

    it('QueryReportController_dealTime', 0, () => {
      let mocker :MockKit = new MockKit();
      when(mocker.mockFunc(dateUtil,DateUtil.convertTimeStampDate))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(dateUtil,DateUtil.convertTimeStampTime))(ArgumentMatchers.any)
        .afterReturn('');
      queryReportController.dealTime();
      expect(queryReportController.timeMillisecond).assertEqual('0');
      mocker.clear(dateUtil);
    })
  })
}