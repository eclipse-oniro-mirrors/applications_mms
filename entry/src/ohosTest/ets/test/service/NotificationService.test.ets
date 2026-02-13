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
import { describe, beforeEach, afterEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import NotificationService, {
  IBadgeContextInfo,
  MmsReplayParameters,
  MmswantAgentInfo
} from '../../../../main/ets/service/NotificationService';
import LooseObject from '../../../../main/ets/data/LooseObject';
import { BaseDataParameters, DataParameters } from '../../../../main/ets/utils/TypesUtils';
import { image } from '@kit.ImageKit';
import YellowPageService from '../../../../main/ets/service/yellowPageService';
import { resourceManager } from '@kit.LocalizationKit';
import StringUtil from '../../../../main/ets/utils/StringUtil';
import { notificationManager } from '@kit.NotificationKit';
import MmsPreferences from '../../../../main/ets/utils/MmsPreferences';
import { commonPasteboard } from '../../../../main/ets/data/Pasteboard';
import { window } from '@kit.ArkUI';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import ConversationListService from '../../../../main/ets/service/ConversationListService';
import ConversationService from '../../../../main/ets/service/ConversationService';
import common from '../../../../main/ets/data/commonData';
import wantAgent from '@ohos.app.ability.wantAgent'
import HiLog from '../../../../main/ets/utils/HiLog';
import { AsyncCallback, screenLock, systemDateTime } from '@kit.BasicServicesKit';
import SharedPreferencesUtils from '../../../../main/ets/utils/SharedPreferencesUtils';
import DotUtil from '../../../../main/ets/utils/MmsDot/DotUtils';
import JudgeNetWork from '../../../../main/ets/service/JudgeNetWork';
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';
import { dataShare } from '@kit.ArkData';
import { UnLockedNotifyService } from '../../../../main/ets/utils/UnLockedNotifyService';

export default function notificationServiceTest() {
  describe('notificationServiceTest', () => {

    let service: NotificationService;
    let context: Context;
    let mocker: MockKit;
    const TAG: string = 'NotificationService';

    beforeEach(() => {
      context = {
        resourceManager: {
          getStringSync: (resource: Resource): string => '',
          getRawFd: (path: string): Promise<resourceManager.RawFileDescriptor> => new Promise<resourceManager.RawFileDescriptor>(resolve => resolve({
            fd: 10,
            offset: 10,
            length: 100
          } as resourceManager.RawFileDescriptor)),
          getMediaContent: (resId: number): Promise<Uint8Array> => new Promise<Uint8Array>(resolve => resolve(new Uint8Array(10)))
        }
      } as Context;
      service = NotificationService.getInstance(context);
      mocker = new MockKit();
    })

    afterEach(() => {
      mocker.clear(service);
    })

    it('NotificationServiceTest_sendNotify_verCode', 0, () => {
      let actionData: LooseObject = {
        "msgId": 1,
        "isMute": 1,
        "slotId": 0,
        "telephone": 10086,
        "verCode": "110011",
        "message": {
          title: 'title'
        },
        "smsType": 0
      };

      when(mocker.mockFunc(service, service.buildWantAgentInfoCopy))(ArgumentMatchers.any)
        .afterReturn({
          wants: [],
          requestCode: 0,
        } as wantAgent.WantAgentInfo);
      when(mocker.mockFunc(service, service.buildWantAgentInfoRead))(ArgumentMatchers.any)
        .afterReturn({
          wants: [],
          requestCode: 1,
        } as wantAgent.WantAgentInfo);
      when(mocker.mockFunc(service, service.buildWantAgentInfo))(ArgumentMatchers.any)
        .afterReturn({
          wants: [],
          requestCode: 2,
        } as wantAgent.WantAgentInfo);
      mocker.mockFunc(service, service.getWantAgent);
      when(mocker.mockFunc(service, service.getIconPixelMap))(ArgumentMatchers.any)
        .afterReturn(new Promise<image.PixelMap>(resolve => resolve({} as image.PixelMap)));
      when(mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().judgeNoticeYellowPageExist))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          name: 'name',
          yellowPageId: '',
          photo: ''
        } as LooseObject)));
      mocker.mockFunc(service, service.pushNotificationRequest);

      service.sendNotify(actionData, context);

      expect(actionData.message.title).assertEqual('title');

      mocker.clear(service);
      mocker.clear(YellowPageService.getInstance());
    })

    it('NotificationServiceTest_sendNotify_photo_notEmpty', 0, () => {
      let actionData: LooseObject = {
        "msgId": 1,
        "isMute": 1,
        "slotId": 1,
        "telephone": 10086,
        "verCode": "110011",
        "message": {
          title: 'title'
        },
        "smsType": 0
      };

      when(mocker.mockFunc(service, service.buildWantAgentInfoCopy))(ArgumentMatchers.any)
        .afterReturn({
          wants: [],
          requestCode: 0,
        } as wantAgent.WantAgentInfo);
      when(mocker.mockFunc(service, service.buildWantAgentInfoRead))(ArgumentMatchers.any)
        .afterReturn({
          wants: [],
          requestCode: 1,
        } as wantAgent.WantAgentInfo);
      when(mocker.mockFunc(service, service.buildWantAgentInfo))(ArgumentMatchers.any)
        .afterReturn({
          wants: [],
          requestCode: 2,
        } as wantAgent.WantAgentInfo);
      mocker.mockFunc(service, service.getWantAgent);
      when(mocker.mockFunc(service, service.getIconPixelMap))(ArgumentMatchers.any)
        .afterReturn(new Promise<image.PixelMap>(resolve => resolve({} as image.PixelMap)));
      when(mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().judgeNoticeYellowPageExist))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          name: 'name',
          yellowPageId: '1',
          photo: 'xx'
        } as LooseObject)));
      mocker.mockFunc(service, service.pushNotificationRequest);

      service.sendNotify(actionData, context);

      expect(actionData.message.title).assertEqual('title');

      mocker.clear(YellowPageService.getInstance());
      mocker.clear(service);
    })

    it('NotificationServiceTest_sendNotify_verCodeLength0_photo_notEmpty_contactId', 0, () => {
      AppStorage.setOrCreate("contactsPhotoMap", {
        "1": {} as image.PixelMap
      })
      let actionData: LooseObject = {
        "msgId": 1,
        "isMute": 1,
        "telephone": 10086,
        "verCode": "110011",
        "message": {
          title: 'title'
        },
        "smsType": 0,
        "slotId": 0
      };
      let contactObjects: LooseObject[] = [{
        'contactId': '1',
        'contactName': 'name'
      }];
      when(mocker.mockFunc(service, service.buildWantAgentInfo))(ArgumentMatchers.any)
        .afterReturn({
          wants: [],
          requestCode: 2,
          extraInfo: {
            contactObjects: JSON.stringify(contactObjects)
          }
        } as wantAgent.WantAgentInfo);
      when(mocker.mockFunc(service, service.buildWantAgentInfoRead))(ArgumentMatchers.any)
        .afterReturn({
          wants: [],
          requestCode: 1,
        } as wantAgent.WantAgentInfo);
      mocker.mockFunc(service, service.getWantAgent);
      when(mocker.mockFunc(service, service.getIconPixelMap))(ArgumentMatchers.any)
        .afterReturn(new Promise<image.PixelMap>(resolve => resolve({} as image.PixelMap)));
      mocker.mockFunc(service, service.pushNotificationRequest);

      service.sendNotify(actionData, context);
      mocker.clear(service);

      expect(actionData.message.title).assertEqual('title');
    })

    it('NotificationServiceTest_sendNotify_verCodeLength0_photo_notEmpty_contactName', 0, () => {
      AppStorage.setOrCreate("contactsPhotoMap", {
        "1": null
      })
      let actionData: LooseObject = {
        "msgId": 1,
        "isMute": 1,
        "telephone": 10086,
        "verCode": "110011",
        "message": {
          title: 'title'
        },
        "smsType": 0,
        "slotId": 1
      };
      let contactObjects: LooseObject[] = [{
        'contactId': "1",
        'contactName': 'name x'
      }];
      when(mocker.mockFunc(service, service.buildWantAgentInfo))(ArgumentMatchers.any)
        .afterReturn({
          wants: [],
          requestCode: 2,
          extraInfo: {
            contactObjects: JSON.stringify(contactObjects)
          }
        } as wantAgent.WantAgentInfo);
      when(mocker.mockFunc(service, service.buildWantAgentInfoRead))(ArgumentMatchers.any)
        .afterReturn({
          wants: [],
          requestCode: 1,
        } as wantAgent.WantAgentInfo);
      mocker.mockFunc(service, service.getWantAgent);
      when(mocker.mockFunc(service, service.getIconPixelMap))(ArgumentMatchers.any)
        .afterReturn(new Promise<image.PixelMap>(resolve => resolve({} as image.PixelMap)));
      mocker.mockFunc(service, service.pushNotificationRequest);
      when(mocker.mockFunc(StringUtil, StringUtil.getFirstName))(ArgumentMatchers.any)
        .afterReturn('name')

      service.sendNotify(actionData, context);

      expect(actionData.message.title).assertEqual('title');

      mocker.clear(StringUtil);
      mocker.clear(service);
    })

    it('NotificationServiceTest_sendNotify_verCodeLength0_photo_notEmpty', 0, () => {
      AppStorage.setOrCreate("contactsPhotoMap", {
        "1": null
      })
      let actionData: LooseObject = {
        "msgId": 1,
        "telephone": 10086,
        "verCode": "110011",
        "message": {
          title: 'title'
        },
        "smsType": 0,
        "slotId": 1
      };
      let contactObjects: LooseObject[] = [{
        'contactId': "1",
        'contactName': null
      }];
      when(mocker.mockFunc(service, service.buildWantAgentInfo))(ArgumentMatchers.any)
        .afterReturn({
          wants: [],
          requestCode: 2,
          extraInfo: {
            contactObjects: JSON.stringify(contactObjects)
          }
        } as wantAgent.WantAgentInfo);
      when(mocker.mockFunc(service, service.buildWantAgentInfoRead))(ArgumentMatchers.any)
        .afterReturn({
          wants: [],
          requestCode: 1,
        } as wantAgent.WantAgentInfo);
      mocker.mockFunc(service, service.getWantAgent);
      when(mocker.mockFunc(service, service.getIconPixelMap))(ArgumentMatchers.any)
        .afterReturn(new Promise<image.PixelMap>(resolve => resolve({} as image.PixelMap)));
      mocker.mockFunc(service, service.pushNotificationRequest);
      when(mocker.mockFunc(StringUtil, StringUtil.getFirstName))(ArgumentMatchers.any)
        .afterReturn('name')

      service.sendNotify(actionData, context);

      expect(actionData.message.title).assertEqual('title');

      mocker.clear(StringUtil);
      mocker.clear(service);
    })

    it('NotificationServiceTest_sendNotify_verCodeLength0_photo_notEmpty_contactId_null', 0, () => {
      AppStorage.setOrCreate("contactsPhotoMap", {
        "1": null
      })
      let actionData: LooseObject = {
        "msgId": 1,
        "telephone": 10086,
        "verCode": "",
        "message": {
          title: 'title'
        },
        "smsType": 0,
        "slotId": 0
      };
      let contactObjects: LooseObject[] = [{
        'contactId': null,
        'contactName': null
      }];
      when(mocker.mockFunc(service, service.buildWantAgentInfo))(ArgumentMatchers.any)
        .afterReturn({
          wants: [],
          requestCode: 2,
          extraInfo: {
            contactObjects: JSON.stringify(contactObjects)
          }
        } as wantAgent.WantAgentInfo);
      when(mocker.mockFunc(service, service.buildWantAgentInfoRead))(ArgumentMatchers.any)
        .afterReturn({
          wants: [],
          requestCode: 1,
        } as wantAgent.WantAgentInfo);
      mocker.mockFunc(service, service.getWantAgent);
      when(mocker.mockFunc(service, service.getIconPixelMap))(ArgumentMatchers.any)
        .afterReturn(new Promise<image.PixelMap>(resolve => resolve({} as image.PixelMap)));
      mocker.mockFunc(service, service.pushNotificationRequest);
      when(mocker.mockFunc(StringUtil, StringUtil.getFirstName))(ArgumentMatchers.any)
        .afterReturn('name');
      when(mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().judgeNoticeYellowPageExist))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          name: 'name',
          yellowPageId: '1',
          photo: 'xx'
        } as LooseObject)));

      service.sendNotify(actionData, context);

      expect(actionData.message.title).assertEqual('title');

      mocker.clear(StringUtil);
      mocker.clear(service);
      mocker.clear(YellowPageService.getInstance());
    })

    it('NotificationServiceTest_normalMMSSendNotify', 0, async () => {
      when(mocker.mockFunc(service, service.getWantAgent))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(service, service.pushNotificationRequest))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(service, service.buildWantAgentInfoRead))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));
      when(mocker.mockFunc(service, service.getIconPixelMap))(ArgumentMatchers.any)
        .afterReturn(new Promise<PixelMap>(resolve => resolve({
          release: (callback: AsyncCallback<void, void>): void => {
          }
        } as PixelMap)));
      when(mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().judgeNoticeYellowPageExist))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          yellowPageId: '',
          name: 'yellow'
        } as LooseObject)));
      when(mocker.mockFunc(JudgeNetWork.getInstance(),
        JudgeNetWork.getInstance().judgeHasNet))(ArgumentMatchers.any)
        .afterReturn(true);
      when(mocker.mockFunc(DotUtil.getInstance(),
        DotUtil.getInstance().setCurrentTime))(ArgumentMatchers.any)
        .afterReturn(10000);
      when(mocker.mockFunc(DotUtil.getInstance(),
        DotUtil.getInstance().securityReport))(ArgumentMatchers.any)
        .afterReturnNothing();
      await (service as object)['normalMMSSendNotify']({
        contactObjects:'[{"telephone": "12306", "contactName": "12306"}]',
        comName: 'comName',
        logoUrl: 'logoUrl',
        notificationType: 1,
        message: {
          title: ''
        },
        msgId: 1,
        yellowPageId: 0
      } as LooseObject, context);
      await (service as object)['normalMMSSendNotify']({
        contactObjects:'[{"telephone": "12306"}]',
        comName: '',
        logoUrl: '',
        notificationType: 1,
        message: {
          title: ''
        },
        msgId: 1,
        yellowPageId: 0
      } as LooseObject, context);
      await (service as object)['normalMMSSendNotify']({
        contactObjects:'[{"telephone": "sip:110@botplatform"}]',
        comName: 'comName',
        logoUrl: 'logoUrl',
        notificationType: 1,
        message: {
          title: ''
        },
        msgId: 1,
        yellowPageId: 0
      } as LooseObject, context);
      await (service as object)['normalMMSSendNotify']({
        contactObjects:'[{"telephone": "12306"}]',
        comName: '',
        logoUrl: '',
        notificationType: 1,
        message: {
          title: ''
        },
        msgId: 1,
        yellowPageId: 0
      } as LooseObject, context);
      mocker.clear(service);
      mocker.clear(YellowPageService.getInstance());
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(JudgeNetWork.getInstance());
      expect(service).not().assertUndefined();
    })

    it('NotificationServiceTest_normalMMSSendNotify_yellowPageId_not_empty', 0, async () => {
      when(mocker.mockFunc(service, service.getWantAgent))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(service, service.pushNotificationRequest))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(service, service.buildWantAgentInfoRead))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));
      when(mocker.mockFunc(service, service.getIconPixelMap))(ArgumentMatchers.any)
        .afterReturn(new Promise<PixelMap>(resolve => resolve({
          release: (callback: AsyncCallback<void, void>): void => {
          }
        } as PixelMap)));
      when(mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().judgeNoticeYellowPageExist))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          yellowPageId: '1',
          name: 'yellow'
        } as LooseObject)));
      when(mocker.mockFunc(JudgeNetWork.getInstance(),
        JudgeNetWork.getInstance().judgeHasNet))(ArgumentMatchers.any)
        .afterReturn(true);
      when(mocker.mockFunc(DotUtil.getInstance(),
        DotUtil.getInstance().setCurrentTime))(ArgumentMatchers.any)
        .afterReturn(10000);
      when(mocker.mockFunc(DotUtil.getInstance(),
        DotUtil.getInstance().securityReport))(ArgumentMatchers.any)
        .afterReturnNothing();
      AppStorage.setOrCreate('updateIsOpenSmartTestSetting', true);
      await (service as object)['normalMMSSendNotify']({
        contactObjects:'[{"telephone": "12306", "contactName": "12306"}]',
        comName: 'comName',
        logoUrl: 'logoUrl',
        notificationType: 1,
        message: {
          title: ''
        },
        msgId: 1,
        yellowPageId: 0
      } as LooseObject, context);
      await (service as object)['normalMMSSendNotify']({
        contactObjects:'[{"telephone": "12306"}]',
        comName: '',
        logoUrl: '',
        notificationType: 1,
        message: {
          title: ''
        },
        msgId: 1,
        yellowPageId: 0
      } as LooseObject, context);
      await (service as object)['normalMMSSendNotify']({
        contactObjects:'[{"telephone": "sip:110@botplatform"}]',
        comName: 'comName',
        logoUrl: 'logoUrl',
        notificationType: 1,
        message: {
          title: ''
        },
        msgId: 1,
        yellowPageId: 0
      } as LooseObject, context);
      await (service as object)['normalMMSSendNotify']({
        contactObjects:'[{"telephone": "12306"}]',
        comName: '',
        logoUrl: '',
        notificationType: 1,
        message: {
          title: ''
        },
        msgId: 1,
        yellowPageId: 0
      } as LooseObject, context);
      mocker.clear(service);
      mocker.clear(YellowPageService.getInstance());
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(JudgeNetWork.getInstance());
      AppStorage.clear();
      expect(service).not().assertUndefined();
    })

    it('NotificationServiceTest_judgeNoticeChatbot', 0, () => {
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));
      (service as object)['judgeNoticeChatbot']([{telephone: '110'} as LooseObject], context, {} as image.PixelMap,
        {
          contactObjects:'[{"telephone": "12306"}]',
          comName: '',
          logoUrl: '',
          notificationType: 1,
          message: {
            title: ''
          },
          msgId: 1,
          yellowPageId: 0
        } as LooseObject, 1, {} as LooseObject, 'titleStr', 'markStr', {} as LooseObject, 'contactNameStr110');
      mocker.clear(DataShareHelper.getInstance());
      expect(service).not().assertUndefined();
    })

    it('NotificationServiceTest_pushNotificationRequest', 0, () => {
      UnLockedNotifyService.getInstance().dataIsMoveEL5 = true;
      try {
        service.pushNotificationRequest({
          contactObjects: '[{"telephone": "12306"}]',
          comName: '',
          logoUrl: '',
          notificationType: 1,
          message: {
            title: ''
          },
          msgId: 1,
          yellowPageId: 0
        } as LooseObject, 1, {} as image.PixelMap,
          {} as LooseObject, 'titleStr', 'markStr',
          {} as LooseObject, 'contactObject', context, true, {} as LooseObject,
          1);
      } catch (e) {
      }
      expect(service).not().assertUndefined();
    })

    it('NotificationServiceTest_pushNotificationRequest_else', 0, () => {
      UnLockedNotifyService.getInstance().dataIsMoveEL5 = true;
      try {
        service.pushNotificationRequest({
          contactObjects: '[{"telephone": "12306"}]',
          comName: '',
          logoUrl: '',
          notificationType: 1,
          isFirstUnlocked : true,
          message: {
            title: ''
          },
          msgId: 1,
          yellowPageId: 0
        } as LooseObject, 1, {} as image.PixelMap,
          {} as LooseObject, 'titleStr', 'markStr',
          {} as LooseObject, 'contactObject', context, false);
      } catch (e) {
      }
      expect(service).not().assertUndefined();
    })

    it('NotificationServiceTest_notificationBarLayout', 0, () => {
      let context = GlobalContext.getContext().getObject('mmsContext') as Context;
      let notificationRequest: notificationManager.NotificationRequest = {
        content: {} as notificationManager.NotificationContent,
        wantAgent: {},
        actionButtons: [],
        overlayIcon: {} as image.PixelMap
      } as notificationManager.NotificationRequest;
      service.notificationBarLayout(notificationRequest, {} as LooseObject, undefined, "", "",
        {} as LooseObject, {} as LooseObject, 0, context);
      expect(JSON.stringify(notificationRequest.wantAgent)).assertEqual('{}');
    })

    it('NotificationServiceTest_sendBlockedNotify', 0, () => {
      let actionData: LooseObject = {
        "msgId": 1,
        "message": "111",
        "telephone": 10086
      };
      when(mocker.mockFunc(service, service.buildBlockedWantAgentInfo))(ArgumentMatchers.any)
        .afterReturn({} as wantAgent.WantAgentInfo);
      mocker.mockFunc(service, service.getWantAgent);
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getDefaultSlotId))()
        .afterReturn(0);
      when(mocker.mockFunc(service, service.getIconPixelMap))(ArgumentMatchers.any)
        .afterReturn(new Promise<image.PixelMap>(resolve => resolve({} as image.PixelMap)));
      let res = false;
      when(mocker.mockFunc(service, service.pushBlockedNotificationRequest))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      service.sendBlockedNotify(actionData, context);

      mocker.clear(service);
      expect(res).assertFalse();
    })

    it('NotificationServiceTest_copyVerCode_code', 0, async () => {
      let data: DataParameters = {
        parameters: {
          action: "string;",
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
          type: 'rcs_send',
          status: '1',
          clurSize: 1,
          totalSize: 1,
          fileName: '1',
          filePath: '1',
          fileType: '1',
          duration: '1',
          code: 1,
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        bundleName: '',
        code: 0,
        data: '',
        event: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let res = false;
      when(mocker.mockFunc(commonPasteboard, commonPasteboard.setPasteboard))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      await service.copyVerCode(data);
      expect(res).assertTrue();
      mocker.clear(commonPasteboard);
    })

    it('NotificationServiceTest_copyVerCode_code_null', 0, async () => {
      let data: DataParameters = {
        parameters: {
          action: "string;",
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
          type: 'rcs_send',
          status: '1',
          clurSize: 1,
          totalSize: 1,
          fileName: '1',
          filePath: '1',
          fileType: '1',
          duration: '1',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        bundleName: '',
        code: 0,
        data: '',
        event: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let res = false;
      when(mocker.mockFunc(commonPasteboard, commonPasteboard.setPasteboard))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      await service.copyVerCode(data);
      expect(res).assertFalse();
      mocker.clear(commonPasteboard);
    })

    it('NotificationServiceTest_markAsReadFromReceive', 0, () => {
      let actionData: LooseObject = {
        telephone: "111",
        threadIds: "1,2"
      };
      let res = false;
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().markAsReadFromReceive))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      service.markAsReadFromReceive(actionData);
      expect(res).assertTrue();
      mocker.clear(ConversationListService.getInstance());
    })

    it('NotificationServiceTest_buildWantAgentInfoRead', 0, () => {
      let actionData: LooseObject = {
        "msgId": 1,
        "unreadTotal": 0,
        "senderNumber": "568098875",
        "message": "111",
        "telephone": "10086",
        "type": 0
      };
      let res: wantAgent.WantAgentInfo = service.buildWantAgentInfoRead(actionData);
      expect(res.wants[0].action).assertEqual('usual.event.SMS_RECEIVE_COMPLETED');
    })

    it('NotificationServiceTest_buildWantAgentInfoRead_isAfterReSendNotification', 0, () => {
      let actionData: LooseObject = {
        "msgId": 1,
        "unreadTotal": 0,
        "isAfterReSendNotification": true,
        "senderNumber": "568098875",
        "message": "111",
        "telephone": "10086",
        "type": 0
      };
      UnLockedNotifyService.getInstance().dataIsMoveEL5 = true;
      let res: wantAgent.WantAgentInfo = service.buildWantAgentInfoRead(actionData);
      expect(res.wants[0].action).assertEqual('usual.event.SMS_RECEIVE_COMPLETED');
    })

    it('NotificationServiceTest_buildWantAgentInfoCopy', 0, () => {
      let actionData: LooseObject = {
        "msgId": 1,
        "unreadTotal": 0,
        "senderNumber": "568098875",
        "message": "111",
        "telephone": "10086",
        "type": 0
      };
      let res: wantAgent.WantAgentInfo = service.buildWantAgentInfoCopy(actionData);
      expect(res.wants[0].action).assertEqual('usual.event.SMS_RECEIVE_COMPLETED');
    })

    it('NotificationServiceTest_buildWantAgentInfoReplay', 0, () => {
      let actionData: LooseObject = {
        "msgId": 1,
        "unreadTotal": 0,
        "senderNumber": "568098875",
        "message": "111",
        "telephone": "10086",
        "type": 0
      };
      let res: MmswantAgentInfo = service.buildWantAgentInfoReplay(actionData);
      expect(res.wants[0].type).assertEqual('MIMETYPE');
    })

    it('NotificationServiceTest_getWantAgent', 0, () => {
      let parameters: MmsReplayParameters = {
        pageFlag: 'conversation',
        contactObjects: {} as LooseObject,
        notificationType: 0,
        yellowPageId: ''
      };
      let wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            deviceId: '',
            bundleName: common.STR.BUNDLE_NAME,
            abilityName: common.STR.ABILITY_NAME,
            action: 'notification.event.message',
            entities: [],
            type: 'MIMETYPE',
            uri: '',
          }
        ],
        actionType: wantAgent.OperationType.START_ABILITY,
        requestCode: 1,
        wantAgentFlags: [wantAgent.WantAgentFlags.CONSTANT_FLAG],
        extraInfo: parameters
      };
      service.getWantAgent(wantAgentInfo, () => {
      });
      expect(wantAgentInfo.wants[0].deviceId).assertEqual("");
    })

    it('NotificationServiceTest_buildWantAgentInfo', 0, () => {
      let actionData: LooseObject = {
        contactObjects: [],
        msgId: 1
      }
      let res: wantAgent.WantAgentInfo = service.buildWantAgentInfo(actionData);
      expect(res.wants[0].type).assertEqual('MIMETYPE');
    })

    it('NotificationServiceTest_buildBlockedWantAgentInfo', 0, () => {
      let actionData: LooseObject = {
        contactObjects: [],
        msgId: '1',
        message: {
          'title': '',
          'text': ''
        }
      }
      let res: wantAgent.WantAgentInfo = service.buildBlockedWantAgentInfo(actionData);
      expect(res.wants[0].type).assertEqual('MIMETYPE');
    })

    it('NotificationServiceTest_buildNotificationRequest', 0, () => {
      let actionData: LooseObject = {
        contactObjects: [],
        msgId: 1,
        message: {
          'title': '',
          'text': ''
        }
      }
      let res: notificationManager.NotificationRequest = service.buildNotificationRequest(actionData);

      expect(res.content.notificationContentType)
        .assertEqual(notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT);
    })

    it('NotificationServiceTest_cancelMessageNotify_fail', 0, async () => {
      let actionData: LooseObject = {
        page: 1,
        contactObjects: [],
        msgId: 1,
      };
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().getSmsMmsInfoSizeByCondition))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(4001)));
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);

      await service.cancelMessageNotify(context, actionData, (res: number) => {
        expect(res).assertEqual(-1);
      });
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationService.getInstance());
    })

    it('NotificationServiceTest_cancelMessageNotify_success_sum_less_than_total', 0, async () => {
      let actionData: LooseObject = {
        page: 1,
        contactObjects: [],
        msgId: 1
      };
      mocker.mockFunc(service, service.cancelNotifies);
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().getSmsMmsInfoSizeByCondition))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(2)));
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [1]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);

      await service.cancelMessageNotify(context, actionData, () => {
      });

      mocker.clear(GlobalContext.getContext());
      mocker.clear(service);
      mocker.clear(ConversationService.getInstance());
      expect(service).not().assertUndefined();
    })

    it('NotificationServiceTest_cancelNotifies', 0, () => {
      let messageList: Array<LooseObject> = [{
        msgId: '1'
      } as LooseObject];
      service.cancelNotifies(messageList, (res: number) => {
        expect(res).assertEqual(0);
      });
    })

    it('NotificationServiceTest_cancelAllNotify', 0, () => {
      mocker.mockFunc(HiLog, HiLog.i);
      service.cancelAllNotify();
      mocker.verify('i', [TAG, 'cancelAllNotify, start: ']).once();
      mocker.clear(HiLog);
    })

    it('NotificationServiceTest_setBadgeNumber', 0, () => {
      mocker.mockFunc(HiLog, HiLog.i);
      service.setBadgeNumber(2);
      mocker.verify('i', [TAG, 'setBadgeNumber, unreadTotal: 2']).never();
      mocker.clear(HiLog);
    })

    it('NotificationServiceTest_updateBadgeNumber_success', 0, () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: {
                totalListCount: 1,
                unreadCount: 1,
                unreadInfo: 1,
                unreadTotalOfInfo: 1
              }
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mocker.mockFunc(HiLog, HiLog.i);

      service.updateBadgeNumber(context);
      mocker.verify('i', [TAG, 'updateBadge Number']).never();
      mocker.clear(HiLog);
      mocker.clear(GlobalContext.getContext());
    })

    it('NotificationServiceTest_updateBadgeNumber_fail', 0, () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
              abilityResult: {
                totalListCount: 1,
                unreadCount: 1,
                unreadInfo: 1,
                unreadTotalOfInfo: 1
              }
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mocker.mockFunc(HiLog, HiLog.i);
      service.updateBadgeNumber(context);
      mocker.verify('i', [TAG, 'updateBadge Number']).never();
      mocker.clear(HiLog);
      mocker.clear(GlobalContext.getContext());
    })

    it('NotificationServiceTest_sendBlockedGuideNotify_return1', 0, () => {
      let actionData: LooseObject = {}
      mocker.mockFunc(HiLog, HiLog.e);
      service.sendBlockedGuideNotify(actionData, context);
      mocker.verify('e', [TAG, 'sendBlockedGuideNotify actionData is null']).never();
      service.sendBlockedGuideNotify(null, context);
      mocker.clear(HiLog);
    })

    it('NotificationServiceTest_resetLockScreenNotification', 0, () => {
      mocker.mockFunc(service, service.sendNotify);
      when(mocker.mockFunc(UnLockedNotifyService, UnLockedNotifyService.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          queryUnLockedNotify: (callback: Function, context?: Context) => {
            callback([{ isAfterReSendNotification: false } as LooseObject,
              { isAfterReSendNotification: true } as LooseObject])
          },
          deleteUnLockedNotify: (callback: Function, context?: Context) => {}
        });
      service.resetLockScreenNotification(context);
      mocker.clear(UnLockedNotifyService);
      expect(service).not().assertUndefined();
    })

    it('NotificationServiceTest_rcsSendReadReceipt', 0, () => {
      (service as object)['rcsSendReadReceipt'](null);
      expect(service).not().assertUndefined();
    })

    it('NotificationServiceTest_updateBadgeNumberWithContext_success', 0, () => {
      let contextInfo: IBadgeContextInfo = {
        appContext: context,
        updateBadgeEventCode: 'subscriberCallBack',
        tracedId: systemDateTime.getTime().toString(),
      }
      mocker.mockFunc(HiLog, HiLog.w);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: {
                totalListCount: 1,
                unreadCount: 1,
                unreadInfo: 1,
                unreadTotalOfInfo: 1
              }
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      service.updateBadgeNumberWithContext(contextInfo);
      mocker.verify('w', [TAG, 'updateBadge Number']).once();
      mocker.clear(HiLog);
      mocker.clear(GlobalContext.getContext());
    })

    it('NotificationServiceTest_getCurrentThreadMobilePhoneNumber_if1', 0, async () => {
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn('1');
      let result = await service.getCurrentThreadMobilePhoneNumber();
      mocker.clear(ConversationListService.getInstance());
      expect(result).not().assertNull();
      mocker.clear(SharedPreferencesUtils);
    })

    it('NotificationServiceTest_getCurrentThreadMobilePhoneNumber_if2', 0, async () => {
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn('');
      let result = await service.getCurrentThreadMobilePhoneNumber();
      mocker.clear(ConversationListService.getInstance());
      expect(result).not().assertNull();
      mocker.clear(SharedPreferencesUtils);
    })

  })
}