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
import { ArgumentMatchers, describe, expect, it, when } from '@ohos/hypium';
import ReportSpamMessageManager from '../../../../main/ets/report/ReportSpamMessageManager';
import { common } from '@kit.AbilityKit';
import { MockKit } from '@ohos/hypium/src/main/module/mock/MockKit';
import ReportConnectServiceManager from '../../../../main/ets/report/ReportConnectServiceManager';
import ConversationController from '../../../../main/ets/pages/conversation/conversationController';
import HiFaultEventUtil from '../../../../main/ets/report/event/HiFaultEventUtil';
import { DateUtil } from '../../../../main/ets/utils/DateUtil';
import ReportParameterHelper from '../../../../main/ets/report/common/ReportParameterHelper';
import { SmsReportParams } from '../../../../main/ets/report/common/ReportParams';
import ReportConnectCloudCallback from '../../../../main/ets/report/hsdr/callback/ReportConnectCloudCallback';
import ReportUtil from '../../../../main/ets/report/ReportUtil';
import { DTGlobalContext } from '../../testability/TestAbility';

export default function reportSpamMessageManagerTest() {

  describe('ReportSpamMessageManagerTest', () => {
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
    it('ReportSpamMessageManagerTest_initReportSpamMessageManager', 0, async () => {
      let context: common.UIAbilityContext = {} as common.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ReportConnectServiceManager.getInstance(),
        ReportConnectServiceManager.getInstance().initReportConnectServiceManager))(ArgumentMatchers.any)
        .afterReturn(new Promise<void>(resolve => resolve()));
      await ReportSpamMessageManager.getInstance().initReportSpamMessageManager(context);
      mocker.verify('initReportConnectServiceManager',[context]).once();
      mocker.clear(ReportConnectServiceManager.getInstance());
    })

    it('ReportSpamMessageManagerTest_reportSmsContent', 0, async () => {
      let reportSpamMessageManager: ReportSpamMessageManager = ReportSpamMessageManager.getInstance();
      let context: common.UIAbilityContext = {} as common.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(ConversationController.getInstance(), ConversationController.getInstance().showReportToast);
      mocker.mockFunc(ReportConnectServiceManager.getInstance(),
        ReportConnectServiceManager.getInstance().disconnectAbility);
      mocker.mockFunc(HiFaultEventUtil, HiFaultEventUtil.reportSmsContentFail);
      when(mocker.mockFunc(DateUtil, DateUtil.isDataValid))(ArgumentMatchers.any).afterReturn(true);
      when(mocker.mockFunc(reportSpamMessageManager,
        reportSpamMessageManager.fetchReportSmsContentRtd))(ArgumentMatchers.any).afterReturn(false);
      await ReportSpamMessageManager.getInstance().reportSmsContent(context, '', '');
      mocker.verify('disconnectAbility',[]).once();
      mocker.clear(ReportConnectServiceManager.getInstance());
    })

    it('ReportSpamMessageManagerTest_reportSmsContentInner', 0, async () => {
      let reportSpamMessageManager: ReportSpamMessageManager = ReportSpamMessageManager.getInstance();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.isDataValid))(ArgumentMatchers.any).afterReturn(true);
      when(mocker.mockFunc(ReportParameterHelper, ReportParameterHelper.getCalleeId))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(ReportParameterHelper, ReportParameterHelper.getIp))(ArgumentMatchers.any).afterReturn('');
      let res = false;
      when(mocker.mockFunc(reportSpamMessageManager, reportSpamMessageManager.startHandlerRequest))(ArgumentMatchers.any).afterAction(() => {
        res = true;
      });

      reportSpamMessageManager.reportSmsContentInner({
        msgStr: '', senderNum: ''
      } as SmsReportParams, (errCode: number, statusCode: number) => {
      });

      expect(res).assertFalse();
      mocker.clear(DateUtil);
      mocker.clear(ReportParameterHelper);
      mocker.clear(reportSpamMessageManager);
    })

    it('ReportSpamMessageManagerTest_startHandlerRequest', 0, async () => {
      let reportSpamMessageManager: ReportSpamMessageManager = ReportSpamMessageManager.getInstance();
      let mocker: MockKit = new MockKit();
      let res = false;
      when(mocker.mockFunc(ReportConnectServiceManager.getInstance(), ReportConnectServiceManager.getInstance()
        .startRequestUcs))(ArgumentMatchers.any).afterAction(() => {
        res = true;
      });
      when(mocker.mockFunc(ReportUtil,ReportUtil.encodeAndEncryptBody))(ArgumentMatchers.any).afterReturn('');
      reportSpamMessageManager.startHandlerRequest('',
        new ReportConnectCloudCallback((errCode: number, statusCode: number) => {
        }));
      expect(res).assertTrue();
      mocker.clear(ReportConnectServiceManager.getInstance());
      mocker.clear(ReportUtil);
    })

    it('ReportSpamMessageManagerTest_reportSmsContentFault', 0, async () => {
      let reportSpamMessageManager: ReportSpamMessageManager = ReportSpamMessageManager.getInstance();
      let mocker: MockKit = new MockKit();
      let res = false;
      when(mocker.mockFunc(HiFaultEventUtil, HiFaultEventUtil.reportSmsContentFail))(ArgumentMatchers.any).afterAction(() => {
        res = true;
      });
      reportSpamMessageManager.reportSmsContentFault({} as SmsReportParams, 0);
      expect(res).assertTrue();
      mocker.clear(HiFaultEventUtil);
    })
  })
}