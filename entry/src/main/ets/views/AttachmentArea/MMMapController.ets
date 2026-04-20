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

import HiLog from '../../utils/HiLog';
import { AddressInfo, LocationType } from '../../utils/TypesUtils';
import LocationUtil from '../../utils/LocationUtil';
import MMAttachmentAreaController from './MMAttachmentAreaController';
import Constant from '../../data/Constant';
// import { staticMap } from '@kit.MapKit';
import FileUtil from '../../utils/FileUtil';
import commonData from '../../data/commonData';
import Prompt from '@ohos.promptAction';
import { NetUtils } from '../../utils/NetUtils';

const TAG = 'MMMapController';

/**
 * The controller for MMMap.
 */
export default class MMMapController {
  private static sInstance: MMMapController;
  private address: undefined | AddressInfo = undefined
  private mmAreaController: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
  /**
   * Simple instance
   *
   * @returns
   */
  public static getInstance() {
    if (MMMapController.sInstance == null) {
      MMMapController.sInstance = new MMMapController();
    }
    return MMMapController.sInstance;
  }

  /**
   * Obtain the location and open the map.
   *
   * @returns
   */
  public async getLocationAndOpenMap(context: Context, callback?:() => void) {
    HiLog.i(TAG, 'getLocationAndOpenMap');
    AppStorage.setOrCreate('selectPicFromGalleryDone', false);
    this.address = await LocationUtil.chooseLocation(null, context);
    HiLog.iw(TAG, 'choose address success.');
    if (this.mmAreaController.hasNeedReplaceVcard() && this.address && callback) {
      callback()
    } else {
      this.handleLocation(context)
    }
  }

  // 添加所选 map 信息 this.address 到附件待发区
  public async handleLocation(context: Context) {
    const netConnectType = await NetUtils.getNetConnectType();
    HiLog.iw(TAG, 'getLocationAndOpenMap netConnectType: ' + netConnectType);
    if (netConnectType === 'noNet') {
      Prompt.showToast({
        message: $r('app.string.net_no_connection'),
        duration: 2000,
      });
      return;
    }
    if (this.address) {
      AppStorage.setOrCreate('selectPicFromGalleryDone', true);
      let mapImgName: string = this.address.buildMapImgName();

      let jpegPath = FileUtil.getSandboxPath(context) + '/' + mapImgName;
      this.mmAreaController.setMap(this.address, mapImgName, jpegPath);
      this.getStaticMapImage(context, this.address, mapImgName, jpegPath);
    }
  }

  private async getStaticMapImage(context: Context, address: AddressInfo, mapImgName: string, jpegPath: string) {
    HiLog.i(TAG, 'getStaticMapImage. Map service not available.');
    // Map service is not available, set flag to true to avoid blocking UI
    AppStorage.setOrCreate('isGetStaticMapImage', true);
  }
}