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
import { describe, beforeEach, afterEach, it, expect, MockKit, when } from '@ohos/hypium';
import { AudioPlayerService } from '../../../../main/ets/service/AudioPlayerService';
import { Mms } from '../../../../main/ets/utils/TypesUtils';
import ObjectUtil from '../../../../main/ets/utils/ObjectUtil';
import HiLog from '../../../../main/ets/utils/HiLog';

export default function audioPlayerServiceTest() {
  describe('audioPlayerServiceTest', () => {

    let audioPlayerService: AudioPlayerService;
    let mocker: MockKit;
    const TAG = 'AudioPlayerService';

    beforeEach(() => {
      audioPlayerService = new AudioPlayerService();
      mocker = new MockKit();
    })

    afterEach(() => {
      AppStorage.clear();
      mocker.clear(audioPlayerService);
      mocker.clear(HiLog);
      mocker.clear(ObjectUtil);
    })

    it('AudioRecorderService_getInstance', 0, () => {
      expect(typeof audioPlayerService).assertEqual(typeof AudioPlayerService.getInstance());
    })

    it('AudioRecorderService_setAudioFilePlayState_msgId_1_avPlayerState_playing', 0, async () => {
      AudioPlayerService.setAudioFilePlayState('1', 'playing');
      expect(JSON.stringify(AppStorage.get(AudioPlayerService.AUDIO_FILE_PLAY_STATE)))
        .assertEqual(JSON.stringify(new Map([['1', 'playing']])))
    })

    it('AudioRecorderService_setAudioFilePlayState_msgId_1_avPlayerState_idle', 0, async () => {
      AudioPlayerService.setAudioFilePlayState('1', 'idle');
      expect(JSON.stringify(AppStorage.get(AudioPlayerService.AUDIO_FILE_PLAY_STATE)))
        .assertEqual(JSON.stringify(new Map()))
    })

    it('AudioRecorderService_setAudioFilePlayState_msgId_undefined_avPlayerState_idle', 0, async () => {
      AudioPlayerService.setAudioFilePlayState(undefined, 'idle');
      expect(JSON.stringify(AppStorage.get(AudioPlayerService.AUDIO_FILE_PLAY_STATE)))
        .assertEqual(JSON.stringify(new Map()))
    })

    it('AudioRecorderService_playAudio_sameAudio_true', 0, async () => {
      let item: Mms = {
        duration: '',
        type: -1,
        path: '',
        name: ''
      };
      mocker.mockFunc(audioPlayerService, audioPlayerService.refreshItemStatus);
      mocker.mockFunc(audioPlayerService, audioPlayerService.stopAudio);
      mocker.mockFunc(audioPlayerService, audioPlayerService.setAVPlayerCallback);
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(item)
        .afterReturn(item);
      await audioPlayerService.startAudio('', item);
      audioPlayerService.playAudio(item);
      mocker.verify('stopAudio', []).never();
    })

    it('AudioRecorderService_playAudio_sameAudio_false', 0, async () => {
      let item: Mms = {
        duration: '',
        type: -1,
        path: '',
        name: 'name'
      };
      let item1: Mms = {
        duration: '',
        type: -1,
        path: '',
        name: ''
      };
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(item)
        .afterReturn(item);
      audioPlayerService.startAudio('', item);
      mocker.mockFunc(audioPlayerService, audioPlayerService.refreshItemStatus);
      mocker.mockFunc(audioPlayerService, audioPlayerService.stopAudio);
      mocker.mockFunc(audioPlayerService, audioPlayerService.setAVPlayerCallback);
      audioPlayerService.playAudio(item1);
      mocker.verify('stopAudio', []).never();
    })

    it('AudioRecorderService_playAudio_currentAudioItem_undefined', 0, async () => {
      let item: Mms = {
        duration: '',
        type: -1,
        path: '',
        name: ''
      };
      mocker.mockFunc(audioPlayerService, audioPlayerService.refreshItemStatus);
      mocker.mockFunc(audioPlayerService, audioPlayerService.startAudio);
      mocker.mockFunc(audioPlayerService, audioPlayerService.setAVPlayerCallback);
      audioPlayerService.playAudio(item);
      mocker.verify('startAudio', ['', item, undefined]).once();
    })

    it('AudioRecorderService_startAudio_failCallback_undefined', 0, async () => {
      let item: Mms = {
        duration: '',
        type: -1,
        path: '',
        name: ''
      };
      mocker.mockFunc(audioPlayerService, audioPlayerService.refreshItemStatus);
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(item)
        .afterReturn(item);
      mocker.mockFunc(HiLog, HiLog.i);
      audioPlayerService.startAudio(item.path, item);
      mocker.verify('i', [TAG, 'startAudio']).once();
    })

    it('AudioRecorderService_startAudio_path_empty_failCallback', 0, async () => {
      let item: Mms = {
        duration: '',
        type: -1,
        path: '',
        name: ''
      };
      mocker.mockFunc(audioPlayerService, audioPlayerService.refreshItemStatus);
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(item)
        .afterReturn(item);
      mocker.mockFunc(HiLog, HiLog.i);
      audioPlayerService.startAudio(item.path, item, () => {
      });
      mocker.verify('i', [TAG, 'startAudio']).once();
    })

    it('AudioRecorderService_startAudio_path_failCallback', 0, async () => {
      let item: Mms = {
        duration: '',
        type: -1,
        path: 'xx',
        name: ''
      };
      mocker.mockFunc(audioPlayerService, audioPlayerService.refreshItemStatus);
      mocker.mockFunc(audioPlayerService, audioPlayerService.setAVPlayerCallback);
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(item)
        .afterReturn(item);
      mocker.mockFunc(HiLog, HiLog.i);
      audioPlayerService.startAudio(item.path, item, () => {
      });
      mocker.verify('i', [TAG, 'startAudio']).once();
    })

    it('AudioRecorderService_startAudio_path_failCallback_undefined', 0, async () => {
      let item: Mms = {
        duration: '',
        type: -1,
        path: 'xx',
        name: ''
      };
      mocker.mockFunc(audioPlayerService, audioPlayerService.refreshItemStatus);
      mocker.mockFunc(audioPlayerService, audioPlayerService.setAVPlayerCallback);
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(item)
        .afterReturn(item);
      mocker.mockFunc(HiLog, HiLog.i);
      audioPlayerService.startAudio(item.path, item);
      mocker.verify('i', [TAG, 'startAudio']).once();
    })

    it('AudioRecorderService_stopAudio', 0, async () => {
      mocker.mockFunc(audioPlayerService, audioPlayerService.refreshItemStatus);
      await audioPlayerService.stopAudio();
      mocker.verify('i', [TAG, 'stopPlayAudio']).never();
    })

    it('AudioRecorderService_stopAudio_callback', 0, async () => {
      mocker.mockFunc(audioPlayerService, audioPlayerService.refreshItemStatus);
      mocker.mockFunc(HiLog, HiLog.i);
      await audioPlayerService.stopAudio(() => {
      });
      mocker.verify('i', [TAG, 'stopPlayAudio']).once();
    })

    it('AudioRecorderService_refreshItemStatus_currentAudioItem', 0, async () => {
      let item: Mms = {
        duration: '',
        type: -1,
        path: '',
        name: 'name'
      };
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(item)
        .afterReturn(item);
      audioPlayerService.startAudio('', item);
      audioPlayerService.refreshItemStatus();
      expect(JSON.stringify(AppStorage.get('stopAudio')))
        .assertEqual('{"duration":"","type":-1,"path":"","name":"name"}');
    })

    it('AudioRecorderService_refreshItemStatus_', 0, async () => {
      audioPlayerService.refreshItemStatus();
      expect(JSON.stringify(AppStorage.get('stopAudio'))).assertEqual('{"duration":"","type":-1,"path":"","name":"name"}');
    })
  })
}