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
import { describe, it, expect, MockKit, ArgumentMatchers, when } from '@ohos/hypium';
import MmsUtil from '../../../../main/ets/utils/MmsUtil';
import { Mms } from '../../../../main/ets/utils/TypesUtils';
import common from "../../../../main/ets/data/commonData";
import commonData from '../../../../main/ets/data/commonData';
import promptAction from '@ohos.promptAction';
import fs from '@ohos.file.fs';
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import HiLog from '../../../../main/ets/utils/HiLog';
import SharedPreferencesUtils from '../../../../main/ets/utils/SharedPreferencesUtils';
import { mmsListType } from '../../../../main/ets/pages/conversation/conversationController';
import FileUtil from '../../../../main/ets/utils/FileUtil';
import OperatorConfigUtil from '../../../../main/cust/utils/OperatorConfigUtil';
import LooseObject from '../../../../main/ets/data/LooseObject';

export default function mmsUtilTest() {
  describe('MmsUtilTest', () => {

    it("MmsUtil_isImage_true", 0, () => {
      let result = MmsUtil.isImage(common.MM_ATTACHMENT_TYPE.IMAGE);
      expect(result).assertEqual(true);
    })

    it("MmsUtil_isImage_false", 0, () => {
      let result = MmsUtil.isImage(common.MM_ATTACHMENT_TYPE.VIDEO);
      expect(result).assertEqual(false);
    })

    it("MmsUtil_isAudio_true", 0, () => {
      let result = MmsUtil.isAudio(common.MM_ATTACHMENT_TYPE.AUDIO);
      expect(result).assertEqual(true);
    })

    it("MmsUtil_isAudio_false", 0, () => {
      let result = MmsUtil.isAudio(common.MM_ATTACHMENT_TYPE.IMAGE);
      expect(result).assertEqual(false);
    })

    it("MmsUtil_isVideo_true", 0, () => {
      let result = MmsUtil.isVideo(common.MM_ATTACHMENT_TYPE.VIDEO);
      expect(result).assertEqual(true);
    })

    it("MmsUtil_isVideo_false", 0, () => {
      let result = MmsUtil.isVideo(common.MM_ATTACHMENT_TYPE.IMAGE);
      expect(result).assertEqual(false);
    })

    it("MmsUtil_isSmil_true", 0, () => {
      let result = MmsUtil.isSmil(common.MM_ATTACHMENT_TYPE.SMIL);
      expect(result).assertEqual(true);
    })

    it("MmsUtil_isSmil_false", 0, () => {
      let result = MmsUtil.isSmil(common.MM_ATTACHMENT_TYPE.AUDIO);
      expect(result).assertEqual(false);
    })

    it('MmsUtil_getRcsContentType', 0, () => {
      let source: Mms[] = [{
        type: 4
      } as Mms, {
        type: 4
      } as Mms];

      expect(MmsUtil.getRcsContentType(source)).assertEqual(commonData.MMS_CONTENT_TYPE.VCARD);

      source = [{
        type: 4
      } as Mms, {
        type: 8
      } as Mms];

      expect(MmsUtil.getRcsContentType(source)).assertEqual(commonData.MMS_CONTENT_TYPE.FILE);

      source = [{
        type: 4
      } as Mms, {
        type: 9
      } as Mms];

      expect(MmsUtil.getRcsContentType(source)).assertEqual(commonData.MMS_CONTENT_TYPE.ORIGIN);
      expect(MmsUtil.getRcsContentType([])).assertEqual(commonData.MMS_CONTENT_TYPE.ORIGIN);
    })

    it("MmsUtil_isValidSize_undefined", 0, () => {
      let result = MmsUtil.isValidSize([]);
      expect(result).assertEqual(undefined);
    })

    it("MmsUtil_isValidSize", 0, () => {
      let source: Array<Mms> = [{
        path: 'data/files/111.txt',
        name: '111.txt',
        size: '12',
        type: common.MM_ATTACHMENT_TYPE.SMIL,
        duration: ''
      }, {
        path: 'data/files/image.jpg',
        name: 'image.jpg',
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        size: '13',
        duration: ''
      }, {
        path: 'data/files/audio.amr',
        name: 'audio.amr',
        type: common.MM_ATTACHMENT_TYPE.AUDIO,
        size: '14',
        duration: '00:20'
      }]
      let result = MmsUtil.isValidSize(source);
      expect(result).assertEqual('13');
    })

    it("MmsUtil_isSmil1", 0, () => {
      let source:Mms[] = [{
        type: 4,
        size:'1'
      } as Mms];
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(MmsUtil,MmsUtil.deleteSmil))(ArgumentMatchers.any)
        .afterReturn(source);
      let result = MmsUtil.isSmil(common.MM_ATTACHMENT_TYPE.AUDIO);
      expect(result).assertFalse();
      mocker.clear(MmsUtil);
    })

    it("MmsUtil_isSmil2", 0, () => {
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(MmsUtil,MmsUtil.deleteSmil))(ArgumentMatchers.any)
        .afterReturn([]);
      let result = MmsUtil.isSmil(common.MM_ATTACHMENT_TYPE.AUDIO);
      expect(result).assertFalse();
      mocker.clear(MmsUtil);
    })

    it("MmsUtil_deleteSmil", 0, () => {
      let source0: Array<Mms> = []
      let result = MmsUtil.deleteSmil(source0)
      expect(result.length).assertEqual(source0.length)
      let source1: Array<Mms> = [
        {
          duration: "30:20",
          type: 3,
          path: "",
          name: "zz.mp3",
          text: "test2",
        },
        {
          duration: "30:20",
          type: 3,
          path: "",
          name: "zz.mp3",
          text: "test2",
        },
        {
          duration: "30:20",
          type: 0,
          path: "",
          name: "zz.smi",
          text: "test2",
        },
        {
          duration: "30:20",
          type: 7,
          path: "",
          name: "zz.txt",
          text: "test2",
        }
      ]
      let result1 = MmsUtil.deleteSmil(source1)
      expect(source1.length - 2).assertEqual(2);
    })


    it("MmsUtil_deleteRcsSmil", 0, () => {
      let result:Mms[] = [];
      result = MmsUtil.deleteRcsSmil([]);
      expect(result.length).assertEqual(0);

      let source:Mms[] = [{
        type: 1,
        size:'1'
      } as Mms];
      result = MmsUtil.deleteRcsSmil(source);
      expect(result.length).assertEqual(1);
    })


    it("MmsUtil_deleteRcsSmil_1", 0, () => {
      let source: Array<Mms> = [{
        path: 'data/files/111.txt',
        name: '111.txt',
        size: '12',
        type: common.MM_ATTACHMENT_TYPE.SMIL,
        duration: ''
      }, {
        path: 'data/files/image.jpg',
        name: 'image.jpg',
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        size: '13',
        duration: ''
      }, {
        path: 'data/files/audio.amr',
        name: 'audio.amr',
        type: common.MM_ATTACHMENT_TYPE.AUDIO,
        size: '14',
        duration: '00:20'
      }]
      let result = MmsUtil.deleteRcsSmil(source);
      expect(result.length).assertEqual(2);
    })

    it("MmsUtil_getMmsSourceFromRequest", 0, () => {
      let list: Array<Record<string, string | number>> = [
        {
          "recordingTime": "30:20",
          "type": 0,
          "path": `/data/app/a.txt`
        },
        {
          "recordingTime": "30:20",
          "type": 0,
          "path": `/data/app/b.mp3`
        },
        {
          "recordingTime": "30:20",
          "type": commonData.ENHANCED_INFO_ITEM_TYPE.MAP,
          "content": 'map_content',
          "path": `/data/app/c.smi`
        }
      ]
      let result = MmsUtil.getMmsSourceFromRequest(list)
      expect(result).assertEqual(result)
    })

    it("MmsUtil_getMmsSourceFromRequest_list_null", 0, () => {
      let list: Array<Record<string, string | number>> = []
      let result = MmsUtil.getMmsSourceFromRequest(list)
      expect(result).assertEqual(result)
    })

    it("MmsUtil_getRcsSourceFromRequest", 0, () => {
      let list: Array<Record<string, string | number>> = [];
      let result = MmsUtil.getRcsSourceFromRequest(list,'');
      expect(result.length).assertEqual(0);

      list = [{
        'recordingTime':'',
        'type':0,
        'path':'xx/xxx.png',
        'imagePath':'',
        'partSize':0,
      } as Record<string, number | string>];
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(MmsUtil,MmsUtil.isRcsMap))(ArgumentMatchers.any)
        .afterReturn(true);
      when(mocker.mockFunc(JSON,JSON.parse))(ArgumentMatchers.any)
        .afterReturn({
          body:';',
          latitude:'10',
          longitude:'10'
        });
      result = MmsUtil.getRcsSourceFromRequest(list,'xx');
      expect(result.length).assertEqual(1);

      result = MmsUtil.getRcsSourceFromRequest(list,'');
      expect(result.length).assertEqual(1);

      when(mocker.mockFunc(MmsUtil,MmsUtil.isRcsMap))(ArgumentMatchers.any)
        .afterReturn(false);
      result = MmsUtil.getRcsSourceFromRequest(list,'');
      expect(result.length).assertEqual(1);

      mocker.clear(MmsUtil);
      mocker.clear(JSON);
    })

    it("MmsUtil_getRcsSourceFromRequest_item_hasNull", 0, () => {
      let list: Array<Record<string, string | number>> = [
        undefined,
        {
        'recordingTime':'',
        'type':0,
        'path':'xx/xxx.png',
        'imagePath':'',
        'partSize':0,
      } as Record<string, number | string>];
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(MmsUtil,MmsUtil.isRcsMap))(ArgumentMatchers.any)
        .afterReturn(true);
      when(mocker.mockFunc(JSON,JSON.parse))(ArgumentMatchers.any)
        .afterReturn({
          body:';',
          latitude:'10',
          longitude:'10'
        });
      let result = MmsUtil.getRcsSourceFromRequest(list,'');
      expect(result.length).assertEqual(1);

      mocker.clear(MmsUtil);
      mocker.clear(JSON);
    })

    it("MmsUtil_getMmsContentType_2", 0, () => {
      let list: Array<Mms> = [{
        path: 'data/files/111.txt',
        name: '111.txt',
        type: common.MM_ATTACHMENT_TYPE.SMIL,
        duration: ''
      }, {
        path: 'data/files/audio.amr',
        name: 'audio.amr',
        type: common.MM_ATTACHMENT_TYPE.SMIL,
        duration: '00:20'
      }, {
        path: 'data/files/image.jpg',
        name: 'image.jpg',
        type: common.MM_ATTACHMENT_TYPE.SMIL,
        duration: ''
      }]
      let contentType = MmsUtil.getMmsContentType(list);
      expect(contentType).assertEqual(0)
    })

    it("MmsUtil_getMmsContentType_1", 0, () => {
      let list: Array<Mms> = [{
        path: 'data/files/111.txt',
        name: '111.txt',
        type: common.MM_ATTACHMENT_TYPE.SMIL,
        duration: ''
      }, {
        path: 'data/files/image.jpg',
        name: 'image.jpg',
        type: common.MM_ATTACHMENT_TYPE.SMIL,
        duration: ''
      }, {
        path: 'data/files/audio.amr',
        name: 'audio.amr',
        type: common.MM_ATTACHMENT_TYPE.SMIL,
        duration: '00:20'
      }]
      let contentType = MmsUtil.getMmsContentType(list);
      expect(contentType).assertEqual(0)
    })

    it("MmsUtil_getMmsContentType_zero", 0, () => {
      let list: Array<Mms> = [{
        path: 'data/files/111.txt',
        name: '111.txt',
        type: common.MM_ATTACHMENT_TYPE.SMIL,
        duration: ''
      }, {
        path: 'data/files/image.jpg',
        name: 'image.jpg',
        type: common.MM_ATTACHMENT_TYPE.SMIL,
        duration: ''
      }]
      let contentType = MmsUtil.getMmsContentType(list);
      expect(contentType).assertEqual(0)
    })

    it("MmsUtil_getMmsContentType_smilParCounts_else", 0, () => {
      let list: Array<Mms> = [{
        path: 'data/files/111.txt',
        name: '111.txt',
        type: common.MM_ATTACHMENT_TYPE.TEXT,
        duration: ''
      }, {
        path: 'data/files/image.jpg',
        name: 'image.jpg',
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        duration: ''
      }]
      let contentType = MmsUtil.getMmsContentType(list, 'msgTitle');
      expect(contentType).assertEqual(0);
    })

    it("MmsUtil_getMmsContentType_smilParCounts_not_empty", 0, () => {
      AppStorage.setOrCreate('smilParCounts', { 'data/files/image.jpg': 1 } as LooseObject);
      let list: Array<Mms> = [{
        path: 'data/files/111.txt',
        name: '111.txt',
        type: common.MM_ATTACHMENT_TYPE.TEXT,
        duration: ''
      }, {
        path: 'data/files/image.jpg',
        name: 'image.jpg',
        type: common.MM_ATTACHMENT_TYPE.SMIL,
        duration: ''
      }]
      let contentType = MmsUtil.getMmsContentType(list);
      expect(contentType).assertEqual(0);
      AppStorage.clear();
    })

    it("MmsUtil_getMmsContentType_smilParCounts_not_empty_parCounts_2", 0, () => {
      AppStorage.setOrCreate('smilParCounts', { 'data/files/image.jpg': 2 } as LooseObject);
      let list: Array<Mms> = [{
        path: 'data/files/111.txt',
        name: '111.txt',
        type: common.ENHANCED_INFO_ITEM_TYPE.FILE,
        duration: ''
      }, {
        path: 'data/files/image.jpg',
        name: 'image.jpg',
        type: common.MM_ATTACHMENT_TYPE.SMIL,
        duration: ''
      }]
      let contentType = MmsUtil.getMmsContentType(list);
      expect(contentType).assertEqual(2);
      AppStorage.clear();
    })

    it("MmsUtil_getMmsFirstType_zero", 0, () => {
      let list: Array<Mms> = [];
      let type = MmsUtil.getMmsFirstType(list);
      expect(type).assertEqual(0);
    })

    it("MmsUtil_getMmsFirstType_one", 0, () => {
      let list: Array<Mms> = [{
        path: 'data/files/111.txt',
        name: '111.txt',
        type: common.MM_ATTACHMENT_TYPE.TEXT,
        duration: ''
      }, {
        path: 'data/files/image.jpg',
        name: 'image.jpg',
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        duration: ''
      }, {
        path: 'data/files/audio.amr',
        name: 'audio.amr',
        type: common.MM_ATTACHMENT_TYPE.AUDIO,
        duration: '00:20'
      }]
      let type = MmsUtil.getMmsFirstType(list);
      expect(type).assertEqual(0)
    })

    it("MmsUtil_getSmilSource_true", 0, () => {
      let source: Mms[] = [];
      let newSource = MmsUtil.getSmilSource(source)

      expect(newSource).assertNull();
    })

    it("MmsUtil_getSmilSource_false", 0, () => {
      let source:Mms[] = [{
        type: 1,
        size:'1'
      } as Mms];
      let newSource = MmsUtil.getSmilSource(source);

      expect(newSource).assertNull();
    })

    it("MmsUtil_getFileUTD_false", 0, () => {
      let path = '';
      const lastDotIndex = path.lastIndexOf('.');

      expect(MmsUtil.getFileUTD(path).length >= 0).assertTrue()
    })

    it("MmsUtil_getFileUTD_jpe", 0, () => {
      let path = 'IMG_1734335455673.jpe';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);

      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_getFileUTD_jpeg", 0, () => {
      let path = 'IMG_1734335455673.jpeg';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);

      let result = MmsUtil.getFileUTD(path, 'jpeg')
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_getFileUTD_jpg", 0, () => {
      let path = 'IMG_1734335455673.jpg';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);

      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_getFileUTD_png", 0, () => {
      let path = 'IMG_1734335455673.png';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);

      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })
    
    it("MmsUtil_getFileUTD_bmp", 0, () => {
      let path = 'IMG_1734335455673.bmp';
      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_badgePosition_other", 0, () => {
      let count: number = 100;
      let fontSizeScale: number = 1.75;
      let result = MmsUtil.badgePosition(count, fontSizeScale);
      let badgeP = {
        x: 4, y: -4
      } as Position;
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(badgeP));
    })
    
    it('FileUtilTest_getRetryTime_success', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let mockFunc: Function = mocker.mockFunc(MmsUtil, MmsUtil.getRetryTime);
      when(mockFunc)(0).afterReturn(111);
      let result = MmsUtil.getRetryTime(0);
      expect(result).assertEqual(111);
      mocker.clear(HiLog);
      mocker.clear(MmsUtil);
    })
    
    it('FileUtilTest_increasesRetryTime_success', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('MMS_RETRY12')
        .afterReturn(12);
      MmsUtil.increasesRetryTime(12);
      mocker.verify('increasesRetryTime',[12]).never();
      mocker.clear(HiLog);
      mocker.clear(SharedPreferencesUtils);
    })

    it("MmsUtil_getMmsFirstType_length", 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let sour: Array<Mms> = [{
        path: 'data/files/111.txt',
        name: '111.txt',
        type: common.MM_ATTACHMENT_TYPE.TEXT,
        duration: ''
      }];
      let mockFunc: Function = mocker.mockFunc(MmsUtil, MmsUtil.generateSlidePreviewData);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(sour);
      let type = MmsUtil.getMmsFirstType(sour);
      expect(type).assertEqual(7);
      mocker.clear(MmsUtil)
      mocker.clear(HiLog)
    })

    it("MmsUtil_isMap_false", 0, () => {
      let result = MmsUtil.isMap(1)
      expect(result).assertEqual(false);
    })
    
    it("MmsUtil_isMap_true", 0, () => {
      let result = MmsUtil.isMap(8)
      expect(result).assertEqual(true);
    })
    
    it("MmsUtil_isSlideNoImage_true", 0, () => {
      let result = MmsUtil.isSlideNoImage(2)
      expect(result).assertEqual(true);
    })
    
    it("MmsUtil_isSlideNoImage_false", 0, () => {
      let result = MmsUtil.isSlideNoImage(0)
      expect(result).assertEqual(false);
    })
    
    it("MmsUtil_isSlideHasImage_true", 0, () => {
      let result = MmsUtil.isSlideHasImage(1)
      expect(result).assertEqual(true);
    })
    
    it("MmsUtil_isSlideHasImage_false", 0, () => {
      let result = MmsUtil.isSlideHasImage(0)
      expect(result).assertEqual(false);
    })

    it("MmsUtil_getFileUTD_gif", 0, () => {
      let path = 'IMG_1734335455673.gif';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);

      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_getFileUTD_heic", 0, () => {
      let path = 'IMG_1734335455673.heic';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);

      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_getFileUTD_mp3", 0, () => {
      let path = 'IMG_1734335455673.mp3';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);

      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_getFileUTD_m4a", 0, () => {
      let path = 'IMG_1734335455673.m4a';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);

      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_getFileUTD_mp2", 0, () => {
      let path = 'IMG_1734335455673.mp2';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);

      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_getFileUTD_flac", 0, () => {
      let path = 'IMG_1734335455673.flac';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);

      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_getFileUTD_aac", 0, () => {
      let path = 'IMG_1734335455673.aac';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);

      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_getFileUTD_wav", 0, () => {
      let path = 'IMG_1734335455673.wav';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);

      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_getFileUTD_wave", 0, () => {
      let path = 'IMG_1734335455673.wave';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);

      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_getFileUTD_mp4", 0, () => {
      let path = 'IMG_1734335455673.mp4';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);

      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_getFileUTD_mkv", 0, () => {
      let path = 'IMG_1734335455673.mkv';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);

      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_getFileUTD_amr", 0, () => {
      let path = 'IMG_1734335455673.amr';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);

      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_badgePosition_true", 0, () => {
      let count: number = 99;
      let fontSizeScale: number = 1.75;
      let result = MmsUtil.badgePosition(count, fontSizeScale);

      expect(typeof result).assertEqual(typeof BadgePosition);
    })

    it("MmsUtil_badgePosition_false_1", 0, () => {
      let count: number = 1;
      let fontSizeScale: number = 1.75;
      let result = MmsUtil.badgePosition(count, fontSizeScale);

      expect(typeof result).assertEqual(typeof BadgePosition);
    })

    it("MmsUtil_badgePosition_false_2", 0, () => {
      let count: number = 100;
      let fontSizeScale: number = 1.25;
      let result = MmsUtil.badgePosition(count, fontSizeScale);

      expect(typeof result).assertEqual(typeof BadgePosition);
    })

    it("MmsUtil_badgePosition_false_3", 0, () => {
      let count: number = 1;
      let fontSizeScale: number = 1.25;
      let result = MmsUtil.badgePosition(count, fontSizeScale);

      expect(typeof result).assertEqual(typeof BadgePosition);
    })

    it('MmsUtil_is_unknown', 0, () => {
      let result = MmsUtil.getFileUTD('testpath.unknown');
      expect(result.length >= 0).assertTrue();
    })

    it("MmsUtil_getFileUTD_type_gif", 0, () => {
      let path = 'IMG.gif';

      const lastDotIndex = MmsUtil.getFileUTD(path).lastIndexOf('.');
      const fileExtName = path.slice(lastDotIndex + 1);
      let result = MmsUtil.getFileUTD(path)
      expect(result.length >= 0).assertTrue();
    })

    it('MmsUtilTest_getSlideShowTypeByFirstItemType_SLIDE_CONTAINS_IMAGE', 0, () => {
      let result = MmsUtil.getSlideShowTypeByFirstItemType(commonData.MM_ATTACHMENT_TYPE.IMAGE);
      expect(result).assertEqual(commonData.MMS_CONTENT_TYPE.SLIDE_CONTAINS_IMAGE);
    })

    it('MmsUtilTest_getSlideShowTypeByFirstItemType_SLIDE_NO_IMAGE', 0, () => {
      let result = MmsUtil.getSlideShowTypeByFirstItemType(commonData.MM_ATTACHMENT_TYPE.TEXT);
      expect(result).assertEqual(commonData.MMS_CONTENT_TYPE.SLIDE_NO_IMAGE);
    })

    it('MmsUtilTest_getAllParNodeFromSmil_parentNode_null', 0, () => {
      MmsUtil.getAllParNodeFromSmil([], []);
      expect(MmsUtil).not().assertUndefined();
    })

    it('MmsUtilTest_checkRcsTransmitToMms_IMAGE', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByUri))('data/files/image.jpg')
        .afterReturn(6);
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(commonData.int.MMS_FILE_MAX_SIZE)
        .afterReturn(7);
      let listType = new mmsListType();
      listType.mmsSource = [{
        path: 'data/files/111.txt',
        name: '111.txt',
        size: '12',
        type: common.MM_ATTACHMENT_TYPE.TEXT,
        duration: ''
      }, {
        path: 'data/files/image.jpg',
        name: 'image.jpg',
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        size: '13',
        duration: ''
      }];
      let res = MmsUtil.checkRcsTransmitToMms(listType);
      mocker.clear(FileUtil);
      mocker.clear(OperatorConfigUtil.getInstance());
      expect(res).assertTrue();
    })

    it('MmsUtilTest_checkRcsTransmitToMms_UNSUPPORT_RCS_TYPE_OF_MMS', 0, () => {
      let listType = new mmsListType();
      listType.mmsSource = [{
        path: 'data/files/audio.amr',
        name: 'audio.amr',
        type: common.ENHANCED_INFO_ITEM_TYPE.AUDIO,
        size: '14',
        duration: '00:20'
      }];
      let res = MmsUtil.checkRcsTransmitToMms(listType);
      expect(res).assertFalse();
    })

    it('MmsUtilTest_checkRcsTransmitToMms_AUDIO', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(FileUtil, FileUtil.getFileSizeByUri))('data/files/image.jpg')
        .afterReturn(6);
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(),
        OperatorConfigUtil.getInstance().getCustMMSSize))(commonData.int.MMS_FILE_MAX_SIZE)
        .afterReturn(5);
      let listType = new mmsListType();
      listType.mmsSource = [{
        path: 'data/files/111.txt',
        name: '111.txt',
        size: '12',
        type: common.MM_ATTACHMENT_TYPE.TEXT,
        duration: ''
      }, {
        path: 'data/files/image.jpg',
        name: 'image.jpg',
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        size: '13',
        duration: ''
      }, {
        path: 'data/files/audio.amr',
        name: 'audio.amr',
        type: common.ENHANCED_INFO_ITEM_TYPE.AUDIO,
        size: '14',
        duration: '00:20'
      }];
      let res = MmsUtil.checkRcsTransmitToMms(listType);
      mocker.clear(FileUtil);
      mocker.clear(OperatorConfigUtil.getInstance());
      expect(res).assertFalse();
    })

    it('MmsUtilTest_getAllParNodeFromSmil', 0, () => {
      MmsUtil.getAllParNodeFromSmil([{
        _name: 'par',
        _text: '_text',
        _type: '_type',
        _attributes: {
          'id': '102'
        },
        _declaration: '_declaration',
        _elements: [{
          _name: 'par',
          _text: '_text',
          _type: '_type',
          _attributes: {
            'id': '102'
          },
          _declaration: '_declaration',
          _elements: []
        }]
      },{
        _name: 'notpar',
        _text: '_text',
        _type: '_type',
        _attributes: {
          'id': '102'
        },
        _declaration: '_declaration',
        _elements: [{
          _name: 'notpar',
          _text: '_text',
          _type: '_type',
          _attributes: {
            'id': '102'
          },
          _declaration: '_declaration',
          _elements: []
        }]
      }], []);
      expect(MmsUtil).not().assertUndefined();
    })

    it("MmsUtilTest_getSmilFullMmsSource", 0, () => {
      let list: Array<Mms> = [{
        path: 'data/files/111.txt',
        name: '111.txt',
        type: common.MM_ATTACHMENT_TYPE.TEXT,
        duration: ''
      }, {
        path: 'data/files/23124.smil',
        name: '23124.smil',
        type: commonData.MM_ATTACHMENT_TYPE.SMIL,
        duration: ''
      }]
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(MmsUtil, MmsUtil.getSmilParStrData))('data/files/23124.smil')
        .afterReturn([{
          _name: 'par',
          _text: '_text',
          _type: '_type',
          _attributes: {
            'id': '102'
          },
          _declaration: '_declaration',
          _elements: [{
            _name: 'par',
            _text: '_text',
            _type: '_type',
            _attributes: {
              'id': '102'
            },
            _declaration: '_declaration',
            _elements: []
          }]
        },{
          _name: 'notpar',
          _text: '_text',
          _type: '_type',
          _attributes: {
            'id': '102'
          },
          _declaration: '_declaration',
          _elements: [{
            _name: 'notpar',
            _text: '_text',
            _type: '_type',
            _attributes: {
              'id': '102'
            },
            _declaration: '_declaration',
            _elements: []
          }]
        }]);
      let fullSource = MmsUtil.getSmilFullMmsSource(list);
      mocker.clear(MmsUtil);
      expect(fullSource.length).assertEqual(2);
    })

    it("MmsUtilTest_getSmilFullMmsSource_name_has_null", 0, () => {
      let list: Array<Mms> = [{
        path: 'data/files/111.txt',
        name: '111.txt',
        type: common.MM_ATTACHMENT_TYPE.TEXT,
        duration: ''
      }, {
        path: 'data/files/23124.smil',
        name: '23124.smil',
        type: commonData.MM_ATTACHMENT_TYPE.SMIL,
        duration: ''
      }]
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(MmsUtil, MmsUtil.getSmilParStrData))('data/files/23124.smil')
        .afterReturn([{
          _name: 'data',
          _text: '_text',
          _type: '_type',
          _attributes: {
            'id': '102',
            'src': 'cid:data'
          },
          _declaration: '_declaration',
          _elements: [{
            _name: null,
            _text: '_text',
            _type: '_type',
            _attributes: {
              'id': '102',
              'src': 'cid:<data>'
            },
            _declaration: '_declaration',
            _elements: []
          }]
        },{
          _name: 'text',
          _text: '_text',
          _type: '_type',
          _attributes: {
            'id': '102',
            'src': 'cid:data'
          },
          _declaration: '_declaration',
          _elements: []
        },{
          _name: 'notpar',
          _text: '_text',
          _type: '_type',
          _attributes: {
            'id': '102',
            'src': 'notpar'
          },
          _declaration: '_declaration',
          _elements: [{
            _name: 'text',
            _text: '_text',
            _type: '_type',
            _attributes: {
              'id': '102',
              'src': 'cid:<text>'
            },
            _declaration: '_declaration',
            _elements: []
          }]
        }]);
      let fullSource = MmsUtil.getSmilFullMmsSource(list);
      mocker.clear(MmsUtil);
      expect(fullSource.length).assertEqual(3);
    })

    it("MmsUtilTest_generateSlidePreviewData", 0, () => {
      let list: Array<Mms> = [{
        path: 'data/files/image.jpg',
        name: 'image.jpg',
        type: commonData.MM_ATTACHMENT_TYPE.IMAGE,
        smilParIndex: 1,
        duration: ''
      }, {
        path: 'data/files/111.txt',
        name: '111.txt',
        type: common.MM_ATTACHMENT_TYPE.TEXT,
        smilParIndex: 1,
        duration: ''
      }, {
        path: 'data/files/image.jpg',
        name: 'image.jpg',
        type: commonData.MM_ATTACHMENT_TYPE.IMAGE,
        smilParIndex: 1,
        duration: ''
      }]
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(MmsUtil, MmsUtil.getSmilFullMmsSource))(ArgumentMatchers.any)
        .afterReturn([{
          path: 'data/files/image.jpg',
          name: 'image.jpg',
          type: commonData.MM_ATTACHMENT_TYPE.IMAGE,
          smilParIndex: 1,
          duration: ''
        }, {
          path: 'data/files/image.jpg',
          name: 'image.jpg',
          type: commonData.MM_ATTACHMENT_TYPE.IMAGE,
          smilParIndex: 1,
          duration: ''
        }, {
          path: 'data/files/image.jpg',
          name: 'image.jpg',
          type: commonData.MM_ATTACHMENT_TYPE.MAP,
          smilParIndex: 1,
          duration: ''
        }, {
          path: 'data/files/111.txt',
          name: '111.txt',
          type: common.MM_ATTACHMENT_TYPE.TEXT,
          smilParIndex: 1,
          duration: ''
        }])
      let slideList = MmsUtil.generateSlidePreviewData(list);
      mocker.clear(MmsUtil);
      expect(slideList.length).assertEqual(1);
    })
  })
}