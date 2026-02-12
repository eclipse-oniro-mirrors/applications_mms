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

import fs from '@ohos.file.fs';
import HiLog from '../utils/HiLog';
import { Mms } from '../utils/TypesUtils';
import MmsUtil from '../utils/MmsUtil';
import { BusinessError } from '@ohos.base';
import media from '@ohos.multimedia.media';
import audio from '@ohos.multimedia.audio';
import commonData from '../data/commonData';
import ObjectUtil from '../utils/ObjectUtil';
import { setWindowKeepScreenState } from '../MainAbility/GlobalHelper';

const TAG = 'AudioPlayerService';

export class AudioPlayerService {
  private avPlayer?: media.AVPlayer;
  private avPlayerForParseAudio?: media.AVPlayer | void;
  private static sInstance: AudioPlayerService;
  private currentAudioItem?: Mms;
  public static readonly AUDIO_FILE_PLAY_STATE = 'conversation_MMContent_MMContentFile_mapMsgId2AudioFilePlayState';
  public playState?: string;

  static getInstance() {
    if (AudioPlayerService.sInstance == null) {
      HiLog.i(TAG, 'getInstance');
      AudioPlayerService.sInstance = new AudioPlayerService();
    }
    return AudioPlayerService.sInstance;
  }

  public static setAudioFilePlayState(msgId: string | undefined, avPlayerState: media.AVPlayerState) {
    if (msgId) {
      if (avPlayerState === 'playing') {
        let map: Map<String, media.AVPlayerState> = new Map([[msgId, avPlayerState]]);
        AppStorage.setOrCreate <Map<String, media.AVPlayerState>>(AudioPlayerService.AUDIO_FILE_PLAY_STATE,
          map);
      } else {
        AppStorage.setOrCreate <Map<String, media.AVPlayerState>>(AudioPlayerService.AUDIO_FILE_PLAY_STATE,
          new Map());
      }
    } else {
      AppStorage.setOrCreate <Map<String, media.AVPlayerState>>(AudioPlayerService.AUDIO_FILE_PLAY_STATE,
        new Map());
    }
  }

  public realseAvPlayerForParseAudio() {
    this.avPlayerForParseAudio && this.avPlayerForParseAudio.release();
    this.avPlayerForParseAudio = undefined;
  }

  public async getAudioDuration(path: string) {
    try {
      let duration = await this.parseAudioFile(path);
      return duration;
    } catch (e) {
      HiLog.e(TAG, 'getAudioDuration failed, error: ' + JSON.stringify(e));
      return '';
    }
  }

  private static clearTimeoutTimer(timerId: number | undefined) {
    if (typeof timerId === 'number' && !isNaN(timerId)) {
      clearTimeout(timerId);
    }
  }

