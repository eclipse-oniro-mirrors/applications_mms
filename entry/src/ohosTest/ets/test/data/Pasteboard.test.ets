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
import { describe, it, expect} from '@ohos/hypium'
import { commonPasteboard } from '../../../../main/ets/data/Pasteboard'

export default function PasteboardTest() {
  describe('PasteboardTest', () => {
    it('PasteboardTest_setPasteboard_when_has_text', 0, async () => {
      commonPasteboard.setPasteboard("123456789");
      expect(commonPasteboard.getPasteboard()).not().assertNull();
    });
    it('PasteboardTest_setPasteboard_when_text_isEmpty', 0, async () => {
      commonPasteboard.setPasteboard("");
      expect(commonPasteboard.getPasteboard()).not().assertNull();
    });
  })
}