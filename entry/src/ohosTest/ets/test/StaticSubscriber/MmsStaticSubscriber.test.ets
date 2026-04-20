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
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import MmsStaticSubscriber from '../../../../main/ets/StaticSubscriber/MmsStaticSubscriber';
import { screenLock, StaticSubscriberExtensionContext } from '@kit.BasicServicesKit';
import { BaseDataParameters, DataParameters } from '../../../../main/ets/utils/TypesUtils';
import { DTGlobalContext } from '../../testability/TestAbility';
import HiLog from '../../../../main/ets/utils/HiLog';
import SharedPreferencesUtils from '../../../../main/ets/utils/SharedPreferencesUtils';
import NotificationService from '../../../../main/ets/service/NotificationService';
import DotUtil from '../../../../main/ets/utils/MmsDot/DotUtils';
import { mmsReceive } from '../../../../main/ets/views/MmsReceive/mmsReceiveMain';
import oobeResult from '../../../../main/ets/oobe/oobeResult';

export default function mmsStaticSubscriberTest() {
  describe('mmsStaticSubscriberTest', () => {

    const TAG: string = 'MmsStaticSubscriber';

    it('mmsStaticSubscriberTest_onReceiveEvent_if1_if3_if4', 0, () => {
      let mmsStaticSubscriber: MmsStaticSubscriber = new MmsStaticSubscriber();
      let data: DataParameters = {
        bundleName: "string;",
        code: 1,
        event: 'usual.event.SMS_RECEIVE_COMPLETED',
        parameters: {
          action: 'notification.event.readdata',
          isCdma: true,
          isNotificationFlag: true,
          isShow: true,
          moduleName: "string;",
          pdus: [],
          slotId: 1,
          id: 1,
          telephone: "111",
          mobilePhoneNumber: "1111",
          msgId: "111",
          type: "111",
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        data: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.init);
      let notificationService: NotificationService = new NotificationService();
      when(mocker.mockFunc(NotificationService, NotificationService.getInstance))(ArgumentMatchers.any)
        .afterReturn(notificationService);
      mocker.mockFunc(notificationService, notificationService.markAsReadFromReceive);
      mocker.mockFunc(notificationService, notificationService.clickRead);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);


      mocker.mockFunc(mmsStaticSubscriber.receiveService, mmsStaticSubscriber.receiveService.dealSmsReceiveData);
      mocker.mockFunc(mmsReceive, mmsReceive.receivePduAndBaseInfo);

      mmsStaticSubscriber.onReceiveEvent(data);

      mocker.verify('i', [TAG, 'onReceiveEvent: SystemUI mark message copy ver code']).never();
      mocker.clear(HiLog);
      mocker.clear(notificationService);
      mocker.clear(notificationService);
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(mmsStaticSubscriber.receiveService);
      mocker.clear(mmsReceive);
      mocker.clear(DotUtil.getInstance());
    })

    it('mmsStaticSubscriberTest_onReceiveEvent_if2_if4_if5', 0, () => {
      let mmsStaticSubscriber: MmsStaticSubscriber = new MmsStaticSubscriber();
      let data: DataParameters = {
        bundleName: "string;",
        code: 1,
        event: 'usual.event.SMS_RECEIVE_COMPLETED',
        parameters: {
          action: 'notification.event.copyvercode',
          isCdma: true,
          isNotificationFlag: false,
          isShow: true,
          moduleName: "string;",
          pdus: [],
          slotId: 1,
          id: 1,
          telephone: "111",
          mobilePhoneNumber: "1111",
          msgId: "111",
          type: "111",
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        data: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.init);
      let notificationService: NotificationService = new NotificationService();
      when(mocker.mockFunc(NotificationService, NotificationService.getInstance))(ArgumentMatchers.any)
        .afterReturn(notificationService);
      mocker.mockFunc(notificationService, notificationService.markAsReadFromReceive);
      mocker.mockFunc(notificationService, notificationService.clickRead);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      mocker.mockFunc(mmsStaticSubscriber.receiveService, mmsStaticSubscriber.receiveService.dealSmsReceiveData);
      mocker.mockFunc(mmsReceive, mmsReceive.receivePduAndBaseInfo);
      mmsStaticSubscriber.onReceiveEvent(data);
      mocker.verify('i', [TAG, 'onReceiveEvent: SystemUI mark message read']).never();
      mocker.clear(HiLog);
      mocker.clear(notificationService);
      mocker.clear(notificationService);
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(mmsStaticSubscriber.receiveService);
      mocker.clear(mmsReceive);
      mocker.clear(DotUtil.getInstance());
    })

    it('mmsStaticSubscriberTest_onReceiveEvent_if2_if3_if6', 0, () => {
      let mmsStaticSubscriber: MmsStaticSubscriber = new MmsStaticSubscriber();
      let context: StaticSubscriberExtensionContext =
        DTGlobalContext.getContext().getObject('mmsContext') as StaticSubscriberExtensionContext;
      mmsStaticSubscriber.context = context;
      let data: DataParameters = {
        bundleName: "string;",
        code: 1,
        event: 'usual.event.SMS_WAPPUSH_RECEIVE_COMPLETED',
        parameters: {
          action: 'notification.event.copyvercode',
          isCdma: true,
          isNotificationFlag: true,
          isShow: true,
          moduleName: "string;",
          pdus: [],
          slotId: 1,
          id: 1,
          telephone: "111",
          mobilePhoneNumber: "1111",
          msgId: "111",
          type: "111",
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        data: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.init);
      let notificationService: NotificationService = new NotificationService();
      when(mocker.mockFunc(NotificationService, NotificationService.getInstance))(ArgumentMatchers.any)
        .afterReturn(notificationService);
      mocker.mockFunc(notificationService, notificationService.markAsReadFromReceive);
      mocker.mockFunc(notificationService, notificationService.clickRead);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);

      mocker.mockFunc(mmsStaticSubscriber.receiveService, mmsStaticSubscriber.receiveService.dealSmsReceiveData);
      mocker.mockFunc(mmsReceive, mmsReceive.receivePduAndBaseInfo);
      mmsStaticSubscriber.onReceiveEvent(data);
      mocker.verify('i', [TAG, 'onReceiveEvent: SystemUI mark message read']).never();
      mocker.clear(HiLog);
      mocker.clear(notificationService);
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(mmsStaticSubscriber.receiveService);
      mocker.clear(mmsReceive);
      mocker.clear(DotUtil.getInstance());
    })

    it('mmsStaticSubscriberTest_onReceiveEvent_if2_if6_if7', 0, () => {
      let mmsStaticSubscriber: MmsStaticSubscriber = new MmsStaticSubscriber();
      let context: StaticSubscriberExtensionContext =
        DTGlobalContext.getContext().getObject('mmsContext') as StaticSubscriberExtensionContext;
      mmsStaticSubscriber.context = context;
      let data: DataParameters = {
        bundleName: "string;",
        code: 1,
        event: 'usual.event.SMS_WAPPUSH_RECEIVE_COMPLETED',
        parameters: {
          action: 'notification.event.copyvercode',
          isCdma: true,
          isNotificationFlag: false,
          isShow: true,
          moduleName: "string;",
          pdus: ['111','222'],
          slotId: 1,
          id: 1,
          telephone: "111",
          mobilePhoneNumber: "1111",
          msgId: "111",
          type: "111",
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        data: 'TEXT_RCS_CHATBOT_RECEIVE',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.init);
      let notificationService: NotificationService = new NotificationService();
      when(mocker.mockFunc(NotificationService, NotificationService.getInstance))(ArgumentMatchers.any)
        .afterReturn(notificationService);
      mocker.mockFunc(notificationService, notificationService.markAsReadFromReceive);
      mocker.mockFunc(notificationService, notificationService.clickRead);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);

      mocker.mockFunc(mmsStaticSubscriber.receiveService, mmsStaticSubscriber.receiveService.dealSmsReceiveData);
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(mmsReceive, mmsReceive.receivePduAndBaseInfo);
      mmsStaticSubscriber.onReceiveEvent(data);
      mocker.verify('i', [TAG, 'onReceiveEvent: SystemUI mark message read']).never();
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(false);
      mmsStaticSubscriber.onReceiveEvent(data);
      mmsStaticSubscriber.handleNormalSMS(data);
      (mmsStaticSubscriber as object)['handleNormalSMSForHasLockedScreen'](data);
      mocker.clear(HiLog);
      mocker.clear(notificationService);
      mocker.clear(notificationService);
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(mmsStaticSubscriber.receiveService);
      mocker.clear(mmsReceive);
      mocker.clear(DotUtil.getInstance());
    })

    it('mmsStaticSubscriberTest_onReceiveEvent_if8', 0, () => {
      let mmsStaticSubscriber: MmsStaticSubscriber = new MmsStaticSubscriber();
      let context: StaticSubscriberExtensionContext =
        DTGlobalContext.getContext().getObject('mmsContext') as StaticSubscriberExtensionContext;
      mmsStaticSubscriber.context = context;
      let data: DataParameters = {
        bundleName: "string;",
        code: 1,
        event: 'usual.event.SCREEN_UNLOCKED',
        parameters: {
          action: '',
          isCdma: true,
          isNotificationFlag: false,
          isShow: true,
          moduleName: "string;",
          pdus: [],
          slotId: 1,
          id: 1,
          telephone: "111",
          mobilePhoneNumber: "1111",
          msgId: "111",
          type: "111",
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        data: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();
      let notificationService: NotificationService = new NotificationService();
      when(mocker.mockFunc(NotificationService, NotificationService.getInstance))(ArgumentMatchers.any)
        .afterReturn(notificationService);
      mocker.mockFunc(notificationService, notificationService.updateBadgeNumber);

      mocker.mockFunc(mmsStaticSubscriber.receiveService, mmsStaticSubscriber.receiveService.startMmsAbilityAndSendNotify);
      mmsStaticSubscriber.onReceiveEvent(data);
      expect(mmsStaticSubscriber).not().assertUndefined();
      mocker.clear(notificationService);
      mocker.clear(mmsStaticSubscriber.receiveService);
    })

    it('mmsStaticSubscriberTest_onReceiveEvent_if9', 0, () => {
      let mmsStaticSubscriber: MmsStaticSubscriber = new MmsStaticSubscriber();
      let context: StaticSubscriberExtensionContext =
        DTGlobalContext.getContext().getObject('mmsContext') as StaticSubscriberExtensionContext;
      mmsStaticSubscriber.context = context;
      let data: DataParameters = {
        bundleName: "string;",
        code: 1,
        event: 'usual.event.SHUTDOWN',
        parameters: {
          action: '',
          isCdma: true,
          isNotificationFlag: false,
          isShow: true,
          moduleName: "string;",
          pdus: [],
          slotId: 1,
          id: 1,
          telephone: "111",
          mobilePhoneNumber: "1111",
          msgId: "111",
          type: "111",
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        data: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      mmsStaticSubscriber.onReceiveEvent(data);
      expect(mmsStaticSubscriber).not().assertUndefined();
      mocker.clear(HiLog);
    })

    it('mmsStaticSubscriberTest_onReceiveEvent_if10', 0, () => {
      let mmsStaticSubscriber: MmsStaticSubscriber = new MmsStaticSubscriber();
      let context: StaticSubscriberExtensionContext =
        DTGlobalContext.getContext().getObject('mmsContext') as StaticSubscriberExtensionContext;
      mmsStaticSubscriber.context = context;
      let data: DataParameters = {
        bundleName: "string;",
        code: 1,
        event: 'smsrdb.event.StoreChanged',
        parameters: {
          action: '',
          isCdma: true,
          isNotificationFlag: false,
          isShow: true,
          moduleName: "string;",
          pdus: [],
          slotId: 1,
          id: 1,
          telephone: "111",
          mobilePhoneNumber: "1111",
          msgId: "111",
          type: "111",
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        data: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();
      let notificationService: NotificationService = new NotificationService();
      when(mocker.mockFunc(NotificationService, NotificationService.getInstance))(ArgumentMatchers.any)
        .afterReturn(notificationService);
      mocker.mockFunc(notificationService, notificationService.updateBadgeNumber);
      mmsStaticSubscriber.onReceiveEvent(data);
      expect(mmsStaticSubscriber).not().assertUndefined();
      mocker.clear(notificationService);
    })

    it('mmsStaticSubscriberTest_onReceiveEvent_if11', 0, () => {
      let mmsStaticSubscriber: MmsStaticSubscriber = new MmsStaticSubscriber();
      let context: StaticSubscriberExtensionContext =
        DTGlobalContext.getContext().getObject('mmsContext') as StaticSubscriberExtensionContext;
      mmsStaticSubscriber.context = context;
      let data: DataParameters = {
        bundleName: "string;",
        code: 1,
        event: 'usual.event.USER_UNLOCKED',
        parameters: {
          action: '',
          isCdma: true,
          isNotificationFlag: false,
          isShow: true,
          moduleName: "string;",
          pdus: [],
          slotId: 1,
          id: 1,
          telephone: "111",
          mobilePhoneNumber: "1111",
          msgId: "111",
          type: "111",
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        data: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();
      let oobeResulr = oobeResult.getInstance()
      when(mocker.mockFunc(oobeResulr, oobeResulr.getMmsNoticeOobeFromUI))(ArgumentMatchers.any)
        .afterReturn(true);
      mmsStaticSubscriber.onReceiveEvent(data);
      expect(mmsStaticSubscriber).not().assertUndefined();
      mocker.clear(oobeResulr);
    })

    it('mmsStaticSubscriberTest_onReceiveEvent_if12', 0, () => {
      let mmsStaticSubscriber: MmsStaticSubscriber = new MmsStaticSubscriber();
      let context: StaticSubscriberExtensionContext =
        DTGlobalContext.getContext().getObject('mmsContext') as StaticSubscriberExtensionContext;
      mmsStaticSubscriber.context = context;
      let data: DataParameters = {
        bundleName: "string;",
        code: 1,
        event: 'usual.event.USER_UNLOCKED',
        parameters: {
          action: '',
          isCdma: true,
          isNotificationFlag: false,
          isShow: true,
          moduleName: "string;",
          pdus: [],
          slotId: 1,
          id: 1,
          telephone: "111",
          mobilePhoneNumber: "1111",
          msgId: "111",
          type: "111",
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        data: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();
      let oobeResulr = oobeResult.getInstance()
      when(mocker.mockFunc(oobeResulr, oobeResulr.getMmsNoticeOobeFromUI))(ArgumentMatchers.any)
        .afterReturn(false);
      mmsStaticSubscriber.onReceiveEvent(data);
      expect(mmsStaticSubscriber).not().assertUndefined();
      mocker.clear(oobeResulr);
    })

    it('mmsStaticSubscriberTest_onReceiveEvent_if13', 0, () => {
      let mmsStaticSubscriber: MmsStaticSubscriber = new MmsStaticSubscriber();
      let context: StaticSubscriberExtensionContext =
        DTGlobalContext.getContext().getObject('mmsContext') as StaticSubscriberExtensionContext;
      mmsStaticSubscriber.context = context;
      let data: DataParameters = {
        bundleName: "string;",
        code: 1,
        event: 'usual.event.BOOT_COMPLETED',
        parameters: {
          action: '',
          isCdma: true,
          isNotificationFlag: false,
          isShow: true,
          moduleName: "string;",
          pdus: [],
          slotId: 1,
          id: 1,
          telephone: "111",
          mobilePhoneNumber: "1111",
          msgId: "111",
          type: "111",
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        data: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();
      let oobeResulr = oobeResult.getInstance()
      when(mocker.mockFunc(oobeResulr, oobeResulr.getMmsNoticeOobeFromUI))(ArgumentMatchers.any)
        .afterReturn(false);
      mmsStaticSubscriber.onReceiveEvent(data);
      expect(mmsStaticSubscriber).not().assertUndefined();
      mocker.clear(oobeResulr);
    })

    it('mmsStaticSubscriberTest_onReceiveEvent_if14', 0, () => {
      let mmsStaticSubscriber: MmsStaticSubscriber = new MmsStaticSubscriber();
      let context: StaticSubscriberExtensionContext =
        DTGlobalContext.getContext().getObject('mmsContext') as StaticSubscriberExtensionContext;
      mmsStaticSubscriber.context = context;
      let data: DataParameters = {
        bundleName: "string;",
        code: 1,
        event: 'usual.event.BOOT_COMPLETED',
        parameters: {
          action: '',
          isCdma: true,
          isNotificationFlag: false,
          isShow: true,
          moduleName: "string;",
          pdus: [],
          slotId: 1,
          id: 1,
          telephone: "111",
          mobilePhoneNumber: "1111",
          msgId: "111",
          type: "111",
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        data: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();
      let oobeResulr = oobeResult.getInstance()
      when(mocker.mockFunc(oobeResulr, oobeResulr.getMmsNoticeOobeFromUI))(ArgumentMatchers.any)
        .afterReturn(true);
      mmsStaticSubscriber.onReceiveEvent(data);
      expect(mmsStaticSubscriber).not().assertUndefined();
      mocker.clear(oobeResulr);
    })

    it('mmsStaticSubscriberTest_reportSuccessRate_null', 0, () => {
      let mmsStaticSubscriber: MmsStaticSubscriber = new MmsStaticSubscriber();
      let context: StaticSubscriberExtensionContext =
        DTGlobalContext.getContext().getObject('mmsContext') as StaticSubscriberExtensionContext;
      mmsStaticSubscriber.context = context;
      (mmsStaticSubscriber as object)['reportSuccessRate'](null);
      expect(mmsStaticSubscriber).not().assertUndefined();
    })
  })
}