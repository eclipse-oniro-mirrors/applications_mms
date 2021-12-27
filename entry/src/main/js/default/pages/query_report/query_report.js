/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import common from '../common_constants.js';
import dateUtil from '../DateUtil.js';
import router from '@system.router';

export default {
    data: {
        // 是否是彩信
        isMsm: true,
        // 发送状态描述
        sendStatusDesc: '',
        // 发送状态
        sendStatus: 0,
        // 时间
        mmsTime: '',
        // 时间戳
        timeMillisecond: 0,
        // 手机号
        telephone: ''
    },
    onShow() {
        // 状态转换成中文描述
        this.dealSendStatus();
        // 时间转换
        this.dealTime();
    },
    dealSendStatus() {
        if (this.sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
            this.sendStatusDesc = this.$t('strings.received');
        } else if (this.sendStatus == common.int.SEND_MESSAGE_FAILED) {
            this.sendStatusDesc = this.isMsm ? this.$t('strings.refused') : this.$t('strings.failed');
        } else {
            this.sendStatusDesc = this.$t('strings.rending');
        }
    },
    dealTime() {
        this.mmsTime = dateUtil.convertTimeStampDate(this.timeMillisecond, this);
    },
    back() {
        router.back();
    }
}