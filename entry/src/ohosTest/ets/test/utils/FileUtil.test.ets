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
import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import FileUtil, { formatFileSize, getMineTypeFromFileName,
  getMineTypeFromFileNameAndCt,
  SaveTextType } from '../../../../main/ets/utils/FileUtil';
import fs from '@ohos.file.fs';
import fileuri from '@ohos.file.fileuri';
import HiLog from '../../../../main/ets/utils/HiLog';
import { DTGlobalContext } from '../../testability/TestAbility';
import LocationUtil from '../../../../main/ets/utils/LocationUtil';

export default function FileUtilTest() {
  describe('FileUtilTest', () => {

    const TAG = 'FileUtil ';
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    it('FileUtilTest_getFileUrl_error', 0, () => {
      let name = '123.jpg';
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(FileUtil, FileUtil.getSandboxPath);
      when(mockFunc)(ArgumentMatchers.any).afterThrow('error');
      let err = FileUtil.getFileUrl(context, name);
      expect(JSON.stringify(err)).assertEqual('{"fileFd":""}');
      mocker.ignoreMock(FileUtil, FileUtil.getSandboxPath);
    })

    it('FileUtilTest_getFileFd_error', 0, () => {
      let fd = FileUtil.getFileFd('data/path/1235.jpg');
      expect(fd).assertEqual(-1);
    })

    it('FileUtilTest_writeToSandBox_name_error', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let path = 'haha/file/123.jpg';
      FileUtil.writeToSandBox(context, path, new Uint8Array().buffer, '345.jpg');
      mocker.verify('i', [TAG, 'writeToSandBox']).times(1);
      mocker.clear(HiLog);
    })

    it('FileUtilTest_getFileName_null', 0, () => {
      let name = FileUtil.getFileName('');
      expect(name).assertEqual('');
    })

    it('FileUtilTest_getFileName', 1, () => {
      let path: string = 'file:///data/file/123.jpg';
      let name = FileUtil.getFileName(path);
      expect(name).assertEqual('123.jpg');
    })

    it('FileUtilTest_getFileFullDirectoryUri_null', 0, () => {
      let uri = FileUtil.getFileFullDirectoryUri('');
      expect(uri).assertEqual('');
    })

    it('FileUtilTest_getFileFullDirectoryUri', 1, () => {
      let path: string = 'file:///data/file/123.jpg';
      let uri = FileUtil.getFileFullDirectoryUri(path);
      expect(uri).assertEqual('');
    })

    it('FileUtilTest_writeTextToSandBox', 1, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let text: string = 'text hello';
      FileUtil.writeTextToSandBox(context, text, false);
      mocker.verify('i', [TAG, 'writeTextToSandBox']).times(1);
      mocker.clear(HiLog);
    })

    it('FileUtilTest_writeTextToSandBox_smil', 1, () => {
      let text: string = 'text hello aa';
      let res: Record<string, string> = FileUtil.writeTextToSandBox(context, text, true);
      expect(res.name.endsWith('.xml')).assertTrue();
    })

    it('FileUtilTest_writeTextToSandBox_error', 1, () => {
      let text: string = 'text';
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(FileUtil, FileUtil.getSandboxPath);
      when(mockFunc)(ArgumentMatchers.any).afterThrow('error');
      let obj = FileUtil.writeTextToSandBox(context, text, false);
      expect(JSON.stringify(obj)).assertEqual(`{"path":"","name":""}`);
      mocker.clear(FileUtil);
    })

    it('FileUtilTest_writeMediaToSandBox_video_error', 1, () => {
      let path = 'haha//123.mp4';
      let obj = FileUtil.writeMediaToSandBox(context, path, 2, false);
      expect(obj).assertEqual('');
    })

    it('FileUtilTest_deleteFile', 1, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      FileUtil.deleteFile(context, '123.jpg');
      mocker.verify('i', [TAG, 'deleteFile']).times(1);
      mocker.clear(HiLog);
    })

    it('FileUtilTest_deleteFile_error', 1, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      FileUtil.deleteFile(context, '');
      mocker.verify('i', [TAG, 'deleteFile']).times(1);
      mocker.clear(HiLog);
    })

    it('FileUtilTest_getFileSizeByUri_error', 1, () => {
      let path = 'data/123.jpg';
      let size = FileUtil.getFileSizeByUri(path);
      expect(size).assertEqual(0);
    })

    it('FileUtilTest_getFileSizeAndFile_error', 1, () => {
      let path = 'data/123.jpg';
      let res = FileUtil.getFileSizeAndFile(path);
      expect(res).assertUndefined();
    })

    it('FileUtilTest_packingSize_error', 1, async () => {
      let path = 'data/123.jpg';
      let res= await FileUtil.packingSize(path);
      expect(res.size).assertEqual(0);
    })

    it('FileUtilTest_hasSandAccess', 0, () => {
      let result = FileUtil.hasSandAccess(context);
      expect(result).assertTrue();
    });

    it('FileUtilTest_getFilePath', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(FileUtil, FileUtil.getSandboxPath))(context).afterReturn('fileDir');
      let result = FileUtil.getFilePath(context, 'str');
      expect(result).assertEqual('fileDir/str');
      mocker.clear(FileUtil);
    });

    it('FileUtilTest_getFileName_if', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let result = FileUtil.getFileName('');
      expect(result).assertEqual('');
      mocker.clear(HiLog);
    });

    it('FileUtilTest_writeMediaToSandBox_image_readonly', 0, async  ()=>{
      let filesDir = FileUtil.getSandboxPath(context);
      let path = filesDir + '/234.mp4';
      let result: string = FileUtil.writeMediaToSandBox(context, path, 1, true);
      expect(result).assertEqual('');
    })

    it('FileUtilTest_writeMediaToSandBox_video_readonly', 0, async  ()=>{
      let filesDir = FileUtil.getSandboxPath(context);
      let path = filesDir + '/234.mp4';
      let result: string = FileUtil.writeMediaToSandBox(context, path, 2, true);
      expect(result).assertEqual('');
    })

    it('FileUtilTest_getTextFileContent_error', 0, () => {
      let uri = 'uri/123.jpg';
      let result = FileUtil.getTextFileContent(uri);
      expect(result).assertEqual('');
    })

    it('FileUtilTest_fileNameRemoveTimestamp', 0, () => {
      let result = FileUtil.fileNameRemoveTimestamp('file_.txt');
      expect(result).assertEqual('file.txt');
    })

    it('FileUtilTest_fileNameRemoveTimestamp_remove', 0, () => {
      let result = FileUtil.fileNameRemoveTimestamp('file_20220101.txt');
      expect(result).assertEqual('file.txt');
    })

    it('FileUtilTest_fileNameRemoveTimestamp_normal', 0, () => {
      let result = FileUtil.fileNameRemoveTimestamp('file_2022_01_01.txt');
      expect(result).assertEqual('file_2022_01.txt');
    })

    it('FileUtilTest_fileNameRemoveTimestamp_noPoint_normal', 0, () => {
      let result = FileUtil.fileNameRemoveTimestamp('file_2022_01_01.');
      expect(result).assertEqual('file_2022_01.');
    })

    it('FileUtilTest_fileNameRemoveTimestamp_noPoint_remove', 0, () => {
      let result = FileUtil.fileNameRemoveTimestamp('file_20220101');
      expect(result).assertEqual('file');
    })

    it('FileUtilTest_fileNameRemoveTimestamp_normal_re', 0, () => {
      let result = FileUtil.fileNameRemoveTimestamp('file_2022_01_01_.txt');
      expect(result).assertEqual('file_2022_01_01.txt');
    })

    it('FileUtilTest_getFileSizeByPath_error', 0, () => {
      let path = 'data/path/123.jpg';
      let result = FileUtil.getFileSizeByPath(path);
      expect(result).assertEqual(0);
    })

    it('FileUtilTest_getFileSizeByPath_null', 0, () => {
      let result = FileUtil.getFileSizeByPath('');
      expect(result).assertEqual(0);
    })

    it('FileUtilTest_getFileSizeAndFile_error_catch', 0, () => {
      let res = FileUtil.getFileSizeAndFile('');
      expect(res).assertUndefined();
    })

    it('FileUtilTest_getTransitStationFileSizeByUri_error', 0, () => {
      let res = FileUtil.getTransitStationFileSizeByUri('');
      expect(res).assertEqual(0);
    })

    it('FileUtilTest_renameFile_failed', 0, () => {
      let res = FileUtil.renameFile('data/path/abc.txt', 'data/path/xyz.txt');
      expect(res).assertEqual('data/path/abc.txt');
    })
    
    it('FileUtilTest_formatFileName_empty', 0, () => {
      let res = FileUtil.formatFileName('');
      expect(res).assertEqual('');
    })

    it('FileUtilTest_formatFileName', 0, () => {
      let res = FileUtil.formatFileName('ab/c/.txt');
      expect(res).assertEqual('abc.txt');
    })

    it('FileUtilTest_formatFileName1', 0, () => {
      let res = FileUtil.formatFileName('ab\\c\\.txt');
      expect(res).assertEqual('abc.txt');
    })

    it('FileUtilTest_formatFileName2', 0, () => {
      let res = FileUtil.formatFileName('ab~c~.txt');
      expect(res).assertEqual('abc.txt');
    })

    it('FileUtilTest_formatFileSize1', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(LocationUtil, LocationUtil.numFormat))(0).afterReturn('0 B');
      let res = formatFileSize(0, 2);
      mocker.clear(LocationUtil);
      expect(res).assertEqual('0 B');
    })

    it('FileUtilTest_formatFileSize2', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(LocationUtil, LocationUtil.numFormat))(500).afterReturn('500 B');
      let res = formatFileSize(500, 1);
      mocker.clear(LocationUtil);
      expect(res).assertEqual('500 B');
    })

    it('FileUtilTest_formatFileSize3', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(LocationUtil, LocationUtil.numFormat))(ArgumentMatchers.any).afterReturn('1.00 KB');
      let res = formatFileSize(1000, 2);
      mocker.clear(LocationUtil);
      expect(res).assertEqual('1.00 KB');
    })

    it('FileUtilTest_formatFileSize4', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(LocationUtil, LocationUtil.numFormat))(ArgumentMatchers.any).afterReturn('2 KB');
      let res = formatFileSize(1500, 0);
      mocker.clear(LocationUtil);
      expect(res).assertEqual('2 KB');
    })

    it('FileUtilTest_formatFileSize5', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(LocationUtil, LocationUtil.numFormat))(ArgumentMatchers.any).afterReturn('1.000 MB');
      let res = formatFileSize(1000000, 3);
      mocker.clear(LocationUtil);
      expect(res).assertEqual('1.000 MB');
    })

    it('FileUtilTest_formatFileSize6', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(LocationUtil, LocationUtil.numFormat))(ArgumentMatchers.any).afterReturn('1.50 MB');
      let res = formatFileSize(1500000, 2);
      mocker.clear(LocationUtil);
      expect(res).assertEqual('1.50 MB');
    })

    it('FileUtilTest_getMineTypeFromFileName_empty', 0, () => {
      let res = getMineTypeFromFileName('');
      expect(res).assertEqual('text/plain');
    })

    it('FileUtilTest_getMineTypeFromFileName', 0, () => {
      let res = getMineTypeFromFileName('file');
      expect(res).assertEqual('text/plain');
    })

    it('FileUtilTest_getMineTypeFromFileName_txt', 0, () => {
      let res = getMineTypeFromFileName('file.txt');
      expect(res).assertEqual('text/plain');
    })

    it('FileUtilTest_getMineTypeFromFileName_jpg', 0, () => {
      let res = getMineTypeFromFileName('file.jpg');
      expect(res).assertEqual('image/jpeg');
    })

    it('FileUtilTest_getMineTypeFromFileName_unknown', 0, () => {
      let res = getMineTypeFromFileName('file.unknown');
      expect(res).assertEqual('text/plain');
    })

    it('FileUtilTest_getMineTypeFromFileNameAndCt_empty', 0, () => {
      let res = getMineTypeFromFileNameAndCt('', undefined);
      expect(res).assertEqual('text/plain');
    })

    it('FileUtilTest_getMineTypeFromFileNameAndCt', 0, () => {
      let res = getMineTypeFromFileNameAndCt('file.', undefined);
      expect(res).assertEqual('text/plain');
    })

    it('FileUtilTest_getMineTypeFromFileNameAndCt_json', 0, () => {
      let res = getMineTypeFromFileNameAndCt('file.', 'application/json');
      expect(res).assertEqual('application/json');
    })

    it('FileUtilTest_getMineTypeFromFileNameAndCt_txt', 0, () => {
      let res = getMineTypeFromFileNameAndCt('file.txt', '');
      expect(res).assertEqual('text/plain');
    })

    it('FileUtilTest_getMineTypeFromFileNameAndCt_unknown', 0, () => {
      let res = getMineTypeFromFileNameAndCt('file.unknown', undefined);
      expect(res).assertEqual('text/plain');
    })

    it('FileUtilTest_getMineTypeFromFileNameAndCt_jpg', 0, () => {
      let res = getMineTypeFromFileNameAndCt('file.jpg', undefined);
      expect(res).assertEqual('image/jpeg');
    })

    it('FileUtilTest_getMineTypeFromFileNameAndCt_jpg_json', 0, () => {
      let res = getMineTypeFromFileNameAndCt('file.jpg', 'application/json');
      expect(res).assertEqual('image/jpeg');
    })

    it('FileUtilTest_writeMediaToSandBox_vCard_readonly', 0, async  ()=>{
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let filesDir = FileUtil.getSandboxPath(context);
      let path = filesDir + '/456.vcf';
      FileUtil.writeMediaToSandBox(context, path, 4, true);
      mocker.verify('i', [TAG, 'writePictureToSandBox']).times(1);
      mocker.clear(HiLog);
    })

    it('FileUtilTest_saveFileToFileManager_vCard_readonly', 0, async  ()=>{
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let filesDir = FileUtil.getSandboxPath(context);
      let name = '789.vcf'
      let path = filesDir + '/' + name;
      FileUtil.saveFileToFileManager(context, path, name);
      mocker.verify('i', [TAG, 'saveFileToFileManager']).times(1);
      mocker.clear(HiLog);
    })
  })
}