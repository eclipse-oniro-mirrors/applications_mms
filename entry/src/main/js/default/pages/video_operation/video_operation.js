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
import router from '@system.router';

export default {
    data: {
        event: '',
        seekingtime: '',
        timeupdatetime: '',
        seekedtime: '',
        isStart: true,
        isfullscreenchange: false,
        isControls: false,
        isPlayImage: true,
    },
    titleBarBack() {
        // 返回按钮
        router.back();
    },
    preparedCallback: function () {
        this.event = this.$t('strings.video_connect_succeed');
    },
    startCallback: function () {
        this.event = this.$t('strings.video_start_play');
    },
    pauseCallback: function () {
        this.event = this.$t('strings.video_pause_play');
    },
    finishCallback: function () {
        this.event = this.$t('strings.video_play_end');
    },
    errorCallback: function () {
        this.event = this.$t('strings.video_play_error');
    },
    seekingCallback: function (e) {
        this.seekingtime = e.currenttime;
    },
    timeupdateCallback: function (e) {
        this.timeupdatetime = e.currenttime;
    },
    changeStartPause: function () {
        if (this.isStart) {
            this.$element('vedioId').pause();
            this.isStart = false;
        } else {
            this.$element('vedioId').start();
            this.isStart = true;
        }
    },
    changeFullscreenhange: function () {
        // 全屏
        if (!this.isfullscreenchange) {
            this.$element('vedioId').requestFullscreen({
                screenOrientation: 'default'
            });
            this.isfullscreenchange = true;
        } else {
            this.$element('vedioId').exitFullscreen();
            this.isfullscreenchange = false;
        }
    },
    playVideo() {
        this.$element('vedioId').start();
        this.isStart = true;
        this.isControls = true;
        this.isPlayImage = false;
    }
}