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

import pasteboard from '@ohos.pasteboard';
import HiLog from '../utils/HiLog';
import StringUtil from '../utils/StringUtil';

const TAG = 'Pasteboard';
interface  PasteboardMethods {
    getPasteboard: () => Promise<pasteboard.PasteData>
    setPasteboard: (text: string) => void
}
let commonPasteboard: PasteboardMethods = {
    getPasteboard() {
        let sysPasteboard = pasteboard.getSystemPasteboard();
        return sysPasteboard.getPasteData();
    },
    setPasteboard(text: string) {
        if (StringUtil.isEmpty(text)) {
            HiLog.e(TAG, 'setPasteboard text is empty');
            return;
        }
        HiLog.iw(TAG, 'setPasteboard text length: ' + text.length);
        let sysPasteboard = pasteboard.getSystemPasteboard();
        let textData = pasteboard.createPlainTextData(text);
        sysPasteboard.setPasteData(textData, () => {
            HiLog.i(TAG, 'setPasteboard done');
        });
    }
};

export { commonPasteboard };