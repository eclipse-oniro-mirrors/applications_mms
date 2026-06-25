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

import { describe, it, expect } from '@ohos/hypium';
import ImageBoundsUtil from '../../../../main/ets/utils/ImageBoundsUtil';

export default function ImageBoundsUtilTest() {
  describe('ImageBoundsUtilTest', () => {

    it('ImageBoundsUtil_getHeight', 0, () => {
      let result = ImageBoundsUtil.getHeight(100, 200, 500);
      expect(Math.trunc(result)).assertEqual(Math.trunc(px2vp(500 / 3) * 4));
    })

    it('ImageBoundsUtil_getHeight1', 0, () => {
      let result1 = ImageBoundsUtil.getHeight(200, 200, 500);
      expect(result1).assertEqual(px2vp(500 / 4) * 3);
    })

    it('ImageBoundsUtil_getHeight2', 0, () => {
      let result2 = ImageBoundsUtil.getHeight(302, 301, 400);
      expect(result2).assertEqual(px2vp(400 / 4) * 3);
    })

    it('ImageBoundsUtil_getHeight3', 0, () => {
      let result3 = ImageBoundsUtil.getHeight(500, 300, 500);
      expect(result3).assertEqual(px2vp(300));
    })

    it('ImageBoundsUtil_getHeight4', 0, () => {
      let result4 = ImageBoundsUtil.getHeight(500, 100, 500);
      expect(result4).assertEqual(px2vp(500 / 8) * 3);
    })

    it('ImageBoundsUtil_getHeight_screenWidth_undefined', 0, () => {
      let result5 = ImageBoundsUtil.getHeight(500, 100, undefined);
      expect(result5).assertEqual(0);
    })

    it('ImageBoundsUtil_getHeight_imageWidth_undefined', 0, () => {
      let result4 = ImageBoundsUtil.getHeight(undefined, 100, 500);
      expect(result4).assertEqual(0);
    })

    it('ImageBoundsUtil_getWidth', 0, () => {
      let result6 = ImageBoundsUtil.getWidth(100, 101, 100);
      expect(result6).assertEqual(px2vp(100));
    })

    it('ImageBoundsUtil_getWidth1', 0, () => {
      let result7 = ImageBoundsUtil.getWidth(51, 101, 100);
      expect(result7).assertEqual(px2vp(51));
    })

    it('ImageBoundsUtil_getWidth2', 0, () => {
      let result8 = ImageBoundsUtil.getWidth(49, 101, 100);
      expect(result8).assertEqual(px2vp(100) / 2);
    })

    it('ImageBoundsUtil_getWidth3', 0, () => {
      let result9 = ImageBoundsUtil.getWidth(101, 101, 100);
      expect(result9).assertEqual((px2vp(100) / 4) * 3);
    })

    it('ImageBoundsUtil_getWidth4', 0, () => {
      let result10 = ImageBoundsUtil.getWidth(101, 100, 100);
      expect(result10).assertEqual(px2vp(100));
    })

    it('ImageBoundsUtil_getWidth_imageWidth_undefined', 0, () => {
      let result10 = ImageBoundsUtil.getWidth(undefined, 100, 100);
      expect(result10).assertEqual(0);
    })

    it('ImageBoundsUtil_getWidth_screenWidth_undefined', 0, () => {
      let result10 = ImageBoundsUtil.getWidth(10, 100, undefined);
      expect(result10).assertEqual(0);
    })

    it('ImageBoundsUtil_getImageBounds', 0, async () => {
      let res: number[] = await ImageBoundsUtil.getImageBounds("1");
      expect(res.length).assertEqual(0);
    })

  })
}