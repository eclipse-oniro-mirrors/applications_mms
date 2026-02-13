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
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import ServiceExtAbility from '../../../../main/ets/StaticSubscriber/ServiceExtAbility';
import { Want } from '@kit.AbilityKit';
import SharedPreferencesUtils from '../../../../main/ets/utils/SharedPreferencesUtils';
import DotUtil from '../../../../main/ets/utils/MmsDot/DotUtils';
import HiLog from '../../../../main/ets/utils/HiLog';
import LooseObject from '../../../../main/ets/data/LooseObject';
import { receiveParams } from '../../../../main/ets/utils/MmsDot/DotCommon';
import { SmartMmsServiceRpcService } from '../../../../main/ets/ServiceExtension/smartRpc/SmartMmsServiceRpcService';
import ReceiveService from '../../../../main/ets/StaticSubscriber/ReceiveService';
import { LocationType, MessageDetail } from '../../../../main/ets/utils/TypesUtils';
import NotificationService from '../../../../main/ets/service/NotificationService';
import { UnLockedNotifyService } from '../../../../main/ets/utils/UnLockedNotifyService';

export default function serviceExtAbilityTest() {
  describe('serviceExtAbilityTest', () => {

    const TAG = 'ServiceExtAbility';

    it('serviceExtAbilityTest_onCreate', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      mocker.mockFunc(SharedPreferencesUtils,SharedPreferencesUtils.init);
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      serviceExtAbility.onCreate({});
      mocker.verify('setObject', ['mmsServiceContext', serviceExtAbility.context]).once();
      mocker.clear(GlobalContext.getContext());
      mocker.clear(SharedPreferencesUtils);
    })

    it('serviceExtAbilityTest_onRequest_if2', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.e);
      let want: LooseObject = {
        parameters: null
      };
      new ServiceExtAbility().onRequest(want as Want, 0);
      mocker.verify('e', [TAG, 'ServiceExtensionAbility onRequest onRequest is null']).never();
      mocker.clear(HiLog);
    })

    it('serviceExtAbilityTest_onRequest_if1', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.e);
      new ServiceExtAbility().onRequest(null, 0);
      mocker.verify('e', [TAG, 'ServiceExtensionAbility onRequest want is null']).never();
      mocker.clear(HiLog);
    })

    it('serviceExtAbilityTest_onRequest_case1', 0, () => {
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      let want: Want = {
        parameters: {
          data: {},
          flag: 1,
          taskId: 1,
          action: 'notification.event.readdata',
          isNotificationFlag: true,
          event: 'usual.event.SMS_RECEIVE_COMPLETED',
          serviceEvent: 'blocked_service_mms_detect_event'
        }
      } as Want;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(serviceExtAbility.receiveService, serviceExtAbility.receiveService.applyEfficiencyResources);
      serviceExtAbility.onRequest(want, 0);
      receiveParams.MSG_TYPE = 3;
      mocker.verify('e', [TAG, 'ServiceExtensionAbility onRequest onRequest is null']).never();
      mocker.clear(serviceExtAbility.receiveService);
    })

    it('serviceExtAbilityTest_onRequest_case2', 0, () => {
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      let want: Want = {
        parameters: {
          data: {},
          serviceEvent: 'vercode_service_event',
          action: 'notification.event.readdata1',
          isNotificationFlag: false,
          event: 'usual.event.SMS_RECEIVE_COMPLETED',
          isCdma: false,
          isShow: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 1,
          taskId: 1,
          telephone: '570977632',
          mobilePhoneNumber: '570977632',
          msgId: '',
          type: ''
        }
      } as Want;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      let serviceConnect: Function = mocker.mockFunc(SmartMmsServiceRpcService.serviceInstance(),
        SmartMmsServiceRpcService.serviceInstance().serviceConnect);
      when(serviceConnect)(ArgumentMatchers.any)
        .afterReturn(new Promise<boolean>(resolve => resolve(false)));
      mocker.mockFunc(HiLog, HiLog.e);
      serviceExtAbility.onRequest(want, 0);
      mocker.verify('e', [TAG, 'ServiceExtensionAbility onRequest onRequest is null']).times(0);
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(ReceiveService.getInstance());
      mocker.clear(HiLog);
      mocker.clear(SmartMmsServiceRpcService.serviceInstance());
    })

    it('serviceExtAbilityTest_onRequest_case2_noIf', 0, () => {
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      let want: Want = {
        parameters: {
          data: {},
          serviceEvent: 'vercode_service_event',
          action: 'notification.event.readdata1',
          isNotificationFlag: false,
          event: 'usual.event.SMS_RECEIVE_COMPLETED',
          isCdma: false,
          isShow: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 1,
          taskId: 1,
          telephone: '570977632',
          mobilePhoneNumber: '570977632',
          msgId: '',
          type: ''
        }
      } as Want;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      let serviceConnect: Function = mocker.mockFunc(SmartMmsServiceRpcService.serviceInstance(),
        SmartMmsServiceRpcService.serviceInstance().serviceConnect);
      when(serviceConnect)(serviceExtAbility.context)
        .afterReturn(new Promise<boolean>(resolve => resolve(true)));
      mocker.mockFunc(HiLog, HiLog.i);
      mocker.mockFunc(serviceExtAbility.receiveService, serviceExtAbility.receiveService.applyEfficiencyResources);
      serviceExtAbility.onRequest(want, 0);
      mocker.verify('e', [TAG, 'ServiceExtensionAbility onRequest onRequest is null']).never();
      serviceExtAbility.onRequest(want, 0);
      mocker.verify('e', [TAG, 'ServiceExtensionAbility onRequest onRequest is null']).never();
      mocker.verify('e', [TAG, 'ServiceExtensionAbility onRequest onRequest is null']).never();
      mocker.clear(DotUtil.getInstance());
      mocker.clear(ReceiveService.getInstance());
      mocker.clear(HiLog);
      mocker.clear(SmartMmsServiceRpcService.serviceInstance());
      mocker.clear(serviceExtAbility.receiveService);
    })

    it('serviceExtAbilityTest_onRequest_case2_noIf1', 0, () => {
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      let want: Want = {
        parameters: {
          data: {},
          serviceEvent: 'vercode_service_event',
          action: 'notification.event.readdata1',
          isNotificationFlag: false,
          event: 'usual.event.SMS_RECEIVE_COMPLETED',
          isCdma: false,
          isShow: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 1,
          taskId: 1,
          telephone: '570977632',
          mobilePhoneNumber: '570977632',
          msgId: '',
          type: ''
        }
      } as Want;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      let serviceConnect: Function = mocker.mockFunc(SmartMmsServiceRpcService.serviceInstance(),
        SmartMmsServiceRpcService.serviceInstance().serviceConnect);
      when(serviceConnect)(serviceExtAbility.context)
        .afterReturn(new Promise<boolean>(resolve => resolve(true)));
      mocker.mockFunc(HiLog, HiLog.i);
      mocker.mockFunc(serviceExtAbility.receiveService, serviceExtAbility.receiveService.applyEfficiencyResources);
      serviceExtAbility.onRequest(want, 0);
      mocker.verify('e', [TAG, 'ServiceExtensionAbility onRequest onRequest is null']).never();

      mocker.clear(DotUtil.getInstance());
      mocker.clear(ReceiveService.getInstance());
      mocker.clear(HiLog);
      mocker.clear(SmartMmsServiceRpcService.serviceInstance());
      mocker.clear(serviceExtAbility.receiveService);
    })

    it('serviceExtAbilityTest_onRequest_case2_noIf2', 0, () => {
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      let want: Want = {
        parameters: {
          data: {},
          serviceEvent: 'vercode_service_event',
          action: 'notification.event.readdata1',
          isNotificationFlag: false,
          event: 'usual.event.SMS_RECEIVE_COMPLETED',
          isCdma: false,
          isShow: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 1,
          taskId: 1,
          telephone: '570977632',
          mobilePhoneNumber: '570977632',
          msgId: '',
          type: ''
        }
      } as Want;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      let serviceConnect: Function = mocker.mockFunc(SmartMmsServiceRpcService.serviceInstance(),
        SmartMmsServiceRpcService.serviceInstance().serviceConnect);
      when(serviceConnect)(serviceExtAbility.context)
        .afterReturn(new Promise<boolean>(resolve => resolve(true)));
      mocker.mockFunc(HiLog, HiLog.i);
      mocker.mockFunc(serviceExtAbility.receiveService, serviceExtAbility.receiveService.applyEfficiencyResources);
      serviceExtAbility.onRequest(want, 0);
      mocker.verify('e', [TAG, 'ServiceExtensionAbility onRequest onRequest is null']).never();

      mocker.clear(DotUtil.getInstance());
      mocker.clear(ReceiveService.getInstance());
      mocker.clear(HiLog);
      mocker.clear(SmartMmsServiceRpcService.serviceInstance());
      mocker.clear(serviceExtAbility.receiveService);
    })

    it('serviceExtAbilityTest_onRequest_if3_noIf4_elseIf_noIf7', 0, () => {
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      let want: Want = {
        parameters: {
          data: {},
          serviceEvent: 'vercode_service_event1',
          action: 'notification.event.readdata1',
          isNotificationFlag: false,
          event: 'usual.event.SMS_RECEIVE_COMPLETED',
          isCdma: false,
          isShow: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 1,
          taskId: 1,
          telephone: '570977632',
          mobilePhoneNumber: '570977632',
          msgId: '',
          type: ''
        }
      } as Want;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      mocker.mockFunc(HiLog, HiLog.e);
      serviceExtAbility.onRequest(want, 0);
      mocker.verify('e', [TAG, 'ServiceExtensionAbility onRequest onRequest is null']).never();
      mocker.clear(DotUtil.getInstance());
      mocker.clear(HiLog);
    })

    it('serviceExtAbilityTest_onRequest_SUBSCRIBER_SCREEN_UNLOCK_EVENT', 0, () => {
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      let want: Want = {
        parameters: {
          data: {},
          serviceEvent: 'usual.event.SCREEN_UNLOCKED',
          action: 'notification.event.readdata1',
          isNotificationFlag: false,
          event: 'usual.event.SCREEN_UNLOCKED',
          isCdma: false,
          isShow: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 1,
          taskId: 1,
          telephone: '570977632',
          mobilePhoneNumber: '570977632',
          msgId: '',
          type: ''
        }
      } as Want;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.e);
      serviceExtAbility.onRequest(want, 0);
      mocker.verify('e', [TAG, 'ServiceExtensionAbility onRequest onRequest is null']).never();
      mocker.clear(HiLog);
    })

    it('serviceExtAbilityTest_onRequest_KEY_DATA_TO_EL5', 0, () => {
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      let want: Want = {
        parameters: {
          data: {},
          serviceEvent: 'smsrdb.event.StoreChanged',
          action: 'notification.event.readdata1',
          isNotificationFlag: false,
          event: 'smsrdb.event.StoreChanged',
          isCdma: false,
          isShow: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 1,
          taskId: 1,
          telephone: '570977632',
          mobilePhoneNumber: '570977632',
          msgId: '',
          type: ''
        }
      } as Want;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.e);
      serviceExtAbility.onRequest(want, 0);
      mocker.verify('e', [TAG, 'ServiceExtensionAbility onRequest onRequest is null']).never();
      mocker.clear(HiLog);
    })

    it('serviceExtAbilityTest_onRequest_SUBSCRIBER_FIRST_LOCK_RECV_EVENT', 0, () => {
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      let want: Want = {
        parameters: {
          data: {},
          serviceEvent: 'usual.event.FIRST_LOCK_RECEIVE_STATUS',
          action: 'notification.event.readdata1',
          isNotificationFlag: false,
          event: 'usual.event.FIRST_LOCK_RECEIVE_STATUS',
          isCdma: false,
          isShow: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 1,
          taskId: 1,
          telephone: '570977632',
          mobilePhoneNumber: '570977632',
          msgId: '',
          type: ''
        }
      } as Want;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.e);
      serviceExtAbility.onRequest(want, 0);
      mocker.verify('e', [TAG, 'ServiceExtensionAbility onRequest onRequest is null']).never();
      mocker.clear(HiLog);
    })

    it('serviceExtAbilityTest_onRequest_SUBSCRIBER_FIRST_LOCK_RECV_EVENT_dataIsMoveEL5_true', 0, () => {
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      let want: Want = {
        parameters: {
          data: null,
          serviceEvent: 'usual.event.FIRST_LOCK_RECEIVE_STATUS',
          action: 'notification.event.readdata1',
          isNotificationFlag: false,
          event: 'usual.event.FIRST_LOCK_RECEIVE_STATUS',
          isCdma: false,
          isShow: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 1,
          taskId: 1,
          telephone: '570977632',
          mobilePhoneNumber: '570977632',
          msgId: '',
          type: ''
        }
      } as Want;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      UnLockedNotifyService.getInstance().dataIsMoveEL5 = true;
      serviceExtAbility.onRequest(want, 0);
      UnLockedNotifyService.getInstance().dataIsMoveEL5 = false;
      mocker.verify('i', [TAG, 'first lock receive notification data']).never();
      mocker.clear(HiLog);
    })

    it('serviceExtAbilityTest_onRequest_SUBSCRIBER_FIRST_LOCK_RECV_EVENT_dataIsMoveEL5_true_notificationData', 0, () => {
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      let want: Want = {
        parameters: {
          data: {
            bundleName: 'string',
            code: 1,
            data: 'string',
            event: 'string',
            isFirstUnlocked: true,
            isAfterNoReadButton: true,
            isAfterReSendNotification: true,
            deliveryTime: 0,
            parameters: {}
          },
          serviceEvent: 'usual.event.FIRST_LOCK_RECEIVE_STATUS',
          action: 'notification.event.readdata1',
          isNotificationFlag: false,
          event: 'usual.event.FIRST_LOCK_RECEIVE_STATUS',
          isCdma: false,
          isShow: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 1,
          taskId: 1,
          telephone: '570977632',
          mobilePhoneNumber: '570977632',
          msgId: '',
          type: ''
        }
      } as Want;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      when(mocker.mockFunc(UnLockedNotifyService.getInstance(),
        UnLockedNotifyService.getInstance().sendFirstLockReceiveNotify))(ArgumentMatchers.any).afterReturnNothing();
      UnLockedNotifyService.getInstance().dataIsMoveEL5 = true;
      serviceExtAbility.onRequest(want, 0);
      UnLockedNotifyService.getInstance().dataIsMoveEL5 = false;
      mocker.clear(NotificationService.getInstance(serviceExtAbility.context));
      mocker.verify('i', [TAG, 'first lock receive notification data']).atLeast(1);
      mocker.clear(HiLog);
    })

    it('serviceExtAbilityTest_onRequest_blocked_service_rcs_detect_event', 0, () => {
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      let want: Want = {
        parameters: {
          data: {},
          serviceEvent: 'blocked_service_rcs_detect_event',
          action: 'notification.event.readdata1',
          isNotificationFlag: false,
          event: 'blocked_service_rcs_detect_event',
          isCdma: false,
          isShow: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 1,
          taskId: 1,
          telephone: '570977632',
          mobilePhoneNumber: '570977632',
          msgId: '',
          type: ''
        }
      } as Want;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.e);
      serviceExtAbility.onRequest(want, 0);
      mocker.verify('e', [TAG, 'ServiceExtensionAbility onRequest onRequest is null']).never();
      mocker.clear(HiLog);
    })

    it('serviceExtAbilityTest_onDisconnect', 0, () => {
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      serviceExtAbility.onDisconnect({});
      mocker.verify('i', [TAG, 'ServiceExtensionAbility onDisconnect']).once();
      mocker.clear(HiLog);
    })

    it('serviceExtAbilityTest_onRequest_case_loc', 0, () => {
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      let actionData: MessageDetail = new MessageDetail;
      actionData.content = '{"body":"name;address","longitude":"1","latitude":"1","accuracy":"0"}';
      let location: LocationType = {
        latitude: 1,
        longitude: 1
      }
      let want: Want = {
        parameters: {
          data: actionData,
          flag: 1,
          taskId: 1,
          action: 'notification.event.readdata',
          isNotificationFlag: true,
          event: 'usual.event.SMS_RECEIVE_COMPLETED',
          serviceEvent: 'rcs_location_get_thumbnails',
          location: location
        }
      } as Want;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(serviceExtAbility.receiveService, serviceExtAbility.receiveService.getLocThumbnails);
      serviceExtAbility.onRequest(want, 0);
      receiveParams.MSG_TYPE = 1;
      mocker.verify('e', [TAG, 'ServiceExtensionAbility onRequest onRequest is null']).never();
      mocker.clear(serviceExtAbility.receiveService);
    })

    it('serviceExtAbilityTest_onRequest_case_SERVICE_EVENT_HANDLE_RECEIVE_CHATBOT_MESSAGE_data_empty', 0, () => {
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      let location: LocationType = {
        latitude: 1,
        longitude: 1
      }
      let want: Want = {
        parameters: {
          data: undefined,
          flag: 1,
          slotId: 1,
          action: 'notification.event.readdata',
          isNotificationFlag: true,
          event: 'usual.event.SMS_RECEIVE_COMPLETED',
          serviceEvent: 'serviceEventHandleReceiveChatbotMessage',
          location: location
        }
      } as Want;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      mocker.mockFunc(HiLog, HiLog.e);
      serviceExtAbility.onRequest(want, 0);
      receiveParams.MSG_TYPE = 1;
      mocker.clear(NotificationService.getInstance());
      mocker.verify('i', [TAG, 'onRequest: handleReceiveChatbotMessage']).atLeast(1);
      mocker.verify('e', [TAG, 'onRequest: handleReceiveChatbotMessage data is empty']).atLeast(1);
      mocker.clear(HiLog);
    })

    it('serviceExtAbilityTest_onRequest_case_SERVICE_EVENT_HANDLE_RECEIVE_CHATBOT_MESSAGE_data_not_empty', 0, () => {
      let serviceExtAbility: ServiceExtAbility = new ServiceExtAbility();
      let location: LocationType = {
        latitude: 1,
        longitude: 1
      }
      let want: Want = {
        parameters: {
          data: {
            bundleName: 'string',
            code: 1,
            data: 'string',
            event: 'string',
            isFirstUnlocked: true,
            isAfterNoReadButton: true,
            isAfterReSendNotification: true,
            deliveryTime: 0,
            parameters: {}
          },
          flag: 1,
          slotId: 1,
          action: 'notification.event.readdata',
          isNotificationFlag: true,
          event: 'usual.event.SMS_RECEIVE_COMPLETED',
          serviceEvent: 'serviceEventHandleReceiveChatbotMessage',
          location: location
        }
      } as Want;
      (serviceExtAbility as object)['handleRcsChatbotMessage'] = () => {};
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      mocker.mockFunc(HiLog, HiLog.e);
      serviceExtAbility.onRequest(want, 0);
      receiveParams.MSG_TYPE = 1;
      mocker.clear(NotificationService.getInstance());
      mocker.verify('i', [TAG, 'onRequest: handleReceiveChatbotMessage']).atLeast(1);
      mocker.verify('e', [TAG, 'onRequest: handleReceiveChatbotMessage data is empty']).never();
      mocker.clear(HiLog);
    })
  })
}