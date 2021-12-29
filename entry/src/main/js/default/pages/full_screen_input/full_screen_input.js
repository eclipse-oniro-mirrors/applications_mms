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
import mmsLog from '../../../default/utils/MmsLog.js';
import router from '@system.router';

const MESSAGE_CODE_STATUS_THREE = 3;
const MESSAGE_CODE_STATUS_SEVENTY = 70;

export default {
    data: {
        // 文本内容
        textValue: '',
        // 文本分页大小
        textPageSize: '',
        // 文本分页数量
        textPageNum: '',
        // 手机号
        telephone: '',
        // 是否存在sim卡
        haveSimCard: false,
    },
    onInit() {
        mmsLog.info('textValue:' + this.inputDetail);
        this.textValue = this.inputDetail;
    },
    singleMsgBack() {
        this.$app.$def.isShowFullScreen = false;
        this.$app.$def.sendFlag = false;
        router.back();
    },
    changeValue(e) {
        if (e.text == null) {
            return;
        }
        this.textValue = e.text;
        this.$app.$def.textValueOther = this.textValue;
        var n = Math.ceil(this.textValue.length / MESSAGE_CODE_STATUS_SEVENTY);
        // 发送剩余编辑字数
        this.textPageSize = MESSAGE_CODE_STATUS_SEVENTY * n - this.textValue.length;
        // 超过70个字符显示分发条数
        this.textPageNum = n;
        // 是否显示全屏
        if (e.lines > MESSAGE_CODE_STATUS_THREE) {
            this.isShowFullScreen = true;
            this.styleFullScreenMore = 'full-screen-mores-true';
        } else {
            this.isShowFullScreen = false;
            this.styleFullScreenMore = 'full-screen-mores-false';
        }
    },
    launchs() {
        router.push({
            uri: 'pages/conversation/conversation',
        });
    },
    send() {
        this.$app.$def.sendFlag = true;
        router.back();
    }
}
