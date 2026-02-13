/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
export interface ImageData {
  clurSize: number
  totalSize: number
  isExistInfoInRcsInfoWithMsgId: boolean
}

export class EnhancedInfoTemporaryDataSource {
  public static sInstance: EnhancedInfoTemporaryDataSource;
  public mapImageMsgIdToData: Map<string, ImageData> = new Map<string, ImageData>();
  public mapMsgIdToProgressWidth: Map<string, number> = new Map<string, number>();
  public mapKeyToPixelMap: Map<string, PixelMap> = new Map<string, PixelMap>();
  public isHideIndexPage: boolean = false;
  public static CHATBOT_CARD_DIVIDER_VP_WIDTH = 1;
  public static ONE_PX_TO_VP = 0;

  constructor() {
  }

  static getInstance() {
    if (!EnhancedInfoTemporaryDataSource.sInstance) {
      EnhancedInfoTemporaryDataSource.sInstance = new EnhancedInfoTemporaryDataSource();
    }
    return EnhancedInfoTemporaryDataSource.sInstance;
  }

  public releasePixelMaps() {
    let mapKeyToPixelMap = this.mapKeyToPixelMap;
    if (!mapKeyToPixelMap || mapKeyToPixelMap.size === 0) {
      return;
    }
    for (let pixelMap of mapKeyToPixelMap.values()) {
      pixelMap.release();
    }
    mapKeyToPixelMap = new Map<string, PixelMap>();
    this.releaseData();
  }

  public releaseData() {
    this.mapImageMsgIdToData = new Map<string, ImageData>();
    this.mapMsgIdToProgressWidth = new Map<string, number>();
    this.mapKeyToPixelMap = new Map<string, PixelMap>();
    this.isHideIndexPage = false;
  }

  public clearMapImageMsgIdToData() {
    this.mapImageMsgIdToData = new Map<string, ImageData>();
  }
}