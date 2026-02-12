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
import image from '@ohos.multimedia.image';
import HiLog from './HiLog';

const TAG = 'ImageBoundsUtil ';

class ImageBoundsUtil {
  getHeight(imageWidth: number, imageHeight: number, screenWidth: number): number {
    let imgFavoriteHeight: number = 0
    if (imageWidth < imageHeight) {
      imgFavoriteHeight = (px2vp(screenWidth) / 3) * 4
    } else if (imageWidth >= imageHeight) {
      if (imageWidth == imageHeight) {
        imgFavoriteHeight = (px2vp(screenWidth) / 4) * 3
      } else if (imageWidth > imageHeight) {
        if (imageHeight >= (screenWidth / 4) * 3) {
          imgFavoriteHeight = (px2vp(screenWidth) / 4) * 3
        } else if (imageHeight > (screenWidth / 8) * 3 && imageHeight < (screenWidth / 4) * 3) {
          imgFavoriteHeight = px2vp(imageHeight)
        } else if (imageHeight <= (screenWidth / 8) * 3) {
          imgFavoriteHeight = (px2vp(screenWidth) / 8) * 3
        }
      }
    }
    return imgFavoriteHeight
  }

  getWidth(imageWidth: number, imageHeight: number, screenWidth: number): number {
    let imgFavoriteWidth: number = 0
    if (imageWidth < imageHeight) {
      if (imageWidth >= screenWidth) {
        imgFavoriteWidth = px2vp(screenWidth)
      } else if (imageWidth > screenWidth / 2 && imageWidth < screenWidth) {
        imgFavoriteWidth = px2vp(imageWidth)
      } else if (imageWidth <= screenWidth / 2) {
        imgFavoriteWidth = px2vp(screenWidth) / 2
      }
    } else if (imageWidth >= imageHeight) {
      if (imageWidth == imageHeight) {
        imgFavoriteWidth = (px2vp(screenWidth) / 4) * 3
      } else if (imageWidth > imageHeight) {
        imgFavoriteWidth = px2vp(screenWidth)
      }
    }
    return imgFavoriteWidth
  }

  async getImageBounds(path: string): Promise<number[]> {
    let widthAndHeightArr: Array<number> = [];
    try {
      let imageSource = image.createImageSource(path);
      let imageInfo = await imageSource.getImageInfo();
      let width: number = imageInfo.size.width;
      let height: number = imageInfo.size.height;
      widthAndHeightArr = [width, height]
      imageSource.release()
    } catch (error) {
      HiLog.i(TAG, 'ImageBoundsUtil err: ' + JSON.stringify(error));
    }
    return widthAndHeightArr
  }
}

export default new ImageBoundsUtil()