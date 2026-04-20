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
import { describe, MockKit, it, beforeEach, when, ArgumentMatchers, expect, afterEach } from '@ohos/hypium';
import { AudioRecorderService } from '../../../../main/ets/service/AudioRecorderService';
import fs from '@ohos.file.fs';
import FileUtil from '../../../../main/ets/utils/FileUtil';
import HiLog from '../../../../main/ets/utils/HiLog';
import { DTGlobalContext } from '../../testability/TestAbility';

export default function audioRecorderServiceTest() {
  describe('audioRecorderServiceTest', () => {

    let audioRecorderService: AudioRecorderService;
    let mocker: MockKit;
    const Tag = 'AudioRecorderService';
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mocker = new MockKit();
      audioRecorderService = new AudioRecorderService();
    })

    afterEach(()=>{
      mocker.clear(audioRecorderService);
    })

    it('audioRecorderServiceTest_setAudioRecorderCallback', 0, () => {
      mocker.mockFunc(audioRecorderService,audioRecorderService.releaseRecorder);
      audioRecorderService.setAudioRecorderCallback();
      mocker.verify('releaseRecorder',[]).never();
    })

    it('audioRecorderServiceTest_createRecorder', 0, () => {
      mocker.mockFunc(HiLog,HiLog.i);
      audioRecorderService.createRecorder(()=>{
      });
      mocker.verify('HiLog',[Tag, 'createAVRecorder success']).never();
      mocker.clear(HiLog);
    })

    it('audioRecorderServiceTest_startRecording', 0, () => {
      mocker.mockFunc(audioRecorderService,audioRecorderService.createRecorder);
      mocker.mockFunc(audioRecorderService,audioRecorderService.setAudioRecorderCallback);
      audioRecorderService.startRecording(context, ()=>{
      });
      mocker.verify('setAudioRecorderCallback',[]).never();
    })

    it('audioRecorderServiceTest_startRecorder', 0, () => {
      mocker.mockFunc(HiLog,HiLog.i);
      audioRecorderService.startRecorder(()=>{
      });
      mocker.verify('HiLog',[Tag, 'start AVRecorder success']).never();
      mocker.clear(HiLog);
    })

    it('audioRecorderServiceTest_stopRecording', 0, async () => {
      mocker.mockFunc(audioRecorderService,audioRecorderService.closeFile);
      mocker.mockFunc(audioRecorderService,audioRecorderService.releaseRecorder);
      await audioRecorderService.stopRecording(context, (param1:string,param2:string)=>{
        expect(param1).assertEqual('');
      });
    })

    it('audioRecorderServiceTest_releaseRecorder', 0, async () => {
      mocker.mockFunc(HiLog,HiLog.i);
      await audioRecorderService.releaseRecorder();
      mocker.verify('HiLog',[Tag, 'releaseRecorder']).never();
      mocker.clear(HiLog);
    })

    it('audioRecorderServiceTest_getRecorderSize', 0, () => {
      audioRecorderService.file = {} as fs.File;
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSize))(ArgumentMatchers.any)
        .afterReturn(1);
      expect(audioRecorderService.getRecorderSize()).assertEqual(1);
      mocker.clear(FileUtil);
    })

    it('audioRecorderServiceTest_getRecorderSize_file_undefined', 0, () => {
      expect(audioRecorderService.getRecorderSize()).assertEqual(0);
    })

    it('audioRecorderServiceTest_closeFile', 0, () => {
      audioRecorderService.file = {} as fs.File;
      mocker.mockFunc(FileUtil, FileUtil.closeFile);
      audioRecorderService.closeFile();
      expect(audioRecorderService.file).assertUndefined();
      mocker.clear(FileUtil);
    })

    it('audioRecorderServiceTest_closeFile_file_undefined', 0, () => {
      audioRecorderService.closeFile();
      expect(audioRecorderService.file).assertUndefined();
    })

    it('audioRecorderServiceTest_rcsStartRecording', 0, () => {
      mocker.mockFunc(audioRecorderService,audioRecorderService.setAudioRecorderCallback);
      mocker.mockFunc(audioRecorderService,audioRecorderService.createRecorder);
      mocker.mockFunc(HiLog,HiLog.i);
      audioRecorderService.rcsStartRecording(context, ()=>{});
      mocker.verify('setAudioRecorderCallback',[]).never();
      mocker.clear(HiLog);
    })
  })
}