/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import HiLog from '../../utils/HiLog'
import MMPictureController from '../../views/AttachmentArea/MMPictureController';

const TAG = 'FullImageDisplayControler';


class RouterParams {
  showIdx: number = 0;
}

export default class FullImageDisplayControler {
  pictureCtrl: MMPictureController = MMPictureController.getInstance();
  showIdx: number = 0;
  private static sInstance: FullImageDisplayControler;
  pageInfos: NavPathStack | null = null;

  static getInstance() {
    if (FullImageDisplayControler.sInstance == null) {
      FullImageDisplayControler.sInstance = new FullImageDisplayControler();
    }
    return FullImageDisplayControler.sInstance;
  };

  onInit(pageInfos: NavPathStack) {
    this.pageInfos = pageInfos;
    let routerParams: Array<RouterParams> = this.pageInfos.getParamByName('FullImageDisplay') as Array<RouterParams>;
    this.showIdx = routerParams[0]?.showIdx == undefined ? 0 : routerParams[0]?.showIdx;
  };

  onShow() {
    HiLog.i(TAG, 'onShow')
  };

  checkBoxChange(context: Context, value: boolean, index: number ) {
    const item = this.pictureCtrl.pictureList[index]
    if (item == undefined) {
      return
    }
    if(value == !item.selected){
      this.pictureCtrl.clickPictureCheckbox(context, value, item, index);
    }
  }

}