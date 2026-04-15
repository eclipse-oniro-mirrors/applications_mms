/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import common from '@ohos.app.ability.common';
import lazy geoLocationManager from '@ohos.geoLocationManager';
import { BusinessError } from '@ohos.base';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import connection from '@ohos.net.connection';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import HiLog from './HiLog';
import { AddressInfo, LocationType } from './TypesUtils';
import MmsUtil from './MmsUtil';
import Constant from '../data/Constant';
import myCommon from '@ohos.app.ability.common';
//import { mapCommon, site } from '@kit.MapKit';
import LooseObject from '../data/LooseObject';
import { i18n, intl } from '@kit.LocalizationKit';

const TAG: string = 'LocationUtil';
const DOUBLE:number = 60;
const DEGREE:string = '°';
const MINUTE:string = '\'';
const SECOND:string = '\"';

export class LocationUtil {

  /**
   * Applying for the Location Permission
   *
   * @returns
   */
  public async requestLocationPermission(): Promise<boolean> {
    HiLog.i(TAG, 'requireLocationPermission: enter');
    let atManager = abilityAccessCtrl.createAtManager();
    let permissions: Permissions[] = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];
    let context = (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);
    let permissionResult = await atManager.requestPermissionsFromUser(context, permissions);
    HiLog.i(TAG, 'requireLocationPermission: ' + JSON.stringify(permissionResult.authResults));
    return (permissionResult.authResults[0] == 0);
  }

  /**
   * Use geoLocationManager to obtain location information.
   *
   * @returns
   */
  public getLocation(): Promise<LocationType> {
    return new Promise(async (resolve, reject) => {
      let requestInfo: geoLocationManager.CurrentLocationRequest = {
        'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
        'scenario': geoLocationManager.LocationRequestScenario.UNSET,
        'maxAccuracy': 0
      };
      try {
        await geoLocationManager.getCurrentLocation(requestInfo).then((result) => {
          let location: LocationType = {
            latitude: result.latitude,
            longitude: result.longitude,
          }
          HiLog.i(TAG, 'Get current location success.');
          resolve(location);
        }).catch((error: BusinessError) => {
          HiLog.e(TAG, 'promise, getCurrentLocation: error=' + JSON.stringify(error));
          reject(error);
        });
      } catch (err) {
        HiLog.e(TAG, 'errCode:' + (err as BusinessError).code + ',errMessage:' + (err as BusinessError).message);
        reject(err);
      }
    })
  }

  /**
   * Open mapkit, and choose a address.
   *
   * @param location Specified location(LatLong)
   * @param callback callback for addressInfo.
   * @param isShowNoNetToast 是否显示无网提示，默认为true
   */
  public async chooseLocation(location: LocationType | null, context: Context,
    callback?: () => void, isShowNoNetToast: boolean = true): Promise<AddressInfo | undefined> {
    HiLog.i(TAG, 'chooseLocation. Map service not available.');
    // Map service is not available, return undefined
    callback && callback()
    return undefined;
  }

  public async getMapImage(location: LocationType | undefined): Promise<PixelMap> {
    HiLog.i(TAG, 'getMapImage. Map service not available.');
    // Map service is not available, throw error or return null
    throw new Error('Map service not available');
  }

  public checkLocationRight(): boolean {
    return geoLocationManager.isLocationEnabled();
  }

  public checkNetworkRight(): boolean {
    return connection.hasDefaultNetSync();
  }

  /**
   * Open mapkit, navigating Locations
   *
   * @param address
   */
  public queryLocation(address?: AddressInfo) {
    if (address == undefined) {
      return;
    }
    HiLog.i(TAG, 'queryLocation.');
    if (!this.checkNetworkRight()) {
      HiLog.i(TAG, 'queryLocation. network off.');
      let context = getContext(this) as common.UIAbilityContext;
      address.name = context.resourceManager.getStringSync(this.getLocationInfo(address.longitude, address.latitude),
        this.getConvertDegreeString(address.latitude), this.getConvertDegreeString(address.longitude));
      address.address = context.resourceManager.getStringSync($r('app.string.cactus_map_no_network'));
    }
    // let latLong: mapCommon.LatLng = {
    //   latitude: address.latitude,
    //   longitude: address.longitude
    // }
    // let options: sceneMap.LocationQueryOptions = {
    //   location: latLong,
    //   name: address.name,
    //   address: address.address,
    // }
    try {
      // sceneMap.queryLocation(getContext(this) as common.UIAbilityContext, options).then(() => {
      //   HiLog.i(TAG, 'Query location success.');
      // }).catch((err: BusinessError) => {
      //   HiLog.i(TAG, `Failed to query Location, code: ${err.code}, message: ${err.message}`);
      // });
    } catch (e) {
      HiLog.i(TAG, `Failed to query Location, message: ${e.message}`);
    }
  }

  public searchName(callback: Function, longitude: number, latitude: number, poiTypes?: Array<string>) {
    HiLog.i(TAG, 'searchName.')
    // let params: site.NearbySearchParams = {
    //   location: {
    //     longitude: longitude,
    //     latitude: latitude
    //   },
    //   radius: 5000,
    //   poiTypes: poiTypes,
    //   pageIndex: 1,
    //   pageSize: 1
    // };
    try {
      // site.nearbySearch(params).then((result: site.NearbySearchResult) => {
      //   HiLog.i(TAG, 'NearbySearch success');
      //   callback(this.buildSiteName(result));
      // }).catch((err: BusinessError) => {
      //   HiLog.e(TAG, `Failed to search name, code: ${err.code}, message: ${err.message}`);
      //   callback(null);
      // });
    } catch (err) {
      HiLog.e(TAG, 'NearbySearch fail err =' + JSON.stringify(err));
      callback(null);
    }

  }

  // private buildSiteName(result: site.NearbySearchResult):LooseObject {
  //   let siteRes:LooseObject = {};
  //   if (result.totalCount != 0) {
  //     let site:site.Site | undefined = result.sites?.pop();
  //     siteRes.name = site?.name;
  //     siteRes.formatAddress = site?.formatAddress;
  //   }
  //   return siteRes;
  // }

  public getLocationInfo(convertLongitude: number, convertLatitude: number): Resource {
    //刷新经纬度信息到界面
    let context:myCommon.UIAbilityContext = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext
    if (convertLatitude >= 0) {
      if (convertLongitude >= 0) {
        return $r('app.string.location_north_east', this.getConvertDegreeString(convertLatitude),
          this.getConvertDegreeString(convertLongitude))
      } else {
        return $r('app.string.location_north_west', this.getConvertDegreeString(convertLatitude),
          this.getConvertDegreeString(convertLongitude));
      }
    } else {
      if (convertLongitude >= 0) {
        return $r('app.string.location_south_east', this.getConvertDegreeString(convertLatitude),
          this.getConvertDegreeString(convertLongitude));
      } else {
        return $r('app.string.location_south_west', this.getConvertDegreeString(convertLatitude),
          this.getConvertDegreeString(convertLongitude));
      }
    }
  }

  public getConvertDegreeString(digitalDegree:number):string {
    let degree:number = Math.trunc(digitalDegree);
    let tmp:number = (digitalDegree - degree) * DOUBLE;
    let minute:number = Math.trunc(tmp);
    let second:number = Math.trunc((tmp - minute) * DOUBLE);
    return Math.abs(degree) + DEGREE + Math.abs(minute) + MINUTE + Math.abs(second) + SECOND;
  }

  public numFormat(formatNumber: number, unit?: string): string {
    let countryId = i18n.System.getSystemRegion();
    let numberFormatUnit = new intl.NumberFormat(countryId);
    if (unit) {
      numberFormatUnit = new intl.NumberFormat(countryId, { style: 'unit', unit: unit, unitDisplay: 'short' });
    }
    return numberFormatUnit.format(formatNumber);
  }

  /**
   * 根据提供的位置、图像高度和图像宽度等参数生成地图图像。
   * @param mapOptions
   * @returns
   */
  public static async getMapImageOfMms(mapOptions: object): Promise<PixelMap | null> {
    HiLog.i(TAG, 'getMapImageOfMms. Map service not available.');
    // Map service is not available
    return null;
  }
}

export default new LocationUtil();