  private async parseAudioFile(path: string) {
    HiLog.i(TAG, `parseAudioFile start`);
    if (!path) {
      return '';
    }
    return new Promise(async (resolve: (duration: string) => void, reject: () => void) => {
      if (this.avPlayerForParseAudio) {
        this.avPlayerForParseAudio.release();
      }
      this.avPlayerForParseAudio = await media.createAVPlayer().catch((err: BusinessError) => {
        HiLog.i(TAG, `parseAudioFile media.createAVPlayer failed, code is ${err.code}, message is ${err.message}`);
      });
      if (!this.avPlayerForParseAudio) {
        HiLog.e(TAG, 'parseAudioFile avPlayerForParseAudio is empty');
        resolve('');
        return;
      }
      let timerId: number = -1;
      this.avPlayerForParseAudio.on('error', (err) => {
        HiLog.e(TAG, `parseAudioFile Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
        resolve('');
        AudioPlayerService.clearTimeoutTimer(timerId);
      });

      this.avPlayerForParseAudio.on('stateChange', async (state, reason) => {
        if (this.avPlayerForParseAudio && state === commonData.MEDIA_STATUS.INITIALIZED) {
          this.setAudioSteam(this.avPlayerForParseAudio);
          await this.avPlayerForParseAudio.prepare();
          resolve(String(this.avPlayerForParseAudio.duration));
          AudioPlayerService.clearTimeoutTimer(timerId);
        } else if ([commonData.MEDIA_STATUS.IDLE, commonData.MEDIA_STATUS.PREPARED,
          commonData.MEDIA_STATUS.RELEASED, commonData.MEDIA_STATUS.ERROR].includes(state)) {
          return;
        } else {
          resolve('');
          AudioPlayerService.clearTimeoutTimer(timerId);
        }
      });

      let file = await fs.open(path);
      let fdPath: string = commonData.STR.FILE_FD + '' + file.fd;
      this.avPlayerForParseAudio.url = fdPath;
      timerId = setTimeout(() => {
        HiLog.e(TAG, `parseAudioFile time out`);
        resolve('');
      }, 3000);
    });
  }

  setAVPlayerCallback() {
    this.avPlayer?.on('seekDone', (seekDoneTime) => {
      HiLog.i(TAG, `AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    })
    this.avPlayer?.on('error', (err) => {
      HiLog.i(TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      this.avPlayer?.reset();
      if (this.currentAudioItem) {
        AppStorage.setOrCreate('stopAudio', this.currentAudioItem);
        this.currentAudioItem = undefined;
      }
      if (err.code === 5400106) {
        MmsUtil.showToast({
          message: $r('app.string.audio_play_error'),
          duration: 2000
        })
      }
    })
    this.avPlayer?.on('stateChange', async (state, reason) => {
      HiLog.i(TAG, 'AVPlayer state: ' + state);
      this.playState = state;
      switch (state) {
        case commonData.MEDIA_STATUS.IDLE:
          HiLog.i(TAG, 'AVPlayer state idle called.');
          this.avPlayer?.release();
          break;
        case commonData.MEDIA_STATUS.INITIALIZED:
          HiLog.i(TAG, 'AVPlayer state initialized called.');
          this.setAudioSteam(this.avPlayer);
          this.avPlayer?.prepare().then(() => {
            HiLog.i(TAG, 'AVPlayer prepare succeeded.');
          }, (err: BusinessError) => {
            HiLog.i(TAG, `Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
          });
          break;
        case commonData.MEDIA_STATUS.PREPARED:
          HiLog.i(TAG, 'AVPlayer state prepared called.');
          this.setAudioInterrupt();
          break;
        case commonData.MEDIA_STATUS.PLAYING:
          HiLog.i(TAG, 'AVPlayer state playing called.');
          setWindowKeepScreenState(true);
          break;
        case commonData.MEDIA_STATUS.PAUSED:
          HiLog.i(TAG, 'AVPlayer state paused called.');
          break;
        case commonData.MEDIA_STATUS.COMPLETED:
          HiLog.i(TAG, 'AVPlayer state completed called.');
          this.avPlayer?.stop();
          AudioPlayerService.setAudioFilePlayState(undefined, 'stopped');
          break;
        case commonData.MEDIA_STATUS.STOPPED:
          HiLog.i(TAG, 'AVPlayer state stopped called.');
          setWindowKeepScreenState(false);
          this.avPlayer?.reset();
          this.refreshItemStatus();
          this.avPlayer?.off('audioInterrupt');
          break;
        case commonData.MEDIA_STATUS.RELEASED:
          HiLog.i(TAG, 'AVPlayer state released called.');
          break;
        default:
          HiLog.i(TAG, 'AVPlayer state unknown called.');
          break;
      }
    })
  }

  setAudioInterrupt() {
    HiLog.i(TAG, 'setAudioInterrupt');
    this.avPlayer?.play();
    this.avPlayer?.on('audioInterrupt', (info: audio.InterruptEvent) => {
      if (info.forceType === audio.InterruptForceType.INTERRUPT_FORCE ||
        info.forceType === audio.InterruptForceType.INTERRUPT_SHARE) {
        this.stopAudio();
      }
    })
  }

  setAudioSteam(avPlayer: media.AVPlayer | undefined) {
    let rendererInfo: audio.AudioRendererInfo = {
      usage: audio.StreamUsage.STREAM_USAGE_VOICE_MESSAGE,
      rendererFlags: 0
    }
    if (avPlayer !== undefined) {
      avPlayer.audioRendererInfo = rendererInfo;
    }
  }

  playAudio(item: Mms, failCallback?: () => void) {
    if (this.currentAudioItem) {
      let sameAudio: boolean = this.currentAudioItem.name == item.name;
      if (sameAudio) {
        this.stopAudio(() => {
        });
      } else {
        AppStorage.setOrCreate('stopAudio', this.currentAudioItem);
        this.currentAudioItem = undefined;
        this.stopAudio(() => {
          HiLog.i(TAG, 'pre audio item stoped');
          this.startAudio(item.path, item, failCallback);
        });
      }

    } else {
      this.startAudio(item.path, item, failCallback);
    }
  }

  async startAudio(filePath: string, item: Mms, failCallback?: () => void) {
    HiLog.i(TAG, 'startAudio');
    this.currentAudioItem = ObjectUtil.getCopyObject(item) as Mms;
    if (!filePath || filePath === '') {
      HiLog.i(TAG, 'playAudio failed, filepath is empty')
      this.refreshItemStatus();
      if (failCallback) {
        failCallback();
      }
      return;
    }

    try {
      this.avPlayer = await media.createAVPlayer();
      this.setAVPlayerCallback();
      let file = await fs.open(filePath);
      let fdPath: string = commonData.STR.FILE_FD + '' + file.fd;
      this.avPlayer.url = fdPath;
    } catch (e) {
      HiLog.e(TAG, 'startAudio failed, error: ' + JSON.stringify(e));
      if (failCallback) {
        failCallback();
      }
    }
  }

  async stopAudio(callback?: Function) {
    HiLog.i(TAG, 'stopPlayAudio');
    if (!this.avPlayer) {
      HiLog.i(TAG, 'avPlayer failed');
      if (callback) {
        callback();
      }
      this.refreshItemStatus();
    } else {
      if (this.avPlayer.state === commonData.MEDIA_STATUS.PREPARED ||
        this.avPlayer.state === commonData.MEDIA_STATUS.PLAYING ||
        this.avPlayer.state === commonData.MEDIA_STATUS.PAUSED) {
        this.avPlayer.stop(async (err) => {
          if (err == null) {
            HiLog.i(TAG, 'play audio stop success');
          } else {
            HiLog.i(TAG, 'play audio stop filed,error message is :' + err.message);
          }
          await this.avPlayer?.reset();
          await this.avPlayer?.release();
          this.avPlayer = undefined;
          if (callback) {
            callback();
          }
        });
      } else {
        HiLog.i(TAG, 'play audio state: ' + this.avPlayer?.state);
        await this.avPlayer?.reset();
        await this.avPlayer?.release();
        this.avPlayer = undefined;
        if (callback) {
          callback();
        }
      }
    }
  }

  refreshItemStatus() {
    if (this.currentAudioItem) {
      HiLog.i(TAG, 'refreshItemStatus');
      AppStorage.setOrCreate('stopAudio', this.currentAudioItem);
      this.currentAudioItem = undefined;
    }
  }
}