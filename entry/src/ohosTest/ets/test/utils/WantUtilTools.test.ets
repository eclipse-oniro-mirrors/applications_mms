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
import { describe, expect, it } from '@ohos/hypium';
import LooseObject from '../../../../main/ets/data/LooseObject';
import WantUtil, { AbilityWant, ContactsParamMsg } from '../../../../main/ets/utils/WantUtil';
import { IWantHelper, WantMaster } from '../../../../main/ets/utils/WantUtilTools';
import { DTGlobalContext } from '../../testability/TestAbility';

export default function WantUtilToolsTest() {
  describe('WantUtilToolsTest', () => {

    it('WantUtilToolsTest_createWantHelper_pageFlag_isempty', 0, () => {
      let parameters: LooseObject = {}
      let wantCategory:string = WantMaster.cls(parameters, '');
      let pageInfos: NavPathStack = new NavPathStack();
      WantMaster.createWantHelper(wantCategory, pageInfos, WantUtil);
      expect(wantCategory).assertEqual('unKnowCategory');
    });

    it('WantUtilToolsTest_createWantHelper_unKnowCategory', 0, () => {
      let parameters: LooseObject = {
        'pageFlag': 'unKnowCategory',
      }
      let wantCategory:string = WantMaster.cls(parameters, '');
      let pageInfos: NavPathStack = new NavPathStack();
      let wantHelper: IWantHelper | undefined = WantMaster.createWantHelper(wantCategory, pageInfos, WantUtil);
      expect(wantCategory).assertEqual('unKnowCategory');
    });

    it('WantUtilToolsTest_createWantHelper_BlockedListWantHelper', 0, () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext") as Context;
      let parameters: LooseObject = {
        'pageFlag': 'blockedList',
      }
      let wantCategory:string = WantMaster.cls(parameters, 'mms.event.notification');
      let pageInfos: NavPathStack = new NavPathStack();
      let wantHelper: IWantHelper | undefined = WantMaster.createWantHelper(wantCategory, pageInfos, WantUtil);
      let isSkipSmsHomePage = WantUtil.parameterCompare(parameters, 'mms.event.notification');
      (wantHelper as IWantHelper).jump(context, parameters, isSkipSmsHomePage, '1')
      expect(wantCategory).assertEqual('BlockedListWantHelper');
    });

    it('WantUtilToolsTest_createWantHelper_NotificationWantHelper', 0, () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext") as Context;
      let parameters: LooseObject = {
        'pageFlag': 'conversation',
      }
      let wantCategory:string = WantMaster.cls(parameters, 'mms.event.notification');
      let pageInfos: NavPathStack = new NavPathStack();
      let wantHelper: IWantHelper | undefined = WantMaster.createWantHelper(wantCategory, pageInfos, WantUtil);
      let isSkipSmsHomePage = WantUtil.parameterCompare(parameters, 'mms.event.notification');
      (wantHelper as IWantHelper).jump(context, parameters, isSkipSmsHomePage, '1')
      expect(wantCategory).assertEqual('NotificationWantHelper');
    });

    it('WantUtilToolsTest_createWantHelper_NotificationWantHelper_hasContactObjects', 0, () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext") as Context;
      let parameters: LooseObject = {
        'pageFlag': 'conversation',
        'contactObjects': true,
      }
      let wantCategory:string = WantMaster.cls(parameters, 'mms.event.notification');
      let pageInfos: NavPathStack = new NavPathStack();
      let wantHelper: IWantHelper | undefined = WantMaster.createWantHelper(wantCategory, pageInfos, WantUtil);
      let isSkipSmsHomePage = WantUtil.parameterCompare(parameters, 'mms.event.notification');
      (wantHelper as IWantHelper).jump(context, parameters, isSkipSmsHomePage, '1')
      expect(wantCategory).assertEqual('NotificationWantHelper');
    });

    it('WantUtilToolsTest_createWantHelper_NotificationWantHelper_preCheck_contactsNum_is_0', 0, () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext") as Context;
      let parameters: LooseObject = {
        'pageFlag': 'conversation',
        'contactObjects': new ContactsParamMsg(),
      }
      let wantCategory:string = WantMaster.cls(parameters, 'mms.event.notification');
      let pageInfos: NavPathStack = new NavPathStack();
      let wantHelper: IWantHelper | undefined = WantMaster.createWantHelper(wantCategory, pageInfos, WantUtil);
      let isSkipSmsHomePage = WantUtil.parameterCompare(parameters, 'mms.event.notification');
      (wantHelper as IWantHelper).jump(context, parameters, isSkipSmsHomePage, '1')
      expect(wantCategory).assertEqual('NotificationWantHelper');
    });

    it('WantUtilToolsTest_createWantHelper_BlockedGuideWantHelper', 0, () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext") as Context;
      let parameters: LooseObject = {
        'pageFlag': 'blockedGuidePage',
      }
      let wantCategory:string = WantMaster.cls(parameters, 'mms.event.notification');
      let pageInfos: NavPathStack = new NavPathStack();
      let wantHelper: IWantHelper | undefined = WantMaster.createWantHelper(wantCategory, pageInfos, WantUtil);
      let isSkipSmsHomePage = WantUtil.parameterCompare(parameters, 'mms.event.notification');
      (wantHelper as IWantHelper).jump(context, parameters, isSkipSmsHomePage, '1')
      expect(wantCategory).assertEqual('BlockedGuideWantHelper');
    });
  })
}