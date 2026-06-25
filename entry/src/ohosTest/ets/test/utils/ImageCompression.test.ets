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
import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import ImageCompression from '../../../../main/ets/utils/ImageCompression';
import { image } from '@kit.ImageKit';

export default function imageCompressionTest() {
  describe('ImageCompressionTest', () => {

    it('ImageCompressionTest_compressedImage', 0, () => {
      ImageCompression.calculateRatio(1).then(res => {
        expect(res).assertLessOrEqual(0.9)
      });

      ImageCompression.calculateRatio(51 * 1024).then(res => {
        expect(res).assertLessOrEqual(0.4)
      });

      ImageCompression.calculateRatio(21 * 1024).then(res => {
        expect(res).assertLessOrEqual(0.6)
      });

      ImageCompression.calculateRatio(16 * 1024).then(res => {
        expect(res).assertLessOrEqual(0.7)
      });

      ImageCompression.calculateRatio(13 * 1024).then(res => {
        expect(res).assertLessOrEqual(0.8)
      });
    })

    it('ImageCompressionTest_packingImage', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ImageCompression, ImageCompression.packing))(ArgumentMatchers.any)
        .afterReturn(new Promise<ArrayBuffer>(resolve => resolve(new ArrayBuffer(0))));

      let res: ArrayBuffer = await ImageCompression.packingImage(new ArrayBuffer(0), {} as image.PixelMap, 0, 0);
      expect(res.byteLength).assertEqual(0);
      res = await ImageCompression.packingImage(new ArrayBuffer(10), {} as image.PixelMap, 0, 0);
      expect(res.byteLength).assertEqual(0);
      mocker.clear(ImageCompression);
    })

  })
}