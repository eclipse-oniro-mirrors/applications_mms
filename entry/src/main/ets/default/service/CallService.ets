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

import call from '@ohos.telephony.call';
import HiLog from '../utils/HiLog';
import common from '../data/commonData';
interface LooseObject {
    [key: string]: any
}

const TAG = 'CallService';
export default {

    /**
     * 打电话
     * @param params 电话号码
     * @return
     */
    call(params, callback) {
        if(params == null || params.telephone == common.string.EMPTY_STR) {
            HiLog.i(TAG, 'call, param is null');
            return;
        }
        let result: LooseObject = {};
        call.dial(params.telephone).then((value) => {
            result.code = common.int.SUCCESS;
            callback(result);
        }).catch((err) => {
            HiLog.e(TAG, 'call, dial error: ' + err.message);
            result.code = common.int.FAILURE;
            callback(result);
        });
    }
}