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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import SmilFile from '../../../../main/ets/utils/SmilFile'
import { Mms, Region } from '../../../../main/ets/utils/TypesUtils'
import common from "../../../../main/ets/data/commonData"
import xml from '@ohos.xml';
import { DTGlobalContext } from '../../testability/TestAbility';

export default function SmilFileTest() {
  describe('SmilFileTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })

    it('SmilFile_buildSmilFile_nopagenum_istext', 0, () => {
      let mms: Mms = {
        duration: '',
        type: 7,
        path: '',
        name: ''
      }
      let mmsSource0: Array<Mms> = [mms]
      let result0 = SmilFile.buildSmilFile(mmsSource0);
      expect(typeof result0).assertEqual('string')
    })

    it('SmilFile_buildSmilFile_nopagenum_isnottext', 0, () => {
      let mms: Mms = {
        duration: '',
        type: 8,
        path: '',
        name: ''
      }
      let mmsSource0: Array<Mms> = [mms]
      let result0 = SmilFile.buildSmilFile(mmsSource0);
      expect(typeof result0).assertEqual('string')
    })

    it('SmilFile_buildSmilFile_nopar', 0, () => {
      let mms: Mms = {
        duration: '',
        type: 1,
        path: '',
        name: '',
        pageNum: 1
      }
      let mmsSource0: Array<Mms> = [mms]
      let result0 = SmilFile.buildSmilFile(mmsSource0);
      expect(typeof result0).assertEqual('string')
    })

    it('SmilFile_buildSmilFiles_haspar', 0, () => {
      let mms: Mms = {
        duration: '',
        type: 1,
        path: '',
        name: '1',
        pageNum: 1
      }
      let mmsSource0: Array<Mms> = [mms, mms]
      let result0 = SmilFile.buildSmilFile(mmsSource0);
      expect(typeof result0).assertEqual('string')
    })

    it('SmilFile_buildSmilFiles_audio', 0, () => {
      let mms: Mms = {
        duration: '',
        type: 3,
        path: '',
        name: '1',
        pageNum: 1
      }
      let mmsSource0: Array<Mms> = [mms]
      let result0 = SmilFile.buildSmilFile(mmsSource0);
      expect(typeof result0).assertEqual('string')
    })

    it('SmilFile_getDurationTime_with', 0, () => {
      let result0 = SmilFile.getDurationTime('11:11')
      expect(result0).assertEqual(671000)
    })

    it('SmilFileTest_buildSmilXml', 0, () => {
      (SmilFile as object)['buildSmilXml'](['101', '342'], [{
        num: 1,
        dur: 3,
        items: [{
          type: 'text',
          dur: 1,
          src: '/src',
          region: 'region'
        },{
          type: 'text',
          dur: 2,
          src: '/src',
          region: 'region'
        },{
          type: 'xx',
          dur: 3,
          src: '/src',
          region: 'region'
        },{
          type: 'xx',
          dur: 4,
          src: '/src',
          region: 'region'
        }]
      }]);
      expect(SmilFile).not().assertUndefined();
    })

    it('SmilFile_getDurationTime_without', 0, () => {
      let result0 = SmilFile.getDurationTime('1111')
      expect(result0).assertEqual(1111)
    })

    it('SmilFile_getSmil_null', 0, () => {
      let mmsSource0: Array<Mms> = []
      let result0 = SmilFile.getSmil('', mmsSource0)
      expect(result0).assertEqual("")
    })

    it('SmilFile_getSmil_mmsSource_length_2_text_empty', 0, () => {
      let mmsSource0: Array<Mms> = [
        {
          duration: "30:20",
          type: common.MM_ATTACHMENT_TYPE.AUDIO,
          path: "",
          name: "cc.mp3",
          text: "test1",
        },
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.TEXT,
          path: "",
          name: "dd.txt"
        }
      ]
      let result0 = SmilFile.getSmil('', mmsSource0)
      expect(result0).assertEqual('<smil></smil>')
    })

    it('SmilFile_getSmil_audio_text', 0, () => {
      let text = "TestText"
      let mmsSource: Array<Mms> = [
        {
          duration: "30:20",
          type: common.MM_ATTACHMENT_TYPE.AUDIO,
          path: "",
          name: "cc.mp3",
          text: "test1",
        },
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.TEXT,
          path: "",
          name: "dd.txt"
        }
      ]
      let result = SmilFile.getSmil(text, mmsSource)
      expect(result)
        .assertEqual(`<smil><head><layout><root-layout />` +
          `<region id="Text" top="0" left="0" height="100%" width="100%" fit="meet"/></layout></head>` +
          `<body><par dur="1820000ms"><audio src="cc.mp3" dur="1820000ms" /><text src="dd.txt" region="Text" /></par>` +
          `</body></smil>`)
    })

    it('SmilFile_getSmil_audio_no_text', 0, () => {
      let mmsSource: Array<Mms> = [
        {
          duration: "30:20",
          type: 3,
          path: "",
          name: "cc.mp3",
          text: "test1"
        }
      ]
      let result = SmilFile.getSmil('', mmsSource);
      expect(result)
        .assertEqual(`<smil><head><layout><root-layout /></layout></head><body>` +
          `<par dur="1820000ms"><audio src="cc.mp3" dur="1820000ms" /></par></body></smil>`)
    })

    it('SmilFile_getSmil_image_text', 0, () => {
      let text = "TestText"
      let mmsSource: Array<Mms> = [
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.IMAGE,
          path: "",
          name: "zz.jpg"
        },
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.TEXT,
          path: "",
          name: "dd.txt"
        }
      ]
      let result = SmilFile.getSmil(text, mmsSource)
      expect(result)
        .assertEqual(`<smil><head><layout><root-layout />` +
          `<region id="Text" top="0" left="0" height="100%" width="100%" fit="meet"/>` +
          `<region id="Image" top="0" left="0" height="100%" width="100%" fit="meet"/>` +
          `</layout></head><body><par dur=""><img src="zz.jpg" region="Image" /><text src="dd.txt" region="Text" />` +
          `</par></body></smil>`)
    })

    it('SmilFile_getSmil_image_no_text', 0, () => {
      let mmsSource: Array<Mms> = [
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.IMAGE,
          path: "",
          name: "zz.jpg"
        }
      ]
      let result = SmilFile.getSmil('', mmsSource);
      expect(result)
        .assertEqual(`<smil><head><layout><root-layout />` +
          `<region id="Image" top="0" left="0" height="100%" width="100%" fit="meet"/>` +
          `</layout></head><body><par dur=""><img src="zz.jpg" region="Image" /></par></body></smil>`)
    })

    it('SmilFile_getSmil_video_text', 0, () => {
      let text = "TestText"
      let mmsSource: Array<Mms> = [
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.VIDEO,
          path: "",
          name: "123.mp4"
        },
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.TEXT,
          path: "",
          name: "dd.txt"
        }
      ]
      let result = SmilFile.getSmil(text, mmsSource)
      expect(result)
        .assertEqual(`<smil><head><layout><root-layout />` +
          `<region id="Text" top="0" left="0" height="100%" width="100%" fit="meet"/>` +
          `<region id="Image" top="0" left="0" height="100%" width="100%" fit="meet"/></layout></head>` +
          `<body><par dur=""><video src="123.mp4" dur="" region="Image" /><text src="dd.txt" region="Text" /></par>` +
          `</body></smil>`)
    })

    it('SmilFile_getSmil_video_no_text', 0, () => {
      let mmsSource: Array<Mms> = [
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.VIDEO,
          path: "",
          name: "123.mp4"
        }
      ]
      let result = SmilFile.getSmil('', mmsSource);
      expect(result)
        .assertEqual(`<smil><head><layout><root-layout />` +
          `<region id="Image" top="0" left="0" height="100%" width="100%" fit="meet"/></layout></head>` +
          `<body><par dur=""><video src="123.mp4" dur="" region="Image" /></par></body></smil>`)
    })

    it('SmilFile_getSmil_text', 0, () => {
      let mmsSource: Array<Mms> = [
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.TEXT,
          path: "",
          name: "123.txt"
        }
      ]
      let result = SmilFile.getSmil('', mmsSource);
      expect(result)
        .assertEqual(`<smil><head></head><body></body></smil>`)
    })

    it('SmilFile_getSmil_text_notEmpty', 0, () => {
      let mmsSource: Array<Mms> = [
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.TEXT,
          path: "",
          name: "123.txt"
        }
      ]
      let result = SmilFile.getSmil('text1', mmsSource);
      expect(result)
        .assertEqual(`<smil><head><layout><root-layout /><region id="Text" top="0" left="0" height="100%" width="100%" fit="meet"/></layout></head><body><par dur=""><text src="123.txt" region="Text" /></par></body></smil>`)
    })

    it("SmilFileTest_addBodyNode", 0, () => {
      let pars = [
        `<par dur="5000ms"><text src="text_2057769970.txt" region="Text"/></par>`,
        `<par dur="5000ms"><img src="4deb1717941fea41c9f3a14590a59ffd.jpg" region="Image"/>/par>`
      ]
      let result = SmilFile.addBodyNode(pars)
      let expectRes = `<body><par dur="5000ms"><text src="text_2057769970.txt" region="Text"/>` +
        `</par><par dur="5000ms"><img src="4deb1717941fea41c9f3a14590a59ffd.jpg" region="Image"/>/par></body>`
      expect(result).assertEqual(expectRes)
    })

    it("SmilFileTest_addHeadNode", 0, () => {
      let result = SmilFile.addHeadNode(`<layout><root-layout width="1152px" height="2256px"/>` +
        `<region id="Text" left="0" top="2030" width="1152px" height="225px" fit="meet"/>` +
        `<region id="Image" left="0" top="0" width="1152px" height="2030px" fit="meet"/></layout>`)
      expect(result)
        .assertEqual(`<head><layout><root-layout width="1152px" height="2256px"/>` +
          `<region id="Text" left="0" top="2030" width="1152px" height="225px" fit="meet"/>` +
          `<region id="Image" left="0" top="0" width="1152px" height="2030px" fit="meet"/></layout></head>`)
    })

    it("SmilFileTest_addLayoutNode", 0, () => {
      let regions = [`<region id="Image" left="0" top="0" width="1152px" height="2030px" fit="meet"/>`]
      let result = SmilFile.addLayoutNode(regions)
      expect(result)
        .assertEqual(`<layout><root-layout />` +
          `<region id="Image" left="0" top="0" width="1152px" height="2030px" fit="meet"/></layout>`)
    })

    it("SmilFileTest_addParElement", 0, () => {
      let duration = `5000ms`
      let subElement = `<text src="text_2058653742.txt" region="Text"/>`
      let result = SmilFile.addParElement(duration, subElement)
      expect(result).assertEqual(`<par dur="5000ms"><text src="text_2058653742.txt" region="Text"/></par>`)
    })

    it("SmilFileTest_addAudioElement", 0, () => {
      let src = `recording2012194031124354242.amr`
      let dur = `4620ms`
      let result = SmilFile.addAudioElement(src, dur)
      expect(result).assertEqual(`<audio src="recording2012194031124354242.amr" dur="4620ms" />`)
    })

    it("SmilFileTest_addImgElement", 0, () => {
      let src = `cc.jpg`
      let result = SmilFile.addImgElement(src)
      expect(result).assertEqual(`<img src="cc.jpg" region="Image" />`)
    })

    it("SmilFileTest_addVideoElement", 0, () => {
      let src = `cc.mp4`
      let dur = `4620ms`
      let result = SmilFile.addVideoElement(src, dur)
      expect(result).assertEqual(`<video src="cc.mp4" dur="4620ms" region="Image" />`)
    })

    it("SmilFileTest_addTextElement", 0, () => {
      let src = `cc.txt`
      let result = SmilFile.addTextElement(src)
      expect(result).assertEqual(`<text src="cc.txt" region="Text" />`)
    })

    it("SmilFileTest_addRegionElement", 0, () => {
      let regionObj: Region = {
        id: "Image",
        fit: undefined,
        top: "0",
        left: "0",
        height: "2030px",
        width: "1152px"
      }
      let result = SmilFile.addRegionElement(regionObj)
      expect(result).assertEqual(`<region id="Image" top="0" left="0" height="2030px" width="1152px" />`)
    })

    it("SmilFileTest_getDuration", 0, () => {
      let result0 = SmilFile.getDuration("")
      expect(result0).assertEqual("")
      let result1 = SmilFile.getDuration("30:20")
      expect(result1).assertEqual("1820000ms")
    })

    it('SmilFileTest_getSlideSmil_mmsSource_empty', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let result = await SmilFile.getSlideSmil('text', [], context);
      expect(result).assertEqual('')
    })

    it('SmilFileTest_getSlideSmil_text_empty', 0, async () => {
      let mmsSource: Array<Mms> = [
        {
          duration: "30:20",
          type: common.MM_ATTACHMENT_TYPE.IMAGE,
          path: "",
          name: "cc.mp3",
          text: "test1",
        },
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.VIDEO,
          path: "",
          name: "dd.txt"
        }
      ]
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let result = await SmilFile.getSlideSmil('', mmsSource, context);
      expect(result).assertEqual('<smil><head><layout><root-layout /><region id="Image" top="0" left="0" height="100%" width="100%" fit="meet"/></layout></head><body><par dur=""><img src="cc.mp3" region="Image" /></par><par dur=""><video src="dd.txt" dur="" region="Image" /></par></body></smil>')
    })

    it('SmilFileTest_getSlideSmil_hasImageRegion_false', 0, async () => {
      let mmsSource: Array<Mms> = [
        {
          duration: "30:20",
          type: common.MM_ATTACHMENT_TYPE.TEXT,
          path: "",
          name: "cc.mp3",
          text: "test1",
        },
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.AUDIO,
          path: "",
          name: "dd.txt"
        }
      ]
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let result = await SmilFile.getSlideSmil('', mmsSource, context);
      expect(result).assertEqual('<smil><head><layout><root-layout /></layout></head><body><par dur=""><audio src="dd.txt" dur="" /></par></body></smil>')
    })

    it('SmilFileTest_getSlideSmil', 0, async () => {
      let mmsSource: Array<Mms> = [
        {
          duration: "30:20",
          type: common.MM_ATTACHMENT_TYPE.AUDIO,
          path: "",
          name: "cc.mp3",
          text: "test1",
        },
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.IMAGE,
          path: "",
          name: "dd.txt"
        },
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.VIDEO,
          path: "",
          name: "dd.txt"
        },
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.TEXT,
          path: "",
          name: "dd.txt"
        }
      ]
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let result = await SmilFile.getSlideSmil('textTest', mmsSource, context)
      expect(result).assertEqual('<smil><head><layout><root-layout /><region id="Text" top="0" left="0" height="100%" width="100%" fit="meet"/><region id="Image" top="0" left="0" height="100%" width="100%" fit="meet"/></layout></head><body><par dur="1820000ms"><text src="dd.txt" region="Text" /><audio src="cc.mp3" dur="1820000ms" /></par><par dur=""><img src="dd.txt" region="Image" /></par><par dur=""><video src="dd.txt" dur="" region="Image" /></par></body></smil>')
    })

    it('SmilFileTest_mmsTypeToParItemType', 0, () => {
      (SmilFile as object)['mmsTypeToParItemType'](0);
      (SmilFile as object)['mmsTypeToParItemType'](1);
      (SmilFile as object)['mmsTypeToParItemType'](2);
      (SmilFile as object)['mmsTypeToParItemType'](3);
      (SmilFile as object)['mmsTypeToParItemType'](4);
      (SmilFile as object)['mmsTypeToParItemType'](5);
      (SmilFile as object)['mmsTypeToParItemType'](6);
      (SmilFile as object)['mmsTypeToParItemType'](7);
      (SmilFile as object)['mmsTypeToParItemType'](8);
      (SmilFile as object)['mmsTypeToParItemType'](9);
      (SmilFile as object)['mmsTypeToParItemType'](10);
      expect(SmilFile).not().assertUndefined();
    })

    it('SmilFileTest_mmsTypeToRegionId', 0, () => {
      (SmilFile as object)['mmsTypeToRegionId'](0);
      (SmilFile as object)['mmsTypeToRegionId'](1);
      (SmilFile as object)['mmsTypeToRegionId'](2);
      (SmilFile as object)['mmsTypeToRegionId'](3);
      (SmilFile as object)['mmsTypeToRegionId'](4);
      (SmilFile as object)['mmsTypeToRegionId'](5);
      (SmilFile as object)['mmsTypeToRegionId'](6);
      (SmilFile as object)['mmsTypeToRegionId'](7);
      (SmilFile as object)['mmsTypeToRegionId'](8);
      (SmilFile as object)['mmsTypeToRegionId'](9);
      (SmilFile as object)['mmsTypeToRegionId'](10);
      expect(SmilFile).not().assertUndefined();
    })

    it('SmilFile_getSmil_vcard_no_text', 0, () => {
      let mmsSource: Array<Mms> = [
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.VCARD,
          path: "",
          name: "123.vcf"
        }
      ]
      let result = SmilFile.getSmil('', mmsSource);
      expect(result)
        .assertEqual(`<smil><head><layout><root-layout />` +
          `</layout></head><body><par dur=""></par></body></smil>`)
    })

    it('SmilFile_getSmil_vcard_text', 0, () => {
      let text = "TestText"
      let mmsSource: Array<Mms> = [
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.VCARD,
          path: "",
          name: "456.vcf"
        },
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.TEXT,
          path: "",
          name: "dd.txt"
        }
      ]
      let result = SmilFile.getSmil(text, mmsSource);
      expect(result)
        .assertEqual(`<smil><head><layout><root-layout /></layout></head><body><par dur=""></par></body></smil>`)
    })

    it('SmilFile_getVcardSmil_vcard_no_text', 0, () => {
      let mmsSource: Array<Mms> = [
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.VCARD,
          path: "",
          name: "123.vcf"
        }
      ]
      let result = SmilFile.getVcardSmil(mmsSource[0], '', mmsSource);
      expect(result.par)
        .assertEqual(`<par dur=""></par>`)
      expect(result.layout)
        .assertEqual(`<layout><root-layout /></layout>`)
    })

    it('SmilFile_getVcardSmil_vcard_text', 0, () => {
      let text = "TestText"
      let mmsSource: Array<Mms> = [
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.VCARD,
          path: "",
          name: "456.vcf"
        },
        {
          duration: "",
          type: common.MM_ATTACHMENT_TYPE.TEXT,
          path: "",
          name: "dd.txt"
        }
      ]
      let result = SmilFile.getVcardSmil(mmsSource[0], text, mmsSource);
      expect(result.par)
        .assertEqual(`<par dur=""></par>`)
      expect(result.layout)
        .assertEqual(`<layout><root-layout /></layout>`)
    })
  })
}