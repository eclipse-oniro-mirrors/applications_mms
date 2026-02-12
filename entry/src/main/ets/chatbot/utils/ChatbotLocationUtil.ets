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
import HiLog from '../../utils/HiLog';
import { geoLocationManager } from '@kit.LocationKit';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import bundleManager from '@ohos.bundle.bundleManager';
import { BusinessError } from '@kit.BasicServicesKit';

const APPROVAL: number = 0
const TAG = 'ChatbotLocationUtil';
const permissionsList: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION',
  'ohos.permission.LOCATION']

export class OUT {
  public latitude: number = 0;
  public longitude: number = 0;
  public altitude: number = 0;
  public cityName: string = '';
  public speed: number = 0;
  public isFinished: boolean = false;
  public error: string = '';
}

export async function nodeGetGeographicalPosition() {
  let output: OUT = {
    latitude: 0,
    longitude: 0,
    altitude: 0,
    cityName: '',
    speed: 0,
    isFinished: false,
    error: 'null'
  }
  if (!geoLocationManager.isLocationEnabled()) {
    HiLog.i(TAG, 'Location module loads fail')
    output.error = 'Location module loads fail'
    await geoLocationManager.enableLocation().catch((error: number) => {
      HiLog.e(TAG, 'enableLocation failed: error=' + JSON.stringify(error));
    });
  }
  let requestInfo: geoLocationManager.CurrentLocationRequest = {
    'priority': 0x203,
    'scenario': 0x300,
    'maxAccuracy': 0
  }
  await geoLocationManager.getCurrentLocation(requestInfo).then((result) => {
    output.latitude = result.latitude
    output.longitude = result.longitude
    output.altitude = result.altitude
    output.speed = result.speed
    output.isFinished = true
  }).catch((error: Error) => {
    HiLog.e(TAG, 'getCurrentLocation failed: error=' + JSON.stringify(error));
  });
  return output
}

export async function nodeGetCityName(input: OUT) {
  let output: OUT = {
    cityName: '',
    latitude: input.latitude,
    longitude: input.longitude,
    altitude: input.altitude,
    speed: input.speed,
    isFinished: false,
    error: input.error
  }
  if (!geoLocationManager.isGeocoderAvailable()) {
    HiLog.e(TAG, 'Geocoder module loads fail')
    output.error = 'Geocoding conversion is not available, please check your device or server'
    return output
  }
  let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest = {
    'locale': 'zh',
    'latitude': input.latitude,
    'longitude': input.longitude,
    'maxItems': 1
  };
  if (!geoLocationManager.isLocationEnabled()) {
    HiLog.i(TAG, 'Location module loads fail')
    output.error = 'Location module loads fail'
    await geoLocationManager.enableLocation().catch((error: number) => {
      HiLog.e(TAG, 'enableLocation failed: error=' + JSON.stringify(error));
    });
  }
  await geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest).then((result) => {
    let cityName = result[0].locality
    if (cityName !== undefined) {
      output.cityName = cityName + '|' + result[0].postalCode + '|' + result[0].descriptions + '|' +
      result[0].administrativeArea + '|' + result[0].subAdministrativeArea + '|' + result[0].placeName +
        '|' + result[0].countryCode;
      output.isFinished = true
    }
  }).catch((error: Error) => {
    HiLog.e(TAG, 'Get addresses from location: error: ' + JSON.stringify(error));
    output.error = 'Reverse geocoding conversion failed'
  });
  return output
}

export async function getGeoData() {
  let reOut: OUT = {
    latitude: 0,
    longitude: 0,
    altitude: 0,
    cityName: '',
    speed: 0,
    isFinished: false,
    error: 'The device has not obtained relevant permissions'
  }
  if (!checkAccess()) {
    return reOut;
  }
  let output = await nodeGetGeographicalPosition()
  if (output !== undefined && !output.isFinished) {
    return output
  }
  if (output === undefined) {
    return reOut;
  }
  output = await nodeGetCityName(output)
  if (output.error === 'Location module loads fail' ) {
    try {
      geoLocationManager.disableLocation()
      output.error = 'null'
    } catch (error) {
      HiLog.e(TAG, 'disableLocation failed: error=' + JSON.stringify(error));
    }
  }
  return output
}

export const getCountryCode = async (): Promise<null | geoLocationManager.CountryCode> => {
  try {
    let countryCode = await geoLocationManager.getCountryCode()
      .catch((error: number) => {
        HiLog.e(TAG, 'promise, getCountryCode: error:' + JSON.stringify(error));
        return null;
      });
    return countryCode;
  } catch (err) {
    let error = err as BusinessError;
    HiLog.e(TAG, 'getCountryCode failed, errCode:' + error?.code + ',errMessage:' + err?.message);
    return null;
  }
}


export default async function checkAccess() {
  let permissionsList: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION',
    'ohos.permission.LOCATION', 'ohos.permission.LOCATION_IN_BACKGROUND']
  let atManager = abilityAccessCtrl.createAtManager()
  let grantStatus: abilityAccessCtrl.GrantStatus = 1
  let tokenId: number = 0
  try {
    let bundleInfo: bundleManager.BundleInfo =
      await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo
    tokenId = appInfo.accessTokenId
  } catch (err) {
    HiLog.e(TAG, 'get BundleInfo For Self fail' + err.message)
  }
  try {
    grantStatus = await atManager.checkAccessToken(tokenId, permissionsList[0])
  } catch (err) {
    HiLog.e(TAG, 'check Access Token fail ' + err.message)
  }
  if (grantStatus === APPROVAL) {
    HiLog.i(TAG, 'Accessible')
    return true
  } else {
    HiLog.i(TAG, 'Inaccessible')
    return false
  }
}

export async function requestPermissionFromUsers(context: common.UIAbilityContext) {
  let isFinished: boolean = false
  let atManager = abilityAccessCtrl.createAtManager()
  await atManager.requestPermissionsFromUser(context, permissionsList).then((result) => {
    let grantStatus: number[] = result.authResults
    for (let i = 0; i < grantStatus.length; i++) {
      if (grantStatus[i] === APPROVAL) {
        isFinished = true
      } else {
        HiLog.i(TAG, 'User denies providing the permissions')
      }
    }
  }).catch((err: Error) => {
    HiLog.e(TAG, 'request Permissions From User' + err.message)
  })
  return isFinished
}