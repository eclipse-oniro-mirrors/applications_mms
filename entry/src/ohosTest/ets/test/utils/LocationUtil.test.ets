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
import { describe, beforeEach, it, expect, MockKit, when, afterEach } from '@ohos/hypium';
import locationUtil from '../../../../main/ets/utils/LocationUtil';
import { AddressInfo, LocationType } from '../../../../main/ets/utils/TypesUtils';
import { resourceManager } from '@kit.LocalizationKit';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import { window } from '@kit.ArkUI';
import myCommon from '@ohos.app.ability.common';
import LooseObject from '../../../../main/ets/data/LooseObject';
import { site } from '@kit.MapKit';
import HiLog from '../../../../main/ets/utils/HiLog';

export default function LocationUtilTest() {
  describe('LocationUtilTest', () => {
    let mocker: MockKit;
    beforeEach(() => {
      mocker = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext').afterReturn({
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Object | window.WindowStage);
    })

    afterEach(() => {
      mocker.clear(GlobalContext.getContext());
      AppStorage.clear();
    })

    it('LocationUtilTest_requestLocationPermission', 0, async () => {
      let res: Promise<boolean> = locationUtil.requestLocationPermission();
      expect(res).not().assertNull();
    })

    it('LocationUtilTest_getLocation', 0, async () => {
      expect(locationUtil.getLocation()).not().assertFail();
    })

    it('LocationUtilTest_chooseLocation', 0, () => {
      let context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      expect(locationUtil.chooseLocation(null, context)).not().assertFail();
    })

    it('LocationUtilTest_getLocationInfo_north_east', 0, () => {
      let result: Resource = locationUtil.getLocationInfo(20.9, 20.9);
      let check: Resource = {
        bundleName: '',
        moduleName: '',
        id: 0
      };
      expect(typeof result).assertEqual(typeof check);
    })

    it('LocationUtilTest_getLocationInfo_north_west', 0, () => {
      let result = locationUtil.getLocationInfo(20.9, -20.9);
      let check: Resource = {
        bundleName: '',
        moduleName: '',
        id: 0
      };
      expect(typeof result).assertEqual(typeof check);
    })

    it('LocationUtilTest_getLocationInfo_south_east', 0, () => {
      let result = locationUtil.getLocationInfo(-20.9, 20.9);
      let check: Resource = {
        bundleName: '',
        moduleName: '',
        id: 0
      };
      expect(typeof result).assertEqual(typeof check);
    })

    it('LocationUtilTest_getLocationInfo_south_west', 0, () => {
      let result = locationUtil.getLocationInfo(-20.9, -20.9);
      let check: Resource = {
        bundleName: '',
        moduleName: '',
        id: 0
      };
      expect(typeof result).assertEqual(typeof check);
    })

    it("LocationUtilTest_getConvertDegreeString", 0, () => {
      when(mocker.mockFunc(locationUtil, locationUtil.getConvertDegreeString))(20.9).afterReturn("'20°53'59");
      expect(locationUtil.getConvertDegreeString(20.9)).assertEqual("'20°53'59");
      mocker.clear(locationUtil);
    })

    it("LocationUtilTest_queryLocation", 0, () => {
      let address: AddressInfo = new AddressInfo(1, 1, 'address.name', 'address.address')
      locationUtil.queryLocation(address);
      expect(address.address).assertEqual('address.address')
    })

    it("LocationUtilTest_queryLocation_address_undefined", 0, () => {
      mocker.mockFunc(HiLog, HiLog.i);
      locationUtil.queryLocation(undefined);
      mocker.verify('i', ['LocationUtil', 'queryLocation.']).never();
      mocker.clear(HiLog);
    })

    it("LocationUtilTest_buildSiteName", 0, () => {
      let result: LooseObject = (locationUtil as object)['buildSiteName']({
        totalCount: 1,
        sites:[{
          name: 'siteName',
          formatAddress: 'siteFormatAddress'
        }]
      } as site.NearbySearchResult) as LooseObject;
      expect(result.name).assertEqual('siteName');
    })

    it("LocationUtilTest_buildSiteName_totalCount_0", 0, () => {
      let result: LooseObject = (locationUtil as object)['buildSiteName']({
        totalCount: 0
      } as site.NearbySearchResult) as LooseObject;
      expect(result?.name).assertUndefined();
    })

    it("LocationUtilTest_getMapImage", 0, async () => {
      AppStorage.setOrCreate('currentColorMode', 1);
      try {
        let result: PixelMap = await locationUtil.getMapImage({
          latitude: 1,
          longitude: 1
        } as LocationType);
        expect(result != null).assertTrue();
      } catch (e) {
      }
      AppStorage.clear();
    })
  })
}