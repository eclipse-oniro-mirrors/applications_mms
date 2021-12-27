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
import Router from '@system.router';
import Prompt from '@system.prompt';

const MESSAGE_CODE_STATUS_TWO = 1;
export default {
    data: {
        // 哪一张图片
        which: 0,
        // 总共图片数量
        total: 0,
        // 是否被选中
        checkedValue: false,
        // 图片或视频在SDK中的路径
        path: '',
        // 图片 1 、视频 2
        type: 1,
        // 所有选中的图片或视频的大小
        totalFileSize: 0.0,
        // 当前这张图片或视频的大小
        fileSize: 0.0
    },
    onInit() {
        this.$watch('checkedValue', 'saveCheckedValue')
    },
    // 返回至'会话详情'页面
    clickToBack() {
        Router.back()
    },
    // 点击checkbox
    onChangeOfCheckbox() {
        if (!this.checkedValue && (this.totalFileSize + this.fileSize) > 300) {
            Prompt.showToast({
                message: this.$t('strings.attachment_failed'),
                duration: 2000,
            });
            return;
        }
        this.checkedValue = !this.checkedValue;
    },
    // 播放视频
    clickToPlayVideo() {
        // 调用播放器播放视频
    },
    saveCheckedValue() {
        this.$app.$def.indexInShowPicPage = this.which - MESSAGE_CODE_STATUS_TWO;
        this.$app.$def.checkedValueInShowPicPage = this.checkedValue;
    }
}
