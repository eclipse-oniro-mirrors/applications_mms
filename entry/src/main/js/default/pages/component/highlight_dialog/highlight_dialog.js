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
import { commonPasteboard } from '../../../utils/Pasteboard.js';
import common from '../../common_constants.js';
export default {
    props: ['text', 'highlightsType'],
    data: {
        telInfo: null,
        urlInfo: null,
        emailInfo: null,
        dateInfo: null
    },
    onInit() {
        this.telInfo = [
            this.$t('strings.call'),
            this.$t('strings.msg_pre_call_editor'),
            this.$t('strings.send_message'),
            this.$t('strings.pasteboard'),
            this.$t('strings.msg_new_contact'),
            this.$t('strings.msg_save_to_an_existing_contact')
        ];
        this.urlInfo = [
            this.$t('strings.open_web'),
            this.$t('strings.pasteboard'),
            this.$t('strings.add_to_bookmarks')
        ];
        this.emailInfo = [
            this.$t('strings.send_message'),
            this.$t('strings.send_email'),
            this.$t('strings.pasteboard'),
            this.$t('strings.msg_new_contact'),
            this.$t('strings.msg_save_to_an_existing_contact')
        ];
        this.dateInfo = [
            this.$t('strings.new_schedule_reminder'),
            this.$t('strings.pasteboard')
        ];
    },
    onShow() {
    },
    computed: {
        info() {
            if (this.highlightsType === common.HIGHLIGHT_TYPE.TEL) {
                return this.telInfo;
            } else if (this.highlightsType === common.HIGHLIGHT_TYPE.EMAIL) {
                return this.emailInfo;
            } else if (this.highlightsType === common.HIGHLIGHT_TYPE.URL) {
                return this.urlInfo;
            } else if (this.highlightsType === common.HIGHLIGHT_TYPE.DATE) {
                return this.dateInfo;
            }
            return null;
        }
    },
    cellClickAction(index) {
        if (this.highlightsType === common.HIGHLIGHT_TYPE.TEL ||
        this.highlightsType === common.HIGHLIGHT_TYPE.EMAIL ||
        this.highlightsType === common.HIGHLIGHT_TYPE.DATE) {
            this.$emit('clickAction', index);
        } else if (this.highlightsType === common.HIGHLIGHT_TYPE.URL) {
            this.clickUrlAction(index);
        }
    },
    clickUrlAction(index) {
        if (index === 0) {
            // 打开网址
        } else if (index === 1) {
            // 复制到剪贴板
            commonPasteboard.setPasteboard(this.text);
        } else {
            // 添加到书签
        }
        this.$emit('cancelDialog');
    },
    cancelDialog() {
        this.$emit('cancelDialog');
    }
}