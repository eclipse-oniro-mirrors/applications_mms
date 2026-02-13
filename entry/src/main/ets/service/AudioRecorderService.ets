/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import HiLog from '../utils/HiLog';
import media from '@ohos.multimedia.media';
import fs from '@ohos.file.fs';
import FileUtil from '../utils/FileUtil';
import MmsUtil from '../utils/MmsUtil';
import commonData from '../data/commonData';
import promptAction from '@ohos.promptAction';

const Tag = 'AudioRecorderService';
const Format = '.m4a';
const rcsFormat = '.amr';

export class AudioRecorderService {
  private avRecorder?: media.AVRecorder;
  private fileName: string = '';
  file?: fs.File;
  private avProfile: media.AVRecorderProfile = {
    audioBitrate: commonData.MEDIA_PARAMETER.AUDIO_BITRATE, // Audio bit rate
    audioChannels: commonData.MEDIA_PARAMETER.AUDIO_CHANNELS, // Number of audio channels
    audioCodec: media.CodecMimeType.AUDIO_AAC,
    audioSampleRate: commonData.MEDIA_PARAMETER.AUDIO_SAMPLE_RATE, // Audio sampling rate
    fileFormat: media.ContainerFormatType.CFT_MPEG_4A
  };
  private avConfig: media.AVRecorderConfig = {
    'audioSourceType': media.AudioSourceType.AUDIO_SOURCE_TYPE_VOICE_MESSAGE,
    'profile': this.avProfile,
    'url': ''
  };

  setAudioRecorderCallback() {
    HiLog.i(Tag, 'setAudioRecorderCallback');
    this.avRecorder?.on('error', (err) => {
      HiLog.i(Tag, `AudioRecorder failed, code is ${err.code}, message is ${err.message}`);
      this.releaseRecorder();
      let message: ResourceStr = $r('app.string.recorder_error');
      if (err.code === commonData.AUDIO_RECORDER_ERROR_CODE.MICROPHONE_IN_USE ||
        err.code === commonData.AUDIO_RECORDER_ERROR_CODE.AUDIO_INTERRUPT) {
        message = $r('app.string.recorder_failed');
      } else if (err.code === commonData.AUDIO_RECORDER_ERROR_CODE.RECORDER_ERROR) {
        message = $r('app.string.recorder_error');
      }
      MmsUtil.showToast({
        message: message,
        duration: commonData.PROMPT_TOAST.DURATION
      });
    });
  }

  createRecorder(callback: Function) {
    HiLog.i(Tag, 'createRecorder');
    media.createAVRecorder((error, recorder) => {
      if (recorder != null) {
        HiLog.i(Tag, 'createAVRecorder success');
        this.avRecorder = recorder;
        callback();
      } else {
        HiLog.i(Tag, `createAVRecorder fail, error message:${error.code}`);
      }
    });
  }

  startRecording(context: Context, callback?: Function) {
    HiLog.i(Tag, 'startRecording')
    this.createRecorder(() => {
      this.setAudioRecorderCallback();
      let name = commonData.STR.RECORDING_PREFIX + new Date().getTime() + Format;
      this.fileName = name;
      let fileObj = FileUtil.getFileUrl(context, name);
      this.avConfig.url = fileObj?.fileFd as string;
      this.file = fileObj?.file as fs.File;
      this.avRecorder?.prepare(this.avConfig, (err) => {
        if (err == null) {
          HiLog.i(Tag, 'prepare success');
          this.startRecorder((ready: boolean) => {
            if (callback) {
              callback(ready)
            }
          });
        } else {
          HiLog.i(Tag, 'prepare failed and error is ' + JSON.stringify(err));
        }
      });
    });
  }

  startRecorder(callback?: Function) {
    HiLog.i(Tag, 'startRecorder');
    this.avRecorder?.start((err) => {
      if (err == null) {
        HiLog.i(Tag, 'start AVRecorder success');
      } else {
        HiLog.i(Tag, 'start AVRecorder failed and errorcode is ' + JSON.stringify(err));
      }
      if (callback) {
        callback(err == null ? true : false)
      }
    });
  }

  async stopRecording(context: Context, callback: Function) {
    HiLog.i(Tag, 'stopRecording' + this.avRecorder?.state);
    if (this.avRecorder?.state === commonData.MEDIA_STATUS.STARTED ||
      this.avRecorder?.state === commonData.MEDIA_STATUS.PAUSED) {
      let err = await this.avRecorder?.stop();
      if (err == null) {
        HiLog.i(Tag, 'stop AVRecorder success');
        let filePath = FileUtil.getFilePath(context, this.fileName);
        callback(filePath, this.fileName);
      } else {
        callback('', '');
        HiLog.i(Tag, 'stop AVRecorder failed and error is ' + JSON.stringify(err));
      }
      this.releaseRecorder();
    } else {
      callback('', '');
      this.releaseRecorder();
    }
  }

  async releaseRecorder() {
    HiLog.i(Tag, 'releaseRecorder');
    if (this.avRecorder) {
      await this.avRecorder.reset();
      await this.avRecorder.release();
      this.avRecorder = undefined;
    }
  }

  getRecorderSize() {
    HiLog.i(Tag, 'getRecorderSize');
    let size: number = 0;
    if (this.file) {
      size = FileUtil.getFileSize(this.file.fd);
    }
    return size;
  }

  closeFile() {
    HiLog.i(Tag, 'closeFile');
    if (this.file) {
      FileUtil.closeFile(this.file);
    }
    this.file = undefined;
  }

  rcsStartRecording(context: Context, callback: (ready: boolean) => void) {
    HiLog.i(Tag, 'rcsStartRecording')
    this.createRecorder(() => {
      this.setAudioRecorderCallback();
      let name = commonData.STR.RECORDING_PREFIX + new Date().getTime() + rcsFormat;
      this.fileName = name;
      let fileObj = FileUtil.getFileUrl(context, name);
      this.avConfig.url = fileObj?.fileFd as string;
      this.file = fileObj?.file as fs.File;
      this.avRecorder?.prepare(this.avConfig, (err) => {
        if (err == null) {
          HiLog.i(Tag, 'prepare success');
          this.startRecorder((ready: boolean) => {
            if (callback) {
              callback(ready)
            }
          });
        } else {
          HiLog.i(Tag, 'prepare failed and error is ' + JSON.stringify(err));
        }
      });
    });
  }
}