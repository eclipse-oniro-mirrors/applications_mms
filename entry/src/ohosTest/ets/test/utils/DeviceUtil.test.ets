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
import { describe, it, expect, when, ArgumentMatchers } from '@ohos/hypium';
import { display, window } from '@kit.ArkUI';
import DeviceUtil from '../../../../main/ets/utils/DeviceUtil';
import { MockKit } from '@ohos/hypium/src/main/module/mock/MockKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { call } from '@kit.TelephonyKit';
import ConversationListController from '../../../../main/ets/pages/conversationlist/conversationListController';

export default function DeviceUtilTest() {

  describe('DeviceUtilTest', () => {

    it('DeviceUtilTest_isTablet', 0, () => {
      let result = DeviceUtil.isTablet()
      expect(result).assertEqual(false)
    })

    it('DeviceUtilTest_isFoldable', 0, () => {
      display.isFoldable = () => {
        return true;
      };
      expect(DeviceUtil.isFoldable()).assertEqual(true);

      display.isFoldable = () => {
        return false;
      };
      expect(DeviceUtil.isFoldable()).assertEqual(false);
    })

    it('DeviceUtilTest_getScreenFoldStatus', 0, () => {
      display.getFoldStatus = () => {
        return display.FoldStatus.FOLD_STATUS_EXPANDED;
      };
      expect(DeviceUtil.getScreenFoldStatus()).assertEqual(1);
    })

    it('DeviceUtilTest_getScreenFoldStatus1', 0, () => {
      display.getFoldStatus = () => {
        return display.FoldStatus.FOLD_STATUS_FOLDED;
      };
      expect(DeviceUtil.getScreenFoldStatus()).assertEqual(2);
    })

    it('DeviceUtilTest_getScreenFoldStatus2', 0, () => {
      display.getFoldStatus = () => {
        return display.FoldStatus.FOLD_STATUS_HALF_FOLDED;
      };
      expect(DeviceUtil.getScreenFoldStatus()).assertEqual(3);
    })

    it('DeviceUtilTest_getScreenFoldStatus3', 0, () => {
      display.getFoldStatus = () => {
        return display.FoldStatus.FOLD_STATUS_UNKNOWN;
      };
      expect(DeviceUtil.getScreenFoldStatus()).assertEqual(4);
    })

    it('DeviceUtilTest_getScreenFoldStatus4', 0, () => {
      display.getFoldStatus = () => {
        return display.FoldStatus.FOLD_STATUS_EXPANDED_WITH_SECOND_EXPANDED;
      };
      expect(DeviceUtil.getScreenFoldStatus()).assertEqual(0);
    })

    it('DeviceUtilTest_setPreferredOrientation', 0, () => {
      let windowObj: window.Window = {
        setPreferredOrientation: (orientation: window.Orientation): Promise<void> => {
          expect(orientation).assertEqual(1);
          return new Promise<void>(resolve => resolve());
        }
      } as window.Window;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isTablet))().afterReturn(true);
      DeviceUtil.setPreferredOrientation(windowObj);

      windowObj = {
        setPreferredOrientation: (orientation: window.Orientation): Promise<void> => {
          expect(orientation).assertEqual(1);
          return new Promise<void>((resolve: () => void, reject: (reason: BusinessError) => void) => reject({
            code: -1, message: 'error'
          } as BusinessError));
        }
      } as window.Window;
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isTablet))().afterReturn(true);
      DeviceUtil.setPreferredOrientation(windowObj);

      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isTablet))().afterReturn(false);
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isFoldable))().afterReturn(false);
      DeviceUtil.setPreferredOrientation(windowObj);

      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isTablet))().afterReturn(false);
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isFoldable))().afterReturn(true);
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.getScreenFoldStatus))().afterReturn(2);
      DeviceUtil.setPreferredOrientation(windowObj);
      mocker.clear(DeviceUtil);
      windowObj = {
        setPreferredOrientation: (orientation: window.Orientation): Promise<void> => {
          expect(orientation).assertEqual(8);
          return new Promise<void>(resolve => resolve());
        }
      } as window.Window;
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isTablet))().afterReturn(false);
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isFoldable))().afterReturn(true);
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.getScreenFoldStatus))().afterReturn(1);
      DeviceUtil.setPreferredOrientation(windowObj);
      mocker.clear(DeviceUtil);
    })

    it('DeviceUtilTest_isFloatingScreen', 0, () => {
      let result: boolean = DeviceUtil.isFloatingScreen();
      expect(result).assertFalse();
      AppStorage.setOrCreate('windowStatusType', window.WindowStatusType.FLOATING);
      result = DeviceUtil.isFloatingScreen();
      expect(result).assertTrue();
      AppStorage.clear();
    })

    it('DeviceUtilTest_isSplitScreen', 0, () => {
      let result: boolean = DeviceUtil.isSplitScreen();
      expect(result).assertFalse();
      AppStorage.setOrCreate('windowStatusType', window.WindowStatusType.SPLIT_SCREEN);
      result = DeviceUtil.isSplitScreen();
      expect(result).assertTrue();
      AppStorage.clear();
    })

    it('DeviceUtilTest_getDeviceScaledDensity', 0, () => {
      let result: number = DeviceUtil.getDeviceScaledDensity();
      expect(result.toFixed(0).length >= 0).assertTrue();
    })

    it('DeviceUtilTest_isTableOrPC', 0, () => {
      let deviceTypeInfo = deviceInfo.deviceType;
      let result: boolean = deviceTypeInfo === 'tablet' || deviceTypeInfo === '2in1';
      expect(DeviceUtil.isTabletOrPC()).assertEqual(result)
    })

    it('DeviceUtilTest_isPC', 0, () => {
      expect(DeviceUtil.isPC()).assertEqual(deviceInfo.deviceType === '2in1')
    })

    it('DeviceUtilTest_hasCellularCapability', 0, () => {
      let result = DeviceUtil.hasCellularCapability()
      expect(result).assertEqual(call.hasVoiceCapability())
    })

    it('DeviceUtilTest_isCellularTablet', 0, () => {
      let result = DeviceUtil.isCellularTablet()
      expect(result).assertEqual(DeviceUtil.isTablet() && DeviceUtil.hasCellularCapability())
    })

    it('DeviceUtilTest_isWifiOnlyTablet', 0, () => {
      let result = DeviceUtil.isWifiOnlyTablet()
      expect(result).assertEqual(DeviceUtil.isTablet() && !DeviceUtil.hasCellularCapability())
    })

    it('DeviceUtilTest_getDistributedModemState', 0, () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let result:string = DeviceUtil.getdistributedModemState(context)
      expect(result).assertEqual('0')
    })

    it('DeviceUtilTest_isSubDevice', 0, () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let mode = DeviceUtil.getdistributedModemState(context)
      let result = DeviceUtil.isSubDevice(context);
      expect(result).assertEqual(mode.includes('sink'))
    })

    it('DeviceUtilTest_isSubDeviceWithConnected', 0, () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let result = DeviceUtil.isSubDeviceWithConnected(context)
      expect(result).assertEqual(DeviceUtil.getdistributedModemState(context) === '1_sink')
    })

    it('DeviceUtilTest_padMargin_16', 0, () => {
      AppStorage.setOrCreate('windowWidth', 0);
      AppStorage.setOrCreate('mmsScreenPercentage', '0');
      let result: number = DeviceUtil.padMargin();
      expect(result).assertEqual(16);
      AppStorage.clear();
    })

    it('DeviceUtilTest_padMargin_24', 0, () => {
      AppStorage.setOrCreate('windowWidth', 200);
      AppStorage.setOrCreate('mmsScreenPercentage', '600');
      let result: number = DeviceUtil.padMargin();
      expect(result).assertEqual(24);
      AppStorage.clear();
    })

    it('DeviceUtilTest_foldMenuPageBack', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('Conversation', 1);
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationListController.getInstance(),
        ConversationListController.getInstance().showFirstMessage))(ArgumentMatchers.any).afterReturnNothing();
      DeviceUtil.foldMenuPageBack(pageInfos);
      expect(pageInfos.size()).assertLess(2);
      mocker.clear(ConversationListController.getInstance());
    })

    it('DeviceUtilTest_foldMenuPageBack_Conversation_null', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationListController.getInstance(),
        ConversationListController.getInstance().showFirstMessage))(ArgumentMatchers.any).afterReturnNothing();
      DeviceUtil.foldMenuPageBack(pageInfos);
      expect(pageInfos.size()).assertLess(1);
      mocker.clear(ConversationListController.getInstance());
    })
  })
